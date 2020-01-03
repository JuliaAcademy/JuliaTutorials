# ------------------------------------------------------------------------------------------
# # Convolutional Neural Networks
# (c) Deniz Yuret, 2019
# * Objectives: See the effect of sparse and shared weights implemented by convolutional
# networks.
# * Prerequisites: [MLP models](40.mlp.ipynb), [MNIST](20.mnist.ipynb)
# * New functions:
# [conv4](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.conv4),
# [pool](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.pool),
# [mat](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.mat)
#
# ![image](https://github.com/denizyuret/Knet.jl/blob/master/docs/src/images/le_net.png?raw=
# true)
# ([image source](http://www.dataiku.com/blog/2015/08/18/Deep_Learning.html))
#
# To improve the performance further, we can use a convolutional neural networks (CNN). See
# the [course notes](http://cs231n.github.io/convolutional-networks/) by Andrej Karpathy for
# a good introduction to CNNs. We will implement the
# [LeNet](http://yann.lecun.com/exdb/lenet) model which consists of two convolutional layers
# followed by two fully connected layers. We will describe and use the
# [conv4](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.conv4) and
# [pool](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.pool) functions provided
# by Knet for the implementation of convolutional nets.
#
# Even though MLPs and CNNs are both universal function approximators and both achieve 0
# error on the training set, we will see that a CNN converges a lot faster and generalizes a
# lot better with less overfitting achieving a 99.5% test accuracy on MNIST. The sparse
# connectivity and shared weights of a CNN give it an inductive bias appropriate for image
# features allowing it to learn better with less data.
# ------------------------------------------------------------------------------------------

# Setup display width, load packages, import symbols
ENV["COLUMNS"]=72
using Pkg; for p in ("Knet","Plots"); haskey(Pkg.installed(),p) || Pkg.add(p); end
using Base.Iterators: flatten
using Statistics: mean
using Knet: Knet, conv4, pool, mat, KnetArray, nll, zeroone, progress, sgd, param, param0, dropout, relu, Data

# ------------------------------------------------------------------------------------------
# ## Introduction to convolution
# ------------------------------------------------------------------------------------------

# Convolution operator in Knet
@doc conv4

# Convolution in 1-D
w = reshape([1.0,2.0,3.0], (3,1,1,1)); @show w
x = reshape([1.0:7.0...], (7,1,1,1)); @show x
@show y = conv4(w, x);  # size Y = X - W + 1 = 5 by default

# Padding
w = reshape([1.0,2.0,3.0], (3,1,1,1)); @show w
x = reshape([1.0:7.0...], (7,1,1,1)); @show x
@show y2 = conv4(w, x, padding=(1,0));  # size Y = X + 2P - W + 1 = 7 with padding=1
# To preserve input size (Y=X) for a given W, what padding P should we use?

# Stride
w = reshape([1.0,2.0,3.0], (3,1,1,1)); @show w
x = reshape([1.0:7.0...], (7,1,1,1)); @show x
@show y3 = conv4(w, x; padding=(1,0), stride=3);  # size Y = 1 + floor((X+2P-W)/S)

# Mode
w = reshape([1.0,2.0,3.0], (3,1,1,1)); @show w
x = reshape([1.0:7.0...], (7,1,1,1)); @show x
@show y4 = conv4(w, x, mode=0);  # Default mode (convolution) inverts w
@show y5 = conv4(w, x, mode=1);  # mode=1 (cross-correlation) does not invert w

# Convolution in more dimensions
x = reshape([1.0:9.0...], (3,3,1,1))

w = reshape([1.0:4.0...], (2,2,1,1))

y = conv4(w, x)

# Convolution with multiple channels, filters, and instances
# size X = [X1,X2,...,Xd,Cx,N] where d is the number of dimensions, Cx is channels, N is instances
x = reshape([1.0:18.0...], (3,3,2,1)) 

