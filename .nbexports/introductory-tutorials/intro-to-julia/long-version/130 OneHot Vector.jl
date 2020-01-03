# ------------------------------------------------------------------------------------------
# Often used in machine learning, a "one hot" vector is a vector of all zeros, except for a
# single `1` entry.
# Representing it as a standard vector is memory-inefficient, so it cries out for a special
# implementation.
# ------------------------------------------------------------------------------------------

struct OneHotVector <: AbstractVector{Int}
    idx::Int
    len::Int
end

Base.size(v::OneHotVector) = (v.len,)

Base.getindex(v::OneHotVector, i::Integer) = Int(i == v.idx)

OneHotVector(3, 10)

A = rand(5,5)

A * OneHotVector(3, 5)

Vector(OneHotVector(3,5))

# ------------------------------------------------------------------------------------------
# ## Exercise
#
# Generalize it to any element type.
# ------------------------------------------------------------------------------------------


