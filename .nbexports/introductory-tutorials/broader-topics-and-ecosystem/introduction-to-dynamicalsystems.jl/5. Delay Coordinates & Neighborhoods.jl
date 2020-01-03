# ------------------------------------------------------------------------------------------
# # Delay Coordinates & Neighborhoods
#
#
# Topics:
# * Delay coordinates & why they ROCK!
# * A `Reconstruction` is a subtype of `AbstractDataset`
# * Estimating Parameters for `Reconstruction`s
# * Multiple-time, multiple timeseries `Reconstruction`s
# * Finding neighborhoods of points in a `Dataset`
# * Excluding temporal neighbors
#
# ---
#
# # Delay Coordinates Reconstruction
# Let's say you have a "real-world system" which you measure in an experimental set-up. You
# are assuming that the system is composed of several dynamic variables, but you can only
# measure one of them (or some function of the variable).
#
# You have a severe lack of recorded information for the system. What do you do?
# 1. Give up on science, it is a complete waste of time.
# 2. Use [Taken's theorem](https://en.wikipedia.org/wiki/Takens%27s_theorem), which is
# indistinguishable from magic.
#
# **DynamicalSystems.jl** suggests the third approach.
#
# From a timeseries $s$ one can *reconstruct* a state-space $\mathbf{z}$ simply by shifting
# $s$ in time, like
#
#   $$\mathbf{z}(n) = (s(n), s(n+\tau), s(n+2\tau), \dots, s(n+(D-1)\tau))$$
#
# This is done with the `Reconstruction(s, D, τ)` function
# ------------------------------------------------------------------------------------------

using DynamicalSystems

s = rand(100000)
D = 3 # reconstruction dimension
τ = 4 # reconstruction delay
R = Reconstruction(s, D, τ)

# ------------------------------------------------------------------------------------------
# ---
#
# Here are some nice examples of `Reconstruction`s of a 3D continuous chaotic system, using
# each of the variables of the system, different delay times and dimension of `2`:
# ------------------------------------------------------------------------------------------

using DynamicalSystems, PyPlot

ds = Systems.gissinger(ones(3)) # 3D continuous chaotic system, also shown in orbit diagrams tutorial
dt = 0.05
data = trajectory(ds, 1000.0, dt = dt)

xyz = columns(data)

figure(figsize = (12,10))
k = 1
for i in 1:3
    for τ in [5, 30, 100]
        R = Reconstruction(xyz[i], 2, τ)
        ax = subplot(3,3,k)
        plot(R[:, 1], R[:, 2], color = "C$(k-1)", lw = 0.8)
        title("var = $i, τ = $τ")
        k+=1
    end
end

tight_layout()
suptitle("2D Reconstructions")
subplots_adjust(top=0.9);

# ------------------------------------------------------------------------------------------
# How does this compare to the "real" two-dimensional representation of the system?
# ------------------------------------------------------------------------------------------

figure(figsize=(6,4))
plot(data[:, 2], data[:, 3], lw=1.0);

# ------------------------------------------------------------------------------------------
# ---
#
# # `Reconstruction <: AbstractDataset`
# A `Reconstruction` instance can be passed around and used exactly like a `Dataset`!
#
# Let's look at a `Reconstruction` of data from a gissinger system's trajectory above
# ------------------------------------------------------------------------------------------

R = Reconstruction(data[:, 1], 2, 30)
R[31:end, 1] == R[1:end-30, 2]

a = 0.0
for point ∈ R
    a += mean(point)
end
a/length(R)

# ------------------------------------------------------------------------------------------
# **Taken's theorem says that some quantities remain invariant under a reconstruction**
#
# We'll show this using a `Reconstruction` with the 3rd dimension of `data`.
#
# (D = 2 is not best for this system. D = 3 is better!)
# ------------------------------------------------------------------------------------------

R = Reconstruction(data[:, 1], 3, 30)

# ------------------------------------------------------------------------------------------
# Let's compare the information dimension of the `Reconstruction`
# ------------------------------------------------------------------------------------------

I1 = information_dim(R)

# ------------------------------------------------------------------------------------------
# and the information dimension of the attractor directly
# ------------------------------------------------------------------------------------------

I2 = information_dim(data)

println("|Reconstructed - original| dimension: $(abs(I1 - I2))")

# ------------------------------------------------------------------------------------------
# # Estimating Reconstruction Parameters
#
# It is important to understand that even though Taken's theorem is 99% magic, it is **not**
# 100%. One still has to choose "appropriately good" values for both the delay time as well
# as the reconstruction dimension! Thankfully, **DynamicalSystems.jl** has some support for
# that as well!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# * `estimate_delay` estimates delay time `τ` using the autocorrelation of the signal
# * `estimate_dimension` returns an estimator of the embedding dimension `D` using Cao's
# method
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Multiple-time, multiple-timeseries Reconstructions
#
# The `Reconstruction` we have seen so far is just a "Vanilla version"...
#
# One can also perform:
#
# 1. Reconstructions with multiple delay times, which tries to capture the effect of
# multiple timescales existing in a system.
# 2. Reconstructions with multiple timeseries.
# 3. Reconstructions with multiple timeseries *and* multiple delay times!
#
# See the documentation string of `Reconstruction` for more!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Neighborhoods
#
# A "neighborhood" is a collection of points that is near a given point. `Dataset`s
# interface the module
# [`NearestNeighbors`](https://github.com/KristofferC/NearestNeighbors.jl) in order to find
# this neighborhood.
#
# We use the function `neighborhood`. The call signature is:
# ```julia
# neighborhood(point, tree, ntype)
# ```
# 
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# `point` is simply the query point. `tree` is the structure required by
# [`NearestNeighbors`](https://github.com/KristofferC/NearestNeighbors.jl), and is obtained
# simply by:
# ------------------------------------------------------------------------------------------

