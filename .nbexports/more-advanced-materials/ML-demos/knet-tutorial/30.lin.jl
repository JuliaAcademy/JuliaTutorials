# ------------------------------------------------------------------------------------------
# # Linear models, loss functions, gradients, SGD
# (c) Deniz Yuret, 2019
# * Objectives: Define, train and visualize a simple model; understand gradients and SGD;
# learn to use the GPU.
# * Prerequisites: [Callable
# objects](https://docs.julialang.org/en/v1/manual/methods/#Function-like-objects-1),
# [Generator expressions](https://docs.julialang.org/en/v1/manual/arrays/#Generator-
# Expressions-1), [MNIST](20.mnist.ipynb), [Iterators](25.iterators.ipynb)
# * New functions:
# [mnistdata](https://github.com/denizyuret/Knet.jl/blob/master/data/mnist.jl),
# [accuracy](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.accuracy),
# [zeroone](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.zeroone),
# [nll](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.nll),
# [Param, @diff, value, params,
# grad](http://denizyuret.github.io/Knet.jl/latest/reference/#AutoGrad),
# [sgd](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.sgd),
# [progress,
# progress!](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.progress),
# [gpu](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.gpu),
# [KnetArray](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.KnetArray),
# [load](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.load),
# [save](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.save)
#
#
# <img src="https://www.oreilly.com/library/view/tensorflow-for-
# deep/9781491980446/assets/tfdl_0401.png" alt="A linear model" width=300/> ([image
# source](https://www.oreilly.com/library/view/tensorflow-for-deep/9781491980446/ch04.html))
#
# In Knet, a machine learning model is defined using plain Julia code. A typical model
# consists of a **prediction** and a **loss** function. The prediction function takes some
# input, returns the prediction of the model for that input. The loss function measures how
# bad the prediction is with respect to some desired output. We train a model by adjusting
# its parameters to reduce the loss.
#
# In this section we will implement a simple linear model to classify MNIST digits. The
# prediction function will return 10 scores for each of the possible labels 0..9 as a linear
# combination of the pixel values. The loss function will convert these scores to normalized
# probabilities and return the average -log probability of the correct answers. Minimizing
# this loss should maximize the scores assigned to correct answers by the model. We will
# make use of the loss gradient with respect to each parameter, which tells us the direction
# of the greatest loss increase. We will improve the model by moving the parameters in the
# opposite direction (using a GPU if available). We will visualize the model weights and
# performance over time. The final accuracy of about 92% is close to the limit of what we
# can achieve with this type of model. To improve further we must look beyond linear models.
# ------------------------------------------------------------------------------------------

# Set display width, load packages, import symbols
ENV["COLUMNS"]=72
using Pkg; for p in ("Knet","AutoGrad","Plots","Images","ImageMagick"); haskey(Pkg.installed(),p) || Pkg.add(p); end
using Statistics: mean
using Base.Iterators: flatten
import Random # seed!
using Knet: Knet, AutoGrad, dir, Data, Param, @diff, value, params, grad, progress, progress!, gpu, KnetArray, load, save
# The following are defined for instruction even though they are provided in Knet
# using Knet: accuracy, zeroone, nll, sgd

# Load data (mnistdata basically replicates mnist.ipynb)
include(Knet.dir("data","mnist.jl"))
dtrn,dtst = mnistdata(xsize=(784,:),xtype=Array)
println.(summary.((dtrn,dtst)));

# ------------------------------------------------------------------------------------------
# ## Model definition
# ------------------------------------------------------------------------------------------

# In Julia we define a new datatype using `struct`:
struct Linear; w; b; end

# The new struct comes with a default constructor:
model = Linear(0.01 * randn(10,784), zeros(10))

# We can define other constructors with different inputs:
Linear(i::Int,o::Int,scale=0.01) = Linear(scale * randn(o,i), zeros(o))

# This one allows instances to be defined using input and output sizes:
model = Linear(784,10)

# ------------------------------------------------------------------------------------------
# ## Prediction
# ------------------------------------------------------------------------------------------

# We turn Linear instances into callable objects for prediction:
(m::Linear)(x) = m.w * x .+ m.b

x,y = first(dtst) # The first minibatch from the test set
summary.((x,y))

Int.(y)' # correct answers are given as an array of integers (remember we use 10 for 0)

