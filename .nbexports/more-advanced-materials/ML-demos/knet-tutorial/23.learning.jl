# ------------------------------------------------------------------------------------------
# # Learning: algorithms, objectives, and assumptions
# (c) Deniz Yuret 2019
#
# In this notebook we will analyze three classic learning algorithms.
# * **Perceptron:** ([Rosenblatt, 1957](https://en.wikipedia.org/wiki/Perceptron)) a neuron
# model trained with a simple algorithm that updates model weights using the input when the
# prediction is wrong.
# * **Adaline:** ([Widrow and Hoff, 1960](https://en.wikipedia.org/wiki/ADALINE)) a neuron
# model trained with a simple algorithm that updates model weights using the error
# multiplied by the input (aka least mean square (LMS), delta learning rule, or the Widrow-
# Hoff rule).
# * **Softmax classification:** ([Cox,
# 1958](https://en.wikipedia.org/wiki/Multinomial_logistic_regression)) a multiclass
# generalization of the logistic regression model from statistics (aka multinomial LR,
# softmax regression, maxent classifier etc.).
#
# We will look at these learners from three different perspectives:
# * **Algorithm:** First we ask only **how** the learner works, i.e. how it changes after
# observing each example.
# * **Objectives:** Next we ask **what** objective guides the algorithm, whether it is
# optimizing a particular objective function, and whether we can use a generic *optimization
# algorithm* instead.
# * **Assumptions:** Finally we ask **why** we think this algorithm makes sense, what prior
# assumptions does this imply and whether we can use *probabilistic inference* for optimal
# learning.
# ------------------------------------------------------------------------------------------

using Knet, Plots, Statistics, LinearAlgebra, Random
Base.argmax(a::KnetArray) = argmax(Array(a))
Base.argmax(a::AutoGrad.Value) = argmax(value(a))
ENV["COLUMNS"] = 72

# ------------------------------------------------------------------------------------------
# ### Data
# ------------------------------------------------------------------------------------------

include(Knet.dir("data/mnist.jl"))
xtrn, ytrn, xtst, ytst = mnist()
ARRAY = Array{Float32}
xtrn, xtst = ARRAY(mat(xtrn)), ARRAY(mat(xtst))
onehot(y) = (m=ARRAY(zeros(maximum(y),length(y))); for i in 1:length(y); m[y[i],i]=1; end; m)
ytrn, ytst = onehot(ytrn), onehot(ytst);

println.(summary.((xtrn, ytrn, xtst, ytst)));

NTRN,NTST,XDIM,YDIM = size(xtrn,2), size(xtst,2), size(xtrn,1), size(ytrn,1)

# ------------------------------------------------------------------------------------------
# ### Prediction
# ------------------------------------------------------------------------------------------

# Model weights
w = ARRAY(randn(YDIM,XDIM))

# Class scores
w * xtrn

# Predictions
[ argmax(w * xtrn[:,i]) for i in 1:NTRN ]'

# Correct answers
[ argmax(ytrn[:,i]) for i in 1:NTRN ]'

# Accuracy
acc(w,x,y) = mean(argmax(w * x, dims=1) .== argmax(y, dims=1))
acc(w,xtrn,ytrn), acc(w,xtst,ytst)

# ------------------------------------------------------------------------------------------
# ## Algorithms
# ------------------------------------------------------------------------------------------

# Training loop
function train(algo,x,y,T=2^20)
    w = ARRAY(zeros(size(y,1),size(x,1)))
    nexamples = size(x,2)
    nextprint = 1
    for t = 1:T
        i = rand(1:nexamples)
        algo(w, x[:,i], y[:,i])  # <== this is where w is updated
        if t == nextprint
            println((iter=t, accuracy=acc(w,x,y), wnorm=norm(w)))
            nextprint = min(2t,T)
        end
    end
    w
end

# ------------------------------------------------------------------------------------------
# ### Perceptron
# ------------------------------------------------------------------------------------------

function perceptron(w,x,y)
    guess = argmax(w * x)
    class = argmax(y)
    if guess != class
        w[class,:] .+= x
        w[guess,:] .-= x
    end
end

# (iter = 1048576, accuracy = 0.8950333333333333, wnorm = 1321.2463f0) in 7 secs
@time wperceptron = train(perceptron,xtrn,ytrn);

# ------------------------------------------------------------------------------------------
# ### Adaline
# ------------------------------------------------------------------------------------------

function adaline(w,x,y; lr=0.0001)
    error = w * x - y
    w .-= lr * error * x'
end

# (iter = 1048576, accuracy = 0.8523, wnorm = 1.2907721f0) in 31 secs with lr=0.0001
@time wadaline = train(adaline,xtrn,ytrn);

# ------------------------------------------------------------------------------------------
# ### Softmax classifier
# ------------------------------------------------------------------------------------------

function softmax(w,x,y; lr=0.01)
    probs = exp.(w * x)
    probs ./= sum(probs)
    error = probs - y
    w .-= lr * error * x'
end

# (iter = 1048576, accuracy = 0.9242166666666667, wnorm = 26.523603f0) in 32 secs with lr=0.01
@time wsoftmax = train(softmax,xtrn,ytrn);

# ------------------------------------------------------------------------------------------
# ## Objectives
# ------------------------------------------------------------------------------------------

# Training via optimization
function optimize(loss,x,y; lr=0.1, iters=2^20)
    w = Param(ARRAY(zeros(size(y,1),size(x,1))))
    nexamples = size(x,2)
    nextprint = 1
    for t = 1:iters
        i = rand(1:nexamples)
        L = @diff loss(w, x[:,i], y[:,i])
        ∇w = grad(L,w)
        w .-= lr * ∇w
        if t == nextprint
            println((iter=t, accuracy=acc(w,x,y), wnorm=norm(w)))
            nextprint = min(2t,iters)
        end
    end
    w
end

# ------------------------------------------------------------------------------------------
# ### Perceptron minimizes the score difference between the correct class and the prediction
# ------------------------------------------------------------------------------------------

function perceptronloss(w,x,y)
    score = w * x
    guess = argmax(score)
    class = argmax(y)
    score[guess] - score[class]
end

# (iter = 1048576, accuracy = 0.8908833333333334, wnorm = 1322.4888f0) in 62 secs with lr=1
@time wperceptron2 = optimize(perceptronloss,xtrn,ytrn,lr=1);

# ------------------------------------------------------------------------------------------
# ### Adaline minimizes the squared error
# ------------------------------------------------------------------------------------------

function quadraticloss(w,x,y)
    0.5 * sum(abs2, w * x - y)
end

# (iter = 1048576, accuracy = 0.8498333333333333, wnorm = 1.2882874f0) in 79 secs with lr=0.0001
@time wadaline2 = optimize(quadraticloss,xtrn,ytrn,lr=0.0001);

# ------------------------------------------------------------------------------------------
# ### Softmax classifier maximizes the probabilities of correct answers
# (or minimizes negative log likelihood, aka cross-entropy or softmax loss)
# ------------------------------------------------------------------------------------------

function negloglik(w,x,y)
    probs = exp.(w * x)
    probs = probs / sum(probs)
    class = argmax(y)
    -log(probs[class])
end

# (iter = 1048576, accuracy = 0.9283833333333333, wnorm = 26.593485f0) in 120 secs with lr=0.01
@time wsoftmax2 = optimize(negloglik,xtrn,ytrn,lr=0.01);


