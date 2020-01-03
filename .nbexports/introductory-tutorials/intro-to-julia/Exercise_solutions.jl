# ------------------------------------------------------------------------------------------
# ### Notebook 1
# #### 1.1
# Look up docs for the `convert` function.
# ------------------------------------------------------------------------------------------

?convert

# ------------------------------------------------------------------------------------------
# #### 1.2
# Assign `365` to a variable named `days`. Convert `days` to a float.
# ------------------------------------------------------------------------------------------

days = 365
convert(Float64, days)

# ------------------------------------------------------------------------------------------
# #### 1.3
# See what happens when you execute
#
# ```julia
# convert(Int64, '1')
# ```
# and
#
# ```julia
# parse(Int64, '1')
# ```
#
# What's the difference?
# ------------------------------------------------------------------------------------------

convert(Int64, '1')

parse(Int64, '1')

# ------------------------------------------------------------------------------------------
# ### Notebook 2
# #### 2.1
# Create a string that says "hi" 1000 times.
# ------------------------------------------------------------------------------------------

"hi"^1000

# ------------------------------------------------------------------------------------------
# #### 2.2
# Declare two variables
#
# ```julia
# a = 3
# b = 4
# ```
# and use them to create two strings:
# ```julia
# "3 + 4"
# "7"
# ```
# ------------------------------------------------------------------------------------------

a = 3; b = 4

"$a + $b"

"$(a + b)"

# ------------------------------------------------------------------------------------------
# ### Notebook 3
#
# #### 3.1
# Create an array, `a_ray`, with the following code:
#
# ```julia
# a_ray = [1, 2, 3]
# ```
#
# Add the number `4` to the end of this array and then remove it.
# ------------------------------------------------------------------------------------------

a_ray = [1, 2, 3]
push!(a_ray, 4)

# ------------------------------------------------------------------------------------------
# #### 3.2
# Try to add "Emergency" as key to `myphonebook` with the value `string(911)` with the
# following code
# ```julia
# myphonebook["Emergency"] = 911
# ```
#
# Why doesn't this work?
# ------------------------------------------------------------------------------------------

