using JSON,JLD,Knet
include("loss.jl")

if !isdefined(Main,:atype)
    global atype = KnetArray{Float32}
end

init(o...)=atype(xavier(Float32,o...))
bias(o...)=atype(zeros(Float32,o...))
elu(x) = relu.(x) .+ (exp.(min.(0,x)) - 1)

function load_resnet(atype;stage=3)
    w,m,meta = ResNetLib.resnet101init(;trained=true,stage=stage)
    global avgimg = meta["normalization"]["averageImage"]
    global descriptions = meta["classes"]["description"]
    return w,m,meta,avgimg
end

function prepocess_image(w,m,imgurl,avgimg;stage=3)
    img = imgdata(imgurl, avgimg)
    return ResNetLib.resnet101(w,m,atype(img);stage=stage);
end

function postpocess_kb(w,x;train=false,pdrop=0.0)
    if train
         x  = dropout(x,pdrop)
    end
    x  = elu(conv4(w[1],x;padding=1,stride=1,mode=1) .+ w[2]) #relu -> elu
    if train
         x  = dropout(x,pdrop)
    end
    x  = elu(conv4(w[3],x;padding=1,stride=1,mode=1) .+ w[4]) #relu -> elu
    h,w,c,b = size(x)
    x  = reshape(x,h*w,c,b)
    return permutedims(x,(2,3,1))
end

function init_postkb(d)
    w = Any[];
    push!(w,init(3,3,1024,d))
    push!(w,bias(1,1,d,1))
    push!(w,init(3,3,d,d))
    push!(w,bias(1,1,d,1))
    return w
end

function process_question(w,r,words,batchSizes;train=false,qdrop=0.0,embdrop=0.0)
    wordemb      = w[1][:,words]

    if train
         wordemb = dropout(wordemb,embdrop)
    end

    B = batchSizes[1]
    eqbatches = all(batchSizes.==B)

    if eqbatches
        wordemb      = reshape(wordemb,size(wordemb,1),1,size(wordemb,2))
        y,hyout,_,rs = rnnforw(r,w[2],wordemb;hy=true,cy=false)
    else
        y,hyout,_,rs = rnnforw(r,w[2],wordemb;batchSizes=batchSizes,hy=true,cy=false)
    end

    q            = vcat(hyout[:,:,1],hyout[:,:,2])

    if train
           q  = dropout(q,qdrop)
    end

    if !eqbatches
        indices      = batchSizes2indices(batchSizes)
        lngths       = length.(indices)
        Tmax         = maximum(lngths)
        td,B         = size(q)
        d            = div(td,2)
        cw           = Any[];

        for i=1:length(indices)
            y1 = y[:,indices[i]]
            df = Tmax-lngths[i]
            if df > 0
                cpad = zeros(Float32,2d,df)
                kpad = atype(cpad) ## look at similar
                ypad = hcat(y1,kpad)
                push!(cw,ypad)
            else
                push!(cw,y1)
            end
        end
        cws_2d =  reshape(vcat(cw...),2d,B*Tmax)
    else
        B      = batchSizes[1]
        Tmax   = length(batchSizes)
        d      = div(size(q,1),2)
        cws_2d = reshape(y,2d,B*Tmax)
    end

    cws_3d =  reshape(w[3]*cws_2d .+ w[4],(d,B,Tmax))

    return q,cws_3d;
end

function batchSizes2indices(batchSizes)
    B = batchSizes[1]
    indices = Any[]
    for i=1:B
        ind = i.+cumsum(filter(x->(x>=i),batchSizes)[1:end-1])
        push!(indices,append!(Int[i],ind))
    end
    return indices
end

function init_rnn(inputSize,embedSize,hiddenSize;outputSize=nothing)
    w = Any[]
    wembed = atype(rand(Float32,embedSize,inputSize))
    push!(w,wembed)
    r,wrnn = rnninit(embedSize,hiddenSize; bidirectional=true, binit=zeros) #change Knet/src/rnn.jl
    #setfgbias!(r,wrnn)
    push!(w,wrnn)
    push!(w,init(hiddenSize,2hiddenSize),bias(hiddenSize,1))
    return w,r
