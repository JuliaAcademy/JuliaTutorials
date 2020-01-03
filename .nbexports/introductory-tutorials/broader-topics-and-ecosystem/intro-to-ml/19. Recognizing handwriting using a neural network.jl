# ------------------------------------------------------------------------------------------
# # Learning to recognize handwritten digits using a neural network
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We have now reached the point where we can tackle a very interesting task: applying the
# knowledge we have gained with machine learning in general, and `Flux.jl` in particular, to
# create a neural network that can recognize handwritten digits! The data are from a data
# set called MNIST, which has become a classic in the machine learning world.
#
# [We could also try to apply the techniques to the original images of fruit instead.
# However, the fruit images are much larger than the MNIST images, which makes the learning
# a suitable neural network too slow.]
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Data munging
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# As we know, the first difficulty with any new data set is locating it, understanding what
# format it is stored in, reading it in and decoding it into a useful data structure in
# Julia.
#
# The original MNIST data is available [here](http://yann.lecun.com/exdb/mnist); see also
# the [Wikipedia page](https://en.wikipedia.org/wiki/MNIST_database). However, the format
# that the data is stored in is rather obscure.
#
# Fortunately, various packages in Julia provide nicer interfaces to access it. We will use
# the one provided by `Flux.jl`.
#
# The data are images of handwritten digits, and the corresponding labels that were
# determined by hand (i.e. by humans). Our job will be to get the computer to **learn** to
# recognize digits by learning, as usual, the function that relates the input and output
# data.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Loading and examining the data
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# First we load the required packages:
# ------------------------------------------------------------------------------------------

using Flux, Flux.Data.MNIST

# ------------------------------------------------------------------------------------------
# Now we read in the data:
# ------------------------------------------------------------------------------------------

labels = MNIST.labels();
images = MNIST.images();  # the semi-colon (`;`) here is important: it prevents Julia from displaying the object

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# Examine the `labels` data. Then examine the first few images. *Do not try to view the
# whole of the `images` object!* Try to drill down to discover how the data is laid out.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 2
#
# Convert the first image to a matrix of `Float64`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Munging the data
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# In the previous notebooks, we arranged the input data for Flux as a `Vector` of `Vector`s.
# Now we will use an alternative arrangement, as a matrix, since that allows `Flux` to use
# matrix operations, which are more efficient.
#
# The column $i$ of the matrix is a vector consisting of the $i$th data point
# $\mathbf{x}^{(i)}$.  Similarly, the desired outputs are given as a matrix, with the $i$th
# column being the desired output $\mathbf{y}^{(i)}$.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 3
#
# An image is a matrix of colours, but now we need a vector instead. To do so, we just
# arrange all of the elements of the matrix in a certain way into a single list;
# fortunately, Julia already provides the function `vec` to do so!
#
# 1. Which order does `vec` use? [This reflects the underlying way in which the matrix is
# stored in memory.]
#
# 2. How can you convert an image into a `Vector` of `Float64`?
#
# 3. Define a variable $n$ that is the length of these vectors.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 4
# Make a function `rewrite` that accepts a range and converts that range of images to
# floating-point vectors and stacks them horizontally using `hcat` and the "splat" operator
# `...`.
#
# We also want a matrix of one-hot vectors. `Flux` provides a function `onehotbatch` to do
# this (you will need to import it). It works like `onehot`, but takes in a vector of labels
# and outputs a matrix `Y`.
#
# Return the pair `(X, Y)`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Setting up the neural network
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Now we must set up a neural network. Since the data is complicated, we may expect to need
# several layers.
# But we can start with a single layer.
#
# - The network will take as inputs the vectors $\mathbf{x}^{(i)}$, so the input layer has
# $n$ nodes.
#
# - The output will be a one-hot vector encoding the digit from 1 to 9 or 0 that is desired.
# There are 10 possible categories, so we need an output layer of size 10.
#
# It is then our task as neural network designers to insert layers between these input and
# output layers, whose weights will be tuned during the learning process. *This is an art,
# not a science*! But major advances have come from finding a good structure for the
# network.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Softmax
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We will make a network with a single layer; let's choose each neuron in the layer to use
# the `relu` activation function.
# The output `relu` can be arbitrarily large, but in the end we will wish to compare the
# network's output with one-hot vectors, i.e. values between $0$ and $1$.
#
# In order to make this work, we will thus use an extra function at the end that takes in a
# vector of arbitrary real numbers and maps it ("squashes it down") to a vector of numbers
# between $0$ and $1$.
#
# The most used function with this property is $\mathrm{softmax}$. Firstly we take the
# exponential of each input variable to make them positive. Then we divide by the sum to
# make sure they lie between $0$ and $1$.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# $$\mathrm{softmax}(\mathbf{x})_i := \frac{\exp (x_i)}{\sum_j \exp(x_j)}$$
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Note that here we have written the result for the $i$th component of the function
# $\mathbf{R}^n \to \mathbf{R}^n$. Note also that the function returns a vector of numbers
# that are positive, and whose components sum to $1$. Thus, in fact, they can be thought of
# as probabilities.
#
# In the neural network context, using a `softmax` after the final layer thus allows us to
# interpret the outputs as probabilities, in our case the probability that the network
# assigns that a given image represents each possible output value ($0$-$9$)!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 5
#
# Make a neural network with one single layer, using the function $\sigma$, and a final
# `softmax`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Training
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# As we know, **training** consists of iteratively adjusting the model's parameters to
# decrease the `loss` function. Which parameters need to be adjusted? All of them!
#
# Since the `loss` function contains a call to the `model` function, calling `back!` on the
# result of the loss function updates the information about the gradient of the loss
# function with respect to *every node in the network!*:
# ------------------------------------------------------------------------------------------

