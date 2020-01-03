# ------------------------------------------------------------------------------------------
# # `NDSparse` Usage
#
# The purpose of this section is to show you how to use the methods associated with NDSparse
# objects. If you've already worked through the section on Table Usage, this notebook will
# seem very familiar!
#
# Let's get started by loading JuliaDB and editing our default settings so that tables will
# display their entries.
# ------------------------------------------------------------------------------------------

using JuliaDB

IndexedTables.set_show_compact!(false);

# ------------------------------------------------------------------------------------------
# - `loadndsparse` is an analog to `loadtable`:
# ------------------------------------------------------------------------------------------

nd = loadndsparse("stocksample", filenamecol = :Ticker, indexcols = [:Ticker, :Date])

# ------------------------------------------------------------------------------------------
# - Having made `:Ticker` and `:Date` the columns by which we index entries to `nd`, we can
# perform a lookup in `nd` via
# ------------------------------------------------------------------------------------------

nd["aapl.us.txt", Date(1986, 2, 10)]

# ------------------------------------------------------------------------------------------
# # `selectkeys` and `selectvalues`
#
# - Rather than `select`, for `NDSparse` you can use `selectkeys` and `selectvalues`.
#
# - In this example, we generate a NDSparse object that contains two indexable columns
# (`:Ticker` and `:Date`) and one column of selected values, `:Close`:
# ------------------------------------------------------------------------------------------

selectvalues(nd, :Close)

# ------------------------------------------------------------------------------------------
# # `map`
#
# - The syntax for `map` is the same for `Table` and `NDSparse` objects:
#
# `map(function, table; select)`
# ------------------------------------------------------------------------------------------

map(r -> r.High - r.Low, nd; select = (:High, :Low))

# ------------------------------------------------------------------------------------------
# # `filter`
#
# - The syntax for filter is the same for `Table` and `NDSparse` objects:
#
# `filter(function, tablename; select)`
#
# - In the following example, we filter `nd` to create a new `NDSparse` object that only
# contains days/stocks that increased in value:
# ------------------------------------------------------------------------------------------

filter(r -> r.Open < r.Close, nd)

# ------------------------------------------------------------------------------------------
# # `reduce` and `groupreduce`
#
# - Syntax is the same as for `Table`:
#
# `reduce(reducer, table; select)`
#
# `groupreduce(reducer, table, by; select)`
# ------------------------------------------------------------------------------------------

groupreduce(+, nd, :Ticker; select = :Volume)

# ------------------------------------------------------------------------------------------
# # `groupby`
#
# - Syntax is the same as for `Table`:
#
# `groupby(function, table, by; select)`
# ------------------------------------------------------------------------------------------

groupby(extrema, nd, :Ticker; select = :Close)

# ------------------------------------------------------------------------------------------
# # `summarize`
#
# - Syntax is the same as for `Table`:
#
# `summarize(function[s], table[, by]; select)`
# ------------------------------------------------------------------------------------------

summarize((mean, std), nd, :Ticker; select = (:Open, :Close))

# ------------------------------------------------------------------------------------------
# # `columns` and `rows`
#
# - Syntax is the same as for `Table`
# ------------------------------------------------------------------------------------------

columns(nd)