end

function setfgbias!(r,w)
    rnnparam(r,w,1,2,2)[:] = 0.5
    rnnparam(r,w,1,6,2)[:] = 0.5
    rnnparam(r,w,2,2,2)[:] = 0.5
    rnnparam(r,w,2,6,2)[:] = 0.5
end

function control_unit(w,ci₋1,qi,cws,pad;train=false,tap=nothing)
    #cws       : d x B x T
    d,B,T      = size(cws)
    #qi,ci     : d x B
    cqi        = reshape(w[1] * vcat(ci₋1,qi) .+ w[2],(d,B,1)) # eq c1
    #cqi       : d x B x 1
    cvis       = reshape(cqi .* cws,(d,B*T)) #eq c2.1.1
    #cvis      : d x BT
    cvis_2d    = reshape(w[3] * cvis .+ w[4],(B,T)) #eq c2.1.2
    #cvis_2d   : B x T
    if pad != nothing
        cvi    = reshape(softmax(cvis_2d .- pad,2),(1,B,T)) #eq c2.2
    else
        cvi    = reshape(softmax(cvis_2d,2),(1,B,T)) #eq c2.2
    end
    tap!=nothing && get!(tap,"w_attn_$(tap["cnt"])",Array(reshape(cvi,B,T)))
    #cvi       : 1 x B x T
    ci         = reshape(sum(cvi.*cws,3),(d,B)) #eq c2.3
end

function init_control(d)
    w = Any[]
    push!(w,init(d,2d))
    push!(w,bias(d,1))
    push!(w,init(1,d))
    push!(w,bias(1,1))
    return w
end

function read_unit(w,mi₋1,ci,KBhw,KBhw′′;train=false,mdrop=0.0,attdrop=0.0,tap=nothing)
    d,B,N          = size(KBhw)
    d,BN           = size(KBhw′′)
    #KBhw'     : d x B x N  := w[3] * khw + w[4]
    #KBhw''    : d x BN     := reshape(w[5] * khw + w[7]),(d,BN))
    if train
        mi₋1       = dropout(mi₋1,mdrop)
    end

    mi_3d           = reshape(w[1]*mi₋1 .+ w[2],(d,B,1)) #eq r1.1
    #mi_3d     : d x B x 1
    ImKB            = reshape(mi_3d .* KBhw,(d,BN)) # eq r1.2
    #ImKB      : d x BN
    ImKB′           = reshape(w[5] * ImKB .+ KBhw′′,(d,B,N)) #eq r2
    #ImKB'     : d x B x N
    ci_3d           = reshape(ci,(d,B,1))
    #ci_3d     : d x B x 1
    IcmKB_pre       = reshape(ci_3d .* ImKB′,(d,BN)) #eq r3.1.1
    #IcmKB_pre : d x BN
    if train
         IcmKB_pre = dropout(IcmKB_pre,attdrop)#dropout(IcmKB_pre,0.15)
    end
    IcmKB           = reshape(w[6] * IcmKB_pre  .+ w[7],(B,N)) #eq r3.1.2
    #IcmKB     : B x N
    mvi             = reshape(softmax(IcmKB,2),(1,B,N)) #eq r3.2
    #mvi       : 1 x B x N
    tap!=nothing && get!(tap,"KB_attn_$(tap["cnt"])",Array(reshape(mvi,B,N)))
    mnew            = reshape(sum(mvi.*KBhw,3),(d,B)) #eq r3.3
end

function init_read(d)
    w = Any[]
    push!(w,init(d,d))
    push!(w,bias(d,1))
    push!(w,init(d,d))
    push!(w,bias(d,1))
    push!(w,init(d,d))
    push!(w,init(1,d))
    push!(w,bias(1,1))
    return w
end

