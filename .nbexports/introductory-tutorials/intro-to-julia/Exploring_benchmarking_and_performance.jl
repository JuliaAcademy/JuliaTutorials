# ------------------------------------------------------------------------------------------
# ## Benchmarking tips
#
# In the `Julia is fast` notebook, we saw the package `BenchmarkTools` and used its
# `@benchmark` macro.
#
# In this notebook, we'll explore the importance of "interpolating" global variables when
# benchmarking functions.
#
# We interpolate a global variable by throwing a `$` in front of it. For example, in `Julia
# is fast`, we benchmarked the `sum` function using `Vector` `A` via
#
# ```julia
# @benchmark sum($A)
# ```
#
# not
#
# ```julia
# @benchmark sum(A)
# ```
#
# Let's see if this can make a difference by examining the ratio in execution times of
# `sum($A)` and `sum(A)` for differently sized arrays `A`.
#
# #### Exercise
#
# Call the `sum` function on a pseudo-randomly populated 1D array called `foo` of several
# lengths between 2 and 2^20 (~10^6). For each size of `foo`, determine the ratio of
# execution times for `sum(foo)` and `sum($foo)`. (To determine this ratio, use the minimum
# run times in each case.)
#
# Plot the ratio of execution times for non-interpolated and interpolated `foo` in calls to
# `sum` versus the length of `foo`. Does interpolating `foo` seem to matter? If so, for what
# sizes of `foo`?
# ------------------------------------------------------------------------------------------







# ------------------------------------------------------------------------------------------
# ## Performance tips -- type stability
#
# One way to optimize code in Julia is to ensure **type stability**. If the type(s) of some
# variables in a function are subject to change or ambiguity, the compiler cannot reason as
# well about those variables, and performance will take a hit. Conversely, we allow the
# compiler to optimize and generate more efficient machine code when we declare variables so
# that their types will be fixed throughout the function body.
#
# For example, let's say we had functions called `baz` and `bar` with the following
# definitions
#
# ```julia
# function baz()
#     s = rand()
#     if s > 2/3
#         return .666667
#     elseif s > 1/3
#         return 1//3
#     else
#         return 0
#     end
# end
# ```
#
# ```julia
# function bar()
#     s = rand()
#     if s > 2/3
#         return .666667
#     elseif s > 1/3
#         return .3333333
#     else
#         return 0.0
#     end
# end
# ```
#
# When I benchmark these via
#
# ```julia
# using BenchmarkTools
# @benchmark baz()
# @benchmark bar()
# ```
#
# I see that `bar` is almost three times as fast as `baz`! The reason is that `bar` is type
# stable while `baz` is not: the compiler can tell that `bar` will always return a `Float`,
# whereas `baz` could return a `Float`, an `Int`, or a `Rational`. When the compiler can
# tell what the types of outputs from a function, or variables declared *within a function*
# are without running the code, it can do much better.
#
# #### Exercise
#
# The following definition for `my_sum` is not type stable.
#
# ```julia
# function my_sum(A)
#     output = 0
#     for x in A
#         output += x
#     end
#     return output
# end
# ```
#
# Copy and execute the above code into a new cell. Benchmark it using `A = rand(10^3)`. Then
# write a new function called `my_sum2` with the same function body as `my_sum`. Update
# `my_sum2` to make it type stable, and benchmark it for a randomly populated array with
# 10^3 entries.
#
# How much does type stability impact performance? If you'd like, try this same exercise for
# multiple sizes of `A` to see if this changes your answer!
#
# 
# ------------------------------------------------------------------------------------------









# ------------------------------------------------------------------------------------------
# #### Exercise
#
# Make the following code type stable. You'll know your efforts are paying off when you see
# a performance boost!
#
# ```julia
# """
#     my_sqrt(x)
#
# Calculate the square root of `x` with Newton's method.
# """
# function my_sqrt(x)
#     output = 1
#     for i in 1:1000
#         output = .5 * (output + x/output)
#     end
#     output
# end
# ```
# ------------------------------------------------------------------------------------------










