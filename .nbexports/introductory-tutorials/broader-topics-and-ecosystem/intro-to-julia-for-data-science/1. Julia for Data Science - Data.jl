# ------------------------------------------------------------------------------------------
# # Julia for Data Science
# Prepared by [@nassarhuda](https://github.com/nassarhuda)! 😃
#
# `Last updated on 03/Jan/2020`
#
# In this tutorial, we will discuss why *Julia* is the tool you want to use for your data
# science applications.
#
# We will cover the following:
# * **Data**
# * Data processing
# * Visualization
#
# ### Data: Build a strong relationship with your data.
# Every data science task has one main ingredient, the _data_! Most likely, you want to use
# your data to learn something new. But before the _new_ part, what about the data you
# already have? Let's make sure you can **read** it, **store** it, and **understand** it
# before you start using it.
#
# Julia makes this step really easy with data structures and packages to process the data,
# as well as, existing functions that are readily usable on your data.
#
# The goal of this first part is get you acquainted with some Julia's tools to manage your
# data.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# First, let's download a csv file from github that we can work with.
#
# Note: `download` depends on external tools such as curl, wget or fetch. So you must have
# one of these.
# ------------------------------------------------------------------------------------------

P = download("https://raw.githubusercontent.com/nassarhuda/easy_data/master/programming_languages.csv","programminglanguages.csv")

# ------------------------------------------------------------------------------------------
# We can use shell commands like `ls` in Julia by preceding them with a semicolon.
# ------------------------------------------------------------------------------------------

;ls

# ------------------------------------------------------------------------------------------
# And there's the *.csv file we downloaded!
#
# Now let's load it into Julia
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# We'll use the `DelimitedFiles` standard library package and its `readdlm()` function as
# shown
# below.
#
# (Today, the [CSV.jl](https://juliadata.github.io/CSV.jl/stable/) package is the
# recommended way to load CSVs in Julia. We can install it via `Pkg.add()`, and load .csv
# files using `CSV.read()`. This tutorial hasn't been updated to use CSV.jl yet.)
# ------------------------------------------------------------------------------------------

# using Pkg
# Pkg.add("CSV") # for CSV.read()
# Pkg.add("DelimitedFiles") # for readdlm

# using CSV
# P = CSV.read("programminglanguages.csv",header=true)
# or
using DelimitedFiles  # Standard library in Base

# ------------------------------------------------------------------------------------------
# By default, `readdlm` will fill an array with the data stored in the input .csv file. If
# we set the keyword argument `header` to `true`, we'll get a second output array for just
# the headers.
# ------------------------------------------------------------------------------------------

P,H = readdlm("programminglanguages.csv", ',', header=true)

P # stores the dataset

H # stores the header names

# ------------------------------------------------------------------------------------------
# Here we write our first small function. <br>
# Now you can answer questions such as, "when was language X created?"
# ------------------------------------------------------------------------------------------

function language_created_year(P,language::String)
    loc = findfirst(P[:,2].==language)
    return P[loc,1]
end

language_created_year(P,"Julia")

language_created_year(P,"julia")

# ------------------------------------------------------------------------------------------
# As expected, this will not return what you want, but thankfully, string manipulation is
# really easy in Julia!
# ------------------------------------------------------------------------------------------

function language_created_year_v2(P,language::String)
    loc = findfirst(lowercase.(P[:,2]).==lowercase.(language))
    return P[loc,1]
end
language_created_year_v2(P,"julia")

# ------------------------------------------------------------------------------------------
# **Reading and writing to files is really easy in Julia.** <br>
#
# You can use different delimiters with the function `readdlm`, from the `DelimitedFiles`
# package. <br>
#
# To write to files, we can use `writedlm`. <br>
#
# Let's write this same data to a file with a different delimiter.
# ------------------------------------------------------------------------------------------

writedlm("programming_languages_data.txt", P, '-')

# ------------------------------------------------------------------------------------------
# We can now check that this worked using a shell command to glance at the file,
# ------------------------------------------------------------------------------------------

;head -10 programming_languages_data.txt