myphonebook = Dict("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

myphonebook["Emergency"] = 911
#= 

Julia constructed `myphonebook` to match the arguments
it was passed; both of which had `String`s for both their
keys and values. We see that myphonebook is a
`Dict{String,String} with 2 entries`. This means Julia
will not accept integers as values in myphonebook.

=#

# This will work:
myphonebook["Emergency"] = "911"

# ------------------------------------------------------------------------------------------
# #### 3.3
# Create a new dictionary called `flexible_phonebook` that has Jenny's number stored as a
# string and Ghostbusters' number stored as an integer.
# ------------------------------------------------------------------------------------------

flexible_phonebook = Dict("Jenny" => "867-5309", "Ghostbusters" => 5552368)

# ------------------------------------------------------------------------------------------
# #### 3.4
# Add the key "Emergency" with the value `911` (an integer) to `flexible_phonebook`.
# ------------------------------------------------------------------------------------------

flexible_phonebook["Emergency"] = 911

# ------------------------------------------------------------------------------------------
# #### 3.5
# Why can we add an integer as a value to `flexible_phonebook` but not `myphonebook`? How
# could we have initialized `myphonebook` so that it would accept integers or strings as
# values?
# ------------------------------------------------------------------------------------------

#= 

We constructed `flexible_phonebook` with two key-value
pairs whose values were different types, so Julia needed
to construct a dictionary that could hold `Any` value.
Unlike myphonebook, flexible_phonebook is a 
`Dict{String,Any} with 2 entries`.

To avoid this, we could have initialized myphonebook a
an empty dictionary and added entries later. Or we
could have explicitly told Julia that we wanted a
dictionary that accepted objects of type `Any` as
values. See examples!
=#

myphonebook = Dict()

# Alternatively we could use a parametric type constructor to tell Julia explicitly
# what types we want to populate our dictionary with.
myphonebook = Dict{String, Any}("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

# ------------------------------------------------------------------------------------------
# ### Notebook 4
#
# #### 4.1
# Write a loop that prints the squares of integers between 1 and 100.
# ------------------------------------------------------------------------------------------

for i in 1:100
   println(i^2) 
end

# ------------------------------------------------------------------------------------------
# #### 4.2
#
# Add to the code above a bit to create a dictionary, `squares` that holds integers and
# their squares as key, value pairs such that
#
# ```julia
# squares[10] == 100
# ```
# ------------------------------------------------------------------------------------------

squares = Dict()
for i in 1:100
   squares[i] = i^2 
end
squares

# ------------------------------------------------------------------------------------------
# #### 4.3
# Use an array comprehension to create an an array that stores the squares of all integers
# between 1 and 100.
# ------------------------------------------------------------------------------------------

[i^2 for i in 1:100]

# ------------------------------------------------------------------------------------------
# ### Notebook 5
#
# #### 5.1
# Write a conditional statement that prints a number if the number is even and the string
# "odd" if the number is odd.
# ------------------------------------------------------------------------------------------

n = 3
if (n % 2) == 0
    println(n)
else
    println("odd")
end

# ------------------------------------------------------------------------------------------
# #### 5.2
# Rewrite the code from 5.1 using a ternary operator.
# ------------------------------------------------------------------------------------------

(n % 2) == 0 ? println(n) : println("odd") 

# ------------------------------------------------------------------------------------------
# ### Notebook 6
#
# #### 6.1
# Write a function that adds 1 to its input.
# ------------------------------------------------------------------------------------------

x -> x + 1

add1(x) = x + 1

# ------------------------------------------------------------------------------------------
# #### 6.2
# Use `map` or `broadcast` to increment every element of matrix `A` by `1`.
# ------------------------------------------------------------------------------------------

A = rand(5,5)
map(x -> x + 1, A)

broadcast(add1, A)

# ------------------------------------------------------------------------------------------
# #### 6.3
# Use the broadcast dot syntax to increment every element of matrix `A` by `1`.
# ------------------------------------------------------------------------------------------

add1.(A)

A .+ 1

# ------------------------------------------------------------------------------------------
# ### Notebook 7
#
# #### 7.1
# Load the Primes package (source code at https://github.com/JuliaMath/Primes.jl).
# ------------------------------------------------------------------------------------------

# using Pkg; Pkg.add("Primes")
using Primes

# ------------------------------------------------------------------------------------------
# #### 7.2
# Verify that you can now use the function `primes` to grab all prime numbers under
# 1,000,000.
# ------------------------------------------------------------------------------------------

primes(1000000)

# ------------------------------------------------------------------------------------------
# ### Notebook 8
#
# #### 8.1
# Given
# ```julia
# x = -10:10
# ```
# plot y vs. x for $y = x^2$.
# ------------------------------------------------------------------------------------------

using Plots; gr()
x = -10:10
y = x .^ 2
plot(x, y)

plot(x -> x ^ 2, x)

# ------------------------------------------------------------------------------------------
# #### 8.2
# Execute the following code
# ------------------------------------------------------------------------------------------

p1 = plot(x, x)
p2 = plot(x, x.^2)
p3 = plot(x, x.^3)
p4 = plot(x, x.^4)
plot(p1,p2,p3,p4,layout=(2,2),legend=false)

# ------------------------------------------------------------------------------------------
# and then create a $4x1$ plot that uses `p1`, `p2`, `p3`, and `p4` as subplots.
# ------------------------------------------------------------------------------------------

p1 = plot(x, x)
p2 = plot(x, x.^2)
p3 = plot(x, x.^3)
p4 = plot(x, x.^4)
plot(p1,p2,p3,p4,layout=(4,1),legend=false)

# ------------------------------------------------------------------------------------------
# ### Notebook 9
#
# #### 9.1
#
# Extend the function `foo`, adding a method that takes only one input argument, which is of
# type `Bool`, and prints "foo with one boolean!"
# ------------------------------------------------------------------------------------------

foo(x::Bool) = println("foo with one boolean!")

# ------------------------------------------------------------------------------------------
# #### 9.2
#
# Check that the method being dispatched when you execute
# ```julia
# foo(true)
# ```
# is the one you wrote.
# ------------------------------------------------------------------------------------------

foo(true)

@which foo(true)

# ------------------------------------------------------------------------------------------
# ### Notebook 10
#
# #### 10.1
# Take the inner product (or "dot" product) of a vector `v` with itself.
# ------------------------------------------------------------------------------------------

v = [1, 2, 3]
v' * v

using LinearAlgebra
dot(v, v)

# ------------------------------------------------------------------------------------------
# #### 10.2
# Take the outer product of a vector v with itself.
# ------------------------------------------------------------------------------------------

v * v'

# ------------------------------------------------------------------------------------------
# ### Notebook 11
#
# #### 11.1
#
# What are the eigenvalues of matrix A?
#
# ```
# A =
# [
#  140   97   74  168  131
#   97  106   89  131   36
#   74   89  152  144   71
#  168  131  144   54  142
#  131   36   71  142   36
# ]
# ```
# ------------------------------------------------------------------------------------------

A =
[
 140   97   74  168  131
  97  106   89  131   36
  74   89  152  144   71
 168  131  144   54  142
 131   36   71  142   36
]

eigdec = eigen(A)
eigdec.values

# ------------------------------------------------------------------------------------------
# #### 11.2
# Create a `Diagonal` matrix from the eigenvalues of `A`.
# ------------------------------------------------------------------------------------------

Diagonal(eigdec.values)

# ------------------------------------------------------------------------------------------
# #### 11.3
# Create a `LowerTriangular` matrix from `A`.
# ------------------------------------------------------------------------------------------

LowerTriangular(A)
