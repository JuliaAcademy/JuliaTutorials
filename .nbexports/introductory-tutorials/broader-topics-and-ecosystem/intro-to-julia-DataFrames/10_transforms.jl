# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames # load package

# ------------------------------------------------------------------------------------------
# ## Split-apply-combine
# ------------------------------------------------------------------------------------------

x = DataFrame(id=[1,2,3,4,1,2,3,4], id2=[1,2,1,2,1,2,1,2], v=rand(8))

gx1 = groupby(x, :id)

gx2 = groupby(x, [:id, :id2])

vcat(gx2...) # back to the original DataFrame

x = DataFrame(id = [missing, 5, 1, 3, missing], x = 1:5)

showall(groupby(x, :id)) # by default groups include mising values and are not sorted

showall(groupby(x, :id, sort=true, skipmissing=true)) # but we can change it :)

x = DataFrame(id=rand('a':'d', 100), v=rand(100));
by(x, :id, y->mean(y[:v])) # apply a function to each group of a data frame

by(x, :id, y->mean(y[:v]), sort=true) # we can sort the output

by(x, :id, y->DataFrame(res=mean(y[:v]))) # this way we can set a name for a column - DataFramesMeta @by is better

x = DataFrame(id=rand('a':'d', 100), x1=rand(100), x2=rand(100))
aggregate(x, :id, sum) # apply a function over all columns of a data frame in groups given by id

aggregate(x, :id, sum, sort=true) # also can be sorted

# ------------------------------------------------------------------------------------------
# *We omit the discussion of of map/combine as I do not find them very useful (better to use
# by)*
# ------------------------------------------------------------------------------------------

x = DataFrame(rand(3, 5))

map(mean, eachcol(x)) # map a function over each column and return a data frame

foreach(c -> println(c[1], ": ", mean(c[2])), eachcol(x)) # a raw iteration returns a tuple with column name and values

colwise(mean, x) # colwise is similar, but produces a vector

x[:id] = [1,1,2]
colwise(mean,groupby(x, :id)) # and works on GroupedDataFrame

map(r -> r[:x1]/r[:x2], eachrow(x)) # now the returned value is DataFrameRow which works similarly to a one-row DataFrame