l = loss(X, Y)

Flux.Tracker.back!(l)

# ------------------------------------------------------------------------------------------
# This is what is going on inside the `train!` function.
# In fact, `train!(loss, data, opt)` iterates over each object in `data` and runs this
# function.
# For this reason, `data` must consist of an iterable object that returns pairs `(X, Y)` at
# each step.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The simplest possibility is
# ------------------------------------------------------------------------------------------

data = ((X, Y), )  # one-element tuple

# ------------------------------------------------------------------------------------------
# Alternatively, we can make one call to the `train!` function iterate over several copies
# of `data`, using `repeated`. This is an **iterator**; it does not copy the data 100 times,
# which would be very wasteful; it just gives an object that repeatedly loops over the same
# data:
# ------------------------------------------------------------------------------------------

dataset = Base.Iterators.repeated((X, Y), 100)

# ------------------------------------------------------------------------------------------
# #### Exercise 6
#
# Train the model on a subset of $N$ images with $N = 5000$.
# ------------------------------------------------------------------------------------------

N = 5_000
X, Y = rewrite(1:N)

# ------------------------------------------------------------------------------------------
# The function `loss` evaluated on the matrices gives the overall loss:
# ------------------------------------------------------------------------------------------

loss(X, Y)

@time Flux.train!(loss, data, opt)

@time Flux.train!(loss, dataset, opt)

# ------------------------------------------------------------------------------------------
# This is (approximately) equivalent to just doing a `for` loop to run the previous `train!`
# command 100 times.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Using callbacks
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The `train!` function can take an optional keyword argument, `cb` (short for
# "*c*all*b*ack"). A callback function is a function that you provide as an argument to a
# function `f`, which "calls back" your function every so often.
#
# This provides the possibility to provide a function that is called at each step or every
# so often during the training process.
# A common use case is to provide a visual trace of the training process by printing out the
# current value of the `loss` function:
# ------------------------------------------------------------------------------------------

callback() = @show(loss(X, Y))

Flux.train!(loss, data, opt; cb = callback)

Flux.train!(loss, dataset, opt; cb = callback)

# ------------------------------------------------------------------------------------------
# However, it is expensive to calculate the complete `loss` function and it is not necessary
# to output it every step. So `Flux` also provides a function `throttle`, that provides a
# mechanism to call a given function at most once every certain number of seconds:
# ------------------------------------------------------------------------------------------

Flux.train!(loss, dataset, opt; cb = Flux.throttle(callback, 1))

for i in 1:100
    Flux.train!(loss, dataset, opt; cb = Flux.throttle(callback, 1))
end

# ------------------------------------------------------------------------------------------
# ## Testing phase
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We now have trained a model, i.e. we have found the parameters `W` and `b` for the network
# layer(s). In order to **test** if the learning procedure was really successful, we check
# how well the resulting trained network performs when we test it with images that the
# network has not yet seen!
#
# Often, a dataset is split up into "training data" and "test (or validation) data" for this
# purpose, and indeed the MNIST data set has a separate pool of training data. We can
# instead use the images that we have not included in our reduced training process.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 7
#
# Take the next 100 images after those that were used for training. How well does it do?
# ------------------------------------------------------------------------------------------

X_test, Y_test = rewrite(N+1:N+100)

loss(X_test, Y_test)

display(images[N+1])
labels[N+1]

[model(X_test[:,1]) Y_test[:,1]]

loss(X_test[:,1], Y_test[:,1])

loss(X_test, Y_test)

# ------------------------------------------------------------------------------------------
# #### Exercise 8
#
# Use the `indmax` function to write a function `prediction` that reports which digit
# `model` predicts, as the index with the maximum weight.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 9
#
# Count the number of correct predictions over the whole data set, and hence the percentage
# of images that are correctly predicted. [This percentage is what is used to compare
# different machine learning techniques.]
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Improving the prediction
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# So far we have used a single layer. In order to improve the prediction, we probably need
# to use more layers.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 10
#
# Introduce an intermediate, hidden layer. Does it give a better prediction?
# ------------------------------------------------------------------------------------------
