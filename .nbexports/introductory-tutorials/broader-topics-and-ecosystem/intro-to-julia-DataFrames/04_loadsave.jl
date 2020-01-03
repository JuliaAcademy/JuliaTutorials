# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), May 23, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames # load package

# ------------------------------------------------------------------------------------------
# ## Load and save DataFrames
# We do not cover all features of the packages. Please refer to their documentation to learn
# them.
#
# Here we'll load `CSV` to read and write CSV files and `JLD`, which allows us to work with
# a Julia native binary format.
# ------------------------------------------------------------------------------------------

using CSV
using JLD

# ------------------------------------------------------------------------------------------
# Let's create a simple `DataFrame` for testing purposes,
# ------------------------------------------------------------------------------------------

x = DataFrame(A=[true, false, true], B=[1, 2, missing],
              C=[missing, "b", "c"], D=['a', missing, 'c'])


# ------------------------------------------------------------------------------------------
# and use `eltypes` to look at the columnwise types.
# ------------------------------------------------------------------------------------------

eltypes(x)

# ------------------------------------------------------------------------------------------
# Let's use `CSV` to save `x` to disk; make sure `x.csv` does not conflict with some file in
# your working directory.
# ------------------------------------------------------------------------------------------

CSV.write("x.csv", x)

# ------------------------------------------------------------------------------------------
# Now we can see how it was saved by reading `x.csv`.
# ------------------------------------------------------------------------------------------

print(read("x.csv", String))

# ------------------------------------------------------------------------------------------
# We can also load it back. `use_mmap=false` disables memory mapping so that on Windows the
# file can be deleted in the same session.
# ------------------------------------------------------------------------------------------

y = CSV.read("x.csv", use_mmap=false)

# ------------------------------------------------------------------------------------------
# When loading in a `DataFrame` from a `CSV`, all columns allow `Missing` by default. Note
# that the column types have changed!
# ------------------------------------------------------------------------------------------

eltypes(y)

# ------------------------------------------------------------------------------------------
# Now let's save `x` to a file in a binary format; make sure that `x.jld` does not exist in
# your working directory.
# ------------------------------------------------------------------------------------------

save("x.jld", "x", x)

# ------------------------------------------------------------------------------------------
# After loading in `x.jld` as `y`, `y` is identical to `x`.
# ------------------------------------------------------------------------------------------

y = load("x.jld", "x")

# ------------------------------------------------------------------------------------------
# Note that the column types of `y` are the same as those of `x`!
# ------------------------------------------------------------------------------------------

eltypes(y)

# ------------------------------------------------------------------------------------------
# Next, we'll create the files `bigdf.csv` and `bigdf.jld`, so be careful that you don't
# already have these files on disc!
#
# In particular, we'll time how long it takes us to write a `DataFrame` with 10^3 rows and
# 10^5 columns to `.csv` and `.jld` files.  *You can expect JLD to be faster!* Use
# `compress=true` to reduce file sizes.
# ------------------------------------------------------------------------------------------

bigdf = DataFrame(Bool, 10^3, 10^2)
@time CSV.write("bigdf.csv", bigdf)
@time save("bigdf.jld", "bigdf", bigdf)
getfield.(stat.(["bigdf.csv", "bigdf.jld"]), :size)

# ------------------------------------------------------------------------------------------
# Finally, let's clean up. Do not run the next cell unless you are sure that it will not
# erase your important files.
# ------------------------------------------------------------------------------------------

foreach(rm, ["x.csv", "x.jld", "bigdf.csv", "bigdf.jld"])