# size W = [W1,W2,...,Wd,Cx,Cy] where d is the number of dimensions, Cx is input channels, Cy is output channels
w = reshape([1.0:24.0...], (2,2,2,3));

# size Y = [Y1,Y2,...,Yd,Cy,N]  where Yi = 1 + floor((Xi+2Pi-Wi)/Si), Cy is channels, N is instances
y = conv4(w,x)

# ------------------------------------------------------------------------------------------
# See http://cs231n.github.io/assets/conv-demo/index.html for an animated example.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Introduction to Pooling
# ------------------------------------------------------------------------------------------

# Pooling operator in Knet
@doc pool

# 1-D pooling example
x = reshape([1.0:6.0...], (6,1,1,1)); @show x
@show pool(x);

# Window size
x = reshape([1.0:6.0...], (6,1,1,1)); @show x
@show pool(x; window=3);  # size Y = floor(X/W)

# Padding
x = reshape([1.0:6.0...], (6,1,1,1)); @show x
@show pool(x; padding=(1,0));  # size Y = floor((X+2P)/W)

# Stride
x = reshape([1.0:10.0...], (10,1,1,1)); @show x
@show pool(x; stride=4);  # size Y = 1 + floor((X+2P-W)/S)

# Mode (using KnetArray here; not all modes are implemented on the CPU)
x = KnetArray(reshape([1.0:6.0...], (6,1,1,1))); @show x
@show pool(x; padding=(1,0), mode=0)  # max pooling
@show pool(x; padding=(1,0), mode=1)  # avg pooling
@show pool(x; padding=(1,0), mode=2); # avg pooling excluding padded values (is not implemented on CPU)

# More dimensions
x = reshape([1.0:16.0...], (4,4,1,1))

pool(x)

# Multiple channels and instances
x = reshape([1.0:32.0...], (4,4,2,1))

# each channel and each instance is pooled separately
pool(x)  # size Y = (Y1,...,Yd,Cx,N) where Yi are spatial dims, Cx and N are identical to input X

# ------------------------------------------------------------------------------------------
# ## Experiment setup
# ------------------------------------------------------------------------------------------

# Load data (see mnist.ipynb)
include(Knet.dir("data","mnist.jl"))  # Load data
dtrn,dtst = mnistdata();              # dtrn and dtst = [ (x1,y1), (x2,y2), ... ] where xi,yi are minibatches of 100

(x,y) = first(dtst)
println.(summary.((x,y)));

# For running experiments
function trainresults(file,model; o...)
    if (print("Train from scratch? "); readline()[1]=='y')
        takeevery(n,itr) = (x for (i,x) in enumerate(itr) if i % n == 1)
        r = ((model(dtrn), model(dtst), zeroone(model,dtrn), zeroone(model,dtst))
             for x in takeevery(length(dtrn), progress(sgd(model,repeat(dtrn,100)))))
        r = reshape(collect(Float32,flatten(r)),(4,:))
        Knet.save(file,"results",r)
        Knet.gc() # To save gpu memory
    else
        isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file",file)
        r = Knet.load(file,"results")
    end
    println(minimum(r,dims=2))
    return r
end

# ------------------------------------------------------------------------------------------
# ## A convolutional neural network model for MNIST
# ------------------------------------------------------------------------------------------

# Define a convolutional layer:
struct Conv; w; b; f; p; end
(c::Conv)(x) = c.f.(pool(conv4(c.w, dropout(x,c.p)) .+ c.b))
Conv(w1::Int,w2::Int,cx::Int,cy::Int,f=relu;pdrop=0) = Conv(param(w1,w2,cx,cy), param0(1,1,cy,1), f, pdrop)

# Redefine dense layer (See mlp.ipynb):
struct Dense; w; b; f; p; end
(d::Dense)(x) = d.f.(d.w * mat(dropout(x,d.p)) .+ d.b) # mat reshapes 4-D tensor to 2-D matrix so we can use matmul
Dense(i::Int,o::Int,f=relu;pdrop=0) = Dense(param(o,i), param0(o), f, pdrop)

