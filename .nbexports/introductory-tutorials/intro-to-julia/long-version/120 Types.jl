# ------------------------------------------------------------------------------------------
# # Julia's Type System
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia programs manipulate *values*, and every value has two parts: a *type* part and a
# data part. The type part answers the question "what kind of thing is this?", and the data
# part distinguishes one thing of a certain kind from every other thing of that kind.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Part 1. DataType
# ------------------------------------------------------------------------------------------

typeof(3)

# ------------------------------------------------------------------------------------------
# In this case the type is `Int64` and the data part is the bits `...0011`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# In Julia types are also values:
# ------------------------------------------------------------------------------------------

typeof(Int64)

typeof(DataType)

# ------------------------------------------------------------------------------------------
# In fact, the identity `typeof(typeof(x)) === DataType` holds for all values in Julia.
# `DataType` is the backbone of the entire system. It does many jobs, which can be
# identified by looking inside a `DataType` object:
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### DataType Job 1: A symbolic description
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# This consists of a name (which is mostly a string), and a vector of sub-components:
# ------------------------------------------------------------------------------------------

T = typeof(1+2im)

T.name

T.parameters

# ------------------------------------------------------------------------------------------
# ### DataType Job 2: A nominal hierarchy of types
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# DataTypes form a tree of declared type relationships ("an x is-a y"):
# ------------------------------------------------------------------------------------------

T.super

T.super.super.super.super  # `Any` is the built-in top of the hierarchy.

# ------------------------------------------------------------------------------------------
# ### DataType Job 3: Describe the representation
# ------------------------------------------------------------------------------------------

T.types

T.name.names

T.size

T.mutable   # whether this was declared with `type` (vs. `immutable`)

T.abstract  # whether this was declared with `abstract`

T.ninitialized

T.layout

# ------------------------------------------------------------------------------------------
# ### Defining struct types
# 
# ------------------------------------------------------------------------------------------

struct Point
    x::Float64
    y::Float64
end

Point(1,2)

# ------------------------------------------------------------------------------------------
# ### Abstract vs. Concrete
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# `abstract` types can have declared subtypes, while concrete types can have instances.
# These are separated because if an `X` IS-A `Y`, and `Y` specifies a representation, then
# `X` had better have the same representation.
#
# "car is-a vehicle" is correct because "vehicle" is an abstract concept that doesn't commit
# to any specifics. But if I tell you I'm giving you a Porsche, it needs to look like a
# Porsche.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# A type `T` is concrete if there could be some value `x` such that `typeof(x) === T`. This
# is also sometimes called a "leaf type".
# ------------------------------------------------------------------------------------------

abstract type PointLike end

# struct Point <: PointLike

# ------------------------------------------------------------------------------------------
# ## Part 2. Type parameters
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Type parameters can be completely or partially specified:
# ------------------------------------------------------------------------------------------

Array{Int}

[1] isa Array

Array{Int,2}

# ------------------------------------------------------------------------------------------
# A type is concrete (can have instances) if
#     1. it is not declared `abstract`
#     2. all parameters are specified
# ------------------------------------------------------------------------------------------

[1] isa Array{Int,1}

[1] isa Array{Int}

[1] isa Array{Number}

Int <: Number

# ------------------------------------------------------------------------------------------
# Types with different *specified* parameters are just different, and have no subtype
# relationship. This is called *invariance*.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Defining types with parameters
# ------------------------------------------------------------------------------------------

struct GenericPoint{T<:Real}
    x::T
    y::T
end

GenericPoint(1,2)

GenericPoint(1.0,2.0)

GenericPoint(1,2.0)

# ------------------------------------------------------------------------------------------
# ### Tuple types
# ------------------------------------------------------------------------------------------

typeof((1,2.0))

# ------------------------------------------------------------------------------------------
# Very similar to other DataTypes, except
#     1. Have no field names, only indices
#     2. `T.parameters == T.types`
#     3. Are always immutable
#     4. Can have any number of fields
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# These factors conspire to make Tuples the only *covariant* types in Julia:
# ------------------------------------------------------------------------------------------

Tuple{Int} <: Tuple{Number}

# ------------------------------------------------------------------------------------------
# A Tuple type is concrete iff all its field types are.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Tuple types can be abstract with respect to the number of elements. These are called
# variadic tuple types, or vararg types.
# ------------------------------------------------------------------------------------------

Tuple{Int,Vararg{Int}}

# ------------------------------------------------------------------------------------------
# Note that `Vararg` refers to the tail of a tuple type, and as such is not a first-class
# type itself. It only makes sense inside a Tuple type. This is a bit unfortunate.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The second parameter to `Vararg` is a length, which can also be either unspecified (as
# above), or specified:
# ------------------------------------------------------------------------------------------

Tuple{Int,Vararg{Int,2}}

# ------------------------------------------------------------------------------------------
# ## Part 3. Larger type domains
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Union types
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# A type can be thought of as a set of possible values. A type expresses *uncertainty* about
# which value we have. You can do set operations on them.
# ------------------------------------------------------------------------------------------

Union{Int64,Float64}

1 isa Union{Int64,Float64}

Int64 <: Number

Int64 <: Union{Int64,Float64}

Union{Int,String} <: Union{Int,String,Float32}

typeintersect(Union{Int,String}, Union{Int,String,Float32})

# ------------------------------------------------------------------------------------------
# Union types naturally lend themselves to missing data.
# ------------------------------------------------------------------------------------------

data = [1.1, missing, 3.2, missing, 5.7, 0.4]

# ------------------------------------------------------------------------------------------
# ### UnionAll types
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# This is an *iterated union* of types.
#
# `Array{T,1} where T<:Integer`
#
# Means "the union of all types of the form Array{T,1} where T is a subtype of Integer".
#
# This expresses uncertainty about the value of a parameter.
#
# This concept exists in all versions of Julia, but does not have syntax or fully correct
# support within the system until upcoming v0.6.0 (currently on branch jb/subtype).
#
# * Since this kind of type introduces *variables*, its expressive power is (probably)
# equivalent to quantified boolean formulas.
# * Requires a quantified-SAT solver in the compiler.
# * Under common assumptions, harder than NP-complete.
# ------------------------------------------------------------------------------------------

# this definition is in the Base library
Vector = Array{T,1} where T

# ------------------------------------------------------------------------------------------
# These are used to express "unspecified parameters".
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# These also describe methods with "method parameters" (or "static parameters"):
# ------------------------------------------------------------------------------------------

func(a::Array{T,1}) where {T<:Integer} = T

func([0x00])

func([1.0])

# ------------------------------------------------------------------------------------------
# #### Question
#
# What is the difference between
#
# `Vector{Vector{T}} where T`
#
# and
#
# `Vector{Vector{T} where T}`?
#
# Is one a subtype of the other?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercise
#
# Define a `UnitPoint{<:Real}` parametric struct type which has `x` and `y` fields of type
# `T` and which has an inner constructor that normalizes its arguments by diving them by
# `hypot(x, y)` upon construction, guaranteeing that the resulting point is on the unit
# circle.
# ------------------------------------------------------------------------------------------