# ------------------------------------------------------------------------------------------
# and also check that we can use `readdlm` to read our new text file correctly.
# ------------------------------------------------------------------------------------------

P_new_delim = readdlm("programming_languages_data.txt", '-');
P == P_new_delim

# ------------------------------------------------------------------------------------------
# ### Dictionaries
# Let's try to store the above data in a dictionary format!
#
# First, let's initialize an empty dictionary
# ------------------------------------------------------------------------------------------

dict = Dict{Integer,Vector{String}}()

# ------------------------------------------------------------------------------------------
# Here we told Julia that we want `dict` to only accept integers as keys and vectors of
# strings as values.
#
# However, we could have initialized an empty dictionary without providing this information
# (depending on our application).
# ------------------------------------------------------------------------------------------

dict2 = Dict()

# ------------------------------------------------------------------------------------------
# This dictionary takes keys and values of any type!
#
# Now, let's populate the dictionary with years as keys and vectors that hold all the
# programming languages created in each year as their values.
# ------------------------------------------------------------------------------------------

for i = 1:size(P,1)
    year,lang = P[i,:]
    
    if year in keys(dict)
        dict[year] = push!(dict[year],lang)
    else
        dict[year] = [lang]
    end
end

# ------------------------------------------------------------------------------------------
# Now you can pick whichever year you want and find what programming languages were invented
# in that year
# ------------------------------------------------------------------------------------------

dict[2003]

# ------------------------------------------------------------------------------------------
# ### DataFrames!
# *Shout out to R fans!*
# One other way to play around with data in Julia is to use a DataFrame.
#
# This requires loading the `DataFrames` package. Thankfully, this tutorial came with a
# Project.toml file that specifies exactly which version of DataFrames to install...
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Project.toml files
#
# For this tutorial (Julia for Data Science), you may have noticed that there are files in
# this folder called [`Project.toml`](/edit/introductory-tutorials/broader-topics-and-
# ecosystem/intro-to-julia-for-data-science/Project.toml) and
# [`Manifest.toml`](/edit/introductory-tutorials/broader-topics-and-ecosystem/intro-to-
# julia-for-data-science/Manifest.toml). These are files autogenerated by Julia's package
# manager, `Pkg`, that describe the _exact set of packages_ installed for a julia project,
# allowing you to share your work in a perfectly reproducible way.
#
# Jupyter was able to detect those `.toml` files, and so this notebook was automatically
# started with _this project activated!_ Note that this means any packages you add or remove
# inside this notebook will only affect this "Julia for Data Science" _project_.
#
# To install all of the package dependencies used in the rest of the tutorial, you only need
# to run this next cell (commands that start with `]` are package repl commands):
# ------------------------------------------------------------------------------------------

] instantiate

# ------------------------------------------------------------------------------------------
# You can read more about package manager commands, here:
# https://docs.julialang.org/en/v1/stdlib/Pkg/index.html
#
# **Now back to DataFrames!**
# ------------------------------------------------------------------------------------------

using DataFrames
df = DataFrame(year = P[:,1], language = P[:,2])

# ------------------------------------------------------------------------------------------
# You can access columns by header name, or column index.
#
# In this case, `df[1]` is equivalent to `df.year` or `df[!, :year]`.
#
# Note that if we want to index columns by header name, we precede the header name with a
# colon. In Julia, this means that the header names are treated as *symbols*.
# ------------------------------------------------------------------------------------------

df.year

# ------------------------------------------------------------------------------------------
# **`DataFrames` provides some handy features when dealing with data**
#
# First, it uses julia's "missing" type.
# ------------------------------------------------------------------------------------------

a = missing
typeof(a)

# ------------------------------------------------------------------------------------------
# Let's see what happens when we try to add a "missing" type to a number.
# ------------------------------------------------------------------------------------------

a + 1

# ------------------------------------------------------------------------------------------
# `DataFrames` provides the `describe` function, which can give you quick statistics about
# each column in your dataframe
# ------------------------------------------------------------------------------------------

describe(df)

# ------------------------------------------------------------------------------------------
# ### RDatasets
#
# We can use RDatasets to play around with pre-existing datasets
# ------------------------------------------------------------------------------------------

