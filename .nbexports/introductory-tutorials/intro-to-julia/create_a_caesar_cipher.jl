# ------------------------------------------------------------------------------------------
# ## Create a caesar cipher
#
# ### Caesar ciphers
#
# A caesar cipher is an encryption scheme that shifts all letters in the alphabet by some
# specified offset to other letters in the alphabet.
#
# For example, a shift of 1 would turn the letter "A" into the letter "B" and the letter "M"
# to the letter "N".
#
# ### Goal
#
# We want to add a method to the `+` operator such that we can add together a string and an
# integer shift to encrypt a message. For example,
#
# ```julia
# 4 + "hello" == "lipps"
# ```
#
# We'll walk you through the steps to do this!
#
# ### Test it out
#
# Once you think you have it working, try to decrypt the following string by adding a shift
# of -7.
# ```julia
# "Kv'uv{'tlkksl'pu'{ol'hmmhpyz'vm'kyhnvuz'mvy'\u80v|'hyl'jy|ujo\u80'huk'{hz{l'nvvk'~p{o'rl{
# jo|w5"
# ```
#
# ### Let's get started!
#
# First, we want a way to convert between characters and integers. Actually, under the hood,
# all of our characters are being represented as numbers via their *ASCII representation*.
#
# You can start to get a feel for how this works by running the following lines of code.
#
# ```julia
# convert(Int, 'a')
# convert(Int, 'b')
# convert(Char, 97)
# convert(Char, 98)
# ```
# ------------------------------------------------------------------------------------------









# ------------------------------------------------------------------------------------------
# What happens when you try to add an integer to a character? (Note that the difference
# between `Char`s and `String`s is important here!)
# ------------------------------------------------------------------------------------------







# ------------------------------------------------------------------------------------------
# When we treat a string elementwise, what is the type of (`typeof`) each element?
# ------------------------------------------------------------------------------------------





# ------------------------------------------------------------------------------------------
# Try to write a function called `caesar(shift, stringin)` that encodes its input string,
# `stringin`, by shifting all letters in the alphabet by `shift`.
#
# One way to do this is to use the `map` or `broadcast` function!
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# If you think you have this working, try out
# ```julia
# caesar(-4, "lipps")
# ```
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# Last, we want to extend the `+` operator to include a way to apply this cipher.
#
# The `+` operator lives in a place called "Base". Everything that lives in Base is
# accessible to us as users by default, but we need a special incantation to modify the
# things that live in Base. If we want to modify `+`, our incantation is
#
# ```julia
# import Base: +
# ```
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# After you have imported `+` from Base, we are ready to modify it.
#
# If you're not sure how to add a method for `+`, let's go through an example first.
#
# Let's say we want to add a method for `+` that allows us to concatenate strings so that we
# can say
# ```julia
# "hello " + "world"
# ```
# and receive the output string ```hello world```.
#
# To do this, we can write a method for `+` like this
# ------------------------------------------------------------------------------------------

+(x::String, y::String) = string(x, y)

# ------------------------------------------------------------------------------------------
# Note that I've added type information about `x` and `y` with a double colon and the word
# `String` to say that `x` and `y` are both strings.
#
# To test that this works, try out
# ```julia
# "hello " + "world"
# ```
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# And now that you've extended `+` once, let's add another method for `+` that calls the
# `caesar` function we've written.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# Now try it out via
#
# ```julia
# -7 + "Kv'uv{'tlkksl'pu'{ol'hmmhpyz'vm'kyhnvuz'mvy'\u80v|'hyl'jy|ujo\u80'huk'{hz{l'nvvk'~p{
# o'rl{jo|w5"
# ```
# ------------------------------------------------------------------------------------------






