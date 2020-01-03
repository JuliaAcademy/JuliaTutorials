# ------------------------------------------------------------------------------------------
# # Entropies & Dimensions
#
#
# Topics:
# * Entropies from **DynamicalSystems.jl**
# * Generalized Dimension
# * Automated dimension estimation!
# * Other related concepts
# * Docstrings
#
# ---
#
# # Generalized Entropy
#
# * In the study of dynamical systems there are many quantities that identify as "entropy".
# * These quantities are not the more commonly known [thermodynamic
# ones](https://en.wikipedia.org/wiki/Entropy), used in Statistical Physics.
# * Rather, they are more like the entropies of [information
# theory](https://en.wikipedia.org/wiki/Entropy_(information_theory), which represent
# information contained within a dataset.
# * In general, the more "uncertain" or "random" the dataset is, the larger its entropy will
# be. On the other hand, the lower the entropy, the more "predictable" the dataset becomes.
#
#
# Let $p$ be an array of probabilities (such that it sums to 1). Then the generalized
# entropy is defined as
#
# $$
# R_\alpha(p) = \frac{1}{1-\alpha}\log\left(\sum_i p[i]^\alpha\right)
# $$
#
# and is also called [Rényi entropy](https://en.wikipedia.org/wiki/R%C3%A9nyi_entropy).
# Other entropies, like e.g. the [Shannon
# entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory) are generalized by it,
# since for $\alpha = 1$, the Rényi entropy becomes the Shannon entropy,
#
# $$
# R_1(p) = -\left(\sum_i p[i] \log (p[i]) \right)
# $$
#
# The Rényi entropy can be computed for a specific dataset, given $p$. But how does one get
# $p$?
# 1. $p$ represents the probability that a point of a dataset falls into a specific "bin".
# 2. It is nothing more than the (normalized) histogram of the dataset!
# ------------------------------------------------------------------------------------------

using DynamicalSystems

# ------------------------------------------------------------------------------------------
# Let's generate a dataset so that we can practice calculating entropies.
# ------------------------------------------------------------------------------------------

N = 100000
randomdata = Dataset(rand(N,3))

# ------------------------------------------------------------------------------------------
# ---
#
# ```julia
# genentropy(α, ε, dataset::AbstractDataset; base = e)
# ```
# * This function calculates the generalized entropy of order `α`.
# * It first calculates the probability array $p$.
# * The "histogram" is created by partitioning the `dataset` into boxes of size `ε`.
# 
# ------------------------------------------------------------------------------------------

genentropy(2, 0.1, randomdata)

genentropy(2, 0.01, randomdata)

genentropy(2, 0.001, randomdata)

genentropy(2, 0.0001, randomdata)

# ------------------------------------------------------------------------------------------
# Note that the output of `genentropy` changed with changing $\varepsilon$ until we hit
# $\varepsilon = 0.001$.
#
# At this point the value for the entropy has already saturated. There's no use in
# partitioning the dataset in smaller boxes.
#
# ---
#
# Now let's calculate the entropy of a coin toss!
#
# First, let's create an array, `y`, that stores the results of coin tosses as `0`s or `1`s
# for `1000000` tosses.
# ------------------------------------------------------------------------------------------

y = Float64.(rand(Bool, 1000000))

sh = genentropy(1, 0.1, y) # Renyi entropy with α = 1 is the Shannon entropy

# ------------------------------------------------------------------------------------------
# The above number should be log(2) [by
# definition](https://en.wikipedia.org/wiki/Shannon_(unit)
# ------------------------------------------------------------------------------------------

isapprox(sh, log(2), rtol = 1e-4)

# ------------------------------------------------------------------------------------------
# `genentropy` is conveniently used with `trajectory` outputs.
#
# Here we create a trajectory for a towel map,
# ------------------------------------------------------------------------------------------

towel = Systems.towel()
tr = trajectory(towel, N-1);
summary(tr)

# ------------------------------------------------------------------------------------------
# and calculate its entropy:
# ------------------------------------------------------------------------------------------

genentropy(1, 0.01, tr) # The result is with log base-e !

# ------------------------------------------------------------------------------------------
# Let's also compare the entropy of the above dataset (a trajectory of the towel map) with
# that of a random dataset:
# ------------------------------------------------------------------------------------------

genentropy(1, 0.01, randomdata)

# ------------------------------------------------------------------------------------------
# * As expected, the entropy of the random dataset is higher.
#
# ---
#
# How much time does the computation take?
# ------------------------------------------------------------------------------------------

using BenchmarkTools
@btime genentropy(1, 0.01, $tr);

