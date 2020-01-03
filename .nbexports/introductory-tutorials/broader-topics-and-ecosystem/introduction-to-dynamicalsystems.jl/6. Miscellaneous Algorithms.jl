# ------------------------------------------------------------------------------------------
# # Miscellaneous Algorithms
#
# Topics:
# * Lyapunov exponent from numerical data
# * Broomhead-King coordinates
# * Finding fixed points of any map of any order
# * Detecting chaos with GALI
# * Docstrings
#
#
# *warning: things will get really fast here*
#
# ---
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Lyapunov exponent from numerical data
# It is possible to compute a maximum Lyapunov exponent from numerical data, stored either
# as a `Dataset` or as a `Reconstruction`. This is done with the function:
#
# ```julia
# E = numericallyapunov(R::AbstractDataset, ks; kwargs...)
# ```
# It returns `E = [E(k) for k ∈ ks]`, where `E(k)` is the average logarithmic distance
# between states of a `neighborhood` for `k` steps (`k` must be integer).
#
# **For a more detailed description, please see the [documentation
# page](https://juliadynamics.github.io/DynamicalSystems.jl/latest/chaos/nlts/#numerical-
# lyapunov-exponent).**
#
# 
# ------------------------------------------------------------------------------------------

using DynamicalSystems

# ------------------------------------------------------------------------------------------
# Let's compute the lyapunov exponent for reference and compare our numerically calculated
# lyapunov exponent to it!
# ------------------------------------------------------------------------------------------

ds = Systems.henon()
λ = lyapunov(ds, 100000)

# ------------------------------------------------------------------------------------------
# Below we create a trajectory, produce a `Reconstruction`, and then pass that
# `Reconstruction` to `numericallyapunov`:
# ------------------------------------------------------------------------------------------

data = trajectory(ds, 1000000)
x = data[:, 1] #fake measurements for the win!

R = Reconstruction(x, 2, 2)
ks = 1:20
E = numericallyapunov(R, ks)

# ------------------------------------------------------------------------------------------
# If the data experiences exponential separation of nearby states, then it must hold that
#
# $$
# E(k) \approx \lambda\times(k \Delta \! t ) + E(0)
# $$
#
# where $\Delta \! t$ is the time difference between successive data points (which is 1 for
# discrete systems).
#
# *This means that, $\lambda$, the slope of the plot E vs. k, is our numerically determined
# lyapunov exponent.*
# ------------------------------------------------------------------------------------------

using PyPlot
figure(figsize=(6,4))
plot(ks, E .- E[1])
xlabel("k"); ylabel("E");

# ------------------------------------------------------------------------------------------
# Above we see that the scaling behavior holds very nicely!
#
# We can use linear_regions to compute the slope automatically:
# ------------------------------------------------------------------------------------------

λ_numeric = linear_region(ks, E)[2]

println("λ - λ_numeric = $(abs(λ - λ_numeric))")

# ------------------------------------------------------------------------------------------
# `numericallyapunov` also takes a number of keyword arguments. You can decide:
#
# 1. Which states of the data should be used for reference states (by default *all* states
# are used).
# 2. How this logarithmic distance should be computed.
# 3. What type of `neighborhood` to use: fixed mass or fixed size.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Broomhead-King coordinates
#
# This alternative/improvement of the traditional delay coordinates `Reconstruction` can be
# a very powerful tool. An example where it shines is on noisy data where that noise creates
# the effect of superficial dimensions.
#
# To show this, we'll use `Distributions` to create random numbers.
# ------------------------------------------------------------------------------------------

using Distributions

ds = Systems.gissinger()
data = trajectory(ds, 1000.0, dt = 0.05)
x = data[:, 1]

L = length(x)
distrib = Normal(0, 0.1)
s = x .+ rand(distrib, L)

U, S = broomhead_king(s, 40)

figure(figsize= (10,6))
subplot(1,2,1)
plot(U[:, 1], U[:, 2])
title("Broomhead-King of s")

subplot(1,2,2)
R = Reconstruction(s, 2, 30)
plot(columns(R)...; color = "C3")
title("2D Reconstruction of s")

tight_layout();

# ------------------------------------------------------------------------------------------
# # Finding fixed points of maps
# Finding unstable (or stable) periodic orbits of a discrete mapping analytically rapidly
# becomes impossible for higher orders of fixed points. Fortunately there is an algorithm
# from Schmelcher & Diakonos for doing so numerically.
#
# The function that performs the algorithm is:
# ```julia
# periodicorbits(ds::DiscreteDynamicalSystem, o, ics, args..)
# ```
# where `o` is the order of fixed points to find and `ics` are the initial conditions to
# start searching from.
#
# This function can take a lot extra optional and keyword arguments and thus it is good
# practice to read the [documentation page](https://juliadynamics.github.io/DynamicalSystems
# .jl/latest/chaos/periodicity/#detecting-stable-and-unstable-periodic-orbits-of-maps) on
# it!!!
#
# I will now compute fixed points of order 3 & 4 of the standard map:
# ------------------------------------------------------------------------------------------

