# ------------------------------------------------------------------------------------------
# # Plotting
#
# ## Basics
# There are a few different ways to plot in Julia (including calling PyPlot). <br>
#
# Here we'll show you how to use `Plots.jl`.  If it's not installed yet, you need to use the
# package manager to install it, and Julia will precompile it for you the first time you use
# it:
# ------------------------------------------------------------------------------------------

# using Pkg
# Pkg.add("Plots")
using Plots

# ------------------------------------------------------------------------------------------
# One of the advantages to `Plots.jl` is that it allows you to seamlessly change backends.
# In this notebook, we'll try out the `gr()` and `plotlyjs()` backends.<br>
#
# In the name of scientific inquiry, let's use this notebook to examine the relationship
# between the global temperature and the number of pirates between roughly 1860 and 2000.
# ------------------------------------------------------------------------------------------

globaltemperatures = [14.4, 14.5, 14.8, 15.2, 15.5, 15.8]
numpirates = [45000, 20000, 15000, 5000, 400, 17];

# ------------------------------------------------------------------------------------------
# Plots supports multiple backends — that is, libraries that actually do the drawing — all
# with the same API. To start out, let's try the GR backend.  You choose it with a call to
# `gr()`:
# ------------------------------------------------------------------------------------------

gr()

# ------------------------------------------------------------------------------------------
# and now we can use commands like `plot` and `scatter` to generate plots.
# ------------------------------------------------------------------------------------------

plot(numpirates, globaltemperatures, label="line")  
scatter!(numpirates, globaltemperatures, label="points") 

# ------------------------------------------------------------------------------------------
# The `!` at the end of the `scatter!` function name makes `scatter!` a mutating function,
# indicating that the scattered points will be added onto the pre-existing plot.
#
# In contrast, see what happens when you replace `scatter!` in the above with the non-
# mutating function `scatter`.
#
# Next, let's update this plot with the `xlabel!`, `ylabel!`, and `title!` commands to add
# more information to our plot.
# ------------------------------------------------------------------------------------------

xlabel!("Number of Pirates [Approximate]")
ylabel!("Global Temperature (C)")
title!("Influence of pirate population on global warming")

# ------------------------------------------------------------------------------------------
# This still doesn't look quite right. The number of pirates has decreased since 1860, so
# reading the plot from left to right is like looking backwards in time rather than
# forwards. Let's flip the x axis to better see how pirate populations have caused global
# temperatures to change over time!
# ------------------------------------------------------------------------------------------

xflip!()

# ------------------------------------------------------------------------------------------
# And there we have it!
#
# Note: We've had some confusion about this exercise. :) This is a joke about how people
# often conflate correlation and causation.
#
# **Without changing syntax, we can create this plot with the UnicodePlots backend**
# ------------------------------------------------------------------------------------------

Pkg.add("UnicodePlots")
unicodeplots()

plot(numpirates, globaltemperatures, label="line")  
scatter!(numpirates, globaltemperatures, label="points") 
xlabel!("Number of Pirates [Approximate]")
ylabel!("Global Temperature (C)")
title!("Influence of pirate population on global warming")

# ------------------------------------------------------------------------------------------
# And notice how this second plot differs from the first!  Using text like this is a little
# silly in a Jupyter notebook where we have fancy drawing capabilities, but it can be very
# useful for quick and dirty visualization in a terminal.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### 8.1
# Given
# ```julia
# x = -10:10
# ```
# plot y vs. x for $y = x^2$.  You may want to change backends back again.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# #### 8.2
# Execute the following code
# ------------------------------------------------------------------------------------------

p1 = plot(x, x)
p2 = plot(x, x.^2)
p3 = plot(x, x.^3)
p4 = plot(x, x.^4)
plot(p1, p2, p3, p4, layout = (2, 2), legend = false)

# ------------------------------------------------------------------------------------------
# and then create a $4x1$ plot that uses `p1`, `p2`, `p3`, and `p4` as subplots.
# ------------------------------------------------------------------------------------------