function write_unit(w,m_new,mi₋1,mj,ci,cj;train=false,selfattn=true,gating=true)
    d,B        = size(m_new)
    #mnew      : d x B
    d,BT       = size(mj)
    T          = div(BT,B)
    #mj        : d x BT
    mi         =  w[1] * vcat(m_new,mi₋1) .+ w[2] #eq w.1 #no such layer in code delete w6-w7
    #mi       : d x B
    !selfattn && return mi
    #iproj     =  w[6] * ci .+ w[7] !!!delete w[6]
    ci_3d      = reshape(ci,d,B,1)
    #ci_3d     : d x B x 1
    cj_3d      = reshape(cj,d,B,T)
    #cj_3d     : d x B x T
    sap        = reshape(ci_3d.*cj_3d,(d,BT)) #eq w2.1.1
    #sap       : d x BT
    sa         = reshape(w[3] * sap .+ w[4],(B,T)) #eq w2.1.2
    #sa        : B x T
    sa′        = reshape(softmax(sa,2),(1,B,T)) #eq w2.1.3
    #sa'       : 1 x B x T
    mj_3d      = reshape(mj,(d,B,T))
    #mj_3d     : d x B x T
    mi_sa      = reshape(sum(sa′ .* mj_3d ,3),(d,B)) #eq w2.2
    #m_sa      : d x B
    mi′′       = w[5] * mi_sa .+ w[6] .+ mi   #eq w2.3
    #mi′′      : d x B

    !gating && return mi′′

    σci′       = sigm.(w[7] * ci .+ w[8])  #eq w3.1
    #σci′      : 1 x B
    mi′′′      = (σci′ .* mi₋1) .+  ((1.-σci′) .* mi′′) #eq w3.2
end

function init_write(d;selfattn=true,gating=true)
    w = Any[]
    push!(w,init(d,2d))
    push!(w,bias(d,1))
    !selfattn && return w
    push!(w,init(1,d))
    push!(w,bias(1,1))
    push!(w,init(d,d))
    push!(w,bias(d,1))
    !gating  && return w
    push!(w,init(1,d))
    push!(w,bias(1,1))
    return w
end


function mac(w,cw,qi,KBhw,KBhw′′,ci₋1,mi₋1,cj,mj,pad;train=false,selfattn=true,gating=true,tap=nothing)
    ci     = control_unit(w[1:4],ci₋1,qi,cw,pad;train=train,tap=tap)
    m_new  = read_unit(w[5:11],mi₋1,ci,KBhw,KBhw′′;train=train,tap=tap)
    mi     = write_unit(w[12:end],m_new,mi₋1,mj,ci,cj;train=train,selfattn=selfattn,gating=gating)
    tap != nothing && (tap["cnt"]+=1)
    return (ci,mi)
end

function init_mac(d;selfattn=true,gating=true)
   w  = Any[];
   append!(w,init_control(d))
   append!(w,init_read(d))
   append!(w,init_write(d;selfattn=selfattn,gating=gating))
   return w
end

function output_unit(w,q,mp;train=false,pdrop=0.0)
  x  = elu(w[1] * vcat(mp,q) .+ w[2])
  if train
      x  = dropout(x,pdrop) #0.15
  end
  y  = w[3] * x .+ w[4]
end

function init_output(d;outsize=28)
    w = Any[];
    push!(w,init(d,3d))
    push!(w,bias(d,1))
    push!(w,init(28,d))
    push!(w,bias(28,1))
    return w;
end

loss_layer(y,answers) = nll(y,answers;average=true)

function forward_net(w,r,qs,KB,batchSizes,pads,xB;answers=nothing,p=12,tap=nothing,selfattn=false,gating=false)
    train         = answers!=nothing

    KBhw          = postpocess_kb(w[1:4],KB;train=train)

    #READ UNIT PRE CALCULATIONS
    d,B,N         = size(KBhw)

    KBhw_2d       = reshape(KBhw,(d,B*N))

