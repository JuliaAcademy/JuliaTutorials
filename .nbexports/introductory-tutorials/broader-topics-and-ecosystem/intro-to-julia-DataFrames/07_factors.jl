# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames # load package

# ------------------------------------------------------------------------------------------
# ## Working with CategoricalArrays
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Constructor
# ------------------------------------------------------------------------------------------

x = categorical(["A", "B", "B", "C"]) # unordered

y = categorical(["A", "B", "B", "C"], ordered=true) # ordered, by default order is sorting order

z = categorical(["A","B","B","C", missing]) # unordered with missings

c = cut(1:10, 5) # ordered, into equal counts, possible to rename labels and give custom breaks

by(DataFrame(x=cut(randn(100000), 10)), :x, d -> DataFrame(n=nrow(d)), sort=true) # just to make sure it works right

v = categorical([1,2,2,3,3]) # contains integers not strings

Vector{Union{String, Missing}}(z) # sometimes you need to convert back to a standard vector

# ------------------------------------------------------------------------------------------
# ### Managing levels
# ------------------------------------------------------------------------------------------

arr = [x,y,z,c,v]

isordered.(arr) # chcek if categorical array is orderd

ordered!(x, true), isordered(x) # make x ordered

ordered!(x, false), isordered(x) # and unordered again

levels.(arr) # list levels

unique.(arr) # missing will be included

y[1] < y[2] # can compare as y is ordered

v[1] < v[2] # not comparable, v is unordered although it contains integers

levels!(y, ["C", "B", "A"]) # you can reorder levels, mostly useful for ordered CategoricalArrays

y[1] < y[2] # observe that the order is changed

levels!(z, ["A", "B"]) # you have to specify all levels that are present

levels!(z, ["A", "B"], allow_missing=true) # unless the underlying array allows for missings and force removal of levels

z[1] = "B"
z # now z has only "B" entries

levels(z) # but it remembers the levels it had (the reason is mostly performance)

droplevels!(z) # this way we can clean it up
levels(z)

# ------------------------------------------------------------------------------------------
# ### Data manipulation
# ------------------------------------------------------------------------------------------

x, levels(x)

x[2] = "0"
x, levels(x) # new level added at the end (works only for unordered)

v, levels(v)

v[1] + v[2] # even though underlying data is Int, we cannot operate on it

Vector{Int}(v) # you have either to retrieve the data by conversion (may be expensive)

get(v[1]) + get(v[2]) # or get a single value

get.(v) # this will work for arrays witout missings

get.(z) # but will fail on missing values

Vector{Union{String, Missing}}(z) # you have to do the conversion

z[1]*z[2], z.^2 # the only exception are CategoricalArrays based on String - you can operate on them normally

recode([1,2,3,4,5,missing], 1=>10) # recode some values in an array; has also in place recode! equivalent

recode([1,2,3,4,5,missing], "a", 1=>10, 2=>20) # here we provided a default value for not mapped recodings

recode([1,2,3,4,5,missing], 1=>10, missing=>"missing") # to recode Missing you have to do it explicitly

t = categorical([1:5; missing])
t, levels(t)

recode!(t, [1,3]=>2)
t, levels(t) # note that the levels are dropped after recode

t = categorical([1,2,3], ordered=true)
levels(recode(t, 2=>0, 1=>-1)) # and if you introduce a new levels they are added at the end in the order of appearance

t = categorical([1,2,3,4,5], ordered=true) # when using default it becomes the last level
levels(recode(t, 300, [1,2]=>100, 3=>200))

# ------------------------------------------------------------------------------------------
# ### Comparisons
# ------------------------------------------------------------------------------------------

x = categorical([1,2,3])
xs = [x, categorical(x), categorical(x, ordered=true), categorical(x, ordered=true)]
levels!(xs[2], [3,2,1])
levels!(xs[4], [2,3,1])
[a == b for a in xs, b in xs] # all are equal - comparison only by contents

signature(x::CategoricalArray) = (x, levels(x), isordered(x)) # this is actually the full signature of CategoricalArray
# all are different, notice that x[1] and x[2] are unordered but have a different order of levels
[signature(a) == signature(b) for a in xs, b in xs]

x[1] < x[2] # you cannot compare elements of unordered CategoricalArray

t[1] < t[2] # but you can do it for an ordered one

isless(x[1], x[2]) # isless works within the same CategoricalArray even if it is not ordered

y = deepcopy(x) # but not across categorical arrays
isless(x[1], y[2])

isless(get(x[1]), get(y[2])) # you can use get to make a comparison of the contents of CategoricalArray

x[1] == y[2] # equality tests works OK across CategoricalArrays

# ------------------------------------------------------------------------------------------
# ### Categorical columns in a DataFrame
# ------------------------------------------------------------------------------------------

df = DataFrame(x = 1:3, y = 'a':'c', z = ["a","b","c"])

categorical!(df) # converts all eltype(AbstractString) columns to categorical

showcols(df)

categorical!(df, :x) # manually convert to categorical column :x

showcols(df)
