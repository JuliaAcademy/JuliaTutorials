# ------------------------------------------------------------------------------------------
# # Iterators
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# `for` loops "lower" to `while` loops plus calls to the `iterate` function:
#
# ```jl
# for i in iter   # or  "for i = iter" or "for i ∈ iter"
#     # body
# end
# ```
#
# internally works the same as:
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ```jl
# next = iterate(iter)
# while next !== nothing
#     (i, state) = next
#     # body
#     next = iterate(iter, state)
# end
# ```
#
# The same applies to comprehensions and generators.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Note `nothing` is a singleton value (the only value of its type `Nothing`) used by
# convention when there is no value to return (a bit like `void` in C). For example
# ------------------------------------------------------------------------------------------

typeof(print("hello"))

A = ['a','b','c'];

iterate(A)

iterate(A, 2)

iterate(A, 3)

iterate(A, 4)

# ------------------------------------------------------------------------------------------
# Iteration is also used by "destructuring" assignment:
# ------------------------------------------------------------------------------------------

x, y = A

x

y

# ------------------------------------------------------------------------------------------
# Yet another user of this "iteration protocol" is so-called argument "splatting":
# ------------------------------------------------------------------------------------------

string(A)

string('a','b','c')

string(A...)

# ------------------------------------------------------------------------------------------
# ## Iteration utilities
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# `collect` gives you all elements of an iterator as an array.
# Comprehensions are actually equivalent to calling `collect` on a generator.
# ------------------------------------------------------------------------------------------

collect(pairs(A))

collect(zip(100:102,A))

# ------------------------------------------------------------------------------------------
# Some other favorites to experiment with. These are in the built-in `Iterators` module:
# - `enumerate`
# - `rest`
# - `take`
# - `drop`
# - `product`
# - `flatten`
# - `partition`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Some iterators are infinite!
# - `countfrom`
# - `repeated`
# - `cycle`
# ------------------------------------------------------------------------------------------

I = zip(Iterators.cycle(0:1), Iterators.flatten([[2,3],[4,5]]))

collect(I)

collect(Iterators.product(I,A))

string(I...)

# ------------------------------------------------------------------------------------------
# ## Defining iterators
# ------------------------------------------------------------------------------------------

struct SimpleRange
    lo::Int
    hi::Int
end

Base.iterate(r::SimpleRange, state = r.lo) = state > r.hi ? nothing : (state, state+1)

Base.length(r::SimpleRange) = r.hi-r.lo+1

collect(SimpleRange(2,8))

# ------------------------------------------------------------------------------------------
# ## Iterator traits
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# For many algorithms, it's useful to know certain properties of an iterator up front.
#
# The most useful is whether an iterator has a fixed, known length.
# ------------------------------------------------------------------------------------------

Base.IteratorSize([1])

Base.IteratorSize(Iterators.repeated(1))

Base.IteratorSize(eachline(open("/dev/null")))

# ------------------------------------------------------------------------------------------
# ## Exercise
#
# Define an iterator giving the first N fibonacci numbers.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Index iterators
# ------------------------------------------------------------------------------------------

A = rand(3,5)

eachindex(A)

keys(A)

Av = view(A, [1,3], [1,2,5])

A[[1,3],[1,2,5]]

eachindex(Av)

# ------------------------------------------------------------------------------------------
# ### Example: $3\times 3\times \dots \times3$ boxcar filter (from a blog post by Tim Holy)
# ------------------------------------------------------------------------------------------

function boxcar3(A::AbstractArray)
    out = similar(A)
    R = CartesianIndices(size(A))
    I1, Iend = first(R), last(R)
    for I in R
        n, s = 0, zero(eltype(out))
        for J in CartesianIndices(map(:, max(I1, I-I1).I, min(Iend, I+I1).I))
            s += A[J]
            n += 1
        end
        out[I] = s/n
    end
    out
end

using Images

A = rand(256,256);

Gray.(A)

Gray.(boxcar3(A))

function sumalongdims!(B, A)
    # It's assumed that B has size 1 along any dimension that we're summing
    fill!(B, 0)
    Bmax = CartesianIndex(size(B))
    for I in CartesianIndices(size(A))
        B[min(Bmax,I)] += A[I]
    end
    B
end

B = zeros(1, 256)

sumalongdims!(B, A)

reduce(+,A,dims=(1,))

# ------------------------------------------------------------------------------------------
# `CartesianIndices` and other "N-d" iterators have a shape that propagates through
# generators.
# ------------------------------------------------------------------------------------------

[1 for i in CartesianIndices((2,3))]

B = rand(5,5)

view(B,CartesianIndices((2,3)))

# ------------------------------------------------------------------------------------------
# ## Exercise: CartesianIndex life!
#
# - Write a function `neighborhood(A::Array, I::CartesianIndex)` that returns a view of the
# 3x3 neighborhood around a location
# - Write a function `liferule(A, I)` that implements the evolution rule of Conway's life
# cellular automaton:
#   - 2 live neighbors $\rightarrow$ stay the same
#   - 3 live neighbors $\rightarrow$ 1
#   - otherwise $\rightarrow$ 0
# - Write a function `life(A)` that maps A to the next life step using these
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Some famous initial conditions:
# ------------------------------------------------------------------------------------------

A = fill(0, 128,128);

A[61:63,61:63] = [1 1 0
                  0 1 1
                  0 1 0]

A = life(A)
# `repeat` can be used to get chunky pixels to make the output easier to see
Gray.(repeat(A,inner=(4,4)))


