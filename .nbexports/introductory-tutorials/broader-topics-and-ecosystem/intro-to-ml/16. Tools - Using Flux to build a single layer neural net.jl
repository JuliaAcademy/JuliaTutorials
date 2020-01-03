# ------------------------------------------------------------------------------------------
# # Building a single neural network layer using `Flux.jl`
#
# In this notebook, we'll move beyond binary classification. We'll try to distinguish
# between three fruits now, instead of two. We'll do this using **multiple** neurons
# arranged in a **single layer**.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Read in and process data
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We can start by loading the necessary packages and getting our data into working order
# with similar code we used at the beginning of the previous notebooks, except that now we
# will combine three different apple data sets, and will add in some grapes to the fruit
# salad!
# ------------------------------------------------------------------------------------------

# Load apple data in with `readdlm` for each file
apples1, applecolnames1 = readdlm("data/Apple_Golden_1.dat", '\t', header = true)
apples2, applecolnames2 = readdlm("data/Apple_Golden_2.dat", '\t', header = true)
apples3, applecolnames3 = readdlm("data/Apple_Golden_3.dat", '\t', header = true)

# Check that the column names are the same for each apple file
println( applecolnames1 == applecolnames2 == applecolnames3)

# ------------------------------------------------------------------------------------------
# Since each apple file has columns with the same headers, we know we can concatenate these
# columns from the different files together:
# ------------------------------------------------------------------------------------------

apples = vcat(apples1, apples2, apples3)

# ------------------------------------------------------------------------------------------
# And now let's build an array called `x_apples` that stores data from the `red` and `blue`
# columns of `apples`. From `applecolnames1`, we can see that these are the 3rd and 5th
# columns of `apples`:
# ------------------------------------------------------------------------------------------

applecolnames1[3], applecolnames1[5]

length(apples[:, 1])

x_apples  = [ [apples[i, 3], apples[i, 5]] for i in 1:length(apples[:, 3]) ]

# ------------------------------------------------------------------------------------------
# Similarly, let's create arrays called `x_bananas` and `x_grapes`:
# ------------------------------------------------------------------------------------------

# Load data from *.dat files
bananas, bananacolnames = readdlm("data/Banana.dat", '\t', header = true)
grapes1, grapecolnames1 = readdlm("data/Grape_White.dat", '\t', header = true)
grapes2, grapecolnames2 = readdlm("data/Grape_White_2.dat", '\t', header = true)

# Concatenate data from two grape files together
grapes = vcat(grapes1, grapes2)

# Check that column 3 and column 5 refer to the "red" and "blue" columns from each file
println("All column headers are the same: ", bananacolnames == grapecolnames1 == grapecolnames2 == applecolnames1)

# Build x_bananas and x_grapes from bananas and grapes
x_bananas  = [ [bananas[i, 3], bananas[i, 5]] for i in 1:length(bananas[:, 3]) ]
x_grapes = [ [grapes[i, 3], grapes[i, 5]] for i in 1:length(grapes[:, 3]) ]

# ------------------------------------------------------------------------------------------
# ## One-hot vectors
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Now we wish to classify *three* different types of fruit. It is not clear how to encode
# these three types using a single output variable; indeed, in general this is not possible.
#
# Instead, we have the idea of encoding $n$ output types from the classification into
# *vectors of length $n$*, called "one-hot vectors":
#
# $$
# \textrm{apple} = \begin{pmatrix} 1 \\ 0 \\ 0 \end{pmatrix};
# \quad
# \textrm{banana} = \begin{pmatrix} 0 \\ 1 \\ 0 \end{pmatrix};
# \quad
# \textrm{grape} = \begin{pmatrix} 0 \\ 0 \\ 1 \end{pmatrix}.
# $$
#
# The term "one-hot" refers to the fact that each vector has a single $1$, and is $0$
# otherwise.
#
# Effectively, the first neuron will learn whether or not (1 or 0) the data corresponds to
# an apple, the second whether or not (1 or 0) it corresponds to a banana, etc.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# `Flux.jl` provides an efficient representation for one-hot vectors, using advanced
# features of Julia so that it does not actually store these vectors, which would be a waste
# of memory; instead `Flux` just records in which position the non-zero element is. To us,
# however, it looks like all the information is being stored:
# ------------------------------------------------------------------------------------------

using Flux: onehot

onehot(1, 1:3)

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# Make an array `labels` that gives the labels (1, 2 or 3) of each data point. Then use
# `onehot` to encode the information about the labels as a vector of `OneHotVector`s.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Single layer in Flux
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's suppose that there are two pieces of input data, as in the previous single neuron
# notebook. Then the network has 2 inputs and 3 outputs:
# ------------------------------------------------------------------------------------------

include("draw_neural_net.jl")
draw_network([2, 3])

# ------------------------------------------------------------------------------------------
# `Flux` allows us to express this again in a simple way:
# ------------------------------------------------------------------------------------------

using Flux

model = Dense(2, 3, σ)

# ------------------------------------------------------------------------------------------
# #### Exercise 2
#
# Now what do the weights inside `model` look like? How does this compare to the diagram of
# the network layer above?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Training the model
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Despite the fact that the model is now more complicated than the single neuron from the
# previous notebook, the beauty of `Flux.jl` is that the rest of the training process
# **looks exactly the same**!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 3
#
# Implement training for this model.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 4
#
# Visualize the result of the learning for each neuron. Since each neuron is sigmoidal, we
# can get a good idea of the function by just plotting a single contour level where the
# function takes the value 0.5, using the `contour` function with keyword argument
# `levels=[0.5, 0.501]`.
# ------------------------------------------------------------------------------------------

plot()

contour!(0:0.01:1, 0:0.01:1, (x,y)->model([x,y]).data[1], levels=[0.5, 0.501], color = cgrad([:blue, :blue]))
contour!(0:0.01:1, 0:0.01:1, (x,y)->model([x,y]).data[2], levels=[0.5,0.501], color = cgrad([:green, :green]))
contour!(0:0.01:1, 0:0.01:1, (x,y)->model([x,y]).data[3], levels=[0.5,0.501], color = cgrad([:red, :red]))

scatter!(first.(x_apples), last.(x_apples), m=:cross, label="apples")
scatter!(first.(x_bananas), last.(x_bananas), m=:circle, label="bananas")
scatter!(first.(x_grapes), last.(x_grapes), m=:square, label="grapes")

# ------------------------------------------------------------------------------------------
# #### Exercise 5
#
# Interpret the results by checking which fruit each neuron was supposed to learn and what
# it managed to achieve.
# ------------------------------------------------------------------------------------------
