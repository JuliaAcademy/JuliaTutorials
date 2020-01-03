# ------------------------------------------------------------------------------------------
# # Character based RNN language model trained on 'The Complete Works of William
# Shakespeare'
# Based on http://karpathy.github.io/2015/05/21/rnn-effectiveness
# ------------------------------------------------------------------------------------------

RNNTYPE = :lstm
BATCHSIZE = 64
SEQLENGTH = 64
INPUTSIZE = 512
VOCABSIZE = 128
HIDDENSIZE = 512
NUMLAYERS = 2
DROPOUT = 0.0
LR=0.001
BETA_1=0.9
BETA_2=0.999
EPS=1e-08
EPOCHS = 30;

base = joinpath(Base.JULIA_HOME, Base.DATAROOTDIR, "julia", "base")
text = ""
for (root,dirs,files) in walkdir(base)
    for f in files
        f[end-2:end] == ".jl" || continue
        text *= readstring(joinpath(root,f))
    end
    # println((root,length(files),all(f->contains(f,".jl"),files)))
end
length(text)

charcnt = Dict{Char,Int}()
for c in text; charcnt[c]=1+get(charcnt,c,0); end
chars = sort(collect(keys(charcnt)), by=(x->charcnt[x]), rev=true)
charid = Dict{Char,Int}()
for i=1:length(chars); charid[chars[i]]=i; end
hcat(chars, map(c->charcnt[c],chars))

data = map(c->charid[c], collect(text))
data[data .> VOCABSIZE] = VOCABSIZE
ntst = 1<<19
tst = data[1:ntst]
trn = data[1+ntst:end]
length.((data,trn,tst))

# Load 'The Complete Works of William Shakespeare'
using Knet
#include(Knet.dir("data","gutenberg.jl"))
#trn,tst,chars = shakespeare()
#map(summary,(trn,tst,chars))

# Print a sample
r = rand(1:(length(trn)-1000))
println(string(chars[trn[r:r+1000]]...)) 

# Minibatch data
function mb(a)
    N = div(length(a),BATCHSIZE)
    x = reshape(a[1:N*BATCHSIZE],N,BATCHSIZE)' # reshape full data to (B,N) with contiguous rows
    minibatch(x[:,1:N-1], x[:,2:N], SEQLENGTH) # split into (B,T) blocks 
end
dtrn,dtst = mb(trn),mb(tst)
map(length, (dtrn,dtst))

# Define model
function initmodel()
    w(d...)=KnetArray(xavier(Float32,d...))
    b(d...)=KnetArray(zeros(Float32,d...))
    r,wr = rnninit(INPUTSIZE,HIDDENSIZE,rnnType=RNNTYPE,numLayers=NUMLAYERS,dropout=DROPOUT)
    wx = w(INPUTSIZE,VOCABSIZE)
    wy = w(VOCABSIZE,HIDDENSIZE)
    by = b(VOCABSIZE,1)
    return r,wr,wx,wy,by
end;

# Given the current character, predict the next character
function predict(ws,xs,hx,cx;pdrop=0)
    r,wr,wx,wy,by = ws
    x = wx[:,xs]                                    # xs=(B,T) x=(X,B,T)
    x = dropout(x,pdrop)
    y,hy,cy = rnnforw(r,wr,x,hx,cx,hy=true,cy=true) # y=(H,B,T) hy=cy=(H,B,L)
    y = dropout(y,pdrop)
    y2 = reshape(y,size(y,1),size(y,2)*size(y,3))   # y2=(H,B*T)
    return wy*y2.+by, hy, cy
end

# Define loss and its gradient
function loss(w,x,y,h;o...)
    py,hy,cy = predict(w,x,h...;o...)
    h[1],h[2] = getval(hy),getval(cy)
    return nll(py,y)
end

lossgradient = gradloss(loss);

function train(model,data,optim)
    hiddens = Any[nothing,nothing]
    Σ,N=0,0
    for (x,y) in data
        grads,loss1 = lossgradient(model,x,y,hiddens;pdrop=DROPOUT)
        update!(model, grads, optim)
        Σ,N=Σ+loss1,N+1
    end
    return Σ/N
