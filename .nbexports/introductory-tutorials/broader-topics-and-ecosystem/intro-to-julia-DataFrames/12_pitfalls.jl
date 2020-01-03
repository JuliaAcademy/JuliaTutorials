# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames

# ------------------------------------------------------------------------------------------
# ## Possible pitfalls
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Know what is copied when creating a `DataFrame`
# ------------------------------------------------------------------------------------------

x = DataFrame(rand(3, 5))

y = DataFrame(x)
x === y # no copyinng performed

y = copy(x)
x === y # not the same object

all(x[i] === y[i] for i in ncol(x)) # but the columns are the same

x = 1:3; y = [1, 2, 3]; df = DataFrame(x=x,y=y) # the same when creating arrays or assigning columns, except ranges

y === df[:y] # the same object

typeof(x), typeof(df[:x]) # range is converted to a vector

# ------------------------------------------------------------------------------------------
# ### Do not modify the parent of `GroupedDataFrame`
# ------------------------------------------------------------------------------------------

x = DataFrame(id=repeat([1,2], outer=3), x=1:6)
g = groupby(x, :id)

x[1:3, 1]=[2,2,2]
g # well - it is wrong now, g is only a view

# ------------------------------------------------------------------------------------------
# ### Remember that you can filter columns of a `DataFrame` using booleans
# ------------------------------------------------------------------------------------------

srand(1)
x = DataFrame(rand(5, 5))

x[x[:x1] .< 0.25] # well - we have filtered columns not rows by accident as you can select columns using booleans

x[x[:x1] .< 0.25, :] # probably this is what we wanted

# ------------------------------------------------------------------------------------------
# ### Column selection for DataFrame creates aliases unless explicitly copied
# ------------------------------------------------------------------------------------------

x = DataFrame(a=1:3)
x[:b] = x[1] # alias
x[:c] = x[:, 1] # also alias
x[:d] = x[1][:] # copy
x[:e] = copy(x[1]) # explicit copy
display(x)
x[1,1] = 100
display(x)