ds = Systems.standardmap()

xs = linspace(0, 2π, 21); ys = copy(xs)
ics = [SVector{2}(x,y) for x in xs for y in ys] # initial conditions container

FP3 = periodicorbits(ds, 3, ics) # order 3 periodic points

FP4 = periodicorbits(ds, 4, ics) # order 4 periodic points

figure(figsize = (6,4))

plot([s[1] for s in FP3], [s[2] for s in FP3], marker = "o", color = "C0", ls = "None")
plot([s[1] for s in FP4], [s[2] for s in FP4], marker = "D", color = "C1", ls = "None");

# ------------------------------------------------------------------------------------------
# Weeeeeeell this isn't really helpful as it doesn't show the phase-space of the standard
# map...
#
# Let's start by creating the phasespace plot and then overlaying these points!
# ------------------------------------------------------------------------------------------

iters = 500
dataset = trajectory(ds, iters)
for x in xs
    for y in ys
        append!(dataset, trajectory(ds, iters, SVector{2}(x, y)))
    end
end

# plot phasespace
figure(figsize = (6,4))
plot(dataset[:, 1], dataset[:, 2], ls = "None", ms= 0.8, marker = ".", color = "black", alpha = 0.5)
xlim(xs[1], xs[end])
ylim(ys[1], ys[end])

# plot fixed points
plot([s[1] for s in FP3], [s[2] for s in FP3], marker = "o", color = "C0", ls = "None")
plot([s[1] for s in FP4], [s[2] for s in FP4], marker = "D", color = "C1", ls = "None");

# ------------------------------------------------------------------------------------------
# * The function did **not** find all fixed points of order 3 or 4.
# * This happened because we did not set the other arguments of `periodicorbits`, and
# therefore a random value was chosen for them.
#
# For more, I am pointing you to the [documentation example](https://juliadynamics.github.io
# /DynamicalSystems.jl/latest/chaos/periodicity/#standard-map-example), where the following
# picture is computed:
#
# <img src="standardmap_fp.png" alt="Fixed points of the standard map" style="width: 800px;"
# align="left"/>
# 
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Detecting Chaos using `gali`
# * In (for example) Hamiltonian systems, it is quite often the case that regular orbits
# (i.e. periodic) co-exist with chaotic orbits.
# * Being able to detect and distinguish chaotic from regular behavior is crucial in the
# study of dynamical systems.
# * Lyapunov exponents *can* be used for this task but they are not efficient.
#
# * One of the newest methods to do this is "GALI", generalized alignment index method.
#
# * GALI uses the fact that deviation vectors (that live on tangent space) tend to align for
# chaotic motion, while they stay "not-aligned" for regular motion.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ---
# Here I will only show a simple example of the standard map, which is a system with **mixed
# phase space**.
#
# For *regular* orbits, `gali` stays approximately constant. For *chaotic* orbits, `gali`
# decays exponentially.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We'll initialize with a random chaotic initial condition,
# ------------------------------------------------------------------------------------------

sm = Systems.standardmap(;k = 1.0)

# ------------------------------------------------------------------------------------------
# get a trajectory,
# ------------------------------------------------------------------------------------------

tr = trajectory(sm, 10000)

# ------------------------------------------------------------------------------------------
# and then plot it:
# ------------------------------------------------------------------------------------------

using PyPlot; figure(figsize=(6,4))
plot(tr[:, 1], tr[:, 2], ls = "None", marker = "o", ms = 0.2);

# ------------------------------------------------------------------------------------------
# To compute `gali`, I use the following call signature:
# ```
# gali(ds::DynamicalSystem, tfinal, k::Int; kwargs...) -> g, t
# ```
# where `k` is the order of GALI I want and `tfinal` specifies for how much time to evolve
# the system and the deviation vectors.
#
# Let's compute the gali_2 for this trajectory:
# ------------------------------------------------------------------------------------------

g, t = gali(sm, 1000, 2)
g

# ------------------------------------------------------------------------------------------
# * `g` quickly decays to zero for a chaotic orbit!
# ------------------------------------------------------------------------------------------

# Initialize with random regular initial condition:
sm = Systems.standardmap([π + 0.01*rand(), 0.01*rand()];k = 1.0)
# Get trajectory:
tr = trajectory(sm, 10000)
# Plot it:
using PyPlot; figure(figsize=(4,2))
plot(tr[:, 1], tr[:, 2], ls = "None", marker = "o", ms = 0.2);

# gali with regular initial condition:
g, t = gali(sm, 1000, 2)
g

# ------------------------------------------------------------------------------------------
# * `g` stays constant for a regular orbit!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Docstrings
# ------------------------------------------------------------------------------------------

?numericallyapunov

?broomhead_king

?periodicorbits

?lambdamatrix

?gali
