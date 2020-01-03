# ------------------------------------------------------------------------------------------
# # Julia for Data Science
#
# * Data
# * **Data processing**
# * Visualization
#
# ### Data processing: Standard machine learning algorithms in Julia
# In what's next, we will see how to use some of the standard machine learning algorithms
# implemented in Julia.
# ------------------------------------------------------------------------------------------

using DataFrames, Statistics

# ------------------------------------------------------------------------------------------
# ### Example 1: Kmeans Clustering
#
# Let's start with some data.
#
# The Sacramento real estate transactions file that we download next is a list of 985 real
# estate transactions in the Sacramento area reported over a five-day period,
# ------------------------------------------------------------------------------------------

download("http://samplecsvs.s3.amazonaws.com/Sacramentorealestatetransactions.csv","houses.csv")
houses = readtable("houses.csv")

# ------------------------------------------------------------------------------------------
# Let's use [`Plots.jl`](https://github.com/JuliaPlots/Plots.jl) to plot with the `pyplot`
# backend. (NOTE: this can take a long time the first time you run it, when it's
# initializing the package.)
# ------------------------------------------------------------------------------------------

using Plots
pyplot()
plot(size=(500,500),leg=false)

# ------------------------------------------------------------------------------------------
# Now let's create a scatter plot to show the price of a house vs. its square footage,
# ------------------------------------------------------------------------------------------

x = houses[!, :sq__ft]
# x = houses[7] # equivalent, useful if file has no header
y = houses[!, :price]
# y = houses[10] # equivalent
scatter(x,y,markersize=3)

# ------------------------------------------------------------------------------------------
# *Houses with 0 square feet that cost money?*
#
# The square footage seems to not have been recorded in these cases.
#
# Filtering these houses out is easy to do!
# ------------------------------------------------------------------------------------------

filter_houses = houses[houses[!, :sq__ft] .> 0, :]  # dot broadcasting
x = filter_houses[!, :sq__ft]
y = filter_houses[!, :price]
scatter(x,y)

# ------------------------------------------------------------------------------------------
# This makes sense! The higher the square footage, the higher the price.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We can filter a `DataFrame` by feature value too, using the `by` function.
# The `mean()` function comes from the `Statistics` module in the standard library, which we
# get from running `using Statistics` at the top of this file.
# ------------------------------------------------------------------------------------------

by(filter_houses,:type,size)

by(filter_houses,:type,filter_houses->mean(filter_houses[!, :price]))

# ------------------------------------------------------------------------------------------
# Now let's do some kmeans clustering on this data.
#
# First, we can load the `Clustering` package to do this.
# ------------------------------------------------------------------------------------------

#Pkg.add("Clustering")
using Clustering

# ------------------------------------------------------------------------------------------
# Let us see how `Clustering` works with a generic example first.
# ------------------------------------------------------------------------------------------

# make a random dataset with 1000 points
# each point is a 5-dimensional vector
J = rand(5, 1000)
R = kmeans(J, 20; maxiter=200, display=:iter) 
# performs K-means over X, trying to group them into 20 clusters
# set maximum number of iterations to 200
# set display to :iter, so it shows progressive info at each iteration

# ------------------------------------------------------------------------------------------
# Now, let's get back to the problem in hand and see how this can be applied over there.
#
# Let's store the features `:latitude` and `:longitude` in an array `X` that we will pass to
# `kmeans`.
#
# First we add data for `:latitude` and `:longitude` to a new `DataFrame` called `X`.
# ------------------------------------------------------------------------------------------

X = filter_houses[!, [:latitude,:longitude]]

# ------------------------------------------------------------------------------------------
# and then we convert `X` to an `Array` via
#
# ```julia
# X = Array(X)
# ```
# or
# ```julia
# X = convert(Array, X)
# ```
#
# Since we know this array has no missing values, we can also change the output type of the
# array to just Float64s, which we'll need for Clustering below:
#
# ```julia
# X = Array{Float64}(X)
# ```
# or
# ```julia
# X = convert(Array{Float64}, X)
# ```
# to turn `X` into an `Array` that stores `Float64`s.
# ------------------------------------------------------------------------------------------

X = Array{Float64}(X)

# ------------------------------------------------------------------------------------------
# We now take the transpose of `X` using the `transpose()` function. A transpose is required
# since `kmeans()` function takes each row as a `feature`, and each column a `data point`.
# ------------------------------------------------------------------------------------------

X = transpose(X)
#X = X'  # (conjugate transposition) also does the same thing (but only for real-valued arrays).
X

# ------------------------------------------------------------------------------------------
# As a first pass at guessing how many clusters we might need, let's use the number of zip
# codes in our data.
#
# (Try changing this to see how it impacts results!)
# ------------------------------------------------------------------------------------------

k = length(unique(filter_houses[!, :zip]))
# there should be atleast 2 distinct features (k>=2) to group the data points
println("unique zip codes are ",k)

# ------------------------------------------------------------------------------------------
# We can use the `kmeans` function to do kmeans clustering!
# ------------------------------------------------------------------------------------------

using Clustering
C = kmeans(X, k) # try changing k

# ------------------------------------------------------------------------------------------
# Now let's create a new data frame, `df`, with all the same data as `filter_houses` that
# also includes a column for the cluster to which each house has been assigned.
# ------------------------------------------------------------------------------------------

df = DataFrame(cluster=C.assignments, city=filter_houses[!, :city],
    latitude=filter_houses[!, :latitude], longitude=filter_houses[!, :longitude], zip=filter_houses[!, :zip])

# ------------------------------------------------------------------------------------------
# Let's plot each cluster as a different color.
# ------------------------------------------------------------------------------------------

clusters_figure = plot()
for i = 1:k
    clustered_houses = df[df[!, :cluster].== i,:]
    xvals = clustered_houses[!, :latitude]
    yvals = clustered_houses[!, :longitude]
    scatter!(clusters_figure,xvals,yvals,markersize=4)
end
xlabel!("Latitude")
ylabel!("Longitude")
title!("Houses color-coded by cluster")
display(clusters_figure)

# ------------------------------------------------------------------------------------------
# And now let's try coloring them by zip code.
# ------------------------------------------------------------------------------------------

unique_zips = unique(filter_houses[!, :zip])
zips_figure = plot()
for uzip in unique_zips
    subs = filter_houses[filter_houses[!, :zip].==uzip,:]
    x = subs[!, :latitude]
    y = subs[!, :longitude]
    scatter!(zips_figure,x,y)
end
xlabel!("Latitude")
ylabel!("Longitude")
title!("Houses color-coded by zip code")
display(zips_figure)

# ------------------------------------------------------------------------------------------
# Let's see the two plots side by side.
# ------------------------------------------------------------------------------------------

plot(clusters_figure,zips_figure,layout=(2, 1))

# ------------------------------------------------------------------------------------------
# Not exactly! but almost... Now we know that ZIP codes are not randomly assigned!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Example 2: Nearest Neighbor with a KDTree
#
# For this example, let's start by loading the `NearestNeighbors` package.
# ------------------------------------------------------------------------------------------

using NearestNeighbors

# ------------------------------------------------------------------------------------------
# With this package, we'll look for the `knearest` neighbors of one of the houses, `point`.
# ------------------------------------------------------------------------------------------

knearest = 10
id = 70 # try changing this
point = X[:,id]

# ------------------------------------------------------------------------------------------
# Now we can build a `KDTree` and use `knn` to look for `point`'s nearest neighbors!
# ------------------------------------------------------------------------------------------

kdtree = KDTree(X)
idxs, dists = knn(kdtree, point, knearest, true)

# ------------------------------------------------------------------------------------------
# We'll first generate a plot with all of the houses in the same color,
# ------------------------------------------------------------------------------------------

x = filter_houses[!, :latitude];
y = filter_houses[!, :longitude];
scatter(x,y);

# ------------------------------------------------------------------------------------------
# and then overlay the data corresponding to the nearest neighbors of `point` in a different
# color.
# ------------------------------------------------------------------------------------------

x = filter_houses[idxs,:latitude];
y = filter_houses[idxs,:longitude];
scatter!(x,y)

# ------------------------------------------------------------------------------------------
# There are those nearest neighbors in red!
#
# We can see the cities of the neighboring houses by using the indices, `idxs`, and the
# feature, `:city`, to index into the `DataFrame` `filter_houses`.
# ------------------------------------------------------------------------------------------

cities = filter_houses[idxs,:city]

# ------------------------------------------------------------------------------------------
# ### Example 3: PCA for dimensionality reduction
#
# Let us try to reduce the dimensions of the price/area data from the houses dataset.
#
# We can start by grabbing the square footage and prices of the houses and storing them in
# an `Array`.
# ------------------------------------------------------------------------------------------

F = filter_houses[!, [:sq__ft,:price]]
F = convert(Array{Float64,2},F)'

# ------------------------------------------------------------------------------------------
# Recall how the data looks when we plot housing prices against square footage.
# ------------------------------------------------------------------------------------------

scatter(F[1,:],F[2,:])
xlabel!("Square footage")
ylabel!("Housing prices")

# ------------------------------------------------------------------------------------------
# We can use the `MultivariateStats` package to run PCA
# ------------------------------------------------------------------------------------------

# Pkg.add("MultivariateStats")
using MultivariateStats

# ------------------------------------------------------------------------------------------
# Use `fit` to fit the model
# ------------------------------------------------------------------------------------------

M = fit(PCA, F)

# ------------------------------------------------------------------------------------------
# Note that you can choose the maximum dimension of the new space by setting `maxoutdim`,
# and you can change the method to, for example, `:svd` with the following syntax.
#
# ```julia
# fit(PCA, F; maxoutdim = 1,method=:svd)
# ```
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# It seems like we only get one dimension with PCA! Let's use `transform` to map all of our
# 2D data in `F` to `1D` data with our model, `M`.
# ------------------------------------------------------------------------------------------

