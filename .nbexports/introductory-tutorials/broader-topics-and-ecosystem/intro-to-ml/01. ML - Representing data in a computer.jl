# ------------------------------------------------------------------------------------------
# # Representing data in a computer
#
# The core of data science and machine learning is **data**: we are interested in extracting
# knowledge from data.
#
# But how exactly do computers represent data? Let's find out exactly what an "artificial
# intelligence" has at its disposal to learn from.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Data is represented as arrays
#
# Let's take a look at some fruit. Using the `Images.jl` library, we can load in some
# images:
# ------------------------------------------------------------------------------------------

using Images

apple = load("data/10_100.jpg")

banana = load("data/104_100.jpg")

# ------------------------------------------------------------------------------------------
# Here we have images of apples and bananas. We would eventually like to build a program
# that can automatically distinguish between the two. However, the computer doesn't "see" an
# apple or a banana; instead, it just sees numbers.
#
# An image is encoded in something called an **array**, which is like a container that has
# boxes or slots for individual pieces of data:
#
# ![attachment:array_cartoon.png](data/array_cartoon.png)
#
# An array is a bunch of numbers in connected boxes; the figure above shows a 1-dimensional
# array. Our images are instead 2-dimensional arrays, or matrices, of numbers, arranged
# something like this:
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ![attachment:array2d.png](data/array2d.png)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# For example, `apple` is an image, consisting of a 100x100 array of numbers:
# ------------------------------------------------------------------------------------------

typeof(apple)

typeof(a)

a = [ 1 2 3;4 5 6]

size(a)

# ------------------------------------------------------------------------------------------
# We can grab the datum stored in the box at row `i` and column `j` by *indexing* using
# square brackets: `[i, j]`. For example, let's get the pixel (piece of the image) in box
# $(40, 60)$, i.e. in the 40th row and 60th column of the image:
# ------------------------------------------------------------------------------------------

apple

dump(typeof(apple[40, 60]))

apple[18:20,29:31]



# ------------------------------------------------------------------------------------------
# We see that Julia displays a coloured box! Julia, via the `Colors.jl` package, is clever
# enough to display colours in a way that is useful to us humans!
#
# So, in fact, an image is a 2D array, in which each element of the array is an object (a
# collection of numbers) describing a coloured pixel.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Colors as numbers
#
# How, then, are these colors actually stored? Computers store colors in RGB format, that is
# they store a value between 0 and 1 for each of three "channels": red, green, and blue.
# Here, 0 means none of that color and 1 means the brightest form of that color. The overall
# color is a combination of those three colors.
#
# For example, we can pull out the `red` value using the function `red` applied to the
# color. Since internally the actual value is stored in a special format, we choose to
# convert it to a standard floating-point number using the `Float64` function:
# ------------------------------------------------------------------------------------------

Float64(red(apple[40, 60]))

[ mean(float.(c.(img))) for c = [red,green,blue], img = [apple,banana] ]

using Plots

histogram(float.(green.(apple[:])),color="red",label="apple", normalize=true, nbins=25)
histogram!(float.(green.(banana[:])),color="yellow",label="banana",normalize=true, nbins=25)

apple

float(red(banana[50,20]))

banana[50,20]

pixel = apple[40, 60]

red_value   = Float64( red(pixel) )
green_value = Float64( green(pixel) )
blue_value  = Float64( blue(pixel) )

print("The RGB values are ($red_value, $green_value, $blue_value)")

# ------------------------------------------------------------------------------------------
# Since the red value is high while the others are low, this means that at pixel `(40, 60)`,
# the picture of the apple is very red. If we do the same at one of the corners of the
# picture, we get the following:
# ------------------------------------------------------------------------------------------

pixel = apple[1, 1]

red_value   = Float64( red(pixel) )
green_value = Float64( green(pixel) )
blue_value  = Float64( blue(pixel) )

print("The RGB values are ($red_value, $green_value, $blue_value)")

apple

# ------------------------------------------------------------------------------------------
# We see that every color is bright, which corresponds to white.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Working on an image as a whole
#
# In Julia, to apply a function to the whole of an array, we place a `.` between the
# function name and the left parenthesis (`(`), so the following gives us the `red` value of
# every pixel in the image:
# ------------------------------------------------------------------------------------------

redpartofapple = Float64.(red.(apple))
mean(redpartofapple)

using Plots

gr()

histogram(redpartofapple[:],color=:red,label="redness in the apple")

# ------------------------------------------------------------------------------------------
# Note that we get a 2D array (matrix) back.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia's [mathematical standard
# library](https://docs.julialang.org/en/stable/stdlib/math/#Mathematics-1) has many
# mathematical functions built in. One of them is the `mean` function, which computes the
# average value. If we apply this to our apple:
# ------------------------------------------------------------------------------------------

mean(Float64.(red.(apple)))

# ------------------------------------------------------------------------------------------
# we see that the value indicates that the average amount of red in the image is a value
# between the amount of red in the apple and the amount of red in the white background.
#
# *Somehow we need to teach a computer to use this information about a picture to recognize
# that there's an apple there!*
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## A quick riddle
#
# Here's a quick riddle. Let's check the average value of red in the image of the banana.
# ------------------------------------------------------------------------------------------

mean(Float64.(red.(banana)))

# ------------------------------------------------------------------------------------------
# Oh no, that's more red than our apple? This isn't a mistake and is actually true! Before
# you move onto the next exercise, examine the images of the apple and the banana very
# carefully and see if you can explain why this is expected.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# What is the average value of blue in the banana?
#
# (To open a new box use <ESC>+b (b is for "below", what do you think a does?))
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 2
#
# Does the banana have more blue or more green?
# ------------------------------------------------------------------------------------------
