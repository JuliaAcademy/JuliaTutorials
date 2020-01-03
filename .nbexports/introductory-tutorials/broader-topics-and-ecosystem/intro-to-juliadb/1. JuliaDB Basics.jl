# ------------------------------------------------------------------------------------------
# <img src="https://juliacomputing.com/assets/img/new/JuliaDB_logo2.svg", width=200>
#
# # JuliaDB is an analytical database that...
#
# - **Loads multi-file datasets**
# - **Sorts data by index variables for fast filter, aggregation, sort, and join
# operations**
# - **Compiles queries** (it's Julia all the way down)
# - **Stores ANY data type** (again, it's Julia)
# - **Saves tables to disk for fast reloading**
# - **Uses Julia's built-in parallel computing features to fully utilize any machine or
# cluster**
# - **Integrates with [OnlineStats](https://github.com/joshday/OnlineStats.jl) for big (or
# small) data analytics**
#
# # Helpful links
#
# For additional documentation, please refer to
#
# - [JuliaDB Docs](http://juliadb.org/latest/api/index.html)
# - [OnlineStats Docs](http://joshday.github.io/OnlineStats.jl/stable/)
#
# # Getting Started
#
# In this notebook, we'll introduce **JuliaDB**'s two main data structures (`Table` and
# `NDSparse`) by
#
# 1. Creating tables from vectors
# 1. Accessing data from `Table` and `NDSparse`
# 1. Loading tables from CSVs
# 1. Saving tables into binary format
# 1. Reloading a saved table
# 1. Using selectors
# ------------------------------------------------------------------------------------------

using JuliaDB

# ------------------------------------------------------------------------------------------
# # Creating tables from Julia Vectors
#
# - First we'll make some data vectors
# ------------------------------------------------------------------------------------------

x = [false, true, false, true]
y = ['B', 'B', 'A', 'A']
z = [.1, .3, .2, .4]
x, y, z

# ------------------------------------------------------------------------------------------
# ## `Table`: Tabular Data Sorted by Primary Key(s)
#
# - We can create a table in **JuliaDB** using the `table` function.
# ------------------------------------------------------------------------------------------

# x, y, z become columns of the table, with default numbering 1, 2, 3.

t1 = table(x, y, z)

# The keyword argument `names` lets us label the columns

t2 = table(x,  y, z, names = [:x, :y, :z])

# ------------------------------------------------------------------------------------------
# ### Sorting by Index Variables
# - Furthermore, we can **sort** a table by a primary key (or keys), which can be set with
# the keyword argument `pkey`.
# - Below, the rows of `t3` are sorted first by the values in column `x` and second by the
# values in column `y`.
# ------------------------------------------------------------------------------------------

t3 = table(x, y, z, names = [:x, :y, :z], pkey = (:x, :y))

# ------------------------------------------------------------------------------------------
# ### Tuple vs. NamedTuple
#
# - We can also build a `table` from a `NamedTuple` of vectors.
# - A `NamedTuple` is created with the `@NT` macro.  Values can be accessed by position or
# name.
# ------------------------------------------------------------------------------------------

# Tuple

a = ("John", "Doe")

@show a[1];

# NamedTuple

b = @NT(firstname = "John", lastname = "Doe")

@show b[1]
@show b[:firstname]
@show b.firstname;

# Column names are taken from the NamedTuple

t4 = table(@NT(x=x, y=y, z=z), pkey = [:x, :y])

# ------------------------------------------------------------------------------------------
# ### `NDSparse`: N-dimensional Sparse Array with Arbitrary Indexes
#
# - Compare the following two data structures:
# ------------------------------------------------------------------------------------------

# maps (tuple of integers) -> value

sparse(reshape(z, 2, 2))

# maps (tuple of arbitrary index types) -> value

ndsparse((x, y), z)

# ------------------------------------------------------------------------------------------
# - Like `table`, we can use `ndsparse` with NamedTuples:
# ------------------------------------------------------------------------------------------

nd2 = ndsparse(@NT(x=x, y=y), z)

# ------------------------------------------------------------------------------------------
# ---
#
# # Accessing data from `Table` and `NDSparse`
#
# ## Index into `Table`
#
# - In the last section, we created the `Table`, `t3`:
# ------------------------------------------------------------------------------------------

t3

# ------------------------------------------------------------------------------------------
# - We can get the first row of `t3` by indexing:
# ------------------------------------------------------------------------------------------

t3[1]

# ------------------------------------------------------------------------------------------
# - We can get an individual element in the row by using the column name:
# ------------------------------------------------------------------------------------------

t3[1].z

# ------------------------------------------------------------------------------------------
# ## Index into `NDSparse`
#
# - Since `NDSparse` acts like an array, accessing data is slightly different.
# - We must look up a value by using the index columns:
# ------------------------------------------------------------------------------------------

nd2[false, 'A']

# ------------------------------------------------------------------------------------------
# - Since `NDSparse` acts like an array, we can look up all the rows where `x` is `false`:
# ------------------------------------------------------------------------------------------

nd2[false, :]