end;

function test(model,data)
    hiddens = Any[nothing,nothing]
    Σ,N=0,0
    for (x,y) in data
        Σ,N = Σ+loss(model,x,y,hiddens), N+1
    end
    return Σ/N
end; 

# Sample from trained model
function generate(model,n)
    function sample(y)
        p,r=Array(exp.(y-logsumexp(y))),rand()
        for j=1:length(p); (r -= p[j]) < 0 && return j; end
    end
    h,c = nothing,nothing
    chars = model[end]
    x = findfirst(chars,'\n')
    for i=1:n
        y,h,c = predict(model,[x],h,c)
        x = sample(y)
        print(chars[x])
    end
    println()
end;

#=
# Train model or load from file if exists
using JLD
model=optim=nothing; knetgc()
if true # !isfile("juliacharlm.jld")
    model = initmodel()
    optim = optimizers(model, Adam; lr=LR, beta1=BETA_1, beta2=BETA_2, eps=EPS);    info("Training...")
    @time for epoch in 1:EPOCHS
        @time trnloss = train(model,dtrn,optim) # ~18 seconds
        @time tstloss = test(model,dtst)        # ~0.5 seconds
        println((:epoch, epoch, :trnppl, exp(trnloss), :tstppl, exp(tstloss)))
    end
    save("juliacharlm.jld","model",model)
else
    model = load("juliacharlm.jld","model")
end
summary(model)
=#

# generate(model,1000)

function hyperloss(v)
    global HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, EPOCHS, model
    HIDDENSIZE = floor(Int, 128 * 2^v[1])
    INPUTSIZE = floor(Int, 128 * 2^v[2])
    NUMLAYERS = max(1,floor(Int,v[3]))
    DROPOUT = isa(v[4],Number) ? sigm(v[4]) : 0
    @show (HIDDENSIZE,INPUTSIZE,NUMLAYERS,DROPOUT)
    knetgc()
    model = initmodel()
    optim = optimizers(model, Adam; lr=LR, beta1=BETA_1, beta2=BETA_2, eps=EPS)
    for epoch in 1:10
        trnloss = train(model,dtrn,optim) # ~18 seconds
        tstloss = test(model,dtst)        # ~0.5 seconds
        println((:epoch, epoch, :trnppl, exp(trnloss), :tstppl, exp(tstloss)))
    end
    trnloss = test(model,dtrn)
    trnppl = exp(trnloss)
    @show (HIDDENSIZE,INPUTSIZE,NUMLAYERS,DROPOUT,trnppl)
    return trnppl
end

model=nothing; knetgc(); hyperloss([3,0,3,0])

