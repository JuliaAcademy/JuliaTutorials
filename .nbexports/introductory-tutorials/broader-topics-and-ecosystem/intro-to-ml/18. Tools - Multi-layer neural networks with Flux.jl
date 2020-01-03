# ------------------------------------------------------------------------------------------
# # Multiple neural network layers with `Flux.jl`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# In a previous notebook, we saw that one layer of neurons wasn't enough to distinguish
# between three types of fruit (apples, bananas *and* grapes), since the data is quite
# complex. To solve this problem, we need to use more layers, so heading into the territory
# of **deep learning**!
#
# By adding another layer between the inputs and the output neurons, a so-called "hidden
# layer", we will get our first serious **neural network**, looking something like this:
# ------------------------------------------------------------------------------------------

include("draw_neural_net.jl")
draw_network([2, 4, 3])

# ------------------------------------------------------------------------------------------
# We will continue to use two input data and try to classify into three types, so we will
# have three output neurons. We have chosen to add a single "hidden layer" in between, and
# have arbitrarily chosen to put 4 neurons there.
#
# Much of the *art* of deep learning is choosing a suitable structure for the neural network
# that will allow the model to be sufficiently complex to model the data well, but
# sufficiently simple to allow the parameters to be learned in a reasonable length of time.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Read in and process data
#
# As before, let's load some pre-processed data using code we've seen in the previous
# notebook.
# ------------------------------------------------------------------------------------------

using Flux
using Flux: onehot

using CSV

apples_1 = CSV.read("data/Apple_Golden_1.dat", delim='\t')
apples_2 = CSV.read("data/Apple_Golden_2.dat", delim='\t')
apples_3 = CSV.read("data/Apple_Golden_3.dat", delim='\t')
bananas = CSV.read("data/Banana.dat", delim='\t')
grapes_1 = CSV.read("data/Grape_White.dat", delim='\t')
grapes_2 = CSV.read("data/Grape_White_2.dat", delim='\t');

apples = vcat(apples_1, apples_2, apples_3)
grapes = vcat(grapes_1, grapes_2);

col1 = :red
col2 = :blue

x_apples  = [ [apples_1[i, col1], apples_1[i, col2]] for i in 1:size(apples_1)[1] ]
append!(x_apples, [ [apples_2[i, col1], apples_2[i, col2]] for i in 1:size(apples_2)[1] ])
append!(x_apples, [ [apples_3[i, col1], apples_3[i, col2]] for i in 1:size(apples_3)[1] ])

x_bananas = [ [bananas[i, col1], bananas[i, col2]] for i in 1:size(bananas)[1] ]

x_grapes = [ [grapes_1[i, col1], grapes_1[i, col2]] for i in 1:size(grapes_1)[1] ]
append!(x_grapes, [ [grapes_2[i, col1], grapes_2[i, col2]] for i in 1:size(grapes_2)[1] ])

xs = vcat(x_apples, x_bananas, x_grapes);

# ------------------------------------------------------------------------------------------
# We now we wish to classify the three types of fruit, so we again use one-hot vectors to
# represent the desired outputs $y^{(i)}$:
# ------------------------------------------------------------------------------------------

labels = [ones(length(x_apples)); 2*ones(length(x_bananas)); 3*ones(length(x_grapes))];

ys = [onehot(label, 1:3) for label in labels];  # onehotbatch(labels, 1:3)

# ------------------------------------------------------------------------------------------
# The input data is in `xs` and the one-hot vectors are in `ys`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Multiple layers in Flux
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's tell Flux what structure we want the network to have. We first specify the number of
# neurons in each layer, and then construct each layer as a `Dense` layer:
# ------------------------------------------------------------------------------------------

inputs = 2
hidden = 4
outputs = 3

layer1 = Dense(inputs, hidden, σ)
layer2 = Dense(hidden, outputs, σ)

# ------------------------------------------------------------------------------------------
# To stitch together multiple layers to make a multi-layer network, we use Flux's `Chain`
# function:
# ------------------------------------------------------------------------------------------

model = Chain(layer1, layer2)

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# What is the internal structure and sub-structure of this `model` object?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Training the model
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We have now set up a model and we have some training data.
# How do we train the model on the data?
#
# The amazing thing is that the rest of the code in `Flux` is **exactly the same as
# before**. This is possible thanks to the design of Julia itself, and of the `Flux`
# package.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 2
#
# Train the model as before, now using the popular `ADAM` optimizer. You may need to train
# the network for longer than before, since we have many more parameters.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Visualizing the results
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# What does this neural network represent? It is simply a more complicated function with two
# inputs and three outputs, i.e. a function $f: \mathbb{R}^2 \to \mathbb{R}^3$.
# Before, with a single layer, each component of the function $f$ basically corresponded to
# a hyperplane; now it will instead be a **more complicated nonlinear function** of the
# input data!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 3
#
# Visualize each component of the output separately as a heatmap and/or contours
# superimposed on the data. Interpret the results.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## What we have learned
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Adding an intermediate layer allows the network to start to deform the separating surfaces
# that it is learning into more complicated, nonlinear (curved) shapes. This allows it to
# separate data that were previously unable to be separated!
#
# However, using only two features means that data from different classes overlaps. To
# distinguish it we would need to use more features.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercise 4
#
# Use three features (red, green and blue) and build a network with one hidden layer. Does
# this help to distinguish the data better?
# ------------------------------------------------------------------------------------------