dataset = Dataset(rand(1000,3))
tree = KDTree(dataset)

# ------------------------------------------------------------------------------------------
# The third argument to `neighborhood` is the *type* of the neighborhood.
#
# * There are two types of neighborhoods!
#
# The first one is defined as the `k` nearest points to a given point. It is represented in
# code by:
# ------------------------------------------------------------------------------------------

mybuddies = FixedMassNeighborhood(3)

# ------------------------------------------------------------------------------------------
# *For experts: for a `FixedMassNeighborhood` a KNN search is done*
# ------------------------------------------------------------------------------------------

point = ones(3)
n = neighborhood(point, tree, mybuddies)

# ------------------------------------------------------------------------------------------
# Notice that the `neighborhood` function does not return the points themselves, but rather
# the indices of the points in the original data:
# ------------------------------------------------------------------------------------------

println("Fixed mass neighborhood of $(point) is:")

for i in n
    println(dataset[i])
end

# ------------------------------------------------------------------------------------------
# ---
#
# The second type of neighborhood contains all the points that are within some given
# distance `ε` from the query.
#
# In code, we represent this as:
# ------------------------------------------------------------------------------------------

where_u_at = FixedSizeNeighborhood(0.001)

# ------------------------------------------------------------------------------------------
#  *For experts: for `FixedSizeNeighborhood` an inrange search is done*
# ------------------------------------------------------------------------------------------

n2 = neighborhood(point, tree, where_u_at)

plz_come_closer = FixedSizeNeighborhood(0.2)
n2 = neighborhood(point, tree, plz_come_closer)

println("Fixed size neighborhood of $(point) is:")

for i in n2
    println(dataset[i])
end

# ------------------------------------------------------------------------------------------
# Okay, so points that have distance < ε are accepted as a neighborhood.
#
# How do we define the "distance" though? When defining a `tree`, you can optionally give a
# distance function. By default Euclidean distance is used, but others also work. For
# example, we can use the `Distances` package to get distance functions,
# ------------------------------------------------------------------------------------------

using Distances

# ------------------------------------------------------------------------------------------
# and define the distance as the `Distances`'s `Chebyshev` distance:
# ------------------------------------------------------------------------------------------

funky_tree = KDTree(dataset, Chebyshev())

n3 = neighborhood(point, funky_tree, plz_come_closer)

# ------------------------------------------------------------------------------------------
# # Excluding temporal neighbors
#
# Before moving on, let's see one last thing.
#
# In this example, the point I want the neighborhood of is now part of my dataset:
# ------------------------------------------------------------------------------------------

point = dataset[end]

# ------------------------------------------------------------------------------------------
# Let's calculate again the two neighborhoods
# ------------------------------------------------------------------------------------------

tree = KDTree(dataset)

# ------------------------------------------------------------------------------------------
# We'll find suuuuuuuper close neighbors with a **very** small $\epsilon$:
# ------------------------------------------------------------------------------------------

ε = 0.000001
where_u_at = FixedSizeNeighborhood(ε)
n2 = neighborhood(point, tree, where_u_at)

# ------------------------------------------------------------------------------------------
# and now we can find the nearest neighbor:
# ------------------------------------------------------------------------------------------

my_best_friend = FixedMassNeighborhood(1)
n3 = neighborhood(point, tree, my_best_friend)

println(n2)
println(n3)

length(dataset) == n2[1] == n3[1]

# ------------------------------------------------------------------------------------------
# **What is happening here is that the `neighborhood` also counted the `point` itself, since
# it is also part of the dataset.**
#
# * Almost always this behavior needs to be avoided. For this reason, there is a second
# method for `neighborhood`:
#
# ```julia
# neighborhood(point, tree, ntype, idx::Int, w::Int = 1)
# ```
#
# In this case, `idx` is the index of the point in the original data. `w` stands for the
# Theiler window (positive integer).
#
# Only points that have index
# `abs(i - idx) ≥ w` are returned as a neighborhood, to exclude close temporal neighbors.
#
# * The default `w=1` is the case of excluding the `point` itself.
#
# ---
#
# Let's revisit the last example (using the default value of `w = 1`):
# ------------------------------------------------------------------------------------------

point = dataset[end]
idx = length(dataset)

n2 = neighborhood(point, tree, where_u_at, idx)
n3 = neighborhood(point, tree, my_best_friend, idx)

println(n2)
println(n3)

# ------------------------------------------------------------------------------------------
# As you can see, there isn't *any* neighbor of `point` with distance `< 0.000001` in this
# dataset, but there is always a nearest neighbor:
# ------------------------------------------------------------------------------------------

println(dataset[n3[1]], " is the nearest neighbor of ", point)

# ------------------------------------------------------------------------------------------
# # Docstrings
# ------------------------------------------------------------------------------------------

?Reconstruction

?neighborhood

?AbstractNeighborhood
