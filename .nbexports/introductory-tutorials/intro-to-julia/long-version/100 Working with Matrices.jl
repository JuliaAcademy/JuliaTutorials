# ------------------------------------------------------------------------------------------
# # Playing with matrices
# (and if you get the subliminal message about abstractions, we'll be thrilled!)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia is a dynamic language.  You don't need type declarations, and can change variable
# types dynamically and interactively.
#
# For working with simple numbers, arrays, and strings, its syntax is *superficially*
# similar to Matlab, Python, and other popular languages.
#
# In order to execute the `In` cells, select the cell and press `Shift-Enter`, or press the
# `Play` button above. To run the entire notebook, navigate to the `Cell` menu and then `Run
# All`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # We tell beginners, you don't need types!
# ------------------------------------------------------------------------------------------

typeof(1.0)

typeof(1)

S = "Hello Julia Clsas"
typeof(S)

#  Exercise fix my spelling in the cell above
S

# ------------------------------------------------------------------------------------------
# # Now forget all that (for now): Julia is not so different from your favorite dynamic
# language
# ------------------------------------------------------------------------------------------

1 + 1  # shift + enter to run

A = rand(5, 5)

using LinearAlgebra # A LinearAlgebra standard package contains structured matrices
A = SymTridiagonal(rand(6), rand(5))

b = rand(6)
A \ b

A = fill(3.15, 5, 5) # Fill a 5x5 array with 3.15's

# ------------------------------------------------------------------------------------------
# # Let's create some addition tables
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# First let's use a nested for loop to fill in a matrix that's initially zero:
# ------------------------------------------------------------------------------------------

A = zeros(5, 5)

for i in 1:5
    for j in 1:5
        A[i, j] = i+j  # Square brackets for indices.  Also: indices start at 1, not 0.
    end
end

A

# ------------------------------------------------------------------------------------------
# We can abbreviate this using a double `for` loop:
# ------------------------------------------------------------------------------------------

for i in 1:5, j in 1:5
   A[i, j] = i+j  # Square brackets for indices.  Also: indices start at 1, not 0.
end

A

# ------------------------------------------------------------------------------------------
# The Julia way would be to use a so-called **array comprehension**:
# ------------------------------------------------------------------------------------------

[i+j for i in 1:5, j in 1:5]

# Equivalently,
[i+j for i = 1:5, j = 1:5]

# ------------------------------------------------------------------------------------------
# **Explore**: What does the following do?
# ------------------------------------------------------------------------------------------

[i for i in (1:7).^2]

# What happens when  we remove the dot syntax?
[i for i in (1:7)^2]

[i^2 for i in 1:7]

# ------------------------------------------------------------------------------------------
# **Explore**: What does the following do?
# ------------------------------------------------------------------------------------------

sort(unique(x^2 + y^2 for x in 1:5, y in 1:5))  # The inner parentheses define a **generator**

# ------------------------------------------------------------------------------------------
# Suppose we want to see $n \times n$ multiplication tables for $n=1,2,3,4,5$:
# ------------------------------------------------------------------------------------------

for n in 1:5
    display([i*j for i=1:n, j=1:n])
end

# ------------------------------------------------------------------------------------------
# # `Interact.jl` is a Julia *package* for interacting with data
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# It's way more fun to **interact** with our data.
# We install the `Interact.jl` package as follows; this needs to be executed only once for
# any given Julia installation:
# ------------------------------------------------------------------------------------------

# using Pkg; Pkg.add("Interact")

# ------------------------------------------------------------------------------------------
# Now we load the package with the following `using` command, in each Julia session:
# ------------------------------------------------------------------------------------------

using Interact

# ------------------------------------------------------------------------------------------
# The package contains a `@manipulate` macro, that is wrapped around a `for` loop:
# ------------------------------------------------------------------------------------------

@manipulate for n in 1:1000
    n
end

@manipulate for n in 1:20
    [i*j for i in 1:n, j in 1:n]
end

# ------------------------------------------------------------------------------------------
# We use a double `for` loop to get a double slider!
# ------------------------------------------------------------------------------------------

@manipulate for n in 3:10, i in 1:9
   A = fill(0, n, n)
   A[1:3, 1:3] .= i    # fill a sub-block
A
end

