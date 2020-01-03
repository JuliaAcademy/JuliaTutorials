# ------------------------------------------------------------------------------------------
# # Introduction to DataFrames
# **[Bogumił Kamiński](http://bogumilkaminski.pl/about/), Apr 21, 2018**
# ------------------------------------------------------------------------------------------

using DataFrames
using BenchmarkTools

# ------------------------------------------------------------------------------------------
# ## Performance tips
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Access by column number is faster than by name
# ------------------------------------------------------------------------------------------

x = DataFrame(rand(5, 1000))
@btime x[500];
@btime x[:x500];

# ------------------------------------------------------------------------------------------
# ### When working with data `DataFrame` use barrier functions or type annotation
# ------------------------------------------------------------------------------------------

function f_bad() # this function will be slow
    srand(1); x = DataFrame(rand(1000000,2))
    y, z = x[1], x[2]
    p = 0.0
    for i in 1:nrow(x)
        p += y[i]*z[i]
    end
    p
end

@btime f_bad();

@code_warntype f_bad() # the reason is that Julia does not know the types of columns in `DataFrame`

# solution 1 is to use barrier function (it should be possible to use it in almost any code)
function f_inner(y,z)
   p = 0.0
   for i in 1:length(y)
       p += y[i]*z[i]
   end
   p
end

function f_barrier() # extract the work to an inner function
    srand(1); x = DataFrame(rand(1000000,2))
    f_inner(x[1], x[2])
end

function f_inbuilt() # or use inbuilt function if possible
    srand(1); x = DataFrame(rand(1000000,2))
    dot(x[1], x[2])
end

@btime f_barrier();
@btime f_inbuilt();

# solution 2 is to provide the types of extracted columns
# it is simpler but there are cases in which you will not know these types
function f_typed()
    srand(1); x = DataFrame(rand(1000000,2))
    y::Vector{Float64}, z::Vector{Float64} = x[1], x[2]
    p = 0.0
    for i in 1:nrow(x)
        p += y[i]*z[i]
    end
    p
end

@btime f_typed();

# ------------------------------------------------------------------------------------------
# ### Consider using delayed `DataFrame` creation technique
# ------------------------------------------------------------------------------------------

function f1()
    x = DataFrame(Float64, 10^4, 100) # we work with DataFrame directly
    for c in 1:ncol(x)
        d = x[c]
        for r in 1:nrow(x)
            d[r] = rand()
        end
    end
    x
end

function f2()
    x = Vector{Any}(100)
    for c in 1:length(x)
        d = Vector{Float64}(10^4)
        for r in 1:length(d)
            d[r] = rand()
        end
        x[c] = d
    end
    DataFrame(x) # we delay creation of DataFrame after we have our job done
end

@btime f1();
@btime f2();

# ------------------------------------------------------------------------------------------
# ### You can add rows to a `DataFrame` in place and it is fast
# ------------------------------------------------------------------------------------------

x = DataFrame(rand(10^6, 5))
y = DataFrame(transpose(1.0:5.0))
z = [1.0:5.0;]

@btime vcat($x, $y); # creates a new DataFrame - slow
@btime append!($x, $y); # in place - fast

x = DataFrame(rand(10^6, 5)) # reset to the same starting point
@btime push!($x, $z); # add a single row in place - fastest

# ------------------------------------------------------------------------------------------
# ### Allowing `missing` as well as `categorical` slows down computations
# ------------------------------------------------------------------------------------------

using StatsBase

function test(data) # uses countmap function to test performance
    println(eltype(data))
    x = rand(data, 10^6)
    y = categorical(x)
    println(" raw:")
    @btime countmap($x)
    println(" categorical:")
    @btime countmap($y)
    nothing
end

test(1:10)
test([randstring() for i in 1:10])
test(allowmissing(1:10))
test(allowmissing([randstring() for i in 1:10]))

