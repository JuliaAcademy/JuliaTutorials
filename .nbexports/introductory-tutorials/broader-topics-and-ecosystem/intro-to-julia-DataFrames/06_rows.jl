# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames # load package
srand(1);

# ------------------------------------------------------------------------------------------
# ## Manipulating rows of DataFrame
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Reordering rows
# ------------------------------------------------------------------------------------------

x = DataFrame(id=1:10, x = rand(10), y = [zeros(5); ones(5)]) # and we hope that x[:x] is not sorted :)

issorted(x), issorted(x, :x) # check if a DataFrame or a subset of its columns is sorted

sort!(x, :x) # sort x in place

y = sort(x, :id) # new DataFrame

sort(x, (:y, :x), rev=(true, false)) # sort by two columns, first is decreasing, second is increasing

sort(x, (order(:y, rev=true), :x)) # the same as above

sort(x, (order(:y, rev=true), order(:x, by=v->-v))) # some more fancy sorting stuff

x[shuffle(1:10), :] # reorder rows (here randomly)

sort!(x, :id)
x[[1,10],:] = x[[10,1],:] # swap rows
x

x[1,:], x[10,:] = x[10,:], x[1,:] # and swap again
x

# ------------------------------------------------------------------------------------------
# ### Merging/adding rows
# ------------------------------------------------------------------------------------------

x = DataFrame(rand(3, 5))

[x; x] # merge by rows - data frames must have the same column names; the same is vcat

y = x[reverse(names(x))] # get y with other order of names

vcat(x, y) # we get what we want as vcat does column name matching

vcat(x, y[1:3]) # but column names must still match

append!(x, x) # the same but modifies x

append!(x, y) # here column names must match exactly

push!(x, 1:5) # add one row to x at the end; must give correct number of values and correct types
x

push!(x, Dict(:x1=> 11, :x2=> 12, :x3=> 13, :x4=> 14, :x5=> 15)) # also works with dictionaries
x

# ------------------------------------------------------------------------------------------
# ### Subsetting/removing rows
# ------------------------------------------------------------------------------------------

x = DataFrame(id=1:10, val='a':'j')

x[1:2, :] # by index

view(x, 1:2) # the same but a view

x[repmat([true, false], 5), :] # by Bool, exact length required

view(x, repmat([true, false], 5), :) # view again

deleterows!(x, 7) # delete one row

deleterows!(x, 6:7) # delete a collection of rows

x = DataFrame([1:4, 2:5, 3:6])

filter(r -> r[:x1] > 2.5, x) # create a new DataFrame where filtering function operates on DataFrameRow

# in place modification of x, an example with do-block syntax
filter!(x) do r
    if r[:x1] > 2.5
        return r[:x2] < 4.5
    end
    r[:x3] < 3.5
end

# ------------------------------------------------------------------------------------------
# ### Deduplicating
# ------------------------------------------------------------------------------------------

x = DataFrame(A=[1,2], B=["x","y"])
append!(x, x)
x[:C] = 1:4
x

unique(x, [1,2]) # get first unique rows for given index

unique(x) # now we look at whole rows

nonunique(x, :A) # get indicators of non-unique rows

unique!(x, :B) # modify x in place

# ------------------------------------------------------------------------------------------
# ### Extracting one row from `DataFrame` into a vector
# ------------------------------------------------------------------------------------------

x = DataFrame(x=[1,missing,2], y=["a", "b", missing], z=[true,false,true])

cols = [:x, :y]
[x[1, col] for col in cols] # subset of columns

[[x[i, col] for col in names(x)] for i in 1:nrow(x)] # vector of vectors, each entry contains one full row of x

Tuple(x[1, col] for col in cols) # similar construct for Tuples, when ported to Julia 0.7 NamedTuples will be added
