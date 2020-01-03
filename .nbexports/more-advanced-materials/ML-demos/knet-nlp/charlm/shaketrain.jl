# ------------------------------------------------------------------------------------------
# # Character based RNN language model trained on 'The Complete Works of William
# Shakespeare'
# Based on http://karpathy.github.io/2015/05/21/rnn-effectiveness
# ------------------------------------------------------------------------------------------

# Load 'The Complete Works of William Shakespeare'
using Knet
include(Knet.dir("data","gutenberg.jl"))
trn,tst,chars = shakespeare()
map(summary,(trn,tst,chars))

# Print a sample
println(string(chars[trn[1020:1210]]...)) 

RNNTYPE = :lstm
BATCHSIZE = 256
SEQLENGTH = 100
INPUTSIZE = 168
VOCABSIZE = 84
HIDDENSIZE = 334
NUMLAYERS = 1
DROPOUT = 0.0
LR=0.001
BETA_1=0.9
BETA_2=0.999
EPS=1e-08
EPOCHS = 30;

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

# Train model or load from file if exists
using JLD
model=optim=nothing; knetgc()
if !isfile("shakespeare.jld")
    model = initmodel()
    optim = optimizers(model, Adam; lr=LR, beta1=BETA_1, beta2=BETA_2, eps=EPS);    info("Training...")
    @time for epoch in 1:EPOCHS
        @time trnloss = train(model,dtrn,optim) # ~18 seconds
        @time tstloss = test(model,dtst)        # ~0.5 seconds
        println((:epoch, epoch, :trnppl, exp(trnloss), :tstppl, exp(tstloss)))
    end
    save("shakespeare.jld","model",model)
else
    model = load("shakespeare.jld","model")
end
summary(model)

# Sample from trained model
function generate(model,n)
    function sample(y)
        p,r=Array(exp.(y-logsumexp(y))),rand()
        for j=1:length(p); (r -= p[j]) < 0 && return j; end
    end
    h,c = nothing,nothing
    x = findfirst(chars,'\n')
    for i=1:n
        y,h,c = predict(model,[x],h,c)
        x = sample(y)
        print(chars[x])
    end
    println()
end;

generate(model,1000)