#     if train
#         KBhw_2d   = dropout(KBhw_2d,0)
#     end

    #KBhw′_pre     = w[15]*KBhw_2d .+ w[16] # look if it is necessary

    KBhw′′           = w[17]*KBhw_2d   .+  w[18]

    #KBhw′         = reshape(KBhw_2d,(d,B,N))

    #END

    q,cws        = process_question(w[5:8],r,qs,batchSizes;train=train)

    ci           = w[end-1]*xB
    mi           = w[end]*xB
    cj           = ci
    mj           = mi
    qi_c         = w[9]*q .+ w[10]

    for i=1:p
        qi        = qi_c[(i-1)*d+1:i*d,:]
        if train
            ci = dropout(ci,0.15)
            mi = dropout(mi,0.15)
        end
        ci,mi     = mac(w[11:end-6],cws,qi,KBhw,KBhw′′,ci,mi,cj,mj,pads;tap=tap,train=train,selfattn=selfattn,gating=gating)
        if selfattn
            cj        = hcat(cj,ci)
            mj        = hcat(mj,mi)
        end
    end

    y = output_unit(w[end-5:end-2],q,mi;train=train)

    if answers==nothing
        predmat = Array{Float32}(y)
        tap!=nothing && get!(tap,"y",predmat)
        return mapslices(indmax,predmat,1)[1,:]
    else
        return loss_layer(y,answers)
    end
end


function init_network(vocab_size,embed_size,d;p=12,loadresnet=false,selfattn=false,gating=false)
    if loadresnet
        rsnt,m,meta = load_resnet(atype;stage=3);
    else
        rsnt,m,meta = nothing,nothing,nothing;
    end
    w           = Any[];
    wcnn        = init_postkb(d)
    append!(w,wcnn);
    wrnn,r      = init_rnn(vocab_size,embed_size,d)
    append!(w,wrnn);
    #for i=1:p
        push!(w,init(p*d,2d),bias(p*d,1)) #qi embbedding
    #end
    wmac = init_mac(d;selfattn=selfattn,gating=gating) #!!!share weights among cells
    append!(w,wmac);
    wout = init_output(d)
    append!(w,wout);
    push!(w,init_state(d,1;initial=:xavier))
    push!(w,init_state(d,1;initial=:randn)) # m0
    return w,r,rsnt,m,meta;
end

function init_state(d,B;initial=:zero)
    if initial == :zero
        x=zeros(Float32,d,B)
    elseif initial == :randn
        x=randn(Float32,d,B)
    elseif initial == :xavier
        x=xavier(Float32,d,B)
    end
    return atype(x)
end

loss = grad(forward_net)

function savemodel(filename,w,wrun,r,opts,p)
    save(filename,"w",w,"wrun",wrun,"r",r,"opts",opts,"p",p)
end

function loadmodel(filename;onlywrun=false)
    d = load(filename)
    if onlywrun
        wrun=d["wrun"];r=d["r"];opts=nothing;w=nothing;p=d["p"]
    else
        w=d["w"];wrun=d["wrun"];r=d["r"];opts=d["opts"];p=d["p"];
    end
    return w,wrun,r,opts,p;
end

function getQdata(dhome,set)
    JSON.parsefile(dhome*set*".json")
end


function invert(vocab)
       int2tok = Array{String}(length(vocab))
       for (k,v) in vocab; int2tok[v] = k; end
       return int2tok
end

function getDicts(dhome,dicfile)
    dic  = JSON.parsefile(dhome*dicfile*".json")
    qvoc = dic["word_dic"]
    avoc = dic["answer_dic"]
    i2w  = invert(qvoc)
    i2a  = invert(avoc)
    return qvoc,avoc,i2w,i2a
end

function loadFeatures(dhome,set)
    feats    = reinterpret(Float32,read(open(dhome*set*".bin")))
    reshape(feats,(14,14,1024,div(length(feats),200704)))
end

