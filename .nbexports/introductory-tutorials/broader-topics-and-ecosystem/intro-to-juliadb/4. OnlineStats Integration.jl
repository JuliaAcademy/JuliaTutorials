# ------------------------------------------------------------------------------------------
# # OnlineStats Integration
#
# - OnlineStats is a Julia package for running statistical algorithms both online (one
# observation at a time) and in parallel.
# - In this notebook we will go over how to run these calculations through JuliaDB.
#
# First we'll load OnlineStats, JuliaDB and Plots (with GR backend)
# ------------------------------------------------------------------------------------------

using OnlineStats, JuliaDB, Plots
gr()

# print table rather than column summary
IndexedTables.set_show_compact!(false);

# ------------------------------------------------------------------------------------------
# Now we'll see:
# 1. An Intro to OnlineStats
# 1. An Example Using OnlineStats with `partitionplot`, `reduce`, and `groupreduce` (all
# available for out-of-core processing!)
# 1. Mosaic Plots
# 1. Linear Regression
# 1. Approximate Solutions to Statistical Learning Models with `StatLearn`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Intro to OnlineStats
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Every stat is a type
# ------------------------------------------------------------------------------------------

m = Mean()

# ------------------------------------------------------------------------------------------
# ### Stats can be `fit!`-ted with more data
# ------------------------------------------------------------------------------------------

fit!(m, randn(100))

# ------------------------------------------------------------------------------------------
# ### Stats can be `merge!`-ed together
# ------------------------------------------------------------------------------------------

m2 = fit!(Mean(), randn(100))

merge!(m, m2)

# ------------------------------------------------------------------------------------------
# ### `fit!`-ting and `merge!`-ing works quite well with JuliaDB
#
# - JuliaDB can send stats to the worker processes and then merge them at the end.
#
# <img src="https://user-
# images.githubusercontent.com/8075494/32748459-519986e8-c88a-11e7-89b3-80dedf7f261b.png"
# width=400>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Example: Diamonds Dataset
#
# - OnlineStats operations are available through `partitionplot`, `reduce` and
# `groupreduce`.
# - Here we will take a look at a dataset about diamond quality.
#
#
# - First let's examine the first few rows of the data:
# ------------------------------------------------------------------------------------------

;head diamonds.csv

# ------------------------------------------------------------------------------------------
# - The first column is the row number, so we'll only load the other columns.  Here we sort
# the data by column 2, `:carat`.
# ------------------------------------------------------------------------------------------

using JuliaDB
t = loadtable("diamonds.csv", indexcols = [2], datacols = 3:11)

# ------------------------------------------------------------------------------------------
# # `partitionplot`
#
# `partitionplot(table[, x], y; by, stat, nparts, dropmissing)`
#
# - We introduced `partitionplot` in the previous notebook.
# - Here we'll go through some more advanced examples.
# - If only one variable is provided, the x-axis will be the number of observations.
# - Note that `:carat` is our index variable and thus it is sorted:
# ------------------------------------------------------------------------------------------

partitionplot(t, :carat)

# ------------------------------------------------------------------------------------------
# - When we provide two variables, the summary of the `y` variable is plotted in each
# "section" of the `x` variable.
#
# - In this example, we'll use the Interact package to choose which statistic to summarize
# `y` with in the of plot `y = :price` vs. `x = :carat`:
# ------------------------------------------------------------------------------------------

import Interact

Interact.@manipulate for summarizer in [Mean(), Extrema(), Hist(10)]
    partitionplot(t, :carat, :price, stat = summarizer)
end

# ------------------------------------------------------------------------------------------
# - Any selector is a valid input to the `x` and `y` arguments of `partitionplot`:
# ------------------------------------------------------------------------------------------

partitionplot(t, :carat => x -> -x, :price, stat = Hist(10))

# ------------------------------------------------------------------------------------------
# - Any valid Plots keyword argument can also be included, such as changing the type of plot
# series to a barplot.
#
# - Here we are essentially plotting `groupby(mean, t, :cut, select = :carat)`:
# ------------------------------------------------------------------------------------------

partitionplot(t, :cut, :carat; stat = Mean(), seriestype = :bar)

# ------------------------------------------------------------------------------------------
# # `reduce` and `groupreduce`
#
# - In the following examples, we'll see that the reducer for `reduce` and `groupreduce` can
# come from OnlineStats.  The OnlineStats reducers can be:
#   1. A `Series`
#   1. An `OnlineStat`
#   1. A tuple of `OnlineStat`s
#
#
# - Here we get the mean of `:carat` for each level of `:cut`:
# ------------------------------------------------------------------------------------------

groupreduce(Mean(), t, :cut; select = :carat)

# ------------------------------------------------------------------------------------------
# - We could also calculate the same information with `groupby`
# - However `[group]reduce` with an OnlineStat is often more efficient.
# ------------------------------------------------------------------------------------------

@time groupreduce(Mean(), t, :cut; select = :carat)
@time groupby(mean, t, :cut; select = :carat)

