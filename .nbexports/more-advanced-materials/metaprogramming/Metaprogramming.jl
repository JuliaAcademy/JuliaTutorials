# ------------------------------------------------------------------------------------------
# # Metaprogramming with Julia
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Scare Quotes
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia supports *metaprogramming*. This is similar to symbolic programming, where we deal
# with expressions (like $2+2$) as opposed to values (like $4$).
#
# Normally, Julia takes all code we give it as a set of instructions, and carries them out.
# If we type `2+2` it will faithfully add those numbers and give us the result.
# ------------------------------------------------------------------------------------------

2+2

# ------------------------------------------------------------------------------------------
# We can prevent this from happening with quotation marks. Surrounding our code with `"`
# treats it as a literal string of characters, without seeing it as code at all.
# ------------------------------------------------------------------------------------------

x = "2+2"

# ------------------------------------------------------------------------------------------
# We can then explicitly tell Julia to evaluate it later on.
# ------------------------------------------------------------------------------------------

eval(Meta.parse(ans))

# ------------------------------------------------------------------------------------------
# Why go through this complicated way to add numbers? The trick is that when we have the
# expression `2+2`, we can modify it in various interesting ways. As a simple example,
# imagine replacing `+` with `-`.
# ------------------------------------------------------------------------------------------

x = replace(x, "+"=>"-")

eval(Meta.parse(x))

# ------------------------------------------------------------------------------------------
# We don't actually want to work with strings here; Julia has a much more powerful way to
# quote code, the frowny face operator `:()`.
# ------------------------------------------------------------------------------------------

x = :(2+2)

eval(x)

# ------------------------------------------------------------------------------------------
# We can quote larger expression, including blocks and entire function definitions. The
# keyword `quote` is an alternative to `begin` that returns the quoted block.
#
# In larger blocks, Julia will preserve line number information, which appears as a comment.
# ------------------------------------------------------------------------------------------

quote
  x = 2 + 2
  hypot(x, 5)
end

:(function mysum(xs)
    sum = 0
    for x in xs
      sum += x
    end
  end)

# ------------------------------------------------------------------------------------------
# ## Fruit of the Expression Tree
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Strings support "interpolation", which allows us to easily build larger strings from
# smaller components.
# ------------------------------------------------------------------------------------------

x = "yields falsehood when preceded by its quotation"
println(x)

y = "'$x' $x"
println(y)

x = :(2+2)

:($x * $x)

eval(ans)

# ------------------------------------------------------------------------------------------
# ## The Root of all Eval
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# `eval` can do more than just returning a result. What happens if we quote something like a
# function definition?
# ------------------------------------------------------------------------------------------

ex = :(foo() = println("I'm foo!"))

# ------------------------------------------------------------------------------------------
# It doesn't actually do anything; yet.
# ------------------------------------------------------------------------------------------

foo()  # throws UndefVarError

# ------------------------------------------------------------------------------------------
# But evaluating `ex` brings `foo` to life!
# ------------------------------------------------------------------------------------------

eval(ex)

foo()

# ------------------------------------------------------------------------------------------
# Using interpolation, we can construct a function definition on-the-fly; in fact, we can
# make a whole series of functions at once.
# ------------------------------------------------------------------------------------------

for name in [:foo, :bar, :baz]
  println(:($name() = println($("I'm $(name)!"))))
end

# ------------------------------------------------------------------------------------------
# And then bring them to life with `eval`, too.
# ------------------------------------------------------------------------------------------

for name in [:foo, :bar, :baz]
  eval(:($name() = println($("I'm $(name)!"))))
end

bar()

baz()

# ------------------------------------------------------------------------------------------
# This can be an *extremely* useful trick when wrapping APIs (say, from a C library or over
# HTTP). APIs often define a list of available functions, so you can grab that and generate
# the whole wrapper at once! See Clang.jl, TensorFlow.jl, or the Base linear algebra
# wrappers for examples.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Original sin
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Here's a more practical example. Consider the following definition of the `sin` function,
# based on the Taylor series.
#
# $$sin(x) = \sum_{k=1}^{\infty} \frac{(-1)^k}{(1+2k)!} x^{1+2k}$$
# ------------------------------------------------------------------------------------------

mysin(x) = sum((-1)^k/factorial(1+2k) * x^(1+2k) for k = 0:5)

mysin(0.5), sin(0.5)

# ------------------------------------------------------------------------------------------
# To see where we are right now, we'll benchmark it.
# ------------------------------------------------------------------------------------------

using BenchmarkTools
@benchmark mysin(0.5)

# ------------------------------------------------------------------------------------------
# Right now, this is much slower than it could be. The reason is that we're looping over
# `k`, which is relatively expensive. It'd be much faster to write out:
# ------------------------------------------------------------------------------------------