function miniBatch(data;shfl=true,srtd=false,B=32)
    B=32
    L = length(data)
    shfl && shuffle!(data)
    srtd && sort!(data;by=x->length(x[2]))
    batchs = [];
    for i=1:B:L
        b         = min(L-i+1,B)
        questions = Any[]
        answers   = zeros(Int,b)
        images    = Any[]
        families  = zeros(Int,b)

        for j=1:b
            crw = data[i+j-1]
            push!(questions,reverse(Array{Int}(crw[2]).+1))
            push!(images,parse(Int,crw[1][end-9:end-4])+1)
            answers[j]  = crw[3]+1
            families[j] = crw[4]
        end

        lngths     = length.(questions);
        srtindices = sortperm(lngths;rev=true)

        lngths     = lngths[srtindices]
        Tmax       = lngths[1]
        questions  = questions[srtindices]
        answers    = answers[srtindices]
        images     = images[srtindices]
        families   = families[srtindices]

        qs = Int[];
        batchSizes = Int[];
        pads = falses(b,Tmax)

        for k=1:b
           pads[k,lngths[k]+1:Tmax]=true
        end

        if sum(pads)==0
           pads=nothing
        end

        while true
            batch = 0
            for j=1:b
                if length(questions[j]) > 0
                    batch += 1
                    push!(qs,pop!(questions[j]))
                end
            end
            if batch != 0
                push!(batchSizes,batch)
            else
                break;
            end
        end
        push!(batchs,(images,qs,answers,batchSizes,pads,families))
    end
    return batchs
end

