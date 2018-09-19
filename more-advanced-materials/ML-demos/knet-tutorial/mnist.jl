using Knet, Images
if ENV["HOME"] == "/mnt/juliabox"; Pkg.dir(path...)=joinpath("/home/jrun/.julia/v0.6",path...); end # juliabox fix
include(Knet.dir("data","mnist.jl"))
xtrn,ytrn,xtst,ytst = mnist()
# map(summary,(xtrn,ytrn,xtst,ytst))

# Minibatch data
Atype = gpu() >= 0 ? KnetArray{Float32} : Array{Float32}
dtst = minibatch(xtst,ytst,100;xtype=Atype) # [ (x1,y1), (x2,y2), ... ] where xi,yi are minibatches of 100
dtrn = minibatch(xtrn,ytrn,100;xtype=Atype) # [ (x1,y1), (x2,y2), ... ] where xi,yi are minibatches of 100
# length(dtrn),length(dtst)

# Loss functions
zeroone(w,data,model) = 1 - accuracy(w,data,model)
softmax(w,data,model) = mean(softmax(w,x,y,model) for (x,y) in data)
softmax(w,x,y,model; o...) = nll(model(w,x;o...),y)
softgrad = grad(softmax)

# Train model(w) with SGD and return a list containing w for every epoch
function train(w,data,predict; epochs=100,lr=0.1,o...)
    weights = Any[deepcopy(w)]
    for epoch in 1:epochs
        for (x,y) in data
            g = softgrad(w,x,y,predict;o...)
            update!(w,g,lr=lr)  # w[i] = w[i] - lr * g[i]
        end
        push!(weights,deepcopy(w))
    end
    return weights
end