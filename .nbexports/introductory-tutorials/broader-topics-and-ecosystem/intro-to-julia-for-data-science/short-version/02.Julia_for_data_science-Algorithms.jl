# ------------------------------------------------------------------------------------------
# # Julia for Data Science - Algorithms
#
# ### Data processing
# In what's next, we will see how to use some of the standard algorithms for data analysis
# implemented in Julia. In particular, we'll look at
#
# 1. Kmeans clustering
# 1. Nearest neighbors with a KDTree
# 1. PCA for dimensionality reduction
# ------------------------------------------------------------------------------------------

using DataFrames, Statistics

# ------------------------------------------------------------------------------------------
# We'll be using the same data for all three of these examples -- the Sacramento real estate
# transactions file that we download next. This is a list of 985 real estate transactions in
# the Sacramento area reported over a five-day period.
# ------------------------------------------------------------------------------------------

download("http://samplecsvs.s3.amazonaws.com/Sacramentorealestatetransactions.csv","houses.csv")
houses = readtable("houses.csv")

# ------------------------------------------------------------------------------------------
# Let's use `Plots` to plot with the `pyplot` backend and start familiarizing ourselves with
# this data set!
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
# ------------------------------------------------------------------------------------------

by(filter_houses,:type,size)

by(filter_houses,:type,filter_houses->mean(filter_houses[!, :price]))

# ------------------------------------------------------------------------------------------
# ### Example 1: Kmeans Clustering
#
# Now let's do some kmeans clustering on this data.
#
# First, we can load the `Clustering` package to do this.
# ------------------------------------------------------------------------------------------

#Pkg.add("Clustering")
using Clustering

# ------------------------------------------------------------------------------------------
# Let's store the features `:latitude` and `:longitude` in an array `X` that we will pass to
# `kmeans`.
# ------------------------------------------------------------------------------------------

X = filter_houses[!, [:latitude,:longitude]]
X = Array{Float64}(X)

# ------------------------------------------------------------------------------------------
# Each feature is stored as a row of `X`, but we can transpose to make these features
# columns of `X`.
# ------------------------------------------------------------------------------------------

X = transpose(X)

# ------------------------------------------------------------------------------------------
# Now let's plot longitudes vs. latitudes for this data!
# ------------------------------------------------------------------------------------------

location_figure = scatter(X[1, :], X[2, :])
# Alternatively....
# location_figure = scatter(filter_houses[!, :latitude], filter_houses[!, :longitude])
xlabel!("Latitude")
ylabel!("Longitude")
title!("Houses plotted by location")
display(location_figure)

# ------------------------------------------------------------------------------------------
# We want to identify clusters in the data above. As a first pass at guessing how many
# clusters we might need, let's use the number of zip codes in our data.
#
# (Try changing this to see how it impacts results!)
# ------------------------------------------------------------------------------------------

k = length(unique(filter_houses[!, :zip])) 

# ------------------------------------------------------------------------------------------
# We can use the `kmeans` function to do kmeans clustering!
# ------------------------------------------------------------------------------------------

C = kmeans(X,k) # try changing k

# ------------------------------------------------------------------------------------------
# Now let's create a new data frame, `df`, with all the same data as `filter_houses` that
# also includes a column for the cluster to which each house has been assigned.
# ------------------------------------------------------------------------------------------

df = DataFrame(cluster = C.assignments,city = filter_houses[!,:city],
    latitude = filter_houses[!,:latitude],longitude = filter_houses[!,:longitude],zip = filter_houses[!,:zip])

# ------------------------------------------------------------------------------------------
# Let's plot each cluster as a different color.
# ------------------------------------------------------------------------------------------

clusters_figure = plot()
for i = 1:k
    # filter df to grab all houses in the ith cluster
    clustered_houses = df[df[!,:cluster].== i,:]
    # grab latitudes and longitudes of all houses in the ith cluster
    xvals = clustered_houses[!,:latitude]
    yvals = clustered_houses[!,:longitude]
    # plot latitudes and longitudes of all houses in the ith cluster
    scatter!(clusters_figure,xvals,yvals,markersize=4)
end
xlabel!("Latitude")
ylabel!("Longitude")
title!("Houses color-coded by cluster")
display(clusters_figure)

# ------------------------------------------------------------------------------------------
# And now let's try coloring them by zip code.
# ------------------------------------------------------------------------------------------

unique_zips = unique(filter_houses[!,:zip])
zips_figure = plot()
for uzip in unique_zips
    # filter houses by zipcode
    subs = filter_houses[filter_houses[!,:zip].==uzip,:]
    # grab the latitudes and longitudes of all houses in a given zipcode/subdivision
    x = subs[!, :latitude]
    y = subs[!, :longitude]
    # plot the houses in this zipcode by latitude and longitude!
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

x = filter_houses[!,:latitude];
y = filter_houses[!,:longitude];
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

F = filter_houses[[:sq__ft,:price]]
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
xlabel!("Square footage")
ylabel!("Housing prices")


