# ------------------------------------------------------------------------------------------
# # Packages
#
# Julia has over 2000 registered packages, making packages a huge part of the Julia
# ecosystem.
#
# Even so, the package ecosystem still has some growing to do. Notably, we have first class
# function calls  to other languages, providing excellent foreign function interfaces. We
# can easily call into python or R, for example, with `PyCall` or `Rcall`.
#
# This means that you don't have to wait until the Julia ecosystem is fully mature, and that
# moving to Julia doesn't mean you have to give up your favorite package/library from
# another language!
#
# To see all available packages, check out
#
# https://pkg.julialang.org/
# or
# https://juliaobserver.com/
#
# For now, let's learn how to use a package.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The first time you use a package on a given Julia installation, you need to use the
# package manager to explicitly add it:
# ------------------------------------------------------------------------------------------

using Pkg
Pkg.add("Example")

# ------------------------------------------------------------------------------------------
# Every time you use Julia (start a new session at the REPL, or open a notebook for the
# first time, for example), you load the package with the `using` keyword
# ------------------------------------------------------------------------------------------

using Example

# ------------------------------------------------------------------------------------------
# In the source code of `Example.jl` at
# https://github.com/JuliaLang/Example.jl/blob/master/src/Example.jl
# we see the following function declared
#
# ```
# hello(who::String) = "Hello, $who"
# ```
#
# Having loaded `Example`, we should now be able to call `hello`
# ------------------------------------------------------------------------------------------

hello("it's me. I was wondering if after all these years you'd like to meet.")

# ------------------------------------------------------------------------------------------
# Now let's play with the Colors package
# ------------------------------------------------------------------------------------------

Pkg.add("Colors")

using Colors

# ------------------------------------------------------------------------------------------
# Let's create a palette of 100 different colors
# ------------------------------------------------------------------------------------------

palette = distinguishable_colors(100)

# ------------------------------------------------------------------------------------------
# and then we can create a randomly checkered matrix using the `rand` command
# ------------------------------------------------------------------------------------------

rand(3, 3)

rand(1:10, 3, 3)

rand(palette, 3, 3)