# ------------------------------------------------------------------------------------------
# # Functions
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia is built around functions: all "commands" or "operations" in Julia are functions:
# ------------------------------------------------------------------------------------------

# verbose form:
function f(x)
    x^2
end

# one-line form:
f2(x) = x^2

# anonymous form:
f3 = x -> x^2;

f(10)

# ------------------------------------------------------------------------------------------
# Functions just work, as long as they make sense:
# ------------------------------------------------------------------------------------------

# The square of a matrix is unambiguously defined
f(rand(3, 3))

# What the 'square of a vector' means is ambiguous
f(rand(3))

# In the definition below, `a` and `power` are optional arguments to `f`, supplied with default values.
function f(x, a=1, power=2)
    a*x^power
end

# `a` defaults to 1 and `power` to 2
f(7)

# The first optional argument passed is assigned to the local variable `a`
# `power` defaults to 2
f(10, 3)

f(10, 3, 3)

# ------------------------------------------------------------------------------------------
# Let's define a function to insert a block in a matrix:
# ------------------------------------------------------------------------------------------

function insert_block(A, i, j, what=7)
    B = A[:,:]        # B is a copy of A       
    B[i:i+2, j:j+2] = fill(what, 3, 3)
    
    return B          # the `return` keyword is optional
end

A = fill(0, 9, 9)
insert_block(A, 3, 5)  # this returns the new matrix

A = fill(0, 9, 9)
insert_block(A, 3, 5, 2)  # Use 2 instead of 7

# ------------------------------------------------------------------------------------------
# We can move the block around:
# ------------------------------------------------------------------------------------------

A = fill(0, 10, 10)
n = size(A, 1)

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i, j)
end

# ------------------------------------------------------------------------------------------
# # Strings
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia can manipulate strings easily:
# ------------------------------------------------------------------------------------------

S = "Hello"

replace(S, "H" => "J")

a = 3

string(S, " ", S, " ", "Julia; a = ", a)  # build a string by concatenating things

# ------------------------------------------------------------------------------------------
# More about strings: <a href="http://docs.julialang.org/en/stable/manual/strings/"> Julia
# Doc on Strings </a>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Functions in Julia try to be **generic**, i.e. to work with as many kinds of object as
# possible:
# ------------------------------------------------------------------------------------------

A = fill("Julia", 5, 5)

# ------------------------------------------------------------------------------------------
# Julia allows us to display objects in different ways. For example, the following code
# displays a matrix of strings
# in the notebook using an HTML representation:
# ------------------------------------------------------------------------------------------

function Base.show(io::IO, ::MIME"text/html", M::Matrix{T}) where {T<:String}
    max_length = maximum(length.(M))
    dv="<div style='display:flex;flex-direction:row'>"
    print(io, dv*join([join("<div style='width:40px; text-align:center'>".*M[i,:].*"</div>", " ") for i in 1:size(M, 1)]
            , "</div>$dv")*"</div>")
end

A

# Remember this ????
A = fill(0, 10, 10)
n = size(A, 1)

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i,j)
end

# ------------------------------------------------------------------------------------------
# Let's use the **same code**, but now with strings:
# ------------------------------------------------------------------------------------------

A = fill("Julia", 10, 10)
n = size(A, 1)

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i,j, "[FUN]")
end

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i, j, "π")
end

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i, j, "♡")
end

airplane = "✈"
alien = "👽"
rand([airplane, alien], 5, 5)

A = fill(airplane, 9, 9)
n = size(A, 1)

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i, j, alien)
end

# ------------------------------------------------------------------------------------------
# # Colors
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The `Colors` package provides objects representing colours:
# ------------------------------------------------------------------------------------------

# using Pkg; Pkg.add("Colors")
using Colors

distinguishable_colors(12)

@manipulate for n in 1:80
    distinguishable_colors(n)
end

colors = distinguishable_colors(100)


# Remember this ????
A = fill(0, 10, 10)
n = size(A, 1)

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i, j)
end

# ------------------------------------------------------------------------------------------
# What happens if we use colors instead?
# ------------------------------------------------------------------------------------------

A = fill(colors[1], 10, 10)
n = size(A, 1)

@manipulate for i in 1:n-2, j in 1:n-2
    insert_block(A, i, j, colors[4])
end

# Exercise: Create Tetris Pieces, have them fall from the top
