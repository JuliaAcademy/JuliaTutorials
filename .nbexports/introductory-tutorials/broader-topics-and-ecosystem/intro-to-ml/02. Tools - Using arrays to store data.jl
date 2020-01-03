# ------------------------------------------------------------------------------------------
# # Tools - Using arrays to store data
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Introduction to arrays
#
# **Arrays are collections of boxes that we can use to store data.** In the last notebook,
# we saw an image that can help us to picture a 1-dimensional array:
#
# <img src="data/array_cartoon.png" alt="Drawing" style="width: 500px;"/>
#
# *Why do we want an object like this to store our data?*
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# An alternative to using an array in some contexts would be to name every individual piece
# of data, as follows:
#
# ```julia
# a = 1.1
# b = 2.2
# c = 3.3
# ```
#
# We can visualize how this data is stored:
#
# <img src="data/without_arrays.png" alt="Drawing" style="width: 500px;"/>
#
#
#
# This is like having a separate box for every piece of data, rather than a series of
# connected boxes for all our data.
#
# The more data we have, the more annoying it becomes to keep track of all these boxes and
# their names. Furthermore, if we want to do the same thing with many pieces of data, it's
# much easier to put all of these pieces of data in one place to work with them at once.
#
# For example, we may want to multiply `a`, `b`, and `c` by `2`. We could multiply three
# times:
#
# ```julia
# a * 2
# b * 2
# c * 2
# ```
#
# Or, instead, we could create one array (let's call it `numbers`) and multiply that array
# by `2`:
# ```julia
# numbers * 2
# ```
#
# The syntax for creating this array, `numbers`, is
#
# ```julia
# numbers = [a, b, c]
# ```
#
# Or, we could have just written
#
# ```julia
# numbers = [1.1, 2.2, 3.3]
# ```
#
# It's worth noting that in Julia, 1-dimensional arrays are also called "vectors".
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Creating arrays
#
# In the last section, we saw that we could create the array `numbers` by typing our
# elements, `a`, `b`, and `c` (or `1.1`, `2.2`, and `3.3`), inside square brackets.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
#
#
# Create an array called `first_array` that stores the numbers 10 through 20.
#
# Reminder: ESC+b to open a box below.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Array comprehensions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Alternatively we can create arrays via *"array comprehensions"*. This is a nice way to
# automate creating an array, if you don't want to have to type long lists of numbers inside
# square brackets.
#
# In an array comprehension, you write code inside square brackets that will generate the
# array as that code is executed. Let's see an example.
#
# ```julia
# counting = [2 * i for i in 1:10]
# ```
#
# The above line of code is saying that we want to create an array called `counting` that
# stores two times each of the integers between 1 and 10. This array comprehension has a few
# different parts, so let's dissect them:
#
# <img src="data/array_comprehension.png" alt="Drawing" style="width: 500px;"/>
#
# If we wanted to create another array, `roots`, that stored the square roots of all
# integers between 1 and 10, we could modify the code above to
#
# ```julia
# roots = [sqrt(i) for i in 1:10]
# ```
#
# #### Exercise
#
# Create an array, `squares`, that stores the squares of all integers between 1 and 100.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Looking inside an array
#
# We can "index" into an array to grab contents inside the array at a particular position.
# To index into our `counting` array, we place square brackets after the name of the array
# and put the position number of the element/data we want inside those brackets.
#
# For example, we might say
#
# ```julia
# counting[3]
# ```
#
# to grab the third element in the array called `counting`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 2
#
# Execute the code in the next cell. It will generate an array called `myprimes` that stores
# the first 168 prime numbers. Index into `myprimes` to grab the 89th smallest prime. What
# is this prime?
# ------------------------------------------------------------------------------------------

using Primes

myprimes = primes(1000); # The semicolon suppresses the output, try removing it

