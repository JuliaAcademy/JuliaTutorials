# ------------------------------------------------------------------------------------------
# # Multiple dispatch
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# **Multiple dispatch** is a key feature of Julia, that we will explore in this notebook.
#
# It helps make software fast. It also makes software extensible, programmable, and
# downright fun to play with.
#
# It may just herald a breakthrough for parallel computation.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# 1. Roman numerals
# 2. Functions
# 3. Parallel computing
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## 1. Roman numerals (for fun)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's define a **new struct** that represents a Roman numeral. For coding simplicity,
# we'll just deal with numbers between 0 and 9.
#
# **Exercise**: Extend this to larger numbers. (Recall that Roman numbers are a base-10
# system!)
# ------------------------------------------------------------------------------------------

struct Roman
    n::Int
end

Base.show(io::IO, r::Roman) = print(io, 'ⅰ' + (r.n - 1) % 10)  # nice display; 'ⅰ' is a Unicode Roman numeral

# ------------------------------------------------------------------------------------------
# We can create an object of this type as follows:
# ------------------------------------------------------------------------------------------

Roman(4)

typeof.([5 5.0 Roman(5) "Five" '5'  5//1])

# ------------------------------------------------------------------------------------------
# We would like to display it nicely, in Roman numerals:
# ------------------------------------------------------------------------------------------

x = [7 1 2 5 8 9]
Roman.(x)   # equivalent to map(Roman, x)  or  [Roman(w) for w in x]

# ------------------------------------------------------------------------------------------
# It'd be nice to be able to add Roman numerals together like normal numbers:
# ------------------------------------------------------------------------------------------

Roman(4) + Roman(5)

# ------------------------------------------------------------------------------------------
# But Julia doesn't know how to do that. Let's teach it by `import`ing the `+` function,
# which then allows us to _extend_ its definition:
# ------------------------------------------------------------------------------------------

import Base: +, *

+(a::Roman, b::Roman) = Roman(a.n + b.n)

Roman(4) + Roman(5)

# ------------------------------------------------------------------------------------------
# This **adds a new method** to the function `+`:
# ------------------------------------------------------------------------------------------

methods(+)

import Base.*
*(i::Roman, j::Roman) = Roman(i.n * j.n)                     # Multiply like a Roman

Roman(3) * Roman(2)

Roman.(1:3) .* [Roman(1) Roman(2) Roman(3)]

# ------------------------------------------------------------------------------------------
# But
# ------------------------------------------------------------------------------------------

Roman(3) * 2

# Complicated mytimes to decide what to do based on type
# not suggested, better way coming soon
function mytimes(i,j)
  if isa(i,Roman) & isa(j,Number)
        return  fill(1, i.n, j)   # i by j matrix with ones
    elseif    isa(i,Number) & isa(j,Roman) 
        return "😄"^(i*j.n)   #  i * j happy faces
    else
        return("I Don't know")
    end
end

mytimes(4,Roman(3)) # Twelve happys

mytimes(Roman(4),3) # 4x3 matrix with ones

# ------------------------------------------------------------------------------------------
# The simplest thing to do is to explicitly define multiplication of a `Roman` by a number.
# We can do it as we see fit:
# ------------------------------------------------------------------------------------------

*(i::Number, j::Roman) = "😄"^(i*j.n)        #  i * j happy faces

*(i::Roman, j::Number) = fill(1, i.n, j)       # i by j matrix

3 * Roman(3) # Nine happys

Roman(3) * 5  # Three by Five matrix of ones

t(x::Roman,y::Roman) = x.n * y.n

t(Roman(5),Roman(4))

# Notice how tight the assembler is!
@code_native t(Roman(2),Roman(4))

# ------------------------------------------------------------------------------------------
# ## Functions
# ------------------------------------------------------------------------------------------

import Base: *, +, ^

*(α::Number,   g::Function) = x -> α * g(x)   # Scalar times function

*(f::Function, λ::Number)   = x -> f(λ * x)   # Scale the argument

*(f::Function, g::Function) = x -> f(g(x))    # Function composition  -- abuse of notation!  use \circ in Julia 0.6

^(f::Function, n::Integer) = n == 1 ? f : f*f^(n-1) # A naive exponentiation algorithm by recursive multiplication

+(f::Function, g::Function) = x -> f(x) + g(x)

# ------------------------------------------------------------------------------------------
# For example, the exponential function is defined as
#
# $$\exp(x) = \sum_{n=0}^\infty \frac{1}{n!} x^n.$$
#
# We can think of this just in terms of functions:
#
# $$\exp = \sum_{n=0}^\infty \frac{1}{n!} \mathrm{pow}_n,$$
#
# where $\mathrm{pow}_n(x) = x^n$.
#
# (starts to blur the symbolic with the numerical!)
# ------------------------------------------------------------------------------------------

pow(n) = x -> x^n

myexp = sum(1/factorial(big(n)) * pow(n) for n in 0:100)   # taylor series not efficient!

[myexp(1); exp(1); exp(big(1))]

f = x -> x^2
f(10)

g = 3f
g(10)

(f^2)(10)  # since we defined multiplication of functions as composition

using Plots;
gr()

x = pi*(0:0.001:4)

plot(x, sin.(x),    c="black", label="Fun")
plot!(x, (12*sin).(x),    c="green", label="Num * Fun")
plot!(x, (sin*12).(x),    c="red", alpha=0.9, label="Fun * Num")
plot!(x, (5*sin*exp).(x), c="blue", alpha=0.2, label="Num * Fun * Fun")

plot([12*sin, sin*12, 5*sin*exp], 0:.01:4π, α=[1 .9 .2], c=[:green :red :blue])

# ------------------------------------------------------------------------------------------
# <img src="https://lh4.googleusercontent.com/--z5eKJbB7sg/UffjL1iAd4I/AAAAAAAABOc/S_wDVyDOB
# fQ/gauss.jpg">
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ###  "Sin^2 phi is odious to me, even though Laplace made use of it; should  it be feared
# that sin^2 phi might become ambiguous, which would perhaps  never occur, or at most very
# rarely when speaking of sin(phi^2), well  then, let us write (sin phi)^2, but not sin^2
# phi, which by analogy  should signify sin(sin phi)." -- Gauss
# ------------------------------------------------------------------------------------------

x=(0:.01:2) * pi;

plot(x, (sin^2).(x), c="blue")     # Squaring just works, y=sin(sin(x)), Gauss would be pleased!
plot!(x, sin.(x).^2,  c="red")         

# ------------------------------------------------------------------------------------------
# # Exercise
# ------------------------------------------------------------------------------------------

h(a, b::Any) = "fallback"
h(a::Number, b::Number) = "a and b are both numbers"
h(a::Number, b) = "a is a number"
h(a, b::Number) = "b is a number"
h(a::Integer, b::Integer) = "a and b are both integers"

# Try playing with h