mysin(x) = x - x^3/6 + x^5/120 # + ...

# ------------------------------------------------------------------------------------------
# But this is tedious to write, and no longer looks like the original Taylor series. It's
# harder to tell if we've made a mistake, and we easily modify it. Is there a way to get the
# best of both worlds?
#
# How about getting Julia to write out that code for us?
#
# To start with, let's consider a symbolic version of the `+` function.
# ------------------------------------------------------------------------------------------

plus(a, b) = :($a + $b)

plus(1, 2)

# ------------------------------------------------------------------------------------------
# With `plus` we can do more interesting things, like symbolic `sum`:
# ------------------------------------------------------------------------------------------

reduce(+, 1:10)

reduce(plus, 1:10)

eval(ans)

# ------------------------------------------------------------------------------------------
# Given that, we can also sum over symbolic variables.
# ------------------------------------------------------------------------------------------

reduce(plus, [:(x^2), :x, 1])

# ------------------------------------------------------------------------------------------
# This gives us an important piece of the puzzle, but we also need to figure out _what_
# we're summing. Let's crate a symbolic version of the Taylor series above, which
# interpolates the value of `k`.
# ------------------------------------------------------------------------------------------

k = 2
:($((-1)^k) * x^$(1+2k) / $(factorial(1+2k)))

# ------------------------------------------------------------------------------------------
# Now we have one term, we can generate as many as we like.
# ------------------------------------------------------------------------------------------

terms = [:($((-1)^k) * x^$(1+2k) / $(factorial(1+2k))) for k = 0:5]

# ------------------------------------------------------------------------------------------
# And sum them –
# ------------------------------------------------------------------------------------------

reduce(plus, ans)

# ------------------------------------------------------------------------------------------
# And create a function definition out of it:
# ------------------------------------------------------------------------------------------

:(mysin(x) = $ans)

eval(ans)

mysin(0.5), sin(0.5)

@benchmark mysin(0.5)

# ------------------------------------------------------------------------------------------
# On my machine `sin2` takes about 50 *nano*seconds to run – not bad for a naive
# implementation. If we challenged a photon to a twenty metre sprint, we'd win!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Beneath the Expression
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# It's really just a normal tree data structure, and we can take a look inside it.
# ------------------------------------------------------------------------------------------

ex = :(f(x, y))
ex = Expr(:call, :f, :x, :y)
@show ex.head;
@show ex.args;

# ------------------------------------------------------------------------------------------
# In our example above, we replace `+` with `-` in a string. In an expression, we can do
# that by altering the `.args` of the expression.
# ------------------------------------------------------------------------------------------

ex = :(2+2)

ex.args[1] = :-
ex

eval(ex)

# ------------------------------------------------------------------------------------------
# Note that larger, more complex expressions are a bit trickier than this. They are
# *nested*, which means that the expression `2+3` is contained inside the larger expression
# `1 + (2 + 3)`.
# ------------------------------------------------------------------------------------------

ex = :(1 + (2 + 3))

ex.args

# ------------------------------------------------------------------------------------------
# A package called MacroTools provides a way to deal with this. It shows us *all* sub-
# expressions in turn, allowing us to decide how we want to change them. It can be thought
# of as a bit like a find-and-replace operation. Here's an example that finds all integers
# in an expression, and increments them.
# ------------------------------------------------------------------------------------------

# import Pkg; Pkg.add("MacroTools")
using MacroTools
using MacroTools: postwalk

postwalk(ex) do x
  x isa Integer ? x+1 : x
end

# ------------------------------------------------------------------------------------------
# To get a feel for what's happening, you can use `@show` to see what `postwalk` sees.
#
# (`@show` is Julia's single most useful feature; if you don't understand what code is
# doing, throw it in and see what's happening.)
# ------------------------------------------------------------------------------------------

map(x -> @show(x), [1,2,3])

postwalk(ex) do x
  @show x
end

# ------------------------------------------------------------------------------------------
# MacroTools also provides tools for *pattern matching* over expressions. `a_ + b_` acts as
# a template; if the expression provided look like the template, `a` and `b` will match the
# two things be added. If not, they'll just be `nothing`.
# ------------------------------------------------------------------------------------------

ex = :(2 + 3)
@capture(ex, a_ + b_)

a, b

ex = :(f(2,3))
@capture(ex, a_ + b_)

a, b

# ------------------------------------------------------------------------------------------
# We can finally use this to replace _all_ `+`s with `-`s in an expression, rather than just
# one.
# ------------------------------------------------------------------------------------------

ex = :(3x^2 + (2x + 1))

postwalk(ex) do x
  @capture(x, a_ + b_) || return x
  :($a - $b)
end

