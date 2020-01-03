# ------------------------------------------------------------------------------------------
# # `Table` Usage
#
# In this notebook we'll show common `Table` operations using the stock market data
# introduced in the previous notebook.  `NDSparse` operations are *nearly* identical, so we
# will focus on `Table`.  The functions we cover here are:
#
# 1. `select`
# 1. `filter`
# 1. `map`
# 1. `reduce`
# 1. `groupreduce`
# 1. `groupby`
# 1. `summarize`
# 1. `columns`/`rows`
# 1. `join`
# 1. `merge`
#
# Each of the above functions has detailed inline documentation, accessed from a Julia REPL
# with `?select`, for example.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Begin by Loading Data
#
# - Let's load the data we saved in the previous notebook:
# ------------------------------------------------------------------------------------------

using JuliaDB

# Print table rather than column summary
IndexedTables.set_show_compact!(false)

# loadtable("stocksample"; filenamecol = :Ticker, indexcols = [:Ticker, :Date]);
t = load("stocks.jdb")

# ------------------------------------------------------------------------------------------
# # Return a Subset of Columns:
#
# - We can use `select` to return a selector (introduced in the previous notebook) applied
# to a table.
#
# ## `select(table, selection)`
#
# - When multiple selectors are involved, rows are "passed around" as a `NamedTuple`.
# - A function paired with multiple selections must then accept a `NamedTuple`.
#
# - For example, to calculate the range of stock prices for each day we can:
#   1. Select `:High` and `:Low`
#   1. Pair it with the anonymous function `row -> row.High - row.Low`
# ------------------------------------------------------------------------------------------

select(t, (:High, :Low) => row -> row.High - row.Low)

# ------------------------------------------------------------------------------------------
# # Return a Subset of Rows:
#
# - We can get the rows that satisfy some condition (when a function returns true) with the
# syntax:
#
# ## `filter(function, table; selection)`
#
# - Here we retrieve the data for AMZN (Amazon) by getting the rows for which `Ticker ==
# "amzn.us.txt"`.
# ------------------------------------------------------------------------------------------

filter(x -> x == "amzn.us.txt", t; select = :Ticker)

# ------------------------------------------------------------------------------------------
# # Apply a Function to a Selection:
#
# - We can use `map` to apply a function on a selection of a table with the syntax below:
#
# ## `map(function, table; select)`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# - If `select` is not provided, each full row will be passed to the function.
# - Here we return the first item in each row:
# ------------------------------------------------------------------------------------------

map(first, t)

# ------------------------------------------------------------------------------------------
# - Note that `map` and `select` can often be used to produce the same result since
# selections can be paired with a function.
# - For example, we previously used
#
#     ```julia
#     select(t, (:High, :Low) => row -> row.High - row.Low)
#     ```
#
#     to calculate stock price ranges.  Equivalently, we can use:
# ------------------------------------------------------------------------------------------

map(r -> r.High - r.Close, t)

# ------------------------------------------------------------------------------------------
# # `reduce`
#
# - `reduce` applies a function (`reducer`) pair-wise to a selection through the syntax:
#
# ## `reduce(reducer, table; select)`
#
# - For example, if a table is four rows long, `reduce(reducer, t)` is equivalent to
#
# ```julia
# out = reducer(row1, row2)
# out = reducer(out, row3)
# out = reducer(out, row4)
# ```
#
# - In order to be meaningful, the `reducer` must have the associative property:
#
# $$(A + B) + C = A + (B + C)$$
#
# 
# ------------------------------------------------------------------------------------------

reduce(+, t; select = :Volume)

# ------------------------------------------------------------------------------------------
# You can also `reduce` with estimators from **OnlineStats** (more on this later):
# ------------------------------------------------------------------------------------------

using OnlineStats

reduce(Sum(Int), t; select = :Volume)

# ------------------------------------------------------------------------------------------
# # `groupreduce`
#
# - Like `reduce`, `groupreduce` applies a reducer pair-wise to table elements.
# - However, the reducer is applied separately across groups (unique values of another
# selection).
# - The syntax is:
#
# ## `groupreduce(reducer, table, by; selection)`
#
# - For example, we can find the total number of trades for each stock by calculating the
# sum of `:Volume`, grouped by `:Ticker`:
# ------------------------------------------------------------------------------------------

groupreduce(+, t, :Ticker; select = :Volume)

# ------------------------------------------------------------------------------------------
# # `groupby`
#
# - `groupby` applies a function to each group subset (not pair-wise like `reduce`) through
# the syntax:
#
# ## `groupby(function, table [, by]; select)`
#
# - Here we get the mean and standard deviation of closing price for each stock:
# ------------------------------------------------------------------------------------------

groupby((mean, std), t, :Ticker; select = :Close)

# ------------------------------------------------------------------------------------------
# # `summarize`
#
# - `summarize` applies a function (or functions) column-wise.  The syntax is:
#
# ## `summarize(function, table, by; select)`
# ------------------------------------------------------------------------------------------

summarize((mean, std), t, :Ticker; select = (:Open, :Close))

# ------------------------------------------------------------------------------------------
# # AoS and SoA
#
# - We can retrieve the table as a "struct of arrays" (`NamedTuple` of `Vector`s) or as an
# "array of structs" (`Vector` of `NamedTuple`s) via `columns` and `rows`, respectively.
#
# ## `columns(t; selection)`
#
# ## `rows(t; selection)`
# ------------------------------------------------------------------------------------------

# NamedTuple of Vectors
columns(t)[1]

# Vector of NamedTuples
rows(t)[1]

# ------------------------------------------------------------------------------------------
# # Joins
#
# ## `join(left, right; how, <options>)`
#
# Join tables together based on matching keys.
#
# - `how` can be one of `:inner`, `:left`, `:outer`, or`:anti`
# - `<options>`: `rkey`, `lkey` (default to indexed variable), `rselect`, `lselect`
# ------------------------------------------------------------------------------------------

t1 = table(@NT(x=1:5, y = rand(5)); pkey = :x)

t2 = table(@NT(x=3:7, z = rand(5)); pkey = :x)

# try :inner, :outer, :left
tjoin = join(t1, t2; how = :inner)

# ------------------------------------------------------------------------------------------
# # Merging
#
# - A `merge` results in a table that is still ordered by the primary key(s).
# ------------------------------------------------------------------------------------------

t3 = table(@NT(x=11:15, y = randn(5)), pkey = :x)

merge(t1, t3)