# ------------------------------------------------------------------------------------------
# ## Size of Selections
#
# - One thing to note is that the selection in `reduce`/`groupreduce` must match the "input
# size" of the `OnlineStat` object passed as an argument.
# - Different stats can be applied to different columns with the `Group` type.
#     - Multiple stats of the same type can be created via integer multiplication (see
# example below)
# - For example, if you want to calculate the means for 5 different columns, you would use
# as reducer:
# ------------------------------------------------------------------------------------------

5 * Mean()

# ------------------------------------------------------------------------------------------
# - In this example we create 3 histograms of 50 bins each to use the columns `:x`, `:y`,
# and `:z` as input:
# ------------------------------------------------------------------------------------------

hists = reduce(3Hist(50), t; select = (:x, :y, :z))

# ------------------------------------------------------------------------------------------
# - The printed histograms do not provide much information.
# - Fortunately, OnlineStats implements many Plots recipes.
# - Plotting a `Group` will then plot the stats it contains:
# ------------------------------------------------------------------------------------------

plot(hists, layout = 3)

# ------------------------------------------------------------------------------------------
# - You may also want to calculate different statistics for different columns.
# ------------------------------------------------------------------------------------------

reducer = Group(Mean(), CountMap(String))

plot(reduce(reducer, t; select = (:carat, :cut)), layout = 2)

# ------------------------------------------------------------------------------------------
# ## Visualizing Continuous Distributions
#
# - The `Hist` type is particularly useful for visualizing continuous distributions, as it
# adaptively finds the "best" bin locations.
#
# - In the following cell, try increasing the number of bins and see how the histogram
# changes:
# ------------------------------------------------------------------------------------------

# try increasing the number of bins
plot(reduce(Hist(50), t; select = :carat))

# ------------------------------------------------------------------------------------------
# ## Visualizing Categorical Distributions
#
# - The `CountMap` type tracks the number of occurrences for each unique value in a column.
# - `CountMap` accepts the column type as its argument.
# - The `:cut` column is of type `String`, so here we use `CountMap(String)`:
# ------------------------------------------------------------------------------------------

plot(reduce(CountMap(String), t; select = :cut))

# ------------------------------------------------------------------------------------------
# ## Mosaic Plot
#
# - Mosaic plots are extremely useful in visualizing the association between two categorical
# variables, as it shows class probabilities of the `x` variables and conditional class
# probabilities of the `y` variable.
# - `Mosaic` accepts the two column types as its input.
#
#
# - The `:cut` and `:color` variables are both of type `String`, so here we use
# `Mosiac(String, String)`.
# - We can see most common `:cut` is `"Ideal"` and the least common is `"Fair"` (which we
# already know from above).
# ------------------------------------------------------------------------------------------

plot(reduce(Mosaic(String, String), t; select = (:cut, :color)))

# ------------------------------------------------------------------------------------------
# # Statistical Models
#
# - We can build linear (and ridge) regression models using the `LinRegBuilder` and `LinReg`
# types.
#
# ## `LinRegBuilder(p)`
#
# - `LinRegBuilder` builds a data structure that allows you to regress any of the observed
# columns on any subset of other columns.
# ------------------------------------------------------------------------------------------

x = (:carat,:depth,:table,:price,:x,:y,:z)

o = reduce(LinRegBuilder(7), t; select = x)

# ------------------------------------------------------------------------------------------
# - If we wish to fit a model with formula:
# ```
# price ~ carat + depth + table + x + y + z + 1
# ```
#   We can specify the `y` variable to be the 4-th column, which was `:price`.  By default,
# an intercept (bias) term is included as the last coefficient.
# ------------------------------------------------------------------------------------------

coef(o; y=4, verbose=true)

# ------------------------------------------------------------------------------------------
# - We can then create a different regression (without revisiting data) based on the formula
#
#   ```
#   carat ~ x + y + z
#   ```
#
#   by specifying the `y` and `x` variables and removing the `bias`:
# ------------------------------------------------------------------------------------------

coef(o; y=1, x = 5:7, bias = false)

# ------------------------------------------------------------------------------------------
# ## `LinReg()`
#
# - The `LinReg` type allows you to fit linear regression with an optional L2 (ridge)
# penalty.
# - One thing to note is that besides `LinRegBuilder`, models in OnlineStats expect data as
# a tuple: `(x, y)`.
#   - This requires selections to take the form: `((xvars...), yvar)`.
#
#
# - In this example, we'll create the model:
# ```
# carat ~ x + y + z
# ```
# - Note that we found the same result as we did with `LinRegBuilder` above.
# ------------------------------------------------------------------------------------------

o = reduce(LinReg(), t; select = ((:x, :y, :z), :carat))

coef(o, 0.1)

# ------------------------------------------------------------------------------------------
# ## Other Models
#
# - **OnlineStats** has a variety of methods that are more advanced than linear regression.
# - They're beyond the scope of this introduction, but interested readers can investigate
# the following:
#
# ### `StatLearn` (Stochastic approximation for linear statistical learning models)
#
# ### `NBClassifier` (Naive Bayes Classifier)
#
# ### `FastTree`/ `FastForest` (experimental online decision trees/random forests)
# 
# ------------------------------------------------------------------------------------------
