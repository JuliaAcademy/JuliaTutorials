# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames # load package

# ------------------------------------------------------------------------------------------
# ## Reshaping DataFrames
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Wide to long
# ------------------------------------------------------------------------------------------

x = DataFrame(id=[1,2,3,4], id2=[1,1,2,2], M1=[11,12,13,14], M2=[111,112,113,114])

melt(x, :id, [:M1, :M2]) # first pass id-variables and then measure variables; meltdf makes a view

# optionally you can rename columns; melt and stack are identical but order of arguments is reversed
stack(x, [:M1, :M2], :id, variable_name=:key, value_name=:observed) # first measures and then id-s; stackdf creates view

# if second argument is omitted in melt or stack , all other columns are assumed to be the second argument
# but measure variables are selected only if they are <: AbstractFloat
melt(x, [:id, :id2])

melt(x, [1, 2]) # you can use index instead of symbol

bigx = DataFrame(rand(10^6, 10)) # a test comparing creation of new DataFrame and a view
bigx[:id] = 1:10^6
@time melt(bigx, :id)
@time melt(bigx, :id)
@time meltdf(bigx, :id)
@time meltdf(bigx, :id);

x = DataFrame(id = [1,1,1], id2=['a','b','c'], a1 = rand(3), a2 = rand(3))

melt(x)

melt(DataFrame(rand(3,2))) # by default stack and melt treats floats as value columns

df = DataFrame(rand(3,2))
df[:key] = [1,1,1]
mdf = melt(df) # duplicates in key are silently accepted

# ------------------------------------------------------------------------------------------
# ### Long to wide
# ------------------------------------------------------------------------------------------

x = DataFrame(id = [1,1,1], id2=['a','b','c'], a1 = rand(3), a2 = rand(3))

y = melt(x, [1,2])
display(x)
display(y)

unstack(y, :id2, :variable, :value) # stndard unstack with a unique key

unstack(y, :variable, :value) # all other columns are treated as keys

# by default :id, :variable and :value names are assumed; in this case it produces duplicate keys
unstack(y)

df = stack(DataFrame(rand(3,2)))

unstack(df, :variable, :value) # unable to unstack when no key column is present
