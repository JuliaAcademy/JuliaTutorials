# ------------------------------------------------------------------------------------------
# # Strings
#
# Topics:
# 1. How to get a string
# 2. String interpolation
# 3. String concatenation
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## How to get a string
#
# Enclose your characters in " " or """ """!
# ------------------------------------------------------------------------------------------

s1 = "I am a string."

s2 = """I am also a string. """

# ------------------------------------------------------------------------------------------
# There are a couple functional differences between strings enclosed in single and triple
# quotes. <br>
# One difference is that, in the latter case, you can use quotation marks within your
# string.
# ------------------------------------------------------------------------------------------

"Here, we get an "error" because it's ambiguous where this string ends "

"""Look, Mom, no "errors"!!! """

# ------------------------------------------------------------------------------------------
# Note that ' ' define a character, but NOT a string!
# ------------------------------------------------------------------------------------------

typeof('a')

'We will get an error here'

# ------------------------------------------------------------------------------------------
# ## String interpolation
#
# We can use the $ sign to insert existing variables into a string and to evaluate
# expressions within a string. <br>
# Below is an example that contains some highly sensitive personal information.
# ------------------------------------------------------------------------------------------

name = "Jane"
num_fingers = 10
num_toes = 10

println("Hello, my name is $name.")
println("I have $num_fingers fingers and $num_toes toes.")

 println("That is $(num_fingers + num_toes) digits in all!!")

# ------------------------------------------------------------------------------------------
# ## String concatenation
#
# Below are three ways we can concatenate strings! <br><br>
# The first way is to use the `string()` function. <br>
# `string()` converts non-string inputs to strings.
# ------------------------------------------------------------------------------------------

s3 = "How many cats ";
s4 = "is too many cats?";
😺 = 10

string(s3, s4)

string("I don't know, but ", 😺, " is too few.")

# ------------------------------------------------------------------------------------------
# We can also use `*` for concatenation!
# ------------------------------------------------------------------------------------------

s3*s4

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### 2.1
# Create a string that says "hi" 1000 times, first with `repeat` and then with the
# exponentiation operator, which can call `*` under the hood. Assign it the variable `hi`
# below.
# ------------------------------------------------------------------------------------------



@assert hi == "hihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihi"

# ------------------------------------------------------------------------------------------
# #### 2.2
# Declare two variables
#
# ```julia
# a = 3
# b = 4
# ```
# and use them to create two strings:
# ```julia
# "3 + 4"
# "7"
# ```
# and store the results in `c` and `d` respectively
# ------------------------------------------------------------------------------------------



@assert c == "3 + 4"
@assert d == "7"

# ------------------------------------------------------------------------------------------
# Please click on `Validate` on the top, once you are done with the exercises.
# ------------------------------------------------------------------------------------------
