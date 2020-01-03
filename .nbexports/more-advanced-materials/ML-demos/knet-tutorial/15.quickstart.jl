# ------------------------------------------------------------------------------------------
# # Quick start
# (c) Deniz Yuret, 2019
#
# This notebook is for the impatient reader who wants to get a flavor of Julia/Knet possibly
# to compare it with other deep learning frameworks. In 15 lines of code and 30 seconds of
# GPU time we define, train, and evaluate the LeNet convolutional neural network model from
# scratch without any predefined layers.
# ------------------------------------------------------------------------------------------

using Knet

# Define convolutional layer:
struct Conv; w; b; f; end
(c::Conv)(x) = c.f.(pool(conv4(c.w, x) .+ c.b))
Conv(w1,w2,cx,cy,f=relu) = Conv(param(w1,w2,cx,cy), param0(1,1,cy,1), f);

# Define dense layer:
struct Dense; w; b; f; end
(d::Dense)(x) = d.f.(d.w * mat(x) .+ d.b)
Dense(i::Int,o::Int,f=relu) = Dense(param(o,i), param0(o), f);

# Define a chain of layers:
struct Chain; layers; Chain(args...)=new(args); end
(c::Chain)(x) = (for l in c.layers; x = l(x); end; x)
(c::Chain)(x,y) = nll(c(x),y)

# Load MNIST data
include(Knet.dir("data","mnist.jl"))
dtrn, dtst = mnistdata();

# Train and test LeNet (about 30 secs on a gpu to reach 99% accuracy)
LeNet = Chain(Conv(5,5,1,20), Conv(5,5,20,50), Dense(800,500), Dense(500,10,identity))
progress!(adam(LeNet, repeat(dtrn,10)))
accuracy(LeNet, dtst)