# ------------------------------------------------------------------------------------------
# ## Specialized histogram
# * Partitioning the dataset (i.e. generating a "histogram") is in general a costly
# operation that depends exponentially on the number of dimensions.
# * In this specific application however, we can tremendously reduce the memory allocation
# and time spent!
#
# Let's get the array of probabilities $p$ for size ε where `tr` is the trajectory of the
# towel map
# ------------------------------------------------------------------------------------------

ε = 0.01
p = non0hist(ε, tr)

# ------------------------------------------------------------------------------------------
# Here's a sanity check, showing our probabilities should sum to roughly `1`.
# ------------------------------------------------------------------------------------------

sum(p)

# ------------------------------------------------------------------------------------------
# How long does generating the histogram take?
# ------------------------------------------------------------------------------------------

@btime non0hist($ε, $tr);

# ------------------------------------------------------------------------------------------
# How long does this take if we create 9-dimensional data and compare again?
# ------------------------------------------------------------------------------------------

nine = Dataset(rand(N, 9))
@btime non0hist($ε, $nine);

# ------------------------------------------------------------------------------------------
# * We went from dimension 3 to dimension 9 but the time roughly only tripled
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Attractor Dimension
# 1. There are numerous methods that one can use to calculate a so-called "dimension" of a
# dataset, like for example the [Fractal
# dimension](https://en.wikipedia.org/wiki/Fractal_dimension).
#
# 2. Most of the time these dimensions indicate some kind of scaling behavior.
#
# 3. For example, the scaling of `genentropy` with decreasing `ε` gives the so-called
# "generalized dimension".
#
#
# $ E \approx -D\log(\varepsilon)$ with $E$ the entropy and $D$ the "dimension".
#
# ---
# I want to know dimension of attractor of the Towel Map!
#
# 
# ------------------------------------------------------------------------------------------

towel = Systems.towel()
towel_tr = trajectory(towel, 1000000);
summary(towel_tr)

# ------------------------------------------------------------------------------------------
# Note that more points = more precision = more computations = more time!
#
# Now I want to compute `genentropy` for different ε.
#
# Which ε should we use...?
#
# Let's do a "random" logspace based guess...
# ------------------------------------------------------------------------------------------

ες = logspace(-4, 1, 12)

Es = zeros(ες)
for (i, ε) ∈ enumerate(ες)
    Es[i] = genentropy(1, ε, towel_tr)
end
Es

# ------------------------------------------------------------------------------------------
# **Shorter version:**
# ------------------------------------------------------------------------------------------

Es = genentropy.(1, ες, towel_tr)

# ------------------------------------------------------------------------------------------
# Alright. Remember that it should be that $E \approx -D\log(\varepsilon)$
#  with $E$ the entropy and $D$ the "dimension".
#
# Let's plot and see:
# ------------------------------------------------------------------------------------------

using PyPlot; figure(figsize = (6,4))
x = -log.(ες)
plot(x, Es); xlabel("-log(ε)"); ylabel("Entropy");
plot([x[4], x[4]], [0, 15], color = "C1", alpha = 0.5)
plot([x[end-3], x[end-3]], [0, 15], color = "C1", alpha = 0.5);

# ------------------------------------------------------------------------------------------
# What typically happens is that there is some region where this scaling behavior holds, but
# then it stops holding due to the finite amount of data points.
#
# Above, the expected scaling behavior holds between the orange vertical lines.
#
# Let's choose the curve points that do fall in the linear regime of the above plot,
# ------------------------------------------------------------------------------------------

x, y = -log.(ες)[4:end-2], Es[4:end-2]

# ------------------------------------------------------------------------------------------
# and find the slope of the curve there, to calculate the dimension, D.
# ------------------------------------------------------------------------------------------

offset, slope = linreg(x, y)
D = slope

# ------------------------------------------------------------------------------------------
# This is actually a correct result, the information dimension of the attractor of the towel
# map is around 2.
#
# ---
#
# * Are the values of `ες` we used good?
# * For a general dataset, how can we determine them?
#
# the function `estimate_boxsizes(dataset; kwargs...)` can help with that!
# ------------------------------------------------------------------------------------------

ες = estimate_boxsizes(towel_tr)

# ------------------------------------------------------------------------------------------
# Let's plot $E$ vs. $-\log \epsilon$ again
# ------------------------------------------------------------------------------------------

Es = genentropy.(1, ες, towel_tr)
figure(figsize = (6,4))
plot(-log.(ες), Es); xlabel("-log(ε)"); ylabel("E");

# ------------------------------------------------------------------------------------------
# ---
# # Automated Dimension Estimation
#
# Given some arbitrary plot like the one above, is there any algorithm to deduce a scaling
# region???
#
# The function `linear_regions(x, y; kwargs...)` decomposes the function `y(x)` into regions
# where  the function is linear.
#
# It returns the indices of `x` that correspond to linear regions and the approximated
# tangents at each region!
# ------------------------------------------------------------------------------------------

