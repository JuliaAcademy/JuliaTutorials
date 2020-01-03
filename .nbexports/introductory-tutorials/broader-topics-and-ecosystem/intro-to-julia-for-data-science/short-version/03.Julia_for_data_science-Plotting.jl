# ------------------------------------------------------------------------------------------
# # Julia for Data Science - Plotting
#
# ### Data visualization: generating nice looking plots in Julia is straight forward
# In what's next, we will see some of the tools that Julia plotting provides to produce high
# quality figures for your data. In particular we'll look at
#
# 1. Plotting mathematical functions
# 1. Visualizing statistics
# 1. Subplotting
# 
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Part 1: plot math functions (specifically latex equations) in our plots
# ------------------------------------------------------------------------------------------

using LaTeXStrings
using Plots
pyplot(leg=false)
x = 1:0.2:4

# ------------------------------------------------------------------------------------------
# Create three functions and plot them all!
# ------------------------------------------------------------------------------------------

y1 = sqrt.(x)
y2 = log.(x)
y3 = x.^2

f1 = plot(x,y1)
plot!(f1,x,y2) # "plot!" means "plot on the same canvas we just plot on"
plot!(f1,x,y3)

# ------------------------------------------------------------------------------------------
# Now we can annotate each of these plots! using either text, or latex strings
# ------------------------------------------------------------------------------------------

annotate!(f1,[(x[6],y1[6],text(L"\sqrt{x}",16,:center)),
          (x[11],y2[11],text(L"log(x)",:right,16)),
          (x[6],y3[6],text(L"x^2",16))])

# ------------------------------------------------------------------------------------------
# ## Part 2: Visualizing statistics
#
# **2D histograms** are really easy!
# ------------------------------------------------------------------------------------------

n = 1000
set1 = randn(n)
set2 = randn(n)
histogram2d(set1,set2,nbins=20,colorbar=true)

# ------------------------------------------------------------------------------------------
# **Let's go back to our houses dataset and learn even more things about it!**
# ------------------------------------------------------------------------------------------

using DataFrames
houses = readtable("houses.csv")
filter_houses = houses[houses[!, :sq__ft].>0,:]
x = filter_houses[!, :sq__ft]
y = filter_houses[!, :price]

gh = histogram2d(x,y,nbins=20,colorbar=true)
xaxis!(gh,"square feet")
yaxis!(gh,"price")

# ------------------------------------------------------------------------------------------
# Interesting!
#
# Most houses sold are in the range 1000-1500 and they cost approximately 150,000 dollars
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# *Let's see more stats plots.*
#
# We can convince ourselves that random distrubutions are indeed very similar.
#
# Let's do that through **box plots** and **violin plots**.
# ------------------------------------------------------------------------------------------

using StatsPlots
y = rand(10000,6) # generate 6 random samples of size 1000 each
f2 = violin(["Series 1" "Series 2" "Series 3" "Series 4" "Series 5"],y,leg=false,color=:red)

boxplot!(["Series 1" "Series 2" "Series 3" "Series 4" "Series 5"],y,leg=false,color=:green)

# ------------------------------------------------------------------------------------------
# These plots look almost identical, so we do have the same distribution indeed.
#
# Let's study the price distributions in different cities in the houses dataset.
# ------------------------------------------------------------------------------------------

some_cities = ["SACRAMENTO","RANCHO CORDOVA","RIO LINDA","CITRUS HEIGHTS","NORTH HIGHLANDS","ANTELOPE","ELK GROVE","ELVERTA" ] # try picking pther cities!

fh = plot(xrotation=90)
for ucity in some_cities
    subs = filter_houses[filter_houses[!, :city].==ucity,:]
    city_prices = subs[!, :price]
    violin!(fh,[ucity],city_prices,leg=false)
end
display(fh)

# ------------------------------------------------------------------------------------------
# ## Part 3: Subplots are very easy!
#
# To create a plot with subplots, all we need to do is throw the variables bound to
# individual plots inside another call to `plot`!
# ------------------------------------------------------------------------------------------

x = -10:.1:10
p1 = plot(x, x)
p2 = plot(x, x.^2)
p3 = plot(x, x.^3)
p4 = plot(x, x.^4)
plot(p1,p2,p3,p4,layout=(2,2),legend=false)

# ------------------------------------------------------------------------------------------
# You can create your own layout as follows.
# ------------------------------------------------------------------------------------------

mylayout = @layout([a{0.5h};[b{0.7w} c]])
plot(fh,f2,gh,layout=mylayout,legend=false)

# this layout:
# 1 
# 2 3

# ------------------------------------------------------------------------------------------
# ### Please let us know how we're doing!
#
# https://tinyurl.com/JuliaDataScience
# ------------------------------------------------------------------------------------------


