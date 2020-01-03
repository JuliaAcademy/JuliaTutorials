# ------------------------------------------------------------------------------------------
# # Learning with a single neuron using Flux.jl
#
# In this notebook, we'll use `Flux` to create a single neuron and teach it to learn, as we
# did by hand in notebook 10!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Read in data and process it
#
# Let's start by reading in our data
# ------------------------------------------------------------------------------------------

using CSV
using TextParse
using DataFrames

applecols, applecolnames = TextParse.csvread("data/Apple_Golden_1.dat", '\t')
bananacols, bananacolnames = TextParse.csvread("data/bananas.dat", '\t')

apples = DataFrame(Dict(strip(name)=>col for (name, col) in zip(applecolnames, applecols)))
bananas = DataFrame(Dict(strip(name)=>col for (name, col) in zip(bananacolnames, bananacols)));

# ------------------------------------------------------------------------------------------
# and processing it to extract information about the red and green coloring in our images:
# ------------------------------------------------------------------------------------------

col1 = :red
col2 = :green

x_apples  = [ [apples[i, col1], apples[i, col2]] for i in 1:size(apples)[1] ]
x_bananas = [ [bananas[i, col1], bananas[i, col2]] for i in 1:size(bananas)[1] ]

xs = vcat(x_apples, x_bananas)

ys = vcat( zeros(size(x_apples)[1]), ones(size(x_bananas)[1]) );

# ------------------------------------------------------------------------------------------
# The input data is in `xs` and the labels (true classifications as bananas or apples) in
# `ys`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Using `Flux.jl`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Now we can load `Flux` to really get going!
# ------------------------------------------------------------------------------------------

using Flux

# ------------------------------------------------------------------------------------------
# We saw in the last notebook that σ is a built-in function in `Flux`.
#
# Another function that is used a lot in neural networks is called `ReLU`; in Julia, the
# function is called `relu`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# Use the docs to discover what `ReLU` is all about.
#
# `relu.([-3, 3])` returns
#
# A) [-3, 3] <br>
# B) [0, 3] <br>
# C) [0, 0] <br>
# D) [3, 3] <br>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Making a single neuron in Flux
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's use `Flux` to build our neuron with 2 inputs and 1 output:
#
#  <img src="data/single-neuron.png" alt="Drawing" style="width: 500px;"/>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We previously put the two weights in a vector, $\mathbf{w}$. Flux instead puts weights in
# a $1 \times 2$ matrix (i.e. a matrix with 1 *row* and 2 *columns*).
#
# Previously, to compute the dot product of $\mathbf{w}$ and $\mathbf{x}$ we had to use
# either the `dot` function, or we had to transpose the vector $\mathbf{w}$:
#
# ```julia
# # transpose w
# b = w' * x
# # or use dot!
# b = dot(w, x)
# ```
# If the weights are instead stored in a $1 \times 2$ matrix, `W`, then we can simply
# multiply `W` and `x` together instead!
#
# We start off with random values for our parameters and data:
# ------------------------------------------------------------------------------------------

W = rand(1, 2)

x = rand(2)

# ------------------------------------------------------------------------------------------
# Note that the product of `W` and `x` will now be an array (vector) with a single element,
# rather than a single number:
# ------------------------------------------------------------------------------------------

W * x

# ------------------------------------------------------------------------------------------
# This means that our bias `b` is treated as an array when we're using `Flux`:
# ------------------------------------------------------------------------------------------

b = rand(1)

