# ------------------------------------------------------------------------------------------
# ## Get Julia running locally
#
#
# ## Local package installations
#
# If you'd like to run these tutorial notebooks locally, you'll want to install all the
# packages used in them. Since installation can take some time, you may want to run this
# notebook before getting started with the tutorial, rather than trying to install
# everything as you go.
#
# #### Installations
# ------------------------------------------------------------------------------------------

using Pkg
Pkg.add(["Example", "Colors", "Primes", "Plots", "BenchmarkTools"])

# ------------------------------------------------------------------------------------------
# #### Loading all packages
# ------------------------------------------------------------------------------------------

using Example, Colors, Plots, BenchmarkTools, Primes

# ------------------------------------------------------------------------------------------
# #### Tests
#
# `plot` should generate a plot,
# ------------------------------------------------------------------------------------------

plot(x -> x^2, -10:10)

# ------------------------------------------------------------------------------------------
# `RGB(0, 0, 0)` should return a black square,
# ------------------------------------------------------------------------------------------

RGB(0, 0, 0)

# ------------------------------------------------------------------------------------------
# and `@btime primes(1000000);` should report an execution time in ms and memory used. For
# example, on one computer, this yielded "2.654 ms (5 allocations: 876.14 KiB)".
# ------------------------------------------------------------------------------------------

@btime primes(1000000);