# ------------------------------------------------------------------------------------------
# ### Slicing
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Instead of grabbing a single number in an array, we can also take a **slice** of an array,
# i.e. a subset of the array, which can include multiple values. To take a slice of
# `counting` that includes the 3rd, 4th, and 5th entries, we use the following syntax with a
# colon (`:`):
#
# ```julia
# counting[3:5]
# ```
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 3
#
# Index into `myprimes` to grab the 89th through the 99th smallest primes (inclusive).
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Modifying an array
#
# In this section, we'll see how to edit an array we've already created. We'll see how to
#
# 1) Update an item at an existing position in an array;
#
# 2) Add an item to the end of an array;
#
# 3) Remove an item from the end of an array.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Update an item at an existing position in an array
#
# First off, we can update an item at an existing position in an array by indexing into the
# array and changing the value at the desired index. For example, let's say we have an array
# called `myfriends`:
#
# ```julia
# myfriends = ["Ted", "Robin", "Barney", "Lily", "Marshall"]
# ```
#
# We can grab Barney's name from `myfriends` via
#
# ```julia
# myfriends[3]
# ```
#
# and we can change "Barney" to something else by reassigning `myfriends[3]`:
#
# ```julia
# myfriends[3] = "Baby Bop"
# ```
#
# Note that a single `=` assigns a new variable to the value on the left of the `=` sign.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 4
#
# Use an array comprehension to create an array, `mysequence`, that stores the numbers 4
# through 10. Index into `mysequence` and update it to replace the last element, `10`, with
# `11`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Add an item to the end of an array
#
# We can add an item to the end of an array with the `push!` function. Don't worry about the
# exclamation mark at the end of `push!`; we'll talk about why that's there later, when we
# discuss functions.
#
# For now, note that when you call `push!` on an array and a value, you add that value to
# the end of the array. For example,
#
# ```julia
# push!(counting, 1000)
# ```
#
# will turn `counting`, which was formerly
#
# ```julia
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# ```
# into
# ```julia
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1000]
# ```
#
# Prove to yourself this works!
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# #### Exercise 5
#
# Copy the following code to declare the array `fibonacci`:
#
# ```julia
# fibonacci = [1, 1, 2, 3, 5, 8, 13]
# ```
#
# Use `push!` to add `21` to `fibonacci` after the number `13`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Remove an item from the end of an array
#
# To remove an item from the end of an array, use the `pop!` function. When using `pop!` on
# arrays, `pop!` only needs one input argument, namely the array you want to change. For
# example, if
#
# ```julia
# counting == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1000]
# ```
#
# then
# ```julia
# pop(counting)
# ```
# will remove `1000` from the end of `counting`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 6
#
# Use `pop!` to remove `21` from `fibonacci`. What does this function call return?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 7
#
# What is the last element of `fibonacci`? Try
#
# ```julia
# fibonacci[end]
# ```
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# ### Arrays of arrays and multidimensional arrays
#
# So far we've only seen 1D arrays of scalars, but arrays can also store other arrays and
# can have an arbitrary number of dimensions.
# <br><br>
# For example, the following are arrays of arrays:
# ------------------------------------------------------------------------------------------

favorites = [ ["koobideh", "chocolate", "eggs"], ["penguins", "cats", "sugargliders"] ]

numbers = [ [1, 2, 3], [4, 5], [6, 7, 8, 9] ]

# ------------------------------------------------------------------------------------------
# One way to create a multidimensional array is to use the `rand` function. `rand` takes an
# arbitrary number of arguments where the number of arguments determines the number of
# dimensions the array created by `rand` will have!
#
# For example, if we pass `rand` two integer inputs, it will generate a 2D array, while
# three integer inputs will generate a 3D array:
# ------------------------------------------------------------------------------------------

rand(4, 3)

rand(4, 3, 2)

# ------------------------------------------------------------------------------------------
# If we want to grab a value from a 2D array, we index into the array, specifying the row
# and column of the element of interest! For example, if we have the array `A` given by
#
# ```julia
# A = [ 1  2  3
#       4  5  6
#       7  8  9 ]
#  ```
#  we could grab the number 6 by saying
#
#  ```
#  A[2, 3]
#  ```
#
#  since 6 is in the 2nd row and 3rd column of `A`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 8
#
#  Copy and execute the following code to get an array, `myprimematrix`, which stores the
# first 100 primes
#
#  ```
#  myprimematrix = reshape(primes(541), (10, 10))
#  ```
#
#  Grab the prime in the 8th row and 5th column via indexing. What is the value of this
# prime?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Copying arrays
#
# Be careful when you want to copy arrays!
#
# Let's say you want to copy an existing array, like `fibonacci`, to an array called
# `somenumbers`. Remember how we defined `fibonacci`:
#
# ```
# fibonacci = [1, 1, 2, 3, 5, 8, 13]
# ```julia
#
# What if we try to copy fibonacci by saying
#
# ```
# somenumbers = fibonacci
# ```julia
# ?
# Execute this code to try to copy fibonacci. Look at `somenumbers` to see if it stores what
# you want.
# ------------------------------------------------------------------------------------------

fibonacci

somenumbers = fibonacci

somenumbers

# ------------------------------------------------------------------------------------------
# Now let's update `somenumbers` by changing its first element.
# ------------------------------------------------------------------------------------------

somenumbers[1] = 404

# ------------------------------------------------------------------------------------------
# Now let's look inside fibonacci.
# ------------------------------------------------------------------------------------------

fibonacci

# ------------------------------------------------------------------------------------------
# #### Exercise 9
#
# What is the first element in `fibonacci`?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Copying or not?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Did copying `fibonacci` like this work?
#
# No, unfortunately not. When we tried to copy, all we did was give `fibonacci` a new name,
# `somenumbers`. Now when we update `somenumbers`, we're also updating `fibonacci` because
# they are the same object!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# If we actually want to make a *copy* of the array bound to `fibonacci`, we can use the
# `copy` function:
# ------------------------------------------------------------------------------------------

# First, restore fibonacci

fibonacci[1] = 1
fibonacci

somemorenumbers = copy(fibonacci)

somemorenumbers[1] = 404

fibonacci

# ------------------------------------------------------------------------------------------
# In this last example, fibonacci was not updated. Therefore we see that the arrays bound to
# `somemorenumbers` and `fibonacci` are distinct.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 10
#
# Copy `myprimematrix` to `mynewprimematrix`. Update `mynewprimematrix[3,3]` to `1234`.
# ------------------------------------------------------------------------------------------