# ------------------------------------------------------------------------------------------
# #### Exercise 2
#
# Write a function `mypredict` that will take a single input, array `x` and use `W`, `b`,
# and built-in `σ` to generate an output prediction (stored as an array). This function
# defines our neural network!
#
# Hint: This function will look very similar to $f_{\mathbf{w},\mathbf{b}}$ from the last
# notebook but has changed since our data structures to store our parameters have changed!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 3
#
# Define a loss function called `loss`.
#
# `loss` should take two inputs: a vector storing data, `x`, and a vector storing the
# correct "labels" for that data. `loss` should return the sum of the squares of differences
# between the predictions and the correct labels.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Calculating gradients using Flux: backpropagation
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# For learning, we know that what we need is a way to calculate derivatives of the `loss`
# function with respect to the parameters `W` and `b`. So far, we have been doing that using
# finite differences.
#
# `Flux.jl` instead implements a numerical method called **backpropagation** that calculates
# gradients (essentially) exactly, in an automatic way, by indirectly applying the rules of
# calculus.
# To do so, it provides a new type of object called "tracked" arrays. These are arrays that
# store not only their current value, but also information about gradients, which is used by
# the backpropagation method.
#
# [If you want to understand the maths behind backpropagation, we recommend e.g. [this
# lecture](https://www.youtube.com/watch?v=i94OvYb6noo).]
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# To do so, `Flux` provides a function `param` to define such objects that will contain the
# information for a *param*eter.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's start, as usual, by setting up some random initial values for the parameters:
# ------------------------------------------------------------------------------------------

W_data = rand(1, 2)  
b_data = rand(1)

W_data, b_data

# ------------------------------------------------------------------------------------------
# We now set up `Flux.jl` objects that will contain these values *and* their derivatives,
# and allow to propagate
# this information around:
# ------------------------------------------------------------------------------------------

W = param(W_data)
b = param(b_data)

# ------------------------------------------------------------------------------------------
# Here, `param` is a function that `Flux` provides to create an object that represents a
# parameter of a machine learning model, i.e. an object which has both a value and
# derivative information, and such that other objects know how to *keep track* of when it is
# used in an expression.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 4
#
# What type does `W` have?
#
# A) Array (1D) <br>
# B) Array (2D) <br>
# C) TrackedArray (1D) <br>
# D) TrackedArray (2D) <br>
# E) Parameter (1D) <br>
# F) Parameter (2D) <br>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 5
#
# `W` stores not only its current value, but also has space to store gradient information.
# You can access the values and gradient of the weights as follows:
#
# ```julia
# W.data
# W.grad
# ```
#
# At this point, are the values of the weights or the gradient of the weights larger?
#
# A) the values of the weights <br>
# B) the gradient of the weights
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 6
#
# For data `x` and `y` where
#
# ```julia
# x, y = [0.413759, 0.692204], [0.845677]
# ```
# apply the loss function to `x` and `y` to give a new variable `l`. What is the type of
# `l`? (How many dimensions does it have?)
#
# A) Array (0D) <br>
# B) Array (1D) <br>
# C) TrackedArray (0D) <br>
# D) TrackedArray (1D)<br>
# E) Float64<br>
# F) Int64<br>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Stochastic gradient descent
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We can now use these features to reimplement stochastic gradient descent, following the
# method we used in the previous notebook, but now using backpropagation!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 7
#
# Modify the code from the previous notebook for stochastic gradient descent to use Flux
# instead.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Investigating stochastic gradient descent
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's look at the values stored in `b` before we run stochastic gradient descent:
# ------------------------------------------------------------------------------------------

b

# ------------------------------------------------------------------------------------------
# After running `stochastic_gradient_descent`, we find the following:
# ------------------------------------------------------------------------------------------

W_final, b_final = stochastic_gradient_descent(loss, W, b, xs, ys, 100000)

# ------------------------------------------------------------------------------------------
# we can look at the values of `W_final` and `b_final`, which our machine learned to
# generate our desired classification.
# ------------------------------------------------------------------------------------------

W_final

b_final

# ------------------------------------------------------------------------------------------
# #### Exercise 8
#
# Plot the data and the learned function.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 9
#
# Do this plot every so often as the learning process is proceeding in order to have an
# animation of the process.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Automation with Flux.jl
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We will need to repeat the above process for a lot of different systems.
# Fortunately, `Flux.jl` provides us with tools to automate this!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Flux allows to create a neuron in a simple way:
# ------------------------------------------------------------------------------------------

