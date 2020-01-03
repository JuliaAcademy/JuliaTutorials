# ------------------------------------------------------------------------------------------
# # Linear algebra in Julia
# Based on work by Andreas Noack Jensen
#
# ## Basic linalg ops
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# First let's define a random matrix
# ------------------------------------------------------------------------------------------

A = rand(1:4,3,3)

# ------------------------------------------------------------------------------------------
# Define a vector of ones
# ------------------------------------------------------------------------------------------

x = fill(1.0, (3))

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
# As in other languages `A'` is the conjugate transpose
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
# ## Special Matrix Structures
#
# Matrix structure is very important in linear algebra. To see *how* important it is, let's
# work with a larger linear system. Use the LinearAlgebra standard package to get access to
# structured matrices:
# ------------------------------------------------------------------------------------------

using LinearAlgebra

n = 1000
A = randn(n,n);

# ------------------------------------------------------------------------------------------
# Julia can often infer special matrix structure
# ------------------------------------------------------------------------------------------

Asym = A + A'
issymmetric(Asym)

# ------------------------------------------------------------------------------------------
# but sometimes floating point error might get in the way.
# ------------------------------------------------------------------------------------------

Asym_noisy = copy(Asym)
Asym_noisy[1,2] += 5eps()

issymmetric(Asym_noisy)

# ------------------------------------------------------------------------------------------
# Luckily we can declare structure explicitly with, for example, `Diagonal`, `Triangular`,
# `Symmetric`, `Hermitian`, `Tridiagonal` and `SymTridiagonal`.
# ------------------------------------------------------------------------------------------

Asym_explicit = Symmetric(Asym_noisy);

# ------------------------------------------------------------------------------------------
# Let's compare how long it takes Julia to compute the eigenvalues of `Asym`, `Asym_noisy`,
# and `Asym_explicit`
# ------------------------------------------------------------------------------------------

@time eigvals(Asym);

@time eigvals(Asym_noisy);

@time eigvals(Asym_explicit);

# ------------------------------------------------------------------------------------------
# In this example, using `Symmetric()` on `Asym_noisy` made our calculations about `5x` more
# efficient :)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### A big problem
# Using the `Tridiagonal` and `SymTridiagonal` types to store tridiagonal matrices makes it
# possible to work with potentially very large tridiagonal problems. The following problem
# would not be possible to solve on a laptop if the matrix had to be stored as a (dense)
# `Matrix` type.
# ------------------------------------------------------------------------------------------

n = 1_000_000;
A = SymTridiagonal(randn(n), randn(n-1));
@time eigmax(A)
