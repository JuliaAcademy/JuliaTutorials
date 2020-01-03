# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), May 23, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames # load package

# ------------------------------------------------------------------------------------------
# ## Handling missing values
#
# A singelton type `Missings.Missing` allows us to deal with missing values.
# ------------------------------------------------------------------------------------------

missing, typeof(missing)

# ------------------------------------------------------------------------------------------
# Arrays automatically create an appropriate union type.
# ------------------------------------------------------------------------------------------

x = [1, 2, missing, 3]

# ------------------------------------------------------------------------------------------
# `ismissing` checks if passed value is missing.
# ------------------------------------------------------------------------------------------

ismissing(1), ismissing(missing), ismissing(x), ismissing.(x)

# ------------------------------------------------------------------------------------------
# We can extract the type combined with Missing from a `Union` via
#
# (This is useful for arrays!)
# ------------------------------------------------------------------------------------------

eltype(x), Missings.T(eltype(x))

# ------------------------------------------------------------------------------------------
# `missing` comparisons produce `missing`.
# ------------------------------------------------------------------------------------------

missing == missing, missing != missing, missing < missing

# ------------------------------------------------------------------------------------------
# This is also true when `missing`s are compared with values of other types.
# ------------------------------------------------------------------------------------------

1 == missing, 1 != missing, 1 < missing

# ------------------------------------------------------------------------------------------
# `isequal`, `isless`, and `===` produce results of type `Bool`.
# ------------------------------------------------------------------------------------------

isequal(missing, missing), missing === missing, isequal(1, missing), isless(1, missing)

# ------------------------------------------------------------------------------------------
# In the next few examples, we see that many (not all) functions handle `missing`.
# ------------------------------------------------------------------------------------------

map(x -> x(missing), [sin, cos, zero, sqrt]) # part 1

map(x -> x(missing, 1), [+, - , *, /, div]) # part 2 

map(x -> x([1,2,missing]), [minimum, maximum, extrema, mean, any, float]) # part 3

# ------------------------------------------------------------------------------------------
# `skipmissing` returns iterator skipping missing values. We can use `collect` and
# `skipmissing` to create an array that excludes these missing values.
# ------------------------------------------------------------------------------------------

collect(skipmissing([1, missing, 2, missing]))

# ------------------------------------------------------------------------------------------
# Similarly, here we combine `collect` and `Missings.replace` to create an array that
# replaces all missing values with some value (`NaN` in this case).
# ------------------------------------------------------------------------------------------

collect(Missings.replace([1.0, missing, 2.0, missing], NaN))

# ------------------------------------------------------------------------------------------
# Another way to do this:
# ------------------------------------------------------------------------------------------

coalesce.([1.0, missing, 2.0, missing], NaN)

# ------------------------------------------------------------------------------------------
# Caution: `nothing` would also be replaced here (for Julia 0.7 a more sophisticated
# behavior of `coalesce` that allows to avoid this problem is planned).
# ------------------------------------------------------------------------------------------

coalesce.([1.0, missing, nothing, missing], NaN)

# ------------------------------------------------------------------------------------------
# You can use `recode` if you have homogenous output types.
# ------------------------------------------------------------------------------------------

recode([1.0, missing, 2.0, missing], missing=>NaN)

# ------------------------------------------------------------------------------------------
# You can use `unique` or `levels` to get unique values with or without missings,
# respectively.
# ------------------------------------------------------------------------------------------

unique([1, missing, 2, missing]), levels([1, missing, 2, missing])

# ------------------------------------------------------------------------------------------
# In this next example, we convert `x` to `y` with `allowmissing`, where `y` has a type that
# accepts missings.
# ------------------------------------------------------------------------------------------

x = [1,2,3]
y = allowmissing(x)

# ------------------------------------------------------------------------------------------
# Then, we convert back with `disallowmissing`. This would fail if `y` contained missing
# values!
# ------------------------------------------------------------------------------------------

z = disallowmissing(y)
x,y,z

# ------------------------------------------------------------------------------------------
# In this next example, we show that the type of each column in `x` is initially `Int64`.
# After using `allowmissing!` to accept missing values in columns 1 and 3, the types of
# those columns become `Union`s of `Int64` and `Missings.Missing`.
# ------------------------------------------------------------------------------------------

x = DataFrame(Int, 2, 3)
println("Before: ", eltypes(x))
allowmissing!(x, 1) # make first column accept missings
allowmissing!(x, :x3) # make :x3 column accept missings
println("After: ", eltypes(x))

# ------------------------------------------------------------------------------------------
# In this next example, we'll use `completecases` to find all the rows of a `DataFrame` that
# have complete data.
# ------------------------------------------------------------------------------------------

x = DataFrame(A=[1, missing, 3, 4], B=["A", "B", missing, "C"])
println(x)
println("Complete cases:\n", completecases(x))

# ------------------------------------------------------------------------------------------
# We can use `dropmissing` or `dropmissing!` to remove the rows with incomplete data from a
# `DataFrame` and either create a new `DataFrame` or mutate the original in-place.
# ------------------------------------------------------------------------------------------

y = dropmissing(x)
dropmissing!(x)
[x, y]

# ------------------------------------------------------------------------------------------
# When we call `showcols` on a `DataFrame` with dropped missing values, the columns still
# allow missing values.
# ------------------------------------------------------------------------------------------

showcols(x)

# ------------------------------------------------------------------------------------------
# Since we've excluded missing values, we can safely use `disallowmissing!` so that the
# columns will no longer accept missing values.
# ------------------------------------------------------------------------------------------

disallowmissing!(x)
showcols(x)