using Flux

model = Dense(2, 1, σ)

# ------------------------------------------------------------------------------------------
# The `2` and `1` refer to the number of inputs and outputs, and the neuron is defined using
# the $\sigma$ function.
# ------------------------------------------------------------------------------------------

typeof(model)

# ------------------------------------------------------------------------------------------
# We have made an object of type `Dense`, defined by `Flux`, with the name `model`. This
# represents a "dense neural network layer" (see later for more on neural network layers).
# The parameters that will be modified during the learning process live *inside* the `model`
# object.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 10
#
# Investigate which variables live inside the `model` object and what type they are. How
# does that compare to the call to create the `Dense` object that we started with?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Model object as a function
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We can apply the `model` object to data just as if it were a standard function:
# ------------------------------------------------------------------------------------------

model(rand(2))

# ------------------------------------------------------------------------------------------
# #### Exercise 11
#
# Prove to yourself that you understand what is going on when we call `model`. Create two
# arrays `W` and `b` with the same elements as `model.W` and `model.b`. Use `W` and `b` to
# generate the same answer that you get when we call `model([.5, .5])`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Using Flux
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We now need to provide Flux with three pieces of information:
#
# 1. A loss function
# 2. Some training data
# 3. An optimization method
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Loss functions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Flux has various loss functions built in, for example the mean-squared error (`mse`) that
# we have been using:
# ------------------------------------------------------------------------------------------

loss(x, y) = Flux.mse(model(x), y)

# ------------------------------------------------------------------------------------------
# Another common one is the cross entropy, `Flux.crossentropy`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Data
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The data can take a couple of different forms.
# One form is a single **iterator**, consisting of pairs $(x, y)$ of data and labels.
# We can achieve this with `zip`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 12
#
# Use `zip` to "zip together" `xs` and `ys`. Then use the `collect` function to check what
# `zip` actually does.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Optimization routine
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Now we need to tell Flux what kind of optimization routine to use. It has several built
# in; the standard stochastic gradient descent algorithm that we have been using is called
# `SGD`. We must pass it two things: a list of parameter objects which will be modified by
# the optimization routine, and a step size:
# ------------------------------------------------------------------------------------------

opt = SGD([model.W, model.b], 0.01)
# give a list of the parameters that will be modified

# ------------------------------------------------------------------------------------------
# The gradient calculations and parameter updates will be carried out by this optimizer
# function; we do not see those details, but if you are curious, you can, of course, look at
# the `Flux.jl` source code!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Training
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We now have all the pieces in place to actually **train** our model (a single neuron) on
# the data.
# "Training" refers to using pre-labeled data to learn the function that relates the input
# data to the desired output data given by the labels.
#
# `Flux` provides the function `train!`, which performs a single pass through the data and
# does a single step of optimization using the partial cost function for each data point:
# ------------------------------------------------------------------------------------------

Flux.train!(loss, data, opt)

# ------------------------------------------------------------------------------------------
# We can then just repeat this several times to train the network more and coax it towards
# the minimum of the cost function:
# ------------------------------------------------------------------------------------------

for i in 1:100
    Flux.train!(loss, data, opt)
end

# ------------------------------------------------------------------------------------------
# Now let's look at the parameters after training:
# ------------------------------------------------------------------------------------------

model.W

model.b

# ------------------------------------------------------------------------------------------
# Instead of writing out a list of parameters to modify, `Flux` provides the function
# `params`, which extracts all available parameters from a model:
# ------------------------------------------------------------------------------------------

opt = SGD(params(model), 0.01)

params(model)

# ------------------------------------------------------------------------------------------
# ## Adding more features
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 13
#
# So far we have just used two features, red and green.
#
# (i) Add a third feature, blue. Plot the new data.
#
# (ii) Train a neuron with 3 inputs and 1 output on the data.
#
# (iii) Can you find a good way to visualize the result?
# ------------------------------------------------------------------------------------------


