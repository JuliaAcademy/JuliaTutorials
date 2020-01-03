# ------------------------------------------------------------------------------------------
# # Julia for Data Science - Data
# Prepared by [@nassarhuda](https://github.com/nassarhuda)! 😃
#
# In the next few notebooks, we will discuss why *Julia* is the tool you want to use for
# your data science applications.
#
# We will cover the following:
# 1. Reading and writing files
# 1. DataFrames
# 1. RDatasets
# 1. FileIO
# 1. File types
#
#
# ### Data: Build a strong relationship with your data.
# Every data science task has one main ingredient, the _data_! Most likely, you want to use
# your data to learn something new. But before the _new_ part, what about the data you
# already have? Let's make sure you can **read** it, **store** it, and **understand** it
# before you start using it.
#
# Julia makes this step really easy with data structures and packages to process the data,
# as well as existing functions that are readily usable on your data.
#
# The goal of this first part is get you acquainted with some Julia's tools to manage your
# data.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# **Reading and writing to files is really easy in Julia.** <br>
#
# To see this, let's download a csv file from github that we can work with.
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
# By default, `readcsv` will fill an array with the data stored in the input .csv file. If
# we set the keyword argument `header` to `true`, we'll get a second output array.
# ------------------------------------------------------------------------------------------

P,H = readcsv("programminglanguages.csv",header=true)

P

# ------------------------------------------------------------------------------------------
# You can use different delimiters with the function `readdlm` (`readcsv` is just an
# instance of `readdlm`). <br>
#
# To write to files, we can use `writecsv` or `writedlm`. <br>
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
# ### DataFrames!
# *Shout out to R fans!*
# One other way to play around with data in Julia is to use a DataFrame.
#
# This requires loading the `DataFrames` package
# ------------------------------------------------------------------------------------------

using DataFrames
df = DataFrame(year = P[:,1], language = P[:,2])

# ------------------------------------------------------------------------------------------
# You can access columns by header name, or column index.
#
# In this case, `df[1]` is equivalent to `df[:year]`.
#
# Note that if we want to access columns by header name, we precede the header name with a
# colon! In Julia, this means that the header names are treated as *symbols*.
# ------------------------------------------------------------------------------------------

df[:year]

# ------------------------------------------------------------------------------------------
# **`DataFrames` provides some handy features when dealing with data**
#
# First, it introduces the "missing" type
# ------------------------------------------------------------------------------------------

a = NA
typeof(a)

# ------------------------------------------------------------------------------------------
# Let's see what happens when we try to add a "missing" type to a number
# ------------------------------------------------------------------------------------------

a + 1

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
# `DataFrames` provides the `describe` can give you quick statistics about each column in
# your dataframe
# ------------------------------------------------------------------------------------------

describe(iris)

# ------------------------------------------------------------------------------------------
# You can create your own dataframe quickly as follows
# ------------------------------------------------------------------------------------------

foods = @data(["apple", "cucumber", "tomato", "banana"])
calories = @data([NA,47,22,105])
typeof(calories)

mean(calories)

# ------------------------------------------------------------------------------------------
# NA ruins everything! 😑
# ------------------------------------------------------------------------------------------

mean(dropna(calories))

# ------------------------------------------------------------------------------------------
# In fact, `describe' will drop these values too
# ------------------------------------------------------------------------------------------

describe(calories)

# ------------------------------------------------------------------------------------------
# Note that `typeof(foods)` is `DataArrays.DataArray{String,1}`
#
# We can easily convert it to a regular julia vector. Let's try this using `convert`:
# ------------------------------------------------------------------------------------------

newfoods = convert(Vector,foods)

# ------------------------------------------------------------------------------------------
# What if we try to do the same conversion from `DataArray` to `Vector` with `calories`?
# ------------------------------------------------------------------------------------------

newcalories = convert(Vector, calories)

# ------------------------------------------------------------------------------------------
# This doesn't work because we didn' indicate how to handle the NA values!
# ------------------------------------------------------------------------------------------

newcalories = convert(Vector,calories,0) # i.e. replace every NA with the value 0

# ------------------------------------------------------------------------------------------
# Now let's create a `DataFrame` that shows foods and their calories from two `DataArray`s!
# ------------------------------------------------------------------------------------------

dataframe_calories = DataFrame(item=foods,calories=calories)

# ------------------------------------------------------------------------------------------
# Let's generate a second `DataFrame` that shows foods and their prices.
# ------------------------------------------------------------------------------------------

prices = @data([0.85,1.6,0.8,0.6,])

dataframe_prices = DataFrame(item=foods,price=prices)

# ------------------------------------------------------------------------------------------
# We can also `join` these two dataframes together because they share a common column,
# `item`.
# ------------------------------------------------------------------------------------------

DF = join(dataframe_calories,dataframe_prices,on=:item)

# ------------------------------------------------------------------------------------------
# Note that we used the keyword argument `on` to say that we wanted to join these dataframes
# together based on the `item` column.
# ------------------------------------------------------------------------------------------

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
# Next, let's load the Julia logo, stored as a .png file
# ------------------------------------------------------------------------------------------

X1 = load("julialogo.png")

# ------------------------------------------------------------------------------------------
# We see below that Julia stores this logo as an array of colors.
# ------------------------------------------------------------------------------------------

@show typeof(X1);
@show size(X1);

# ------------------------------------------------------------------------------------------
# ### File types
# In Julia, many file types are supported so you do not have to transfer a file you got from
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


