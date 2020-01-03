# ------------------------------------------------------------------------------------------
# # Basic linear algebra in Julia
# Author: Andreas Noack Jensen (MIT) (http://www.econ.ku.dk/phdstudent/noack/)
# (with edits from Jane Herriman)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# First let's define a random matrix
# ------------------------------------------------------------------------------------------

A = rand(1:4,3,3)

# ------------------------------------------------------------------------------------------
# Define a vector of ones
# ------------------------------------------------------------------------------------------

x = fill(1.0, (3,)) # = fill(1.0, 3)

# ------------------------------------------------------------------------------------------
# Notice that $A$ has type Array{Int64,2} but $x$ has type Array{Float64,1}. Julia defines
# the aliases Vector{Type}=Array{Type,1} and Matrix{Type}=Array{Type,2}.
#
# Many of the basic operations are the same as in other languages
# #### Multiplication
# ------------------------------------------------------------------------------------------

b = A*x

# ------------------------------------------------------------------------------------------
# #### Transposition
# As in other languages `A'` is the conjugate transpose, or adjoint
# ------------------------------------------------------------------------------------------

A'

# ------------------------------------------------------------------------------------------
# and we can get the transpose with
# ------------------------------------------------------------------------------------------

transpose(A)

# ------------------------------------------------------------------------------------------
# #### Transposed multiplication
# Julia allows us to write this without *
# ------------------------------------------------------------------------------------------

A'A

# ------------------------------------------------------------------------------------------
# #### Solving linear systems
# The problem $Ax=b$ for ***square*** $A$ is solved by the \ function.
# ------------------------------------------------------------------------------------------

A\b

# ------------------------------------------------------------------------------------------
# `A\b` gives us the *least squares solution* if we have an overdetermined linear system (a
# "tall" matrix)
# ------------------------------------------------------------------------------------------

Atall = rand(3, 2)

Atall\b

# ------------------------------------------------------------------------------------------
# and the *minimum norm least squares solution* if we have a rank-deficient least squares
# problem
# ------------------------------------------------------------------------------------------

v = rand(3)
rankdef = hcat(v, v)

rankdef\b

# ------------------------------------------------------------------------------------------
# Julia also gives us the minimum norm solution when we have an underdetermined solution (a
# "short" matrix)
# ------------------------------------------------------------------------------------------

bshort = rand(2)
Ashort = rand(2, 3)

Ashort\bshort

# ------------------------------------------------------------------------------------------
# # The LinearAlgebra library
#
# While much of linear algebra is available in Julia by default (as shown above), there's a
# standard library named `LinearAlgebra` that brings in many more relevant names and
# functions. In particular, it provides factorizations and some structured matrix types.  As
# with all packages, you can bring these additional features into your session with a `using
# LinearAlgebra`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### 10.1
# Take the inner product (or "dot" product) of a vector `v` with itself and assign it to
# variable `dot_v`.
#
# 
# ------------------------------------------------------------------------------------------

v = [1,2,3]



@assert dot_v == 14

# ------------------------------------------------------------------------------------------
# #### 10.2
# Take the outer product of a vector v with itself and assign it to variable `outer_v`
# ------------------------------------------------------------------------------------------



@assert outer_v == [1 2 3
                    2 4 6
                    3 6 9]

@assert cross_v == [0, 0, 0]

# ------------------------------------------------------------------------------------------
# Please click on `Validate` on the top, once you are done with the exercises.
# ------------------------------------------------------------------------------------------
