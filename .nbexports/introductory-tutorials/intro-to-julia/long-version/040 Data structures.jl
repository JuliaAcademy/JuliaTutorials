# ------------------------------------------------------------------------------------------
# # Data structures
#
# Once we start working with many pieces of data at once, it will be convenient for us to
# store data in structures like arrays or dictionaries (rather than just relying on
# variables).<br>
#
# Types of data structures covered:
# 1. Tuples
# 2. Named Tuples
# 3. Dictionaries
#
# <br>
# As an overview, tuples and arrays are both ordered sequences of elements (so we can index
# into them). Dictionaries and arrays are both mutable.
# We'll explain this more below!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Tuples
#
# We can create a tuple by enclosing an ordered collection of elements in `( )`.
#
# Syntax: <br>
# ```julia
# (item1, item2, ...)```
# ------------------------------------------------------------------------------------------

myfavoriteanimals = ("penguins", "cats", "sugargliders")

# ------------------------------------------------------------------------------------------
# We can index into this tuple,
# ------------------------------------------------------------------------------------------

myfavoriteanimals[1]

# ------------------------------------------------------------------------------------------
# but since tuples are immutable, we can't update it
# ------------------------------------------------------------------------------------------

myfavoriteanimals[1] = "otters"

# ------------------------------------------------------------------------------------------
# ## Now in 1.0: NamedTuples
#
# As you might guess, `NamedTuple`s are just like `Tuple`s except that each element
# additionally has a name! They have a special syntax using `=` inside a tuple:
#
# ```julia
# (name1 = item1, name2 = item2, ...)
# ```
# ------------------------------------------------------------------------------------------

myfavoriteanimals = (bird = "penguins", mammal = "cats", marsupial = "sugargliders")

# ------------------------------------------------------------------------------------------
# Like regular `Tuples`, `NamedTuples` are ordered, so we can retrieve their elements via
# indexing:
# ------------------------------------------------------------------------------------------

myfavoriteanimals[1]

# ------------------------------------------------------------------------------------------
# They also add the special ability to access values by their name:
# ------------------------------------------------------------------------------------------

myfavoriteanimals.bird

# ------------------------------------------------------------------------------------------
# ## Dictionaries
#
# If we have sets of data related to one another, we may choose to store that data in a
# dictionary. We can create a dictionary using the `Dict()` function, which we can
# initialize as an empty dictionary or one storing key, value pairs.
#
# Syntax:
# ```julia
# Dict(key1 => value1, key2 => value2, ...)```
#
# A good example is a contacts list, where we associate names with phone numbers.
# ------------------------------------------------------------------------------------------

myphonebook = Dict("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

# ------------------------------------------------------------------------------------------
# In this example, each name and number is a "key" and "value" pair. We can grab Jenny's
# number (a value) using the associated key
# ------------------------------------------------------------------------------------------

myphonebook["Jenny"]

# ------------------------------------------------------------------------------------------
# We can add another entry to this dictionary as follows
# ------------------------------------------------------------------------------------------

myphonebook["Kramer"] = "555-FILK"

# ------------------------------------------------------------------------------------------
# Let's check what our phonebook looks like now...
# ------------------------------------------------------------------------------------------

myphonebook

# ------------------------------------------------------------------------------------------
# We can delete Kramer from our contact list - and simultaneously grab his number - by using
# `pop!`
# ------------------------------------------------------------------------------------------

pop!(myphonebook, "Kramer")

myphonebook

# ------------------------------------------------------------------------------------------
# Unlike tuples and arrays, dictionaries are not ordered. So, we can't index into them.
# ------------------------------------------------------------------------------------------

myphonebook[1]

# ------------------------------------------------------------------------------------------
# In the example above, `julia` thinks you're trying to access a value associated with the
# key `1`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercises
# ------------------------------------------------------------------------------------------

@assert a_ray == [1, 2, 3]

# ------------------------------------------------------------------------------------------
# #### 3.2
# Try to add "Emergency" as key to `myphonebook` with the value `string(911)` with the
# following code
# ```julia
# myphonebook["Emergency"] = 911
# ```
#
# Why doesn't this work?
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# #### 3.3
# Create a new dictionary called `flexible_phonebook` that has Jenny's number stored as an
# integer and Ghostbusters' number stored as a string with the following code
#
# ```julia
# flexible_phonebook = Dict("Jenny" => 8675309, "Ghostbusters" => "555-2368")
# ```
# ------------------------------------------------------------------------------------------



@assert flexible_phonebook == Dict("Jenny" => 8675309, "Ghostbusters" => "555-2368")

# ------------------------------------------------------------------------------------------
# #### 3.4
# Add the key "Emergency" with the value `911` (an integer) to `flexible_phonebook`.
# ------------------------------------------------------------------------------------------



@assert haskey(flexible_phonebook, "Emergency")

@assert flexible_phonebook["Emergency"] == 911

# ------------------------------------------------------------------------------------------
# #### 3.5
# Why can we add an integer as a value to `flexible_phonebook` but not `myphonebook`? How
# could we have initialized `myphonebook` so that it would accept integers as values?
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# Please click on `Validate` button at the top, upon completion of the excercise
# ------------------------------------------------------------------------------------------
