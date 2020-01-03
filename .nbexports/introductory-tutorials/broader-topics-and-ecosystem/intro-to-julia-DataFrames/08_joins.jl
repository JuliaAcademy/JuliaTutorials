# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2017**
# ------------------------------------------------------------------------------------------

using DataFrames # load package

# ------------------------------------------------------------------------------------------
# ## Joining DataFrames
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Preparing DataFrames for a join
# ------------------------------------------------------------------------------------------

x = DataFrame(ID=[1,2,3,4,missing], name = ["Alice", "Bob", "Conor", "Dave","Zed"])
y = DataFrame(id=[1,2,5,6,missing], age = [21,22,23,24,99])
x,y

rename!(x, :ID=>:id) # names of columns on which we want to join must be the same

# ------------------------------------------------------------------------------------------
# ### Standard joins: inner, left, right, outer, semi, anti
# ------------------------------------------------------------------------------------------

join(x, y, on=:id) # :inner join by default, missing is joined

join(x, y, on=:id, kind=:left)

join(x, y, on=:id, kind=:right)

join(x, y, on=:id, kind=:outer)

join(x, y, on=:id, kind=:semi)

join(x, y, on=:id, kind=:anti)

# ------------------------------------------------------------------------------------------
# ### Cross join
# ------------------------------------------------------------------------------------------

# cross-join does not require on argument
# it produces a Cartesian product or arguments
function expand_grid(;xs...) # a simple replacement for expand.grid in R
    reduce((x,y) -> join(x, DataFrame(Pair(y...)), kind=:cross),
           DataFrame(Pair(xs[1]...)), xs[2:end])
end

expand_grid(a=[1,2], b=["a","b","c"], c=[true,false])

# ------------------------------------------------------------------------------------------
# ### Complex cases of joins
# ------------------------------------------------------------------------------------------

x = DataFrame(id1=[1,1,2,2,missing,missing],
              id2=[1,11,2,21,missing,99],
              name = ["Alice", "Bob", "Conor", "Dave","Zed", "Zoe"])
y = DataFrame(id1=[1,1,3,3,missing,missing],
              id2=[11,1,31,3,missing,999],
              age = [21,22,23,24,99, 100])
x,y

join(x, y, on=[:id1, :id2]) # joining on two columns

join(x, y, on=[:id1], makeunique=true) # with duplicates all combinations are produced (here :inner join)

join(x, y, on=[:id1], kind=:semi) # but not by :semi join (as it would duplicate rows)
