# ------------------------------------------------------------------------------------------
# ## Neural networks
#
# Now that we know what neurons are, we are ready for the final step: the neural network!. A
# neural network is literally made out of a network of neurons that are connected together.
#
# So far, we have just looked at single neurons, that only have a single output.
# What if we want multiple outputs?
#
#
# ### Multiple output models
#
# What if we wanted to distinguish between apples, bananas, *and* grapes? We could use
# *vectors* of `0` or `1` values to symbolize each output.
#
# <img src="data/fruit-salad.png" alt="Drawing" style="width: 300px;"/>
#
# The idea of using vectors is that different directions in the space of outputs encode
# information about different types of inputs.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Now we extend our previous model to give multiple outputs by repeating it with different
# weights. For the first element of the array we'd use:
#
# $$\sigma(x;w^{(1)},b^{(1)}) := \frac{1}{1 + \exp(-w^{(1)} \cdot x + b^{(1)})};$$
#
# then for the second we'd use
#
# $$\sigma(x;w^{(2)},b^{(2)}) := \frac{1}{1 + \exp(-w^{(2)} \cdot x + b^{(2)})};$$
#
# and if you wanted $n$ outputs, you'd have for each one
#
# $$\sigma(x;w^{(i)},b^{(i)}) := \frac{1}{1 + \exp(-w^{(i)} \cdot x + b^{(i)})}.$$
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Notice that these equations are all the same, except for the parameters, so we can write
# this model more succinctly, as follows. Let's write $b$ in an array:
#
# $$b=\left[\begin{array}{c}
# b_{1}\\
# b_{2}\\
# \vdots\\
# b_{n}
# \end{array}\right]$$
#
# and put our array of weights as a matrix:
#
# $$ \mathsf{W}=\left[\begin{array}{c}
# \\
# \\
# \\
# \\
# \end{array}\begin{array}{cccc}
# w_{1}^{(1)} & w_{2}^{(1)} & \ldots & w_{n}^{(1)}\\
# w_{1}^{(2)} & w_{2}^{(2)} & \ldots & w_{n}^{(2)}\\
# \vdots & \vdots &  & \vdots\\
# w_{1}^{(n)} & w_{2}^{(n)} & \ldots & w_{n}^{(n)}
# \end{array}\right]
# $$
#
# We can write this all in one line as:
#
# $$\sigma(x;w,b)= \left[\begin{array}{c}
# \sigma^{(1)}\\
# \sigma^{(2)}\\
# \vdots\\
# \sigma^{(n)}
# \end{array}\right] = \frac{1}{1 + \exp(-\mathsf{W} x + b)}$$
#
# $\mathsf{W} x$ is the operation called "matrix multiplication"
#
# [Show small matrix multiplication]
#
# It takes each column of weights and does the dot product against $x$ (remember, that's how
# $\sigma^{(i)}$ was defined) and spits out a vector from doing that with each column. The
# result is a vector, which makes this version of the function give a vector of outputs
# which we can use to encode larger set of choices.
#
# Matrix multiplication is also interesting since **GPUs (Graphics Processing Units, i.e.
# graphics cards) are basically just matrix multiplication machines**, which means that by
# writing the equation this way, the result can be calculated really fast.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# This "multiple input and multiple output" version of the sigmoid function is known as a
# *layer of neurons*.
#
# Previously we worked with a single neuron, which we visualized as
#
# <img src="data/single-neuron.png" alt="Drawing" style="width: 300px;"/>
#
# where we have two pieces of data (green) coming into a single neuron (pink) that returned
# a single output. We could use this single output to do binary classification - to identify
# an image of a fruit as `1`, meaning banana or as `0`, meaning not a banana (or an apple).
#
# To do non-binary classification, we can use a layer of neurons, which we can visualize as
#
# <img src="data/single-layer.png" alt="Drawing" style="width: 300px;"/>
#
# We now have stacked a bunch of neurons on top of each other to hopefully work together and
# train to output results of more complicated features.
#
# We still have two input pieces of data, but now have several neurons, each of which
# produces an output for a given binary classification:
# * neuron 1: "is it an apple?"
# * neuron 2: "is it a banana?"
# * neuron 3: "is it a grape?"
# ------------------------------------------------------------------------------------------