x = -log.(ες)
lrs, slopes = linear_regions(x, Es)

for i in 1:length(slopes)
    println("linear region $(i) starts from index $(lrs[i]) and ends at index $(lrs[i+1])")
    println("with corresponding slope $(slopes[i])")
    println()
end

# ------------------------------------------------------------------------------------------
# The linear region which is biggest is "probably correct one".
# Here the last linear region is the largest; thus the slope is
# ------------------------------------------------------------------------------------------

slopes[end]

# ------------------------------------------------------------------------------------------
# This `linear_regions` function seems very shady... Is there any "easy" way to visualize
# what it does? *Say no more!*
#
# In this next example, we'll use `ChaosTools`, which belows to `DynamicalSystems`.
# ------------------------------------------------------------------------------------------

using PyPlot, ChaosTools

# ------------------------------------------------------------------------------------------
# `ChaosTools` provides a function, `plot_linear_regions` !
# ------------------------------------------------------------------------------------------

figure(figsize=(6,4))
plot_linear_regions(x, Es)
xlabel("-log(ε)"); ylabel("E");

# ------------------------------------------------------------------------------------------
# Adjust the tolerance of `linear_regions` using keyword argument `tol`
# ------------------------------------------------------------------------------------------

figure(figsize=(6,4))
plot_linear_regions(x, Es; tol = 0.8)
xlabel("-log(ε)"); ylabel("E");

# ------------------------------------------------------------------------------------------
# Notice how the color schemes allow us to visualize that adjusting the tolerance reduces
# our number of linear regimes!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## `generalized_dim` function
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's summarize what we just did to estimate the dimension of an attractor.
#
# 1. We decided on some partition sizes `ες` to use (the function `estimate_boxsizes` can
# give an estimate for that).
# 2. For each `ε` in `ες` we calculated the entropy via `genentropy`. We stored these
# entropies in an array `Es`.
# 3. We tried to find a "linear scaling region" of the curve `Es` vs. `-log.(ες)`.
# 4. The slope of this "linear scaling region" is the dimension we estimated.
#
# Wouldn't it be **cool** if all of this process could happen with one function call?
#
# This is *exactly* what the following function does:
# ```julia
# generalized_dim(α, dataset, ες = estimate_boxsizes(tr))
# ```
# which computes the `α`-order generalized dimension.
# ------------------------------------------------------------------------------------------

generalized_dim(2.0, tr)

generalized_dim(1.0, tr)

# ------------------------------------------------------------------------------------------
# The first input to `generalized_dim` is our value for $\alpha$!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Similarly, let's calculate the dimension of the Henon map that we have seen in previous
# tutorials,
# ------------------------------------------------------------------------------------------

hen = Systems.henon()
tr = trajectory(hen, 200000)
generalized_dim(0, tr)

# ------------------------------------------------------------------------------------------
# and of the Lorenz system:
# ------------------------------------------------------------------------------------------

lor = Systems.lorenz()
tr_lor = trajectory(lor, 1000.0; dt = 0.05);

generalized_dim(2.0, tr_lor)

# ------------------------------------------------------------------------------------------
# The correlation dimension of the Lorenz attractor (for default parameters) is reported
# *somewhere* around `2.0` (Grassberger and Procaccia, 1983).
#
# ## `generalized_dim` is but a crude estimate!
#
# **It is important to understand that `generalized_dim` is only a crude estimate! You must
# check and double-check and triple-check if you want more accuracy!**
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Other related concepts
# ## Kaplan-Yorke dimension
# The Kaplan-Yorke dimension is defined as simply the (interpolated) number where the sum of
# Lyapunov exponents crosses zero.
#
# This simple interpolation is done by the function `kaplanyorke_dim(ls)`.
# ------------------------------------------------------------------------------------------

lor = Systems.lorenz()

ls = lyapunovs(lor, 4000.0; Ttr = 100.0)

kaplanyorke_dim(ls)

# ------------------------------------------------------------------------------------------
# ## Permutation Entropy
#
# Another entropy-like quantity that you can compute with **DynamicalSystems.jl** is the
# [permutation entropy](https://juliadynamics.github.io/DynamicalSystems.jl/latest/chaos/ent
# ropies/#permutation-entropy).
#
# This is done with the function `permentropy(s, order; ...)`. The permutation entropy is
# different because it requires a *timeseries* `s` as the input.
# ------------------------------------------------------------------------------------------

# create timeseries:
s = (ds = Systems.towel(); trajectory(towel, 10000)[:, 1])
# order `o` permutation entropy:
o = 6
permentropy(s, o)

# ------------------------------------------------------------------------------------------
# # Docstrings
# ------------------------------------------------------------------------------------------

?genentropy

?generalized_dim

?non0hist

?estimate_boxsizes

?linear_regions

?kaplanyorke_dim

?permentropy
