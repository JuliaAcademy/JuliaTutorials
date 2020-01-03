# ------------------------------------------------------------------------------------------
# # Factorizations and other fun
# Based on work by Andreas Noack
#
# ## Outline
#  - Factorizations
#  - Special matrix structures
#  - Generic linear algebra
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Before we get started, let's set up a linear system and use `LinearAlgebra` to bring in
# the factorizations and special matrix structures.
# ------------------------------------------------------------------------------------------

using LinearAlgebra
A = rand(3, 3)
x = fill(1, (3,))
b = A * x

# ------------------------------------------------------------------------------------------
# ## Factorizations
#
# #### LU factorizations
# In Julia we can perform an LU factorization
# ```julia
# PA = LU
# ```
# where `P` is a permutation matrix, `L` is lower triangular unit diagonal and `U` is upper
# triangular, using `lufact`.
#
# Julia allows computing the LU factorization and defines a composite factorization type for
# storing it.
# ------------------------------------------------------------------------------------------

Alu = lu(A)

typeof(Alu)

# ------------------------------------------------------------------------------------------
# The different parts of the factorization can be extracted by accessing their special
# properties
# ------------------------------------------------------------------------------------------

Alu.P

Alu.L

Alu.U

# ------------------------------------------------------------------------------------------
# Julia can dispatch methods on factorization objects.
#
# For example, we can solve the linear system using either the original matrix or the
# factorization object.
# ------------------------------------------------------------------------------------------

A\b

Alu\b

# ------------------------------------------------------------------------------------------
# Similarly, we can calculate the determinant of `A` using either `A` or the factorization
# object
# ------------------------------------------------------------------------------------------

det(A) ≈ det(Alu)

# ------------------------------------------------------------------------------------------
# #### QR factorizations
#
# In Julia we can perform a QR factorization
# ```
# A=QR
# ```
#
# where `Q` is unitary/orthogonal and `R` is upper triangular, using `qrfact`.
# ------------------------------------------------------------------------------------------

Aqr = qr(A)

# ------------------------------------------------------------------------------------------
# Similarly to the LU factorization, the matrices `Q` and `R` can be extracted from the QR
# factorization object via
# ------------------------------------------------------------------------------------------

Aqr.Q

Aqr.R

# ------------------------------------------------------------------------------------------
# #### Eigendecompositions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The results from eigendecompositions, singular value decompositions, Hessenberg
# factorizations, and Schur decompositions are all stored in `Factorization` types.
#
# The eigendecomposition can be computed
# ------------------------------------------------------------------------------------------

Asym = A + A'
AsymEig = eigen(Asym)

# ------------------------------------------------------------------------------------------
# The values and the vectors can be extracted from the Eigen type by special indexing
# ------------------------------------------------------------------------------------------

AsymEig.values

AsymEig.vectors

# ------------------------------------------------------------------------------------------
# Once again, when the factorization is stored in a type, we can dispatch on it and write
# specialized methods that exploit the properties of the factorization, e.g. that
# $A^{-1}=(V\Lambda V^{-1})^{-1}=V\Lambda^{-1}V^{-1}$.
# ------------------------------------------------------------------------------------------

inv(AsymEig)*Asym

# ------------------------------------------------------------------------------------------
# ## Special matrix structures
# Matrix structure is very important in linear algebra. To see *how* important it is, let's
# work with a larger linear system
# ------------------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------------------
# ## Generic linear algebra
# The usual way of adding support for numerical linear algebra is by wrapping BLAS and
# LAPACK subroutines. For matrices with elements of `Float32`, `Float64`, `Complex{Float32}`
# or `Complex{Float64}` this is also what Julia does.
#
# However, Julia also supports generic linear algebra, allowing you to, for example, work
# with matrices and vectors of rational numbers.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Rational numbers
# Julia has rational numbers built in. To construct a rational number, use double forward
# slashes:
# ------------------------------------------------------------------------------------------

1//2

# ------------------------------------------------------------------------------------------
# #### Example: Rational linear system of equations
# The following example shows how linear system of equations with rational elements can be
# solved without promoting to floating point element types. Overflow can easily become a
# problem when working with rational numbers so we use `BigInt`s.
# ------------------------------------------------------------------------------------------

Arational = Matrix{Rational{BigInt}}(rand(1:10, 3, 3))/10

x = fill(1, 3)
b = Arational*x

Arational\b

lu(Arational)

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### 11.1
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
# and assign it a variable `A_eigv`
# ------------------------------------------------------------------------------------------

using LinearAlgebra



@assert A_eigv ==  [-128.49322764802145, -55.887784553056875, 42.7521672793189, 87.16111477514521, 542.4677301466143]

# ------------------------------------------------------------------------------------------
# #### 11.2
# Create a `Diagonal` matrix from the eigenvalues of `A`.
# ------------------------------------------------------------------------------------------



@assert A_diag ==  [-128.493    0.0      0.0      0.0       0.0;
    0.0    -55.8878   0.0      0.0       0.0;
    0.0      0.0     42.7522   0.0       0.0;
    0.0      0.0      0.0     87.1611    0.0;
    0.0 0.0      0.0      0.0     542.468]

# ------------------------------------------------------------------------------------------
# #### 11.3
# Create a `LowerTriangular` matrix from `A` and store it in `A_lowertri`
# ------------------------------------------------------------------------------------------



@assert A_lowertri ==  [140    0    0    0   0;
  97  106    0    0   0;
  74   89  152    0   0;
 168  131  144   54   0;
 131   36   71  142  36]

# ------------------------------------------------------------------------------------------
# ### Please let us know how we're doing!
# https://tinyurl.com/introJuliaFeedback
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Please click on `Validate` on the top, once you are done with the exercises.
# ------------------------------------------------------------------------------------------