#=

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (1024, 128, 2, 0.5)
(:epoch, 1, :trnppl, 9.589466f0, :tstppl, 4.9871907f0)
(:epoch, 2, :trnppl, 3.741831f0, :tstppl, 3.9569008f0)
(:epoch, 3, :trnppl, 3.111019f0, :tstppl, 3.6438942f0)
(:epoch, 4, :trnppl, 2.842651f0, :tstppl, 3.490925f0)
(:epoch, 5, :trnppl, 2.6792212f0, :tstppl, 3.406119f0)
(:epoch, 6, :trnppl, 2.567202f0, :tstppl, 3.337223f0)
(:epoch, 7, :trnppl, 2.484569f0, :tstppl, 3.2894032f0)
(:epoch, 8, :trnppl, 2.4184995f0, :tstppl, 3.2509122f0)
(:epoch, 9, :trnppl, 2.3658345f0, :tstppl, 3.2483802f0)
(:epoch, 10, :trnppl, 2.3232405f0, :tstppl, 3.2095058f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = (1024, 128, 2, 0.5, 2.0069642f0)

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (4096, 128, 1, 0.5)
(:epoch, 1, :trnppl, 7.630349f0, :tstppl, 8.994627f0)
(:epoch, 2, :trnppl, 3.1094067f0, :tstppl, 3.7359138f0)
(:epoch, 3, :trnppl, 2.5211895f0, :tstppl, 3.406949f0)
(:epoch, 4, :trnppl, 2.24173f0, :tstppl, 3.3002508f0)
(:epoch, 5, :trnppl, 2.0695934f0, :tstppl, 3.2824345f0)
(:epoch, 6, :trnppl, 1.9510676f0, :tstppl, 3.2519991f0)
(:epoch, 7, :trnppl, 1.8637797f0, :tstppl, 3.2833624f0)
(:epoch, 8, :trnppl, 1.7990172f0, :tstppl, 3.2755644f0)
(:epoch, 9, :trnppl, 1.7516453f0, :tstppl, 3.3127692f0)
(:epoch, 10, :trnppl, 1.7112837f0, :tstppl, 3.3849468f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = (4096, 128, 1, 0.5, 1.5795085f0)
1.5795085f0

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (2048, 128, 1, 0.5)
(:epoch, 1, :trnppl, 6.897045f0, :tstppl, 4.5084825f0)
(:epoch, 2, :trnppl, 3.1653059f0, :tstppl, 3.7902246f0)
(:epoch, 3, :trnppl, 2.6861045f0, :tstppl, 3.5171616f0)
(:epoch, 4, :trnppl, 2.4583292f0, :tstppl, 3.4100456f0)
(:epoch, 5, :trnppl, 2.3147066f0, :tstppl, 3.3488684f0)
(:epoch, 6, :trnppl, 2.2171206f0, :tstppl, 3.3439498f0)
(:epoch, 7, :trnppl, 2.1446044f0, :tstppl, 3.3066962f0)
(:epoch, 8, :trnppl, 2.0894327f0, :tstppl, 3.3102229f0)
(:epoch, 9, :trnppl, 2.0460289f0, :tstppl, 3.287103f0)
(:epoch, 10, :trnppl, 2.0100765f0, :tstppl, 3.3185039f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = (2048, 128, 1, 0.5, 1.7895192f0)
1.7895192f0

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (2896, 128, 1, 0.5)
(:epoch, 1, :trnppl, 7.1333003f0, :tstppl, 4.4698453f0)
(:epoch, 2, :trnppl, 3.04668f0, :tstppl, 3.719867f0)
(:epoch, 3, :trnppl, 2.5365477f0, :tstppl, 3.439777f0)
(:epoch, 4, :trnppl, 2.295574f0, :tstppl, 3.3415797f0)
(:epoch, 5, :trnppl, 2.1462688f0, :tstppl, 3.27515f0)
(:epoch, 6, :trnppl, 2.044871f0, :tstppl, 3.2823677f0)
(:epoch, 7, :trnppl, 1.9718276f0, :tstppl, 3.2806444f0)
(:epoch, 8, :trnppl, 1.9180799f0, :tstppl, 3.2798069f0)
(:epoch, 9, :trnppl, 1.8782355f0, :tstppl, 3.2703993f0)
(:epoch, 10, :trnppl, 1.8446114f0, :tstppl, 3.3073356f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = 
1.6504527f0
(2896, 128, 1, 0.5, 1.6504527f0)

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (2048, 128, 1, 0)
(:epoch, 1, :trnppl, 17.54582f0, :tstppl, 9.120878f0)
(:epoch, 2, :trnppl, 5.3387966f0, :tstppl, 5.298701f0)
(:epoch, 3, :trnppl, 3.4404564f0, :tstppl, 4.2200007f0)
(:epoch, 4, :trnppl, 2.7447715f0, :tstppl, 3.8503358f0)
(:epoch, 5, :trnppl, 2.3742914f0, :tstppl, 3.695858f0)
(:epoch, 6, :trnppl, 2.1303215f0, :tstppl, 3.6608467f0)
(:epoch, 7, :trnppl, 1.9553958f0, :tstppl, 3.687474f0)
(:epoch, 8, :trnppl, 1.8226186f0, :tstppl, 3.7828565f0)
(:epoch, 9, :trnppl, 1.7212292f0, :tstppl, 3.8975382f0)
(:epoch, 10, :trnppl, 1.6417012f0, :tstppl, 4.0848227f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = 
1.7484467f0
(2048, 128, 1, 0, 1.7484467f0)

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (1024, 128, 2, 0.5)
(:epoch, 1, :trnppl, 22.390598f0, :tstppl, 13.189085f0)
(:epoch, 2, :trnppl, 7.4823937f0, :tstppl, 5.720241f0)
(:epoch, 3, :trnppl, 4.6992884f0, :tstppl, 4.448046f0)
(:epoch, 4, :trnppl, 3.7799704f0, :tstppl, 3.972568f0)
(:epoch, 5, :trnppl, 3.3514497f0, :tstppl, 3.7654393f0)
(:epoch, 6, :trnppl, 3.0903006f0, :tstppl, 3.5971427f0)
(:epoch, 7, :trnppl, 2.9079294f0, :tstppl, 3.484381f0)
(:epoch, 8, :trnppl, 2.7710462f0, :tstppl, 3.443712f0)
(:epoch, 9, :trnppl, 2.663027f0, :tstppl, 3.3361208f0)
(:epoch, 10, :trnppl, 2.5764978f0, :tstppl, 3.3100765f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = 
2.175947f0
(1024, 128, 2, 0.5, 2.175947f0)

(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT) = (1024, 128, 2, 0)
(:epoch, 1, :trnppl, 22.009565f0, :tstppl, 11.428911f0)
(:epoch, 2, :trnppl, 6.030965f0, :tstppl, 5.366185f0)
(:epoch, 3, :trnppl, 3.614693f0, :tstppl, 4.288177f0)
(:epoch, 4, :trnppl, 2.906743f0, :tstppl, 3.948376f0)
(:epoch, 5, :trnppl, 2.572164f0, :tstppl, 3.8014898f0)
(:epoch, 6, :trnppl, 2.3514614f0, :tstppl, 3.7232788f0)
(:epoch, 7, :trnppl, 2.1846726f0, :tstppl, 3.7083063f0)
(:epoch, 8, :trnppl, 2.056641f0, :tstppl, 3.7179863f0)
(:epoch, 9, :trnppl, 1.9550104f0, :tstppl, 3.768648f0)
(:epoch, 10, :trnppl, 1.8722341f0, :tstppl, 3.8625576f0)
(HIDDENSIZE, INPUTSIZE, NUMLAYERS, DROPOUT, trnppl) = 
1.9898754f0

=#

#foo = download("http://ai.ku.edu.tr/models/nlp-demos/juliacharlm.jld")
using JLD
model = nothing; knetgc()
model = load(foo,"model")
summary.(model)

cpumodel = (model[1],map(Array,model[2:end])...)

generate(cpumodel,1000)

dump(cpumodel[1])

cpumodel[1].rnnDesc = cpumodel[1].dropoutDesc = nothing

dump(cpumodel[1])

save("juliacharlm.jld","model",cpumodel)

pwd()

foo

shake = load("shakespeare.jld","model")

generate(shake,1000)

cpumodel = (cpumodel..., chars)

include(Knet.dir("data","gutenberg.jl"))
_,_,chars2 = shakespeare()

shake = (shake..., chars2)

generate(shake,1000)

summary.(shake)

cpushake = (shake[1],map(Array,shake[2:end])...)

dump(cpushake[1])

cpushake[1].rnnDesc = cpushake[1].dropoutDesc = nothing

save("shakespeare.jld","model",cpushake)

foo1 = download("http://people.csail.mit.edu/deniz/models/nlp-demos/shakespeare.jld")


m1 = load(foo1,"model")


generate(m1,100)

generate(m2,100)

cpumodel

save("juliacharlm.jld","model",cpumodel)

foo2 = download("http://people.csail.mit.edu/deniz/models/nlp-demos/juliacharlm.jld")
m2 = load(foo2,"model")

generate(m2,100)

dump(m2[1])


