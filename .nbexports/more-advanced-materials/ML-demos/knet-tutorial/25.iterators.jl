# ------------------------------------------------------------------------------------------
# # Iterators
# (c) Deniz Yuret, 2019
#
# * Objective: Learning how to construct and use Julia iterators.
# * Reading: [Interfaces](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-
# iteration-1),  [Collections](https://docs.julialang.org/en/v1/base/collections/#lib-
# collections-iteration-1), [Iteration
# Utilities](https://docs.julialang.org/en/v1/base/iterators) and [Generator
# expressions](https://docs.julialang.org/en/v1/manual/arrays/#Generator-Expressions-1) in
# the Julia manual.
# * Prerequisites: [minibatch,
# Data](https://github.com/denizyuret/Knet.jl/blob/master/src/data.jl) from the [MNIST
# notebook](20.mnist.ipynb)
# * New functions:
# [first](https://docs.julialang.org/en/v1/base/collections/#Base.first),
# [collect](https://docs.julialang.org/en/v1/base/collections/#Base.collect-Tuple{Any}),
# [repeat](https://docs.julialang.org/en/v1/base/arrays/#Base.repeat),
# [take](https://docs.julialang.org/en/v1/base/iterators/#Base.Iterators.take),
# [drop](https://docs.julialang.org/en/v1/base/iterators/#Base.Iterators.drop),
# [cycle](https://docs.julialang.org/en/v1/base/iterators/#Base.Iterators.cycle),
# [Stateful](https://docs.julialang.org/en/v1/base/iterators/#Base.Iterators.Stateful),
# [iterate](https://docs.julialang.org/en/v1/base/collections/#lib-collections-iteration-1)
#
# The `minibatch` function returns a `Knet.Data` object implemented as a Julia iterator that
# generates (x,y) minibatches. Iterators are lazy objects that only generate their next
# element when asked. This has the advantage of not wasting time and memory trying to create
# and store all the elements at once. We can even have infinite iterators! The training
# algorithms in Knet are also implemented as iterators so that:
# 1. We can monitor and report the training loss
# 2. We can take snapshots of the model during training
# 3. We can pause/terminate training when necessary
#
# Here are some things Julia can do with iterators:
# ------------------------------------------------------------------------------------------

# Set display width, load packages, import symbols
ENV["COLUMNS"]=72
using Pkg; haskey(Pkg.installed(),"Knet") || Pkg.add("Knet")
using Base.Iterators: take, drop, cycle, Stateful
using Knet

# Load data
include(Knet.dir("data","mnist.jl"))
xtrn,ytrn,xtst,ytst = mnist()
dtst = minibatch(xtst,ytst,100)

# We can peek at the first element using first()
summary.(first(dtst))

# Iterators can be used in for loops
# Let's count the elements in dtst:
n = 0
for (x,y) in dtst; n += 1; end
@show n;

# Iterators can be converted to arrays using `collect` 
# (don't do this unless necessary, it just wastes memory. Use a for loop instead)
collect(dtst) |> summary

# We can generate an iterator for multiple epochs using `repeat`
# (an epoch is a single pass over the dataset)
n = 0
for (x,y) in repeat(dtst,5); n += 1; end
@show n;

# We can generate partial epochs using `take` which takes the first n elements
n = 0
for (x,y) in take(dtst,20); n += 1; end
@show n;

# We can also generate partial epochs using `drop` which drops the first n elements
n = 0
for (x,y) in drop(dtst,20); n += 1; end
@show n;

# We can repeat forever using `cycle` (this is useful to train until convergence)
# You do not want to collect a cycle or run a for loop without break! 
n = 0; t = time_ns()
for (x,y) in cycle(dtst)
    n += 1
    time_ns() - t > 2e9 && break # Break after 2 seconds
end
@show n;

# We can make an iterator `Stateful` so it remembers where it left off.
# (by default iterators start from the beginning)
dtst1 = dtst            # dtst1 will start from beginning every time
dtst2 = Stateful(dtst)  # dtst2 will remember where we left off
for (x,y) in dtst1; println(Int.(y[1:5])); break; end
for (x,y) in dtst1; println(Int.(y[1:5])); break; end
for (x,y) in dtst2; println(Int.(y[1:5])); break; end
for (x,y) in dtst2; println(Int.(y[1:5])); break; end

# We can shuffle instances at every epoch using the keyword argument `shuffle=true`
# (by default elements are generated in the same order)
dtst1 = minibatch(xtst,ytst,100)              # dtst1 iterates in the same order
dtst2 = minibatch(xtst,ytst,100,shuffle=true) # dtst2 shuffles each time
for (x,y) in dtst1; println(Int.(y[1:5])); break; end
for (x,y) in dtst1; println(Int.(y[1:5])); break; end
for (x,y) in dtst2; println(Int.(y[1:5])); break; end
for (x,y) in dtst2; println(Int.(y[1:5])); break; end

# We can construct new iterators using [Generator expressions](https://docs.julialang.org/en/v1/manual/arrays/#Generator-Expressions-1)
# The following example constructs an iterator over the x norms in a dataset:
xnorm(data) = (sum(abs2,x) for (x,y) in data)
collect(xnorm(dtst))'

# Every iterator implements the `iterate` function which returns
# the next element and state (or nothing if no elements left).
# Here is how the for loop for dtst is implemented:
n = 0; next = iterate(dtst)
while next != nothing
    ((x,y), state) = next
    n += 1
    next = iterate(dtst,state)
end
@show n;

# You can define your own iterator by declaring a new type and overriding the `iterate` method.
# Here is another way to define an iterator over the x norms in a dataset:
struct Xnorm; itr; end

function Base.iterate(f::Xnorm, s...)
    next = iterate(f.itr, s...)
    next === nothing && return nothing
    ((x,y),state) = next
    return sum(abs2,x), state
end

Base.length(f::Xnorm) = length(f.itr) # collect needs this

collect(Xnorm(dtst))'
