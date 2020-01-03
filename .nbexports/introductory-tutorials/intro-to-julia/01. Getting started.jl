# ------------------------------------------------------------------------------------------
# # Getting started
#
# Topics:
# 1.  How to print
# 2. How to assign variables
# 3. How to comment
# 4. Syntax for basic math
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## How to print
#
# In Julia we usually use `println()` to print
# ------------------------------------------------------------------------------------------

println("I'm excited to learn Julia!")

# ------------------------------------------------------------------------------------------
# ## How to assign variables
#
# All we need is a variable name, value, and an equal's sign!<br>
# Julia will figure out types for us.
# ------------------------------------------------------------------------------------------

my_answer = 42
typeof(my_answer)

my_pi = 3.14159
typeof(my_pi)

😺 = "smiley cat!"
typeof(😺)

# ------------------------------------------------------------------------------------------
# To type a smiley cat, use tab completion to select the emoji name and then tab again
# ------------------------------------------------------------------------------------------

# \:smi + <tab> --> select with down arrow + <enter> ---> <tab> + <enter> to complete

# ------------------------------------------------------------------------------------------
# After assigning a value to a variable, we can reassign a value of a different type to that
# variable without any issue.
# ------------------------------------------------------------------------------------------

😺 = 1

typeof(😺)

# ------------------------------------------------------------------------------------------
# Note: Julia allows us to write super generic code, and 😺 is an example of this.
#
# This allows us to write code like
# ------------------------------------------------------------------------------------------

😀 = 0
😞 = -1

😺 + 😞 == 😀

# ------------------------------------------------------------------------------------------
# ## How to comment
# ------------------------------------------------------------------------------------------

# You can leave comments on a single line using the pound/hash key

#=

For multi-line comments, 
use the '#= =#' sequence.

=#

# ------------------------------------------------------------------------------------------
# ## Syntax for basic math
# ------------------------------------------------------------------------------------------

sum = 3 + 7

difference = 10 - 3

product = 20 * 5

quotient = 100 / 10

power = 10 ^ 2

modulus = 101 % 2

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# #### 1.1
# Look up docs for the `convert` function.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# #### 1.2
# Assign `365` to a variable named `days`. Convert `days` to a float and assign it to
# variable `days_float`
# ------------------------------------------------------------------------------------------



@assert days == 365
@assert days_float == 365.0


# ------------------------------------------------------------------------------------------
# #### 1.3
# See what happens when you execute
#
# ```julia
# convert(Int64, "1")
# ```
# and
#
# ```julia
# parse(Int64, "1")
# ```
# ------------------------------------------------------------------------------------------



Please click on `Validate` on the top, once you are done with the exercises.