using RDatasets
iris = dataset("datasets", "iris")

# ------------------------------------------------------------------------------------------
# Note that data loaded with `dataset` is stored as a DataFrame. 😃
# ------------------------------------------------------------------------------------------

typeof(iris) 

# ------------------------------------------------------------------------------------------
# The summary we get from `describe` on `iris` gives us a lot more information than the
# summary on `df`!
# ------------------------------------------------------------------------------------------

describe(iris)

# ------------------------------------------------------------------------------------------
# ### More on Missing Values
#
# Julia 1.0 and beyond has native support for `missing` values. (Before Julia 1.0, this was
# done via the DataArrays.jl package.)
# More information on using arrays with missing values can be found
# [in the Julia documentation](https://docs.julialang.org/en/v1/manual/missing/#Arrays-With-
# Missing-Values-1).
# ------------------------------------------------------------------------------------------

foods = ["apple", "cucumber", "tomato", "banana"]
calories = [missing,47,22,105]
typeof(calories)

using Statistics  # julia's standard library for stats
mean(calories)

# ------------------------------------------------------------------------------------------
# Missing values ruin everything! 😑
#
# Luckily we can ignore them with `skipmissing`!
# ------------------------------------------------------------------------------------------

mean(skipmissing(calories))

# ------------------------------------------------------------------------------------------
# Oh WAIT! Detour. How did I get the emoji there?
#
# Try this out:
#
# ```
# \:expressionless: + <TAB>
# ```
# ------------------------------------------------------------------------------------------

😑 = 0 # expressionless
😀 = 1
😞 = -1

# ------------------------------------------------------------------------------------------
# *Back to missing values*
# ------------------------------------------------------------------------------------------

prices = [0.85,1.6,0.8,0.6,]

dataframe_calories = DataFrame(item=foods,calories=calories)

dataframe_prices = DataFrame(item=foods,price=prices)

# ------------------------------------------------------------------------------------------
# We can also `join` two dataframes together
# ------------------------------------------------------------------------------------------

DF = join(dataframe_calories,dataframe_prices,on=:item)

# ------------------------------------------------------------------------------------------
# ### FileIO
# ------------------------------------------------------------------------------------------

using FileIO
julialogo = download("https://avatars0.githubusercontent.com/u/743164?s=200&v=4","julialogo.png")

# ------------------------------------------------------------------------------------------
# Again, let's check that this download worked!
# ------------------------------------------------------------------------------------------

;ls

# ------------------------------------------------------------------------------------------
#
# Next, let's load the Julia logo, stored as a .png file
#
# **NOTE: You may see errors below, that certain Image packages could not be found. If so:**
#  - This is because these packages are specific to your OS, so aren't installed by default.
#  - Simply run the suggested commands to install the packages, then try again.
# ------------------------------------------------------------------------------------------

# These commands may vary depending on your operating system.
#import Pkg; Pkg.add("QuartzImageIO")
#import Pkg; Pkg.add("ImageMagick")

X1 = load("julialogo.png")

# ------------------------------------------------------------------------------------------
# We see here that Julia stores this logo as an array of colors.
# ------------------------------------------------------------------------------------------

@show typeof(X1);
@show size(X1);

# ------------------------------------------------------------------------------------------
# And if we load the Images package, it will display in Jupyter as an image:
# ------------------------------------------------------------------------------------------

using Images

X1

# ------------------------------------------------------------------------------------------
# ### File types
# In Julia, many file types are supported so you do not have to transfer a file you from
# another language to a text file before you read it.
#
# *Some packages that achieve this:*
# MAT CSV NPZ JLD FASTAIO
#
#
# Let's try using MAT to write a file that stores a matrix.
# ------------------------------------------------------------------------------------------

using MAT

A = rand(5,5)
matfile = matopen("densematrix.mat", "w") 
write(matfile, "A", A)
close(matfile)

# ------------------------------------------------------------------------------------------
# Now try opening densematrix.mat with MATLAB!
# ------------------------------------------------------------------------------------------

newfile = matopen("densematrix.mat")
read(newfile,"A")

names(newfile)

close(newfile)


