# ------------------------------------------------------------------------------------------
# # Getting to know Julia
# (Originally from https://juliabox.com under tutorials/intro-to-julia/short-
# version/01.Getting_to_know_Julia.ipynb)
#
# This notebook is meant to offer a crash course in Julia syntax to show you that Julia is
# lightweight and easy to use -- like your favorite high-level language!
#
# We'll talk about
# - Strings
# - Data structures
# - Loops
# - Conditionals
# - Functions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Strings
# ------------------------------------------------------------------------------------------

string1 = "How many cats "

string2 = "is too many cats?"

string(string1, string2)

😺 = 10
println("I don't know but $😺 are too few!")

# ------------------------------------------------------------------------------------------
# Note: Julia allows us to write super generic code, and 😺 is an example of this.
#
# This allows us to write code like
# ------------------------------------------------------------------------------------------

😺 = 1
😀 = 0
😞 = -1

😺 + 😞 == 😀

# ------------------------------------------------------------------------------------------
# ## Data structures
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Tuples
#
# We can create a tuple by enclosing an ordered collection of elements in `( )`.
#
# Syntax: <br>
# ```julia
# (item1, item2, ...)```
# ------------------------------------------------------------------------------------------

myfavoriteanimals = ("penguins", "cats", "sugargliders")

myfavoriteanimals[1]

# ------------------------------------------------------------------------------------------
# ### Dictionaries
#
# If we have sets of data related to one another, we may choose to store that data in a
# dictionary. To do this, we use the `Dict()` function.
#
# Syntax:
# ```julia
# Dict(key1 => value1, key2 => value2, ...)```
#
# A good example of a dictionary is a contacts list, where we associate names with phone
# numbers.
# ------------------------------------------------------------------------------------------

myphonebook = Dict("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

myphonebook["Jenny"]

# ------------------------------------------------------------------------------------------
# ### Arrays
#
# Unlike tuples, arrays are mutable. Unlike dictionaries, arrays contain ordered sequences
# of elements. <br>
# We can create an array by enclosing this sequence of elements in `[ ]`.
#
# Syntax: <br>
# ```julia
# [item1, item2, ...]```
#
#
# For example, we might create an array to keep track of my friends
# ------------------------------------------------------------------------------------------

myfriends = ["Ted", "Robyn", "Barney", "Lily", "Marshall"]

fibonacci = [1, 1, 2, 3, 5, 8, 13]

mixture = [1, 1, 2, 3, "Ted", "Robyn"]

# ------------------------------------------------------------------------------------------
# We can also create arrays of other data structures, or multi-dimensional arrays.
# ------------------------------------------------------------------------------------------

numbers = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]

rand(4, 3)

# ------------------------------------------------------------------------------------------
# ## Loops
#
# ### `for` loops
#
# The syntax for a `for` loop is
#
# ```julia
# for *var* in *loop iterable*
#     *loop body*
# end
# ```
# ------------------------------------------------------------------------------------------

for n in 1:10
    println(n)
end

# ------------------------------------------------------------------------------------------
# ### `while` loops
#
# The syntax for a `while` is
#
# ```julia
# while *condition*
#     *loop body*
# end
# ```
# ------------------------------------------------------------------------------------------

n = 0
while n < 10
    global n += 1
    println(n)
end

# ------------------------------------------------------------------------------------------
# ## Conditionals
#
# #### with `if`
#
# In Julia, the syntax
#
# ```julia
# if *condition 1*
#     *option 1*
# elseif *condition 2*
#     *option 2*
# else
#     *option 3*
# end
# ```
#
# allows us to conditionally evaluate one of our options.
# ------------------------------------------------------------------------------------------

x, y = 1, 2
if x > y
    x
else
    y
end

# ------------------------------------------------------------------------------------------
# #### with ternary operators
#
# For this last block, we could instead use the ternary operator with the syntax
#
# ```julia
# a ? b : c
# ```
#
# which equates to
#
# ```julia
# if a
#     b
# else
#     c
# end
# ```
# ------------------------------------------------------------------------------------------

(x > y) ? x : y

# ------------------------------------------------------------------------------------------
# ## Functions
#
# Topics:
# 1. How to declare a function
# 2. Duck-typing in Julia
# 3. Mutating vs. non-mutating functions
# 4. Some higher order functions
#
# ### How to declare a function
#
# #### First way: with `function` and `end` keywords
# ------------------------------------------------------------------------------------------

function f(x)
    x^2
end

# ------------------------------------------------------------------------------------------
# #### Second way: with `=`
# ------------------------------------------------------------------------------------------

f2(x) = x^2

# ------------------------------------------------------------------------------------------
# Third way: as an anonymous function
# ------------------------------------------------------------------------------------------

f3 = x -> x^2

# ------------------------------------------------------------------------------------------
# #### Calling these functions
# ------------------------------------------------------------------------------------------

f(42)

f2(42)

f3(42)

# ------------------------------------------------------------------------------------------
# ### Duck-typing in Julia
# *"If it quacks like a duck, it's a duck."* <br><br>
# Julia functions will just work on whatever inputs make sense. <br><br>
# For example, `f` will work on a matrix.
# ------------------------------------------------------------------------------------------

A = rand(3, 3)
A

f(A)

# ------------------------------------------------------------------------------------------
# On the other hand, `f` will not work on a vector. Unlike `A^2`, which is well-defined, the
# meaning of `v^2` for a vector, `v`, is ambiguous.
# ------------------------------------------------------------------------------------------

v = rand(3)

f(v)

# ------------------------------------------------------------------------------------------
# ### Mutating vs. non-mutating functions
#
# By convention, functions followed by `!` alter their contents and functions lacking `!` do
# not.
#
# For example, let's look at the difference between `sort` and `sort!`.
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
# ### Some higher order functions
#
# #### map
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
# and this will still compile down to code that runs as efficiently as `C`!
# ------------------------------------------------------------------------------------------