# Let's define a chain of layers
struct Chain
    layers
    Chain(layers...) = new(layers)
end
(c::Chain)(x) = (for l in c.layers; x = l(x); end; x)
(c::Chain)(x,y) = nll(c(x),y)
(c::Chain)(d::Data) = mean(c(x,y) for (x,y) in d)

lenet =   Chain(Conv(5,5,1,20), 
                Conv(5,5,20,50), 
                Dense(800,500,pdrop=0.3), 
                Dense(500,10,identity,pdrop=0.3))
summary.(l.w for l in lenet.layers)

lenet(x,y)

# ------------------------------------------------------------------------------------------
# ## CNN vs MLP
# ------------------------------------------------------------------------------------------

# 1.08e-02  100.00%┣████████████████▉┫ 60000/60000 [03:50/03:50, 260.67i/s]
# [0.000135032; 0.0196918; 0.0; 0.0053]
cnn = trainresults("cnn113.jld2", lenet);

mlp = Knet.load("mlp113f.jld2","results");

using Plots; default(fmt=:png,ls=:auto)

# Comparison to MLP shows faster convergence, better generalization
plot([mlp[1,:], mlp[2,:], cnn[1,:], cnn[2,:]],ylim=(0.0,0.1),
     labels=[:trnMLP :tstMLP :trnCNN :tstCNN],xlabel="Epochs",ylabel="Loss")  

plot([mlp[3,:], mlp[4,:], cnn[3,:], cnn[4,:]],ylim=(0.0,0.03),
    labels=[:trnMLP :tstMLP :trnCNN :tstCNN],xlabel="Epochs",ylabel="Error")  

# ------------------------------------------------------------------------------------------
# ## Convolution vs Matrix Multiplication
# ------------------------------------------------------------------------------------------

# Convolution and matrix multiplication can be implemented in terms of each other.
# Convolutional networks have no additional representational power, only statistical efficiency.
# Our original 1-D example
@show w = reshape([1.0,2.0,3.0], (3,1,1,1))
@show x = reshape([1.0:7.0...], (7,1,1,1))
@show y = conv4(w, x);  # size Y = X - W + 1 = 5 by default

# Convolution as matrix multiplication (1)
# Turn w into a (Y,X) sparse matrix
w2 = Float64[3 2 1 0 0 0 0; 0 3 2 1 0 0 0; 0 0 3 2 1 0 0; 0 0 0 3 2 1 0; 0 0 0 0 3 2 1]

@show y2 = w2 * mat(x);

# Convolution as matrix multiplication (2)
# Turn x into a (W,Y) dense matrix (aka the im2col operation)
# This is used to speed up convolution with known efficient matmul algorithms
x3 = Float64[1 2 3 4 5; 2 3 4 5 6; 3 4 5 6 7]

@show w3 = [3.0 2.0 1.0]
@show y3 = w3 * x3;

# Matrix multiplication as convolution
# This could be used to make a fully connected network accept variable sized inputs.
w = reshape([1.0:6.0...], (2,3))

x = reshape([1.0:3.0...], (3,1))

y = w * x

# Consider w with size (Y,X)
# Treat each of the Y rows of w as a convolution filter
w2 = copy(reshape(Array(w)', (3,1,1,2)))

# Reshape x for convolution
x2 = reshape(x, (3,1,1,1))

# Use conv4 for matrix multiplication
y2 = conv4(w2, x2; mode=1)

# ------------------------------------------------------------------------------------------
# * So there is no difference between the class of functions representable with an MLP vs
# CNN.
# * Sparse connections and weight sharing give CNNs more generalization power with images.
# * Number of parameters in MLP256: (256x784)+256+(10x256)+10 = 203530
# * Number of parameters in LeNet: (5*5*1*20)+20+(5*5*20*50)+50+(500*800)+500+(10*500)+10 =
# 431080
# ------------------------------------------------------------------------------------------