# ------------------------------------------------------------------------------------------
# ## Iteration
#
# - `Table` and `NDSparse` also differ in how they iterate over the data.
# ------------------------------------------------------------------------------------------

# Table: iterate over Tuples/NamedTuples of rows

for row in t3
    println(row)
end

# NDSparse: iterate over values

for item in nd2
    println(item)
end

# ------------------------------------------------------------------------------------------
# ---
#
# # Loading tables from CSVs
#
# - Now we'll load data from multiple CSV files into a table.
# - Our example data is 8 different stocks' OHLC data (each stock in a separate file).
#     - We can start by looking at all the available files in the `stocksample` directory.
#     - `;` allows us to run shell commands from Jupyter or a Julia REPL.
# 
# ------------------------------------------------------------------------------------------

;ls stocksample

# ------------------------------------------------------------------------------------------
# - Each txt file has the structure:
# ------------------------------------------------------------------------------------------

;head stocksample/aapl.us.txt

# ------------------------------------------------------------------------------------------
# - We can now use the `loadtable` function to load all files in the `stocksample` directory
# into one table:
# ------------------------------------------------------------------------------------------

stocks = loadtable("stocksample")

# ------------------------------------------------------------------------------------------
# - All data from the 8 files is now in one table, but we don't have the stock ticker
# information!
# - `loadtable` has a `filenamecol` option that will add a column for us, which we will call
# `:Ticker`:
# ------------------------------------------------------------------------------------------

stocks = loadtable("stocksample"; filenamecol = :Ticker)

# ------------------------------------------------------------------------------------------
# - Furthermore, we can use the `indexcols` to specify how data is sorted.
#   - First we'll sort by `:Ticker`
#   - Then sort by `:Date`
# ------------------------------------------------------------------------------------------

stocks = loadtable("stocksample"; filenamecol = :Ticker, indexcols = [:Ticker, :Date])

# ------------------------------------------------------------------------------------------
# - Notice the printing style has changed.  A summary is printed when the display width is
# too narrow to print all the columns.  In Jupyter, the width is hardcoded as 80 characters,
# so the table actually fits in this case.  We can override this behavior with:
# ------------------------------------------------------------------------------------------

IndexedTables.set_show_compact!(false)

stocks

# ------------------------------------------------------------------------------------------
# ## Motivation for ND Sparse
#
# ### What was Apple's closing price on 1986-02-10?
#
# - For a `Table`, this requires a query
# - With `NDSparse`, this is just `getindex`
#     - Load data as `NDSparse` and use arbitrary indexes (`String` and `Date`) to look up
# the closing price:
# ------------------------------------------------------------------------------------------

# Load data as NDSparse:

stocksnd = loadndsparse("stocksample", filenamecol=:Ticker, indexcols = [:Ticker, :Date])

# Get the value associated with Apple and 1986-02-10:

stocksnd["aapl.us.txt", Date(1986, 2, 10)].Close

# ------------------------------------------------------------------------------------------
# # Saving Tables to Disk
#
# - **JuliaDB** can save tables into a binary format that can be loaded efficiently in
# future Julia sessions.
#     - `save(table, destination)`
# ------------------------------------------------------------------------------------------

save(stocks, "stocks.jdb")

# ------------------------------------------------------------------------------------------
# # Reloading a Saved Table
#
# - To load a saved table, we use the `load` function rather than `loadtable`.
# - This is typically **much** faster than reloading from the CSVs.
# ------------------------------------------------------------------------------------------

@time reloaded_stocks = load("stocks")

stocks == reloaded_stocks

# ------------------------------------------------------------------------------------------
# ---
#
# # Using  Selectors
#
# ### Selectors are powerful ways to select and manipulate data
#
# 1. `Integer`: column at position
# 2. `Symbol`: column by name
# 3. `Array`: itself
# 4. `Pair{Selection => Function}`: function mapped to selection
# 5. `Tuple` of selections: table of each selection
#
# ### Selectors show up in many places (everything in green)
#
# <code>select(t, <span style="color: green">which</span>)
# map(f, t; <span style="color: green">select</span>)
# reduce(f, t; <span style="color: green">select</span>)
# filter(f, t; <span style="color: green">select</span>)
# groupby(f, t, <span style="color: green">by</span>; <span style="color:
# green">select</span>)
# groupreduce(f, t, <span style="color: green">by</span>; <span style="color:
# green">select</span>)
# join(f, l, r; how, <span style="color: green">lkey</span>, <span style="color:
# green">rkey</span>, <span style="color: green">lselect</span>, <span style="color:
# green">rselect</span>)
# groupjoin(f, l, r; how, <span style="color: green">lkey</span>, <span style="color:
# green">rkey</span>, <span style="color: green">lselect</span>, <span style="color:
# green">rselect</span>)
# </code>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Selector Examples
#
# - A single selection returns a Vector:
# ------------------------------------------------------------------------------------------

select(stocks, 1)[1:5]

select(stocks, :Date)[1:5]

# ------------------------------------------------------------------------------------------
# - Multiple selections return a table:
# ------------------------------------------------------------------------------------------

select(stocks, (1, :Date))[1:5]
