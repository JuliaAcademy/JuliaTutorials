# ------------------------------------------------------------------------------------------
# # IMDB Training Notebook
# ------------------------------------------------------------------------------------------

using Knet
# Hyperparams LSTM
EPOCHS=3
BATCHSIZE=64
EMBEDSIZE=125
NUMHIDDEN=100
LR=0.0001
BETA_1=0.9
BETA_2=0.999
EPS=1e-08
MAXLEN=150 #maximum size of the word sequence
MAXFEATURES=30000 #vocabulary size
DROPOUT=0.35
SEED=1311194
gpu(0)
atype = gpu()<0 ? Array{Float32}:KnetArray{Float32}

#define model"
function initmodel()
    rnnSpec,rnnWeights = rnninit(EMBEDSIZE,NUMHIDDEN; rnnType=:lstm)
    inputMatrix = atype(xavier(Float32,EMBEDSIZE,MAXFEATURES))
    outputMatrix = atype(xavier(Float32,2,NUMHIDDEN))
    return rnnSpec,(rnnWeights,inputMatrix,outputMatrix)
end

function savemodel(weights,rnnSpec;localfile="model_imdb.jld")
    save(localfile,"weights",weights,"rnnSpec",rnnSpec)
end

# define loss and its gradient
function predict(weights, inputs, rnnSpec;train=false)
    rnnWeights, inputMatrix, outputMatrix = weights # (1,1,W), (X,V), (2,H)
    indices = hcat(inputs...)' # (B,T)
    rnnInput = inputMatrix[:,indices] # (X,B,T)
    if train
        rnnInput = dropout(rnnInput,DROPOUT)
    end
    rnnOutput = rnnforw(rnnSpec, rnnWeights, rnnInput)[1] # (H,B,T)
    if train
        rnnOutput = dropout(rnnOutput,DROPOUT)
    end
    return outputMatrix * rnnOutput[:,:,end] # (2,H) * (H,B) = (2,B)
end

loss(w,x,y,r;train=false)=nll(predict(w,x,r;train=train),y)
lossgradient = grad(loss);

# load data
include("imdb.jl")
@time (xtrn,ytrn,xtst,ytst,imdbdict)=imdb(maxlen=MAXLEN,maxval=MAXFEATURES,seed=SEED)
for d in (xtrn,ytrn,xtst,ytst); println(summary(d)); end
imdbarray = Array{String}(88584)
for (k,v) in imdbdict; imdbarray[v]=k; end

rnd = rand(1:length(xtrn))
println("Sample review:\n",join(imdbarray[xtrn[rnd]]," "),"\n")
println("Classification: ",join(ytrn[rnd]))

# prepare for training
weights = nothing; knetgc(); # Reclaim memory from previous run
rnnSpec,weights = initmodel()
optim = optimizers(weights, Adam; lr=LR, beta1=BETA_1, beta2=BETA_2, eps=EPS);

# 29s
info("Training...")
@time for epoch in 1:EPOCHS
    @time for (x,y) in minibatch(xtrn,ytrn,BATCHSIZE;shuffle=true)
        grads = lossgradient(weights,x,y,rnnSpec;train=true)
        update!(weights, grads, optim)
    end
end

info("Testing...")
@time accuracy(weights, minibatch(xtst,ytst,BATCHSIZE), (w,x)->predict(w,x,rnnSpec))

savemodel(weights,rnnSpec)