function loadTrainingData(dhome="data/")
    info("Loading pretrained features for train&val sets.
    It requires minimum 70GB RAM!!!")
    trnfeats = loadFeatures(dhome,"train")
    valfeats = loadFeatures(dhome,"val")
    info("Loading questions ...")
    trnqstns = getQdata(dhome,"train")
    valqstns = getQdata(dhome,"val")
    info("Loading dictionaries ... ")
    qvoc,avoc,i2w,i2a = getDicts(dhome,"dic")
    return (trnfeats,valfeats),(trnqstns,valqstns),(qvoc,avoc,i2w,i2a)
end

function loadDemoData(dhome="data/demo/")
    info("Loading demo features ...")
    feats = loadFeatures(dhome,"demo")
    info("Loading demo questions ...")
    qstns = getQdata(dhome,"demo")
    info("Loading dictionaries ...")
    dics = getDicts(dhome,"dic")
    return feats,qstns,dics
end

function modelrun(w,r,opts,data,feats;p=12,train=false,wrun=nothing,ema=Float32(0.999),prefix=string(now())[1:11])

    B        = 32 # x 2 = 64 : look at bottom
    KxB      = atype(ones(Float32,1,B))
    #Requires to create 32x2 batchsize
    cumgrads = nothing
    if train
        cumgrads = map(similar,w)
    end

    #Statistics: Add accuracy according to question families
    cnt=total=0.0
    L = length(data)
    println("Timer Starts");flush(STDOUT);tic()

    for i=1:L

        if i % 100 == 0
            toc();tic();
            println(@sprintf("%.2f Completed",100i/L))
            !train && println(@sprintf("%.2f Accuracy",100cnt/total))
            flush(STDOUT)
        end

        if i % 2250 == 0 && train
            savemodel(prefix*"W.jld",w,wrun,r,opts,p); info("model saved"); flush(STDOUT)
            gc(); Knet.gc(); gc();
        end

        filenames,qs,answers,batchSizes,pad,_ = data[i]

        if batchSizes[1] != B
            B    = batchSizes[1]
            KxB  = atype(ones(Float32,1,B))
        end

        X = Any[];
        for k=1:B
               push!(X,view(featdict,:,:,:,filenames[k]))
        end
        xs = cat(4,X...)

        Kxs  = convert(atype,xs)

        Kpad = pad==nothing ? nothing : atype(pad * Float32(1e22))

        if train

            grads = loss(w,r,qs,Kxs,batchSizes,Kpad,KxB;answers=answers,p=p)

            for (cu,gr) in zip(cumgrads,grads)
                axpy!(Float32(0.5),gr,cu);
            end

            if iseven(i)
                Knet.update!(w,cumgrads,opts)
                if wrun != nothing
                    for (wr,wi) in zip(wrun,w)
                        axpy!(1.0-ema,wi-wr,wr)
                    end
                end
                map(x->fill!(x,Float32(0.0)),cumgrads)
            end

        else
            preds  = forward_net(w,r,qs,Kxs,batchSizes,Kpad,KxB)
            cnt   += sum(preds.==answers)
            total += B
        end
    end
end

function train!(w,wrun,r,opts,sets,feats;epochs=10,p=12)
    info("Training Starts....")
    for i=1:epochs
        modelrun(w,r,opts,sets[1],feats[1];wrun=wrun,train=true,p=p)
        if iseven(i)
            modelrun(wrun,r,opts,sets[2],feats[2];train=false,p=p)
        end
    end
    return w,wrun,r,opts;
end

function train(sets,feats;epochs=10,lr=0.0001,mfile=nothing,p=12)
     if mfile==nothing
         w,r,rsnt,_,_ = init_network(90,300,512;loadresnet=false,p=p);
         wrun=deepcopy(w)
         opts = optimizers(w,Adam;lr=lr)
     else
         w,wrun,r,opts,p = loadmodel(mfile)
     end
     train!(w,wrun,r,opts,sets,feats;epochs=10,p=p)
     return w,wrun,r,opts;
end

function train(dhome="data/";mfile=nothing,epochs=10,lr=0.0001,p=12)
     feats,qdata,dics = loadTrainingData(dhome)
     sets = []
     for q in questions; push!(sets,miniBatch(q)); end
     qdata = nothing; gc();
     w,wrun,r,opts = train(sets,feats;epochs=epochs,lr=lr,mfile=mfile,p=p)
     return w,wrun,r,opts,sets,feats,dics;
end

function validate(wrun,r,valset,valfeats)
     modelrun(wrun,r,nothing,valset,valfeats;train=false)
end

function validate(mfile,valset,valfeats)
     _,wrun,r,_ = loadmodel(mfile)
     modelrun(wrun,r,nothing,valset,valfeats;train=false)
     return wrun,r
end

function validate(mfile,dhome)
     _,wrun,r,_ = loadmodel(mfile)
     valfeats   = loadFeatures(dhome,"val")
     qdata      = getQdata(dhome,"val")
     dics       = getDicts(dhome,"dic")
     valset     = minibatch(qdata)
     modelrun(wrun,r,nothing,valset,valfeats;train=false)
     return wrun,r,valset,valfeats
end


function singlerun(w,r,feat,question;p=12)
    KxB        = atype(ones(Float32,1,1))
    pad        = nothing
    batchSizes = ones(Int,length(question))
    Kxs        = convert(atype,feat)
    results    = Dict()
    results["cnt"] = 1
    forward_net(w,r,question,Kxs,batchSizes,pad,KxB;tap=results,p=p)
    prediction = indmax(results["y"])
    return results,prediction
end

function visualize(img,results;p=12)
    s_y,s_x = size(img)./14
    for k=1:p
        α = results["w_attn_$(k)"][:]
        println("step_$(k) most attn. wrds: ",i2w[question[sortperm(α;rev=true)[1:2]]])
        flush(STDOUT)
        display([RGB{N0f8}(α[i],α[i],α[i]) for i=1:length(α)]);
        hsvimg = convert.(HSV,img);
        attn = results["KB_attn_$(k)"]
        for i=1:14,j=1:14
            rngy          = floor(Int,(i-1)*s_y+1):floor(Int,min(i*s_y,320))
            rngx          = floor(Int,(j-1)*s_x+1):floor(Int,min(j*s_x,480))
            hsvimg[rngy,rngx]  = scalepixel.(hsvimg[rngy,rngx],attn[sub2ind((14,14),i,j)])
        end
        display(hsvimg)
    end
end

function scalepixel(pixel,scaler)
     return HSV(pixel.h,pixel.s,pixel.v+2*scaler)
end
