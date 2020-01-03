# ------------------------------------------------------------------------------------------
# # Arrays and Loops
#
# We'll cover:
# 1. Array literals
# 2. Concatenation
# 3. For loops
# 4. Comprehensions
# 5. Element types
# 6. Dequeues
# 7. The `bang!` convention
# 8. Variable names vs. copies
#
# # Arrays
#
# Julia has highly efficient multidimensional arrays, both constructed and indexed with
# square brackets.
#
# Syntax: <br>
# ```julia
# [item1, item2, ...]
# ```
# ------------------------------------------------------------------------------------------

squares = [1, 4, 9, 15, 25, 36, 49, 64]

squares[1]

squares[1:3]

squares[end]

squares[4] = 16

squares

typeof(squares)

# ------------------------------------------------------------------------------------------
# ## Concatenation
#
# If, instead of commas, you just use spaces, then the values are concatenated horizontally.
# ------------------------------------------------------------------------------------------

cubes = [1, 8, 27, 64, 125, 216, 343, 512]

powers = [1:8 squares cubes]

powers[4, 2]

powers[:, 3]

powers[7, :]

typeof(powers)

# ------------------------------------------------------------------------------------------
# Semicolon separators perform vertical concatenation:
# ------------------------------------------------------------------------------------------

[squares; cubes]

# ------------------------------------------------------------------------------------------
# Whereas commas would simply create an array of arrays:
# ------------------------------------------------------------------------------------------

nested_powers = [[1,2,3,4,5,6,7,8], squares, cubes]

nested_powers[2]

# ------------------------------------------------------------------------------------------
# Horizontal and vertical concatenation can be used together to as a simple syntax for
# matrix literals:
# ------------------------------------------------------------------------------------------

[1 3 5; 2 4 6]

# ------------------------------------------------------------------------------------------
# # Loops
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Of course, we could construct this programmatically with a for-loop. The syntax for a
# `for` loop is
#
# ```julia
# for *var* in *loop iterable*
#     *loop body*
# end
# ```
#
# 
# ------------------------------------------------------------------------------------------

A = fill(0, (8, 3)) # Allocate an 8x3 matrix to store the values into
for pow in 1:3
    for value in 1:8
        A[value, pow] = value ^ pow
    end
end
A

A == powers

# ------------------------------------------------------------------------------------------
# ## Array Comprehensions
# ------------------------------------------------------------------------------------------

squares = [value^2 for value in 1:8]

cubes = [value^3 for value in 1:8]

powers = [value^pow for value in 1:8, pow in 1:3]

# ------------------------------------------------------------------------------------------
# # The element type
#
# Note that every time an array prints out, it is displaying its element type and
# dimensionality, for example `Array{Int64, 2}`. This describes what it can store — and thus
# what it can return upon indexing.
# ------------------------------------------------------------------------------------------

typeof(powers)

typeof(powers[1, 1])

# ------------------------------------------------------------------------------------------
# Further, the array will try to convert any new values assigned into it to its element
# type:
# ------------------------------------------------------------------------------------------

powers[1, 1] = 1.6

powers[1, 1] = -5.0 # This can be losslessly converted to an integer

powers

# ------------------------------------------------------------------------------------------
# Arrays that have an exact and concrete element type are generally significantly faster, so
# Julia will try to find an amenable element type for you in its literal construction
# syntax:
# ------------------------------------------------------------------------------------------

fortytwosarray = [42, 42.0, 4.20e1, 4.20f1, 84//2, 0x2a]

for x in fortytwosarray
    show(x)
    println("\tisa $(typeof(x))")
end

# ------------------------------------------------------------------------------------------
# The `Any` array can be helpful for disabling these behaviors and allowing all kinds of
# different objects:
# ------------------------------------------------------------------------------------------

anyfortytwos = Any[42, 42.0, 4.20e1, 4.20f1, 84//2, 0x2a]

anyfortytwos[1] = "FORTY TWO"
anyfortytwos

# ------------------------------------------------------------------------------------------
# # Vectors as dequeues
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# One-dimensional arrays can be appended to and have items removed from them:
# ------------------------------------------------------------------------------------------

fib = [1, 1, 2, 3, 5, 8, 13]

push!(fib, 21)

push!(fib, sum(fib[end-1:end]))

pop!(fib)

pushfirst!(fib, 0)

popfirst!(fib)

# ------------------------------------------------------------------------------------------
# ## Aside: why so shouty!?
#
# Why are there exclamations in all the above function calls? `push!(fib, ...)`,
# `pop!(fib)`, etc.?
# ------------------------------------------------------------------------------------------

push!

# ------------------------------------------------------------------------------------------
# This is entirely a convention. It's a signal to the caller that one of the argument is
# going to be _mutated_. It's perhaps easiest to demonstrate with an example:
# ------------------------------------------------------------------------------------------

A = rand(0:10, 10)

sort(A)

A

sort!(A)

A # That changed A!

# ------------------------------------------------------------------------------------------
# ## Aside: names vs. copies
#
# Remember that variables are just names we give our objects. So watch what happens if we
# give the same object two different names:
# ------------------------------------------------------------------------------------------

fibonacci = [1, 1, 2, 3, 5, 8, 13]

some_numbers = fibonacci
some_numbers[1] = 404
some_numbers

fibonacci

fibonacci[1] = 1
some_numbers = copy(fibonacci)
some_numbers[2] = 404
fibonacci
