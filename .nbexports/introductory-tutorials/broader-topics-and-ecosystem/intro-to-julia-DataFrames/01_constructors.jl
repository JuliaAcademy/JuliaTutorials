# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), May 23, 2018**
#
# Let's get started by loading the `DataFrames` package.
# ------------------------------------------------------------------------------------------

using DataFrames

# ------------------------------------------------------------------------------------------
# ## Constructors and conversion
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Constructors
#
# In this section, you'll see many ways to create a `DataFrame` using the `DataFrame()`
# constructor.
#
# First, we could create an empty DataFrame,
# ------------------------------------------------------------------------------------------

DataFrame() # empty DataFrame

# ------------------------------------------------------------------------------------------
# Or we could call the constructor using keyword arguments to add columns to the
# `DataFrame`.
# ------------------------------------------------------------------------------------------

DataFrame(A=1:3, B=rand(3), C=randstring.([3,3,3]))

# ------------------------------------------------------------------------------------------
# We can create a `DataFrame` from a dictionary, in which case keys from the dictionary will
# be sorted to create the `DataFrame` columns.
# ------------------------------------------------------------------------------------------

x = Dict("A" => [1,2], "B" => [true, false], "C" => ['a', 'b'])
DataFrame(x)

# ------------------------------------------------------------------------------------------
# Rather than explicitly creating a dictionary first, as above, we could pass `DataFrame`
# arguments with the syntax of dictionary key-value pairs.
#
# Note that in this case, we use symbols to denote the column names and arguments are not
# sorted. For example, `:A`, the symbol, produces `A`, the name of the first column here:
# ------------------------------------------------------------------------------------------

DataFrame(:A => [1,2], :B => [true, false], :C => ['a', 'b'])

# ------------------------------------------------------------------------------------------
# Here we create a `DataFrame` from a vector of vectors, and each vector becomes a column.
# ------------------------------------------------------------------------------------------

DataFrame([rand(3) for i in 1:3])

# ------------------------------------------------------------------------------------------
#  For now we can construct a single `DataFrame` from a `Vector` of atoms, creating a
# `DataFrame` with a single row. In future releases of DataFrames.jl, this will throw an
# error.
# ------------------------------------------------------------------------------------------

DataFrame(rand(3))

# ------------------------------------------------------------------------------------------
# Instead use a transposed vector if you have a vector of atoms (in this way you effectively
# pass a two dimensional array to the constructor which is supported).
# ------------------------------------------------------------------------------------------

DataFrame(transpose([1, 2, 3]))

# ------------------------------------------------------------------------------------------
# Pass a second argument to give the columns names.
# ------------------------------------------------------------------------------------------

DataFrame([1:3, 4:6, 7:9], [:A, :B, :C])

# ------------------------------------------------------------------------------------------
# Here we create a `DataFrame` from a matrix,
# ------------------------------------------------------------------------------------------

DataFrame(rand(3,4))

# ------------------------------------------------------------------------------------------
# and here we do the same but also pass column names.
# ------------------------------------------------------------------------------------------

DataFrame(rand(3,4), Symbol.('a':'d'))

# ------------------------------------------------------------------------------------------
# We can also construct an uninitialized DataFrame.
#
# Here we pass column types, names and number of rows; we get `missing` in column :C because
# `Any >: Missing`.
# ------------------------------------------------------------------------------------------

DataFrame([Int, Float64, Any], [:A, :B, :C], 1)

# ------------------------------------------------------------------------------------------
# Here we create a `DataFrame`, but column `:C` is #undef and Jupyter has problem with
# displaying it. (This works OK at the REPL.)
#
# This will be fixed in next release of DataFrames!
# ------------------------------------------------------------------------------------------

DataFrame([Int, Float64, String], [:A, :B, :C], 1)

# ------------------------------------------------------------------------------------------
# To initialize a `DataFrame` with column names, but no rows use
# ------------------------------------------------------------------------------------------

DataFrame([Int, Float64, String], [:A, :B, :C], 0) 

# ------------------------------------------------------------------------------------------
# This syntax gives us a quick way to create homogenous `DataFrame`.
# ------------------------------------------------------------------------------------------

DataFrame(Int, 3, 5)

# ------------------------------------------------------------------------------------------
# This example is similar, but has nonhomogenous columns.
# ------------------------------------------------------------------------------------------

DataFrame([Int, Float64], 4)

# ------------------------------------------------------------------------------------------
# Finally, we can create a `DataFrame` by copying an existing `DataFrame`.
#
# Note that `copy` creates a shallow copy.
# ------------------------------------------------------------------------------------------

y = DataFrame(x)
z = copy(x)
(x === y), (x === z), isequal(x, z)

# ------------------------------------------------------------------------------------------
# ### Conversion to a matrix
#
# Let's start by creating a `DataFrame` with two rows and two columns.
# ------------------------------------------------------------------------------------------

x = DataFrame(x=1:2, y=["A", "B"])

# ------------------------------------------------------------------------------------------
# We can create a matrix by passing this `DataFrame` to `Matrix`.
# ------------------------------------------------------------------------------------------

Matrix(x)

# ------------------------------------------------------------------------------------------
# This would work even if the `DataFrame` had some `missing`s:
# ------------------------------------------------------------------------------------------

x = DataFrame(x=1:2, y=[missing,"B"])

Matrix(x)

# ------------------------------------------------------------------------------------------
# In the two previous matrix examples, Julia created matrices with elements of type `Any`.
# We can see more clearly that the type of matrix is inferred when we pass, for example, a
# `DataFrame` of integers to `Matrix`, creating a 2D `Array` of `Int64`s:
# ------------------------------------------------------------------------------------------

x = DataFrame(x=1:2, y=3:4)

Matrix(x)

# ------------------------------------------------------------------------------------------
# In this next example, Julia correctly identifies that `Union` is needed to express the
# type of the resulting `Matrix` (which contains `missing`s).
# ------------------------------------------------------------------------------------------

x = DataFrame(x=1:2, y=[missing,4])

Matrix(x)

# ------------------------------------------------------------------------------------------
# Note that we can't force a conversion of `missing` values to `Int`s!
# ------------------------------------------------------------------------------------------

Matrix{Int}(x)

# ------------------------------------------------------------------------------------------
# ### Handling of duplicate column names
#
# We can pass the `makeunique` keyword argument to allow passing duplicate names (they get
# deduplicated)
# ------------------------------------------------------------------------------------------

df = DataFrame(:a=>1, :a=>2, :a_1=>3; makeunique=true)

# ------------------------------------------------------------------------------------------
# Otherwise, duplicates will not be allowed in the future.
# ------------------------------------------------------------------------------------------

df = DataFrame(:a=>1, :a=>2, :a_1=>3)

# ------------------------------------------------------------------------------------------
# A constructor that is passed column names as keyword arguments is a corner case.
# You cannot pass `makeunique` to allow duplicates here.
# ------------------------------------------------------------------------------------------

df = DataFrame(a=1, a=2, makeunique=true)