ypred = model(x)  # Predictions on the first minibatch: a 10x100 score matrix

# We can calculate the accuracy of our model for the first minibatch
accuracy(model,x,y) = mean(y' .== map(i->i[1], findmax(Array(model(x)),dims=1)[2]))
accuracy(model,x,y)

# We can calculate the accuracy of our model for the whole test set
accuracy(model,data) = mean(accuracy(model,x,y) for (x,y) in data)
accuracy(model,dtst)

# ZeroOne loss (or error) is defined as 1 - accuracy
zeroone(x...) = 1 - accuracy(x...)
zeroone(model,dtst)

# ------------------------------------------------------------------------------------------
# ## Loss function
# ------------------------------------------------------------------------------------------

# For classification we use negative log likelihood loss (aka cross entropy, softmax loss, NLL)
# This is the average -log probability assigned to correct answers by the model
function nll(scores, y)
    expscores = exp.(scores)
    probabilities = expscores ./ sum(expscores, dims=1)
    answerprobs = (probabilities[y[i],i] for i in 1:length(y))
    mean(-log.(answerprobs))
end

# model(x) gives predictions, let model(x,y) give the loss
(m::Linear)(x, y) = nll(m(x), y)
model(x,y)

# We can also use the Knet nll implementation for efficiency
(m::Linear)(x, y) = Knet.nll(m(x), y)
model(x,y)

# If the input is a dataset compute average loss:
(m::Linear)(data::Data) = mean(m(x,y) for (x,y) in data)

# Here is per-instance average negative log likelihood for the whole test set
model(dtst)

# ------------------------------------------------------------------------------------------
# **Bonus question:** What is special about the loss value 2.3?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Calculating the gradient using AutoGrad
# ------------------------------------------------------------------------------------------

@doc AutoGrad

# Redefine the constructor to use Param's so we can compute gradients
Linear(i::Int,o::Int,scale=0.01) = 
    Linear(Param(scale * randn(o,i)), Param(zeros(o)))

# Set random seed for replicability
Random.seed!(9);

# Use a larger scale to get a large initial loss
model = Linear(784,10,1.0)

# We can still do predictions and calculate loss:
model(x,y)

# And we can do the same loss calculation also computing gradients:
J = @diff model(x,y)

# To get the actual loss value from J:
value(J)

# params(J) returns an iterator of Params J depends on (i.e. model.b, model.w):
params(J) |> collect

# To get the gradient of a parameter from J:
∇w = grad(J,model.w)

# Note that each gradient has the same size and shape as the corresponding parameter:
@show ∇b = grad(J,model.b);

# ------------------------------------------------------------------------------------------
# ## Checking the gradient using numerical approximation
#
# What does ∇b represent?
#
# ∇b[10] = 0.79 means if I increase b[10] by ϵ, loss will increase by 0.79ϵ
# ------------------------------------------------------------------------------------------

# Loss for the first minibatch with the original parameters
@show value(model.b)
model(x,y)

# To numerically check the gradient let's increase the last entry of b by +0.1.
model.b[10] = 0.1

# We see that the loss moves by ≈ +0.79*0.1 as expected.
@show value(model.b)
model(x,y)

# Reset the change.
model.b[10] = 0

# ------------------------------------------------------------------------------------------
# ## Checking the gradient using manual implementation
# ------------------------------------------------------------------------------------------

# Without AutoGrad we would have to define the gradients manually:
function nllgrad(model,x,y)
    scores = model(x)
    expscores = exp.(scores)
    probabilities = expscores ./ sum(expscores, dims=1)
    for i in 1:length(y); probabilities[y[i],i] -= 1; end
    dJds = probabilities / length(y)
    dJdw = dJds * x'
    dJdb = vec(sum(dJds,dims=2))
    dJdw,dJdb
end;

∇w2,∇b2 = nllgrad(model,x,y)

∇w2 ≈ ∇w

∇b2 ≈ ∇b

# ------------------------------------------------------------------------------------------
# ## Training with Stochastic Gradient Descent (SGD)
# ------------------------------------------------------------------------------------------

# Here is a single SGD update:
function sgdupdate!(func, args; lr=0.1)
    fval = @diff func(args...)
    for param in params(fval)
        ∇param = grad(fval, param)
        param .-= lr * ∇param
    end
    return value(fval)
end

# We define SGD for a dataset as an iterator so that:
# 1. We can monitor and report the training loss
# 2. We can take snapshots of the model during training
# 3. We can pause/terminate training when necessary
sgd(func, data; lr=0.1) = 
    (sgdupdate!(func, args; lr=lr) for args in data)

# Let's train a model for 10 epochs to compare training speed on cpu vs gpu.
# progress!(itr) displays a progress bar when wrapped around an iterator like this:
# 2.94e-01  100.00%┣████████████████████┫ 6000/6000 [00:10/00:10, 592.96/s] 2.31->0.28
model = Linear(784,10)
@show model(dtst)
progress!(sgd(model, repeat(dtrn,10)))
@show model(dtst);

# ------------------------------------------------------------------------------------------
# ## Using the GPU
# ------------------------------------------------------------------------------------------

# The training would go a lot faster on a GPU:
# 2.94e-01  100.00%┣███████████████████┫ 6000/6000 [00:02/00:02, 2653.45/s]  2.31->0.28
# To work on a GPU, all we have to do is convert Arrays to KnetArrays:
if gpu() >= 0  # gpu() returns a device id >= 0 if there is a GPU, -1 otherwise
    atype = KnetArray{Float32}  # KnetArrays are stored and operated in the GPU
    dtrn,dtst = mnistdata(xsize=(784,:),xtype=atype)
    Linear(i::Int,o::Int,scale=0.01) = 
        Linear(Param(atype(scale * randn(o,i))), 
               Param(atype(zeros(o))))

    model = Linear(784,10)
    @show model(dtst)
    progress!(sgd(model,repeat(dtrn,10)))
    @show model(dtst)
end;

# ------------------------------------------------------------------------------------------
#
# ## Recording progress
# ------------------------------------------------------------------------------------------

function trainresults(file, model)
    if (print("Train from scratch? (~77s) "); readline()[1]=='y')
        # This will take every nth element of an iterator:
        takeevery(n,itr) = (x for (i,x) in enumerate(itr) if i % n == 1)
        # We will use it to snapshot model and results every epoch (i.e. 600 iterations)
        lin = ((deepcopy(model),model(dtrn),model(dtst),zeroone(model,dtrn),zeroone(model,dtst))
        # (progress displays a bar like progress! but returns an iterator, progress! returns nothing)
               for x in takeevery(length(dtrn), progress(sgd(model,repeat(dtrn,100)))))
        # Save it as a 5x100 array
        lin = reshape(collect(flatten(lin)),(5,:))
        # Knet.save and Knet.load can be used to store models in files
        Knet.save(file,"results",lin)
    else
        isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file", file)
        lin = Knet.load(file,"results")    
    end
    return lin
end

# 2.43e-01  100.00%┣████████████████▉┫ 60000/60000 [00:44/00:44, 1349.13/s]
lin = trainresults("lin113.jld2",Linear(784,10));

# ------------------------------------------------------------------------------------------
# ## Linear model shows underfitting
# ------------------------------------------------------------------------------------------

using Plots; default(fmt = :png)

# Demonstrates underfitting: training loss not close to 0
# Also slight overfitting: test loss higher than train
plot([lin[2,:], lin[3,:]],ylim=(.0,.4),labels=[:trnloss :tstloss],xlabel="Epochs",ylabel="Loss")

# this is the error plot, we get to about 7.5% test error, i.e. 92.5% accuracy
plot([lin[4,:], lin[5,:]],ylim=(.0,.12),labels=[:trnerr :tsterr],xlabel="Epochs",ylabel="Error")

# ------------------------------------------------------------------------------------------
# ## Visualizing the learned weights
# ------------------------------------------------------------------------------------------

# Let us visualize the evolution of the weight matrix as images below
# Each row is turned into a 28x28 image with positive weights light and negative weights dark gray
using Images, ImageMagick
for t in 10 .^ range(0,stop=log10(size(lin,2)),length=20) #logspace(0,2,20)
    i = ceil(Int,t)
    f = lin[1,i]
    w1 = reshape(Array(value(f.w))', (28,28,1,10))
    w2 = clamp.(w1.+0.5,0,1)
    IJulia.clear_output(true)
    display(hcat([mnistview(w2,i) for i=1:10]...))
    display("Epoch $(i-1)")
    sleep(1) # (0.96^i)
end