y = transform(M, F)

# ------------------------------------------------------------------------------------------
# Let's use `reconstruct` to put our now 1D data, `y`, in a form that we can easily overlay
# (`Xr`) with our 2D data in `F` along the principle direction/component.
# ------------------------------------------------------------------------------------------

Xr = reconstruct(M, y)

# ------------------------------------------------------------------------------------------
# And now we create that overlay, where we can see points along the principle component in
# red.
#
# (Each blue point maps uniquely to some red point!)
# ------------------------------------------------------------------------------------------

scatter(F[1,:],F[2,:])
scatter!(Xr[1,:],Xr[2,:])

# ------------------------------------------------------------------------------------------
# ### Example 4: Learn how to build a simple multi-layer-perceptron on the MNIST dataset
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

methodswith(typeof(ps))

# ------------------------------------------------------------------------------------------
# Use `X` to create our training data and then declare our evaluation function:
# ------------------------------------------------------------------------------------------

datasetx = repeated((X, Y), 200)
evalcb = () -> @show(loss(X, Y))
ps = Flux.params(m)

# ------------------------------------------------------------------------------------------
# So far, we have defined our training data and our evaluation functions.
#
# Let's take a look at the function signature of Flux.train!
# ------------------------------------------------------------------------------------------

?Flux.train!

# ------------------------------------------------------------------------------------------
# **Now we can train our model and look at the accuracy thereafter.**
# ------------------------------------------------------------------------------------------

opt = ADAM()
Flux.train!(loss, ps, datasetx, opt, cb = throttle(evalcb, 10))

accuracy(X, Y)

# ------------------------------------------------------------------------------------------
# Now that we've trained our model, let's create test data, `tX`,
# ------------------------------------------------------------------------------------------

tX = hcat(float.(reshape.(MNIST.images(:test), :))...)

# ------------------------------------------------------------------------------------------
# and run our model on one of the images from `tX`
# ------------------------------------------------------------------------------------------

test_image = m(tX[:,1])

argmax(test_image) - 1

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

# ------------------------------------------------------------------------------------------
# ### Example 5: Linear regression in Julia (we will write our own Julia code and Python
# code)
#
# Let's try to find the best line fit of the following data:
# ------------------------------------------------------------------------------------------

xvals = repeat(1:0.5:10, inner=2)
yvals = 3 .+ xvals .+ 2 .* rand(length(xvals)) .-1
scatter(xvals, yvals, color=:black, leg=false)

# ------------------------------------------------------------------------------------------
# We want to fit a line through this data.
#
# Let's write a Julia function to do this.
# ------------------------------------------------------------------------------------------

function find_best_fit(xvals,yvals)
    meanx = mean(xvals)
    meany = mean(yvals)
    stdx = std(xvals)
    stdy = std(yvals)
    r = cor(xvals,yvals)
    a = r*stdy/stdx
    b = meany - a*meanx
    return a,b
end

# ------------------------------------------------------------------------------------------
# To fit the line, we just need to find the slope and the y-intercept (a and b).
#
# Then add this fit to the existing plot!
# ------------------------------------------------------------------------------------------

a,b = find_best_fit(xvals,yvals)
ynew = a .* xvals .+ b

plot!(xvals,ynew)

# ------------------------------------------------------------------------------------------
# Let's generate a much bigger dataset,
# ------------------------------------------------------------------------------------------

xvals = 1:100000;
xvals = repeat(xvals,inner=3);
yvals = 3 .+ xvals .+ 2 .* rand(length(xvals)) .- 1;

@show size(xvals)
@show size(yvals)

# ------------------------------------------------------------------------------------------
# and now we can time how long it takes to find a fit to this data.
# ------------------------------------------------------------------------------------------

@time a,b = find_best_fit(xvals,yvals)

# ------------------------------------------------------------------------------------------
# Now we will write the same code using Python
# ------------------------------------------------------------------------------------------

using PyCall
using Conda

py"""
import numpy
def find_best_fit_python(xvals,yvals):
    meanx = numpy.mean(xvals)
    meany = numpy.mean(yvals)
    stdx = numpy.std(xvals)
    stdy = numpy.std(yvals)
    r = numpy.corrcoef(xvals,yvals)[0][1]
    a = r*stdy/stdx
    b = meany - a*meanx
    return a,b
"""

find_best_fit_python = py"find_best_fit_python"

xpy = PyObject(xvals)
ypy = PyObject(yvals)
@time a,b = find_best_fit_python(xpy,ypy)

# ------------------------------------------------------------------------------------------
# **Let's use the benchmarking package to time these two.**
# ------------------------------------------------------------------------------------------

using BenchmarkTools

@btime a,b = find_best_fit_python(xvals,yvals)

@btime a,b = find_best_fit(xvals,yvals)


