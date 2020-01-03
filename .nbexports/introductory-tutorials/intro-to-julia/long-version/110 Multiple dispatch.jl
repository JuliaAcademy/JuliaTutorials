# ------------------------------------------------------------------------------------------
# # Multiple Dispatch
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# In this notebook we'll explore **multiple dispatch**, which is a key feature of Julia.
#
# Multiple dispatch makes software *generic* and *fast*!
#
# #### Starting with the familiar
#
# To understand multiple dispatch in Julia, let's start with what we've already seen.
#
# We can declare functions in Julia without giving Julia any information about the types of
# the input arguments that function will receive:
# ------------------------------------------------------------------------------------------

square(x) = x^2

square(10)

square("Hello ")

square([1,2,3])

# ------------------------------------------------------------------------------------------
# #### Specifying the types of our input arguments
#
# However, we also have the *option* to tell Julia explicitly what types our input arguments
# are allowed to have.
#
# For example, let's write a function `f` that only takes `Number`s as inputs.
# ------------------------------------------------------------------------------------------

f(a::Integer, b::Integer) = "a and b are both integers"

f(3, 4)

f(1.2, 3.4)

# ------------------------------------------------------------------------------------------
# But we can define that method!
# ------------------------------------------------------------------------------------------

f(a::Float64, b::Float64) = "a and b are both Float64s"

f(1.2, 3.4)

# ------------------------------------------------------------------------------------------
# ### Basic dispatch
# ------------------------------------------------------------------------------------------

f(a, b) = "fallback"
f(a::Number, b::Number) = "a and b are both numbers"
f(a::Number, b) = "a is a number"
f(a, b::Number) = "b is a number"
f(a::Integer, b::Integer) = "a and b are both integers"

methods(f)

f(1.5, 2)

f(1, "bar")

f(1, 2)

f("foo", [1,2])

f(1, 2, 3)

# ------------------------------------------------------------------------------------------
# ### Ambiguities
# ------------------------------------------------------------------------------------------

g(a::Int, b::Number) = 1
g(a::Number, b::Int) = 2

g(1, 2.5)

g(1.5, 2)

g(1, 2)

g(x::Int, y::Int) = 3

g(1, 2)

# ------------------------------------------------------------------------------------------
# ### "Diagonal" dispatch
# ------------------------------------------------------------------------------------------

f(a::T, b::T) where {T<:Number} = "a and b are both $(T)s"

methods(f)

f(big(1.5), big(2.5))

f(big(1), big(2)) # <== integer rule is more specific

f(a::T, b::T) where {T<:Integer} = "both are $T integers"

methods(f)

f(big(1), big(2))

f("foo", "bar") # <== still doesn't apply to non-numbers

# ------------------------------------------------------------------------------------------
# ### Varargs methods
# ------------------------------------------------------------------------------------------

f(args::Number...) = "$(length(args))-ary heterogeneous call"
f(args::T...) where {T<:Number} = "$(length(args))-ary homogeneous call"

f(1)

f(1, 2, 3)

f(1, 1.5, 2)

f()

f(1, 2) # <== previous 2-arg method is more specific

f("foo") # <== still doesn't apply to non-numbers

# "splat" (more below)
f([1, 2, 3]...)

# ------------------------------------------------------------------------------------------
# ### Optional Arguments
# ------------------------------------------------------------------------------------------

h(x, y = 0) = 2x + 3y

methods(h)

# ------------------------------------------------------------------------------------------
# Shorthand for this:
# ```
# h(x, y) = 2x + 3y
# h(x) = h(x, 0)
# ```
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Keyword Arguments
# ------------------------------------------------------------------------------------------

k(x, y = 0; opt::Bool = false) = opt ? 2x+y : x+2y

k(2)

k(2, 3)

k(2, opt=true)

k(2, 3, opt=true)

foo(x, y; req::Bool) = req ? 2x+y : x+2y

foo(2, 3)

methods(k)

k(2, opt=true)

# ------------------------------------------------------------------------------------------
# ### Keyword arguments: slurp and splat
# ------------------------------------------------------------------------------------------

function allkw(; kw...)
    @show keys(kw)
end

allkw(a=1,b=2)

# ------------------------------------------------------------------------------------------
# Just like iterators can be splatted as positional arguments, dict-like collections and
# named tuples can be splatted as keyword arguments.
# ------------------------------------------------------------------------------------------

function rect(;width=1,height=1,fill="#")
    for i in 1:height
        println(fill^width)
    end
end

params = (width=8,height=3,fill='A')

rect(; params...)

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### Exercise 1
#
# Write a function that repeats a string an integer number of times which takes the
# arguments in either order.
#
# #### Exercise 2a
#
# Write a function `F` that returns the tuple `(x, y, k)` where:
# - `x` is the first positional argument and is mandatory
# - `y` is the second positional argument and is optional
# - `k` is an optional keyword argument
#
# The optional arguments should have the following defaults:
# - `y` defaults to `2x`
# - `k` defaults to `2y`
#
# #### Exercise 2b
#
# Write a function `G` just like `F` but with differet defaults:
# - `k` defaults to `2x`
# - `y` defaults to `2k`
# ------------------------------------------------------------------------------------------
