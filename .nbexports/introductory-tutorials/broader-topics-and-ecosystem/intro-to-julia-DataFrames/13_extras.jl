# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), May 13, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames

# ------------------------------------------------------------------------------------------
# ## Extras - selected functionalities of selected packages
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### FreqTables: creating cross tabulations
# ------------------------------------------------------------------------------------------

using FreqTables
df = DataFrame(a=rand('a':'d', 1000), b=rand(["x", "y", "z"], 1000))
ft = freqtable(df, :a, :b) # observe that dimensions are sorted if possible

ft[1,1], ft['b', "z"] # you can index the result using numbers or names

prop(ft, 1) # getting proportions - 1 means we want to calculate them in rows (first dimension)

prop(ft, 2) # and columns are normalized to 1.0 now

x = categorical(rand(1:3, 10))
levels!(x, [3, 1, 2, 4]) # reordering levels and adding an extra level
freqtable(x) # order is preserved and not-used level is shown

freqtable([1,1,2,3,missing]) # by default missings are listed

freqtable([1,1,2,3,missing], skipmissing=true) # but we can skip them

# ------------------------------------------------------------------------------------------
# ### DataFramesMeta - working on `DataFrame`
# ------------------------------------------------------------------------------------------

using DataFramesMeta
df = DataFrame(x=1:8, y='a':'h', z=repeat([true,false], outer=4))

@with(df, :x+:z) # expressions with columns of DataFrame

@with df begin # you can define code blocks
    a = :x[:z]
    b = :x[.!:z]
    :y + [a; b]
end

a # @with creates hard scope so variables do not leak out

df2 = DataFrame(a = [:a, :b, :c])
@with(df2, :a .== ^(:a)) # sometimes we want to work on raw Symbol, ^() escapes it

df2 = DataFrame(x=1:3, y=4:6, z=7:9)
@with(df2, _I_(2:3)) # _I_(expression) is translated to df2[expression]

@where(df, :x .< 4, :z .== true) # very useful macro for filtering

@select(df, :x, y = 2*:x, z=:y) # create a new DataFrame based on the old one

@transform(df, a=1, x = 2*:x, y=:x) # create a new DataFrame adding columns based on the old one

@transform(df, a=1, b=:a) # old DataFrame is used and :a is not present there

@orderby(df, :z, -:x) # sorting into a new data frame, less powerful than sort, but lightweight

@linq df |> # chaining of operations on DataFrame
    where(:x .< 5) |>
    orderby(:z) |>
    transform(x²=:x.^2) |>
    select(:z, :x, :x²)

f(df, col) = df[col] # you can define your own functions and put them in the chain
@linq df |> where(:x .<= 4) |> f(:x)

# ------------------------------------------------------------------------------------------
# ### DataFramesMeta - working on grouped `DataFrame`
# ------------------------------------------------------------------------------------------

df = DataFrame(a = 1:12, b = repeat('a':'d', outer=3))
g = groupby(df, :b)

@by(df, :b, first=first(:a), last=last(:a), mean=mean(:a)) # more convinient than by from DataFrames

@based_on(g, first=first(:a), last=last(:a), mean=mean(:a)) # the same as by but on grouped DataFrame

@where(g, mean(:a) > 6.5) # filter gropus on aggregate conditions

@orderby(g, -sum(:a)) # order groups on aggregate conditions

@transform(g, center = mean(:a), centered = :a - mean(:a)) # perform operations within a group and return ungroped DataFrame

DataFrame(g) # a nice convinience function not defined in DataFrames

@transform(g) # actually this is the same

@linq df |> groupby(:b) |> where(mean(:a) > 6.5) |> DataFrame # you can do chaining on grouped DataFrames as well

# ------------------------------------------------------------------------------------------
# ### DataFramesMeta - rowwise operations on `DataFrame`
# ------------------------------------------------------------------------------------------

df = DataFrame(a = 1:12, b = repeat(1:4, outer=3))

# such conditions are often needed but are complex to write
@transform(df, x = ifelse.((:a .> 6) .& (:b .== 4), "yes", "no"))

# one option is to use a function that works on a single observation and broadcast it
myfun(a, b) = a > 6 && b == 4 ? "yes" : "no"
@transform(df, x = myfun.(:a, :b))

# or you can use @byrow! macro that allows you to process DataFrame rowwise
@byrow! df begin
    @newcol x::Vector{String}
    :x = :a > 6 && :b == 4 ? "yes" : "no"
end

# ------------------------------------------------------------------------------------------
# ### Visualizing data with StatPlots
# ------------------------------------------------------------------------------------------

using StatPlots # you might need to setup Plots package and some plotting backend first

# we present only a minimal functionality of the package

srand(1)
df = DataFrame(x = sort(randn(1000)), y=randn(1000), z = [fill("b", 500); fill("a", 500)])

@df df plot(:x, :y, legend=:topleft, label="y(x)") # a most basic plot

@df df density(:x, label="") # density plot

@df df histogram(:y, label="y") # and a histogram

@df df boxplot(:z, :x, label="x")

@df df violin(:z, :y, label="y")
