# ------------------------------------------------------------------------------------------
# # Multiple dispatch
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# In this notebook we'll explore **multiple dispatch**, which is a key feature of Julia.
#
# Multiple dispatch makes software *generic* and *fast*!
#
# #### Starting with the familiar
#
# To understand multiple dispatch in Julia, let's start with what we've already seen.
#
# We can declare functions in Julia without giving Julia any information about the types of
# the input arguments that function will receive:
# ------------------------------------------------------------------------------------------

f(x) = x^2

# ------------------------------------------------------------------------------------------
# and then Julia will determine on its own which input argument types make sense and which
# do not:
# ------------------------------------------------------------------------------------------

f(10)

f([1, 2, 3])

# ------------------------------------------------------------------------------------------
# #### Specifying the types of our input arguments
#
# However, we also have the *option* to tell Julia explicitly what types our input arguments
# are allowed to have.
#
# For example, let's write a function `foo` that only takes strings as inputs.
# ------------------------------------------------------------------------------------------

foo(x::String, y::String) = println("My inputs x and y are both strings!")

# ------------------------------------------------------------------------------------------
# We see here that in order to restrict the type of `x` and `y` to `String`s, we just follow
# the input argument name by a double colon and the keyword `String`.
#
# Now we'll see that `foo` works on `String`s and doesn't work on other input argument
# types.
# ------------------------------------------------------------------------------------------

foo("hello", "hi!")

foo(3, 4)

# ------------------------------------------------------------------------------------------
# To get `foo` to work on integer (`Int`) inputs, let's tack `::Int` onto our input
# arguments when we declare `foo`.
# ------------------------------------------------------------------------------------------

foo(x::Int, y::Int) = println("My inputs x and y are both integers!")

foo(3, 4)

# ------------------------------------------------------------------------------------------
# Now `foo` works on integers! But look, `foo` also still works when `x` and `y` are
# strings!
# ------------------------------------------------------------------------------------------

foo("hello", "hi!")

# ------------------------------------------------------------------------------------------
# This is starting to get to the heart of multiple dispatch. When we declared
#
# ```julia
# foo(x::Int, y::Int) = println("My inputs x and y are both integers!")
# ```
# we didn't overwrite or replace
# ```julia
# foo(y::String, y::String)```
#
# Instead, we just added an additional ***method*** to the ***generic function*** called
# `foo`.
#
# A ***generic function*** is the abstract concept associated with a particular operation.
#
# For example, the generic function `+` represents the concept of addition.
#
# A ***method*** is a specific implementation of a generic function for *particular argument
# types*.
#
# For example, `+` has methods that accept floating point numbers, integers, matrices, etc.
#
# We can use the `methods` to see how many methods there are for `foo`.
# ------------------------------------------------------------------------------------------

methods(foo)

methods(+)

# ------------------------------------------------------------------------------------------
# So, we now can call `foo` on integers or strings. When you call `foo` on a particular set
# of arguments, Julia will infer the types of the inputs and dispatch the appropriate
# method. *This* is multiple dispatch.
#
# Multiple dispatch makes our code generic and fast. Our code can be generic and flexible
# because we can write code in terms of abstract operations such as addition and
# multiplication, rather than in terms of specific implementations. At the same time, our
# code runs quickly because Julia is able to call efficient methods for the relevant types.
#
# To see which method is being dispatched when we call a generic function, we can use the
# @which macro:
# ------------------------------------------------------------------------------------------

@which foo(3, 4)

@which 3.0 + 3.0

# ------------------------------------------------------------------------------------------
# Given that a method written specifically for floating point numbers is dispatched on `3.0
# + 3.0`, the LLVM code generated is extremely terse:
# ------------------------------------------------------------------------------------------

@code_llvm 3.0 + 3.0

# ------------------------------------------------------------------------------------------
# Note that Julia is fast even when we write generic function definitions because, at the
# end of the day, specific/tailored methods are called under the hood.
#
# For example, note that we can declare the adding function `myadd` without providing any
# type annotations -
# ------------------------------------------------------------------------------------------

myadd(x, y) = x + y

# ------------------------------------------------------------------------------------------
# and though we haven't constrained the types of `x` and `y`, we'll see that the LLVM code
# generated for `myadd(3.0, 3.0)` looks like that of `3.0 + 3.0`
# ------------------------------------------------------------------------------------------

@code_llvm myadd(3.0, 3.0)