# ------------------------------------------------------------------------------------------
# ## Macro Agressions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# You have probably seen macros already – basic features in Julia like `@show`, `@time` and
# `@inline` are really macros. For basic usage, it's enough to think of them as simple
# annotations that alter how code is run. But we now know enough to dig into how they work
# under the hood.
#
# Normal functions never see _code_, only _values_. If we pass `2+2` to a function, it sees
# `4`.
# ------------------------------------------------------------------------------------------

function foo(x)
  @show x
  return x
end

foo(2+2)

# ------------------------------------------------------------------------------------------
# Macros are much like function, but they see _code_ that was passed to them, like the
# expressions that we saw above. Macros get a chance to manipulate this code and alter how
# it behaves.
# ------------------------------------------------------------------------------------------

macro foo(x)
  @show x
  return x
end

@foo(2+2)

# ------------------------------------------------------------------------------------------
# As a simple example, we can replace one of the arguments to `+` and get a different result
# back.
# ------------------------------------------------------------------------------------------

macro foo(x)
  x.args[2] = 5
  return x
end

@foo(2+2)

# ------------------------------------------------------------------------------------------
# MacroTools provides a useful tool, `@expand`, to see what's going on inside a macro; it
# reveals the code that the macro returns without running it.
# ------------------------------------------------------------------------------------------

@expand @foo(2+2)

# ------------------------------------------------------------------------------------------
# You can of course use this on the macros that come with Julia, and it's a good way to
# learn how they work.
# ------------------------------------------------------------------------------------------

@time 2+2

@expand @time 2+2

# ------------------------------------------------------------------------------------------
# Let's do something more advanced. Using the techniques we developed above, we can find-
# and-replace `+` expressions in code. We'll still do the addition, but we'll also log what
# we added for debugging purposes.
#
# First, let's make an example expression using quotation.
# ------------------------------------------------------------------------------------------

ex = quote
  s = 0
  for x in xs
    s = s + x
  end
  return s
end

# ------------------------------------------------------------------------------------------
# We can use `ex` to develop the code transformation we want, and check that the code does
# the right thing.}
# ------------------------------------------------------------------------------------------

postwalk(ex) do x
  @capture(x, a_ + b_) || return x
  quote
    println("Adding " * string($a) * " to " * string($b))
    $x
  end
end

# ------------------------------------------------------------------------------------------
# Now we just wrap this in a macro, and we can add it to a normal function definition!
# ------------------------------------------------------------------------------------------

macro log_adds(ex)
  postwalk(ex) do x
    @capture(x, a_ + b_) || return x
    quote
      println("Adding " * string($a) * " to " * string($b))
      $x
    end
  end
end

@log_adds function mysum(xs)
  sum = 0
  for x in xs
    sum = sum + x
  end
  return sum
end

mysum(1:10)

# ------------------------------------------------------------------------------------------
# Adding and removing `@log_adds` is much nicer than inserting the debug calls by hand,
# especially if you have lots of `+`s in the code. Perhaps you can extend the macro to
# support logging other operators, like `-`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Generated Functions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# _Generated functions_ are a new metaprogramming tool unique to Julia. This section will
# briefly describe and motivate them, and [this blog
# post](http://mikeinnes.github.io/2017/08/24/cudanative.html) gives more examples for the
# interested reader.
#
# Essentially, a generated function is like a macro that operates on _types_ rather than
# expression trees. If we try to inspect arguments, we'll see their types rather than their
# values.
# ------------------------------------------------------------------------------------------

@generated function gadd(a, b)
  Core.println("a = $a, b = $b")
  :(a+b)
end

gadd(5, 2.5)

# ------------------------------------------------------------------------------------------
# Generated functions become more powerful when working with more complex types. For
# example, notice how arrays store their rank inside the type, so this is something we can
# generate code for.
# ------------------------------------------------------------------------------------------

rand(2,2)

typeof(ans)

# ------------------------------------------------------------------------------------------
# Why might this be useful? If you write code to deal with arrays, you'll notice that you
# often need a `for` loop for each dimension of the array. If you want to work with a 7D
# array, you need to write seven nested loops!
# ------------------------------------------------------------------------------------------

function mysum(xs::Array{<:Any,1})
  sum = 0
  for i = 1:length(xs)
    sum += xs[i]
  end
  return sum
end

function mysum(xs::Array{<:Any,2})
  sum = 0
  for i = 1:size(xs,1)
    for j = 1:size(xs, 2)
      sum += xs[i]
    end
  end
  return sum
end

# ------------------------------------------------------------------------------------------
# Where other languages simply hard-code a version of each function for vectors, matrices
# and perhaps 3D arrays, Julia allows us to easily write N-dimensional algorithms by
# generating nested loops as needed.
# ------------------------------------------------------------------------------------------


