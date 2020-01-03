# ------------------------------------------------------------------------------------------
# # Functions
#
# Topics:
# 1. How to declare a function
# 2. Duck-typing in Julia
# 3. Mutating vs. non-mutating functions
# 4. Some higher order functions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## How to declare a function
# Julia gives us a few different ways to write a function. The first requires the `function`
# and `end` keywords
# ------------------------------------------------------------------------------------------

function sayhi(name)
    println("Hi $name, it's great to see you!")
end

function f(x)
    x^2
end

# ------------------------------------------------------------------------------------------
# We can call either of these functions like this:
# ------------------------------------------------------------------------------------------

sayhi("C-3PO")

f(42)

# ------------------------------------------------------------------------------------------
# Alternatively, we could have declared either of these functions in a single line
# ------------------------------------------------------------------------------------------

sayhi2(name) = println("Hi $name, it's great to see you!")

f2(x) = x^2

sayhi2("R2D2")

f2(42)

# ------------------------------------------------------------------------------------------
# Finally, we could have declared these as "anonymous" functions
# ------------------------------------------------------------------------------------------

sayhi3 = name -> println("Hi $name, it's great to see you!")

f3 = x -> x^2

sayhi3("Chewbacca")

f3(42)

# ------------------------------------------------------------------------------------------
# ## Duck-typing in Julia
# *"If it quacks like a duck, it's a duck."* <br><br>
# Julia functions will just work on whatever inputs make sense. <br><br>
# For example, `sayhi` works on the name of this minor tv character, written as an
# integer...
# ------------------------------------------------------------------------------------------

sayhi(55595472)

# ------------------------------------------------------------------------------------------
# And `f` will work on a matrix.
# ------------------------------------------------------------------------------------------

A = rand(3, 3)
A

f(A)

# ------------------------------------------------------------------------------------------
# `f` will also work on a string like "hi" because `*` is defined for string inputs as
# string concatenation.
# ------------------------------------------------------------------------------------------

f("hi")

# ------------------------------------------------------------------------------------------
# On the other hand, `f` will not work on a vector. Unlike `A^2`, which is well-defined, the
# meaning of `v^2` for a vector, `v`, is not a well-defined algebraic operation.
# ------------------------------------------------------------------------------------------

v = rand(3)

f(v)

# ------------------------------------------------------------------------------------------
# ## Mutating vs. non-mutating functions
#
# By convention, functions followed by `!` alter their contents and functions lacking `!` do
# not.
#
# For example, let's look at the difference between `sort` and `sort!`.
# 
# ------------------------------------------------------------------------------------------

v = [3, 5, 2]

sort(v)

v

# ------------------------------------------------------------------------------------------
# `sort(v)` returns a sorted array that contains the same elements as `v`, but `v` is left
# unchanged. <br><br>
#
# On the other hand, when we run `sort!(v)`, the contents of v are sorted within the array
# `v`.
# ------------------------------------------------------------------------------------------

sort!(v)

v

# ------------------------------------------------------------------------------------------
# ## Some higher order functions
#
# ### map
#
# `map` is a "higher-order" function in Julia that *takes a function* as one of its input
# arguments.
# `map` then applies that function to every element of the data structure you pass it. For
# example, executing
#
# ```julia
# map(f, [1, 2, 3])
# ```
# will give you an output array where the function `f` has been applied to all elements of
# `[1, 2, 3]`
# ```julia
# [f(1), f(2), f(3)]
# ```
# ------------------------------------------------------------------------------------------

map(f, [1, 2, 3])

# ------------------------------------------------------------------------------------------
# Here we've squared all the elements of the vector `[1, 2, 3]`, rather than squaring the
# vector `[1, 2, 3]`.
#
# To do this, we could have passed to `map` an anonymous function rather than a named
# function, such as
# ------------------------------------------------------------------------------------------

x -> x^3

# ------------------------------------------------------------------------------------------
# via
# ------------------------------------------------------------------------------------------

map(x -> x^3, [1, 2, 3])

# ------------------------------------------------------------------------------------------
# and now we've cubed all the elements of `[1, 2, 3]`!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### broadcast
#
# `broadcast` is another higher-order function like `map`. `broadcast` is a generalization
# of `map`, so it can do every thing `map` can do and more. The syntax for calling
# `broadcast` is the same as for calling `map`
# ------------------------------------------------------------------------------------------

broadcast(f, [1, 2, 3])

# ------------------------------------------------------------------------------------------
# and again, we've applied `f` (squared) to all the elements of `[1, 2, 3]` - this time by
# "broadcasting" `f`!
#
# Some syntactic sugar for calling `broadcast` is to place a `.` between the name of the
# function you want to `broadcast` and its input arguments. For example,
#
# ```julia
# broadcast(f, [1, 2, 3])
# ```
# is the same as
# ```julia
# f.([1, 2, 3])
# ```
# ------------------------------------------------------------------------------------------

f.([1, 2, 3])

# ------------------------------------------------------------------------------------------
# Notice again how different this is from calling
# ```julia
# f([1, 2, 3])
# ```
# We can square every element of a vector, but we can't square a vector!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# To drive home the point, let's look at the difference between
#
# ```julia
# f(A)
# ```
# and
# ```julia
# f.(A)
# ```
# for a matrix `A`:
# ------------------------------------------------------------------------------------------

A = [i + 3*j for j in 0:2, i in 1:3]

f(A)

# ------------------------------------------------------------------------------------------
# As before we see that for a matrix, `A`,
# ```
# f(A) = A^2 = A * A
# ```
#
# On the other hand,
# ------------------------------------------------------------------------------------------

B = f.(A)

# ------------------------------------------------------------------------------------------
# contains the squares of all the entries of `A`.
#
# This dot syntax for broadcasting allows us to write relatively complex compound
# elementwise expressions in a way that looks natural/closer to mathematical notation. For
# example, we can write
# ------------------------------------------------------------------------------------------

A .+ 2 .* f.(A) ./ A

# ------------------------------------------------------------------------------------------
# instead of
# ------------------------------------------------------------------------------------------

broadcast(x -> x + 2 * f(x) / x, A)

# ------------------------------------------------------------------------------------------
# and the two will perform exactly the same.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### 6.1
# Write a function `add_one` that adds 1 to its input.
# ------------------------------------------------------------------------------------------

@assert add_one(1) == 2

@assert add_one(11) == 12

# ------------------------------------------------------------------------------------------
# #### 6.2
# Use `map` or `broadcast` to increment every element of matrix `A` by `1` and assign it to
# a variable `A1`.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# #### 6.3
# Use the broadcast dot syntax to increment every element of matrix `A1` by `1` and store it
# in variable `A2`
# ------------------------------------------------------------------------------------------



@assert A2 == [3 4 5; 6 7 8;9 10 11]

# ------------------------------------------------------------------------------------------
# Please click on `Validate` on the top, once you are done with the exercises.
# ------------------------------------------------------------------------------------------
