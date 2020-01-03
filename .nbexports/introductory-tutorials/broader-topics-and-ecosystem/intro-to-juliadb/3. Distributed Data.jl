# ------------------------------------------------------------------------------------------
# # Distributed Data
#
# JuliaDB can distribute datasets across multiple processes and can even work with data
# larger than available memory (RAM).
#
# First let's start by adding some worker Julia processes.  If you do not specify a number,
# `addprocs` will add as many workers as there are CPU cores available.
# ------------------------------------------------------------------------------------------

addprocs(2)

using JuliaDB

# print table rather than column summary
IndexedTables.set_show_compact!(false);

# ------------------------------------------------------------------------------------------
# ### When multiple processes are available, `loadtable` will create distributed tables.
#
# - Note the line above the column names printed below:
#
# `Distributed Table with 56023 rows in 2 chunks`
# ------------------------------------------------------------------------------------------

dt = loadtable("stocksample", filenamecol = :Ticker, indexcols = [:Ticker, :Date])

# ------------------------------------------------------------------------------------------
# ### Notable difference 1: No `getindex`
# ------------------------------------------------------------------------------------------

# We are no longer able to get the row based on row number

dt[1]

# ------------------------------------------------------------------------------------------
# ### Notable difference 2: Not iterable
# ------------------------------------------------------------------------------------------

# Similarly, we're no longer allowed to iterate over the rows

for row in dt
    println(row)
end

# ------------------------------------------------------------------------------------------
# # Bring Distributed Table Into Master Process
#
# - While not necessary for most operations, you may occasionally want to bring a dataset
# into the master process.
# - This is accomplished with the `collect` function.
# - Note that after `collect`ing, the header says `Table` instead of `Distributed Table`.
# ------------------------------------------------------------------------------------------

t = collect(dt)

# ------------------------------------------------------------------------------------------
# # Table Operations Still Work on a Distributed Table!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Functions that return a single value still return a single value.
# ------------------------------------------------------------------------------------------

reduce(+, dt; select = :Close)

# ------------------------------------------------------------------------------------------
# ### Functions that returned a Table now return a Distributed Table.
# ------------------------------------------------------------------------------------------

groupreduce(+, dt, :Ticker; select = :Close)

# ------------------------------------------------------------------------------------------
# ### Functions that returned an `Array` now return a `DArray`.
# ------------------------------------------------------------------------------------------

select(dt, :Close)

# ------------------------------------------------------------------------------------------
# - Similar to tables, `collect` will change a `DArray` to an `Array`:
# ------------------------------------------------------------------------------------------

collect(select(dt, :Close))

# ------------------------------------------------------------------------------------------
# # Out-of-Core Functionality
#
# - Doc Reference: http://juliadb.org/latest/manual/out-of-core.html
#
# ### JuliaDB can be used to load/query datasets that are too big to fit in memory (RAM).
#
# - The current out-of-core design is based around working with many files where each fits
# comfortably in memory.
# - In the future, JuliaDB will support individual files that are larger than memory.
#
# #### Out-of-core support is restricted to `reduce`, `groupreduce`, and (a subset of)
# `join`
#
# - Now let's pretend the stock data is much larger than it actually is and go through the
# steps of how to handle a larger-than-memory dataset.
#
# ### 1. Data is loaded into a distributed dataset in *chunks* that fit in memory
#
# - A *chunk* contains the data from at least one file (one file cannot be split into
# multiple chunks).
# - The `loadtable` and `loadndsparse` functions have the keyword arguments:
#   - `output`: Directory where the loaded data is written to an efficient binary format.
#   - `chunks`: Number of parts to split the data into
# - Data processing will occur on `number_of_files / chunks` files at a time.
#
#
# - Here we load the stock data in 8 chunks (one file per chunk) into the output directory
# `bin`.
# ------------------------------------------------------------------------------------------

loadtable("stocksample", output = "bin", chunks=8, 
    filenamecol=:Ticker, indexcols=[:Ticker, :Date])

# ------------------------------------------------------------------------------------------
# ### 2. Data can then be `load`ed from the binary format
#
# - `bintable` is now a distributed table made up of chunks that are on disk.
# ------------------------------------------------------------------------------------------

bintable = load("bin")

# ------------------------------------------------------------------------------------------
# ### 3. We can use out-of-core supported functions like usual
#
# - When we call a function like `groupreduce`, each worker process will operate on one
# chunk at a time.
#
# - You want to be sure that both `nprocs() * (size of chunks)` and the output of
# `reduce`/`groupreduce` fits in memory!
# ------------------------------------------------------------------------------------------

groupreduce(+, bintable, :Ticker; select = :Volume)

# ------------------------------------------------------------------------------------------
# # Plotting Big Data
#
# - There are a few options for plotting JuliaDB datasets through the use of the Plots
# package.
#
# ## Plotting with StatPlots
#
# - The StatPlots package allows you to plot a variety of tabular data structures, including
# those in JuliaDB.
# - It gives you the entire power and flexibility of Plots, but **not for Distributed
# Tables**.
# ------------------------------------------------------------------------------------------

using StatPlots
gr()

@df collect(dt) plot(:Date, :Close; group=:Ticker, legend=:topleft)

# ------------------------------------------------------------------------------------------
# ## Plotting with `partitionplot`
#
# - For large datasets, it may not be feasible to plot every point.
# - JuliaDB offers an alternative with `partitionplot`, which uses types in OnlineStats to
# incrementally build summaries of the data that can be plotted for datasets of **any**
# size.
# - The motivating idea is that the human brain cannot comprehend a huge number of points,
# so we can portray nearly the same information with summaries of the data rather than the
# data itself.
#
#
# - The syntax for `partitionplot` is
#
#   `partitionplot(table[, x], y; by, nparts = 100, stat = Extrema(), dropmissing = false)`
#
#   where:
#
#   - `x`, `y`, and `by` are selections
#   - The number of summaries to be calculated are between `nparts` and `2 * nparts`
#   - The type of summary is `stat`
#   - Missing values are skipped if `dropmissing == true`
#   - Any additional keyword arguments will be passed to Plots
#
# - In the following example, we "recreate" the above plot by plotting the extrema (maximum
# and minimum) of the closing price over sections of time.
# ------------------------------------------------------------------------------------------

using OnlineStats

partitionplot(collect(bintable), :Date, :Close, by = :Ticker, nparts=100, stat = Extrema(),
    legend = :topleft)
