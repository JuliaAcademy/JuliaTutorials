# ------------------------------------------------------------------------------------------
# ## Learn how to build a simple multi-layer-perceptron on the MNIST dataset
#
# MNIST from: https://github.com/FluxML/model-zoo/blob/master/mnist/mlp.jl
#
# Let's start by loading `Flux`, importing a few things from `Flux` explicitly, and bringing
# the `repeated` function into our scope.
# ------------------------------------------------------------------------------------------

using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle
using Base.Iterators: repeated

# ------------------------------------------------------------------------------------------
# We can now store all the MNIST images in `imgs` and take a peak into this vector to see
# what the data looks like
# ------------------------------------------------------------------------------------------

imgs = MNIST.images()
imgs[3]

# ------------------------------------------------------------------------------------------
# Let's look at the type of an individual image.
# ------------------------------------------------------------------------------------------

typeof(imgs[3])

# ------------------------------------------------------------------------------------------
# #### Reorganizing our array of images
#
# We see this is a 2D array that stores `ColorTypes`. To work more easily with this data,
# let's convert all `ColorTypes` to floating point numbers.
# ------------------------------------------------------------------------------------------

fpt_imgs = float.(imgs)

# ------------------------------------------------------------------------------------------
# Now we can see what `imgs[3]` looks like as an array of floats, rather than as an array of
# colors!
# ------------------------------------------------------------------------------------------

fpt_imgs[3]

# ------------------------------------------------------------------------------------------
# **Let's stack the images to create one large 2D array, `X`, that stores the data for each
# image as a column.**
#
# To do this, we can **first** use `reshape` to unravel each image, creating a 1D array
# (`Vector`) of floats from a 2D array (`Matrix`) of floats.
# ------------------------------------------------------------------------------------------

unraveled_fpt_imgs = reshape.(fpt_imgs, :);
typeof(unraveled_fpt_imgs)

# ------------------------------------------------------------------------------------------
# (Note that `Vector` is an alias for a 1D `Array`.)
# ------------------------------------------------------------------------------------------

Vector

# ------------------------------------------------------------------------------------------
# This makes `unraveled_fpt_imgs` a `Vector` of `Vector`s where `imgs[3]` is now
# ------------------------------------------------------------------------------------------

unraveled_fpt_imgs[3]

# ------------------------------------------------------------------------------------------
# After using `reshape` to get a `Vector` of `Vector`s, we can use `hcat` to build a
# `Matrix`, `X`, from `unraveled_fpt_imgs` where the `Vector`s stored in
# `unraveled_fpt_imgs` will become the columns of `X`.
#
# Note that we're using the "splat" command below, `...`, which allows you to pass all the
# elements of an object to a function, rather than just passing the object itself.
# ------------------------------------------------------------------------------------------

X = hcat(unraveled_fpt_imgs...)

# ------------------------------------------------------------------------------------------
# #### How to go back to images from this 2D `Array`
#
# So now each column in X is an image reshaped to a vector of floating points. Let's pick
# one column and see what the digit is.
#
# Let's try to view the second image in the original array, `imgs`, by taking the second
# column of `X`
# ------------------------------------------------------------------------------------------

onefigure = X[:,2]

# ------------------------------------------------------------------------------------------
# We'll `reshape` this array to a 2D, 28x28 array,
# ------------------------------------------------------------------------------------------

t1 = reshape(onefigure,28,28)

# ------------------------------------------------------------------------------------------
# and finally use `colorview` from the `Images` package to view the handwritten digit.
# ------------------------------------------------------------------------------------------

using Images

colorview(Gray, t1)

# ------------------------------------------------------------------------------------------
# *Our data is in working order!*
#
# For our machine to learn the digit with which each image is associated, we'll need to
# train it using correct answers. Therefore we'll make use of the `labels` associated with
# these images from MNIST.
# ------------------------------------------------------------------------------------------

labels = MNIST.labels() # the true labels

# ------------------------------------------------------------------------------------------
# One-hot-encode the labels with `onehotbatch`
# ------------------------------------------------------------------------------------------

Y = onehotbatch(labels, 0:9)

# ------------------------------------------------------------------------------------------
# which gives a binary indicator vector for each figure
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Build the network
# ------------------------------------------------------------------------------------------

m = Chain(
  Dense(28^2, 32, relu),
  Dense(32, 10),
  softmax)

# ------------------------------------------------------------------------------------------
# Define the loss functions and accuracy
# ------------------------------------------------------------------------------------------

loss(x, y) = Flux.crossentropy(m(x), y)
accuracy(x, y) = mean(argmax(m(x)) .== argmax(y))

# ------------------------------------------------------------------------------------------
# Use `X` to create our training data and then declare our evaluation function:
# ------------------------------------------------------------------------------------------

dataset = repeated((X, Y), 200)
evalcb = () -> @show(loss(X, Y))
opt = ADAM(Flux.params(m))

# ------------------------------------------------------------------------------------------
# So far, we have defined our training data and our evaluation functions.
#
# Let's take a look at the function signature of Flux.train!
# ------------------------------------------------------------------------------------------

?Flux.train!

# ------------------------------------------------------------------------------------------
# **Now we can train our model and look at the accuracy thereafter.**
# ------------------------------------------------------------------------------------------

Flux.train!(loss, dataset, opt, cb = throttle(evalcb, 10))

accuracy(X, Y)

# ------------------------------------------------------------------------------------------
# Now that we've trained our model, let's create test data, `tX`,
# ------------------------------------------------------------------------------------------

tX = hcat(float.(reshape.(MNIST.images(:test), :))...)

# ------------------------------------------------------------------------------------------
# and run our model on one of the images from `tX`
# ------------------------------------------------------------------------------------------

test_image = m(tX[:,1])

indmax(test_image) - 1

# ------------------------------------------------------------------------------------------
# The largest element of `test_image` is the 8th element, so our model says that test_image
# is a "7".
#
# Now we can look at the original image.
# ------------------------------------------------------------------------------------------

using Images
t1 = reshape(tX[:,1],28,28)
colorview(Gray, t1)

# ------------------------------------------------------------------------------------------
# and there we have it!
# ------------------------------------------------------------------------------------------
