# ------------------------------------------------------------------------------------------
# # ModInt: a simple modular integer type
# ------------------------------------------------------------------------------------------

struct ModInt{n} <: Integer
    k::Int

    # Constructor definition...
    # note the left side looks like the call it defines
    ModInt{n}(k::Int) where {n} = new(mod(k,n))
end

a = ModInt{13}(1238279873492834)

b = ModInt{13}(9872349827349827)

a + b

# ------------------------------------------------------------------------------------------
# To extend standard functions we need to import them.
# ------------------------------------------------------------------------------------------

import Base: +

+(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k + b.k)

a + b

import Base: *, -

*(a::ModInt{n}, b::ModInt{n}) where{n} = ModInt{n}(a.k * b.k)
-(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k - b.k)
-(a::ModInt{n}) where {n} = ModInt{n}(-a.k)

a * b

a - b

-b

Base.show(io::IO, a::ModInt{n}) where {n} =
    get(io, :compact, false) ? show(io, a.k) : print(io, "$(a.k) mod $n")

a

b

a + 1

Base.promote_rule(::Type{ModInt{n}}, ::Type{Int}) where {n} = ModInt{n}

Base.convert(::Type{ModInt{n}}, x::Int) where {n} = ModInt{n}(x)

a + 1

1 + a

A = map(ModInt{13}, rand(1:100, 5, 5))

A^100000000

2A^100 .- 1

# ------------------------------------------------------------------------------------------
# ### Summary
#
# Here is all the code that defines the `ModInt` type:
# ```jl
# struct ModInt{n} <: Integer
#     k::Int
#
#     # Constructor definition...
#     # note the left side looks like the call it defines
#     ModInt{n}(k::Int) where {n} = new(mod(k,n))
# end
#
# import Base: +, *, -
#
# +(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k + b.k)
# *(a::ModInt{n}, b::ModInt{n}) where{n} = ModInt{n}(a.k * b.k)
# -(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k - b.k)
# -(a::ModInt{n}) where {n} = ModInt{n}(-a.k)
#
# Base.show(io::IO, a::ModInt{n}) where {n} =
#     get(io, :compact, false) ? show(io, a.k) : print(io, "$(a.k) mod $n")
#
# Base.promote_rule(::Type{ModInt{n}}, ::Type{Int}) where {n} = ModInt{n}
# Base.convert(::Type{ModInt{n}}, x::Int) where {n} = ModInt{n}(x)
# ```
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercise
#
# Add two methods that allows operations between modular integers with different modulus
# using the rule that they should combine in the modulus that is the `lcm` (least common
# multiple) of the moduli of the arguments.
#
# **Hint:** try something, see what fails, define something to make that work.
# ------------------------------------------------------------------------------------------

x = ModInt{12}(9)

y = ModInt{15}(13)

# two method definitions here...

@assert x + y == ModInt{60}(22)
@assert x * y == ModInt{60}(57)
