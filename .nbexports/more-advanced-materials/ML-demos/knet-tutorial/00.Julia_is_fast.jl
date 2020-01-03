# ------------------------------------------------------------------------------------------
# # Julia is fast
# (Originally from https://juliabox.com under tutorials/intro-to-julia/short-
# version/05.Julia_is_fast.ipynb)
#
# Very often, benchmarks are used to compare languages.  These benchmarks can lead to long
# discussions, first as to exactly what is being benchmarked and secondly what explains the
# differences.  These simple questions can sometimes get more complicated than you at first
# might imagine.
#
# The purpose of this notebook is for you to see a simple benchmark for yourself.  One can
# read the notebook and see what happened on the author's Macbook Pro with a 4-core Intel
# Core I7, or run the notebook yourself.
#
# (This material began life as a wonderful lecture by Steven Johnson at MIT:
# https://github.com/stevengj/18S096/blob/master/lectures/lecture1/Boxes-and-
# registers.ipynb.)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Outline of this notebook
#
# - Define the sum function
# - Implementations & benchmarking of sum in...
#     - C (hand-written)
#     - python (built-in)
#     - python (numpy)
#     - python (hand-written)
#     - Julia (built-in)
#     - Julia (hand-written)
#     - Julia (hand-written with SIMD)
# - Summary of benchmarks
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # `sum`: An easy enough function to understand
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Consider the  **sum** function `sum(a)`, which computes
# $$
# \mathrm{sum}(a) = \sum_{i=1}^n a_i,
# $$
# where $n$ is the length of `a`.
# ------------------------------------------------------------------------------------------

a = rand(10^7) # 1D vector of random numbers, uniform on [0,1)
a'

sum(a)

# ------------------------------------------------------------------------------------------
# The expected result is 5 * 10^6, since the mean of each entry is 0.5
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Benchmarking a few ways in a few languages
# ------------------------------------------------------------------------------------------

using Pkg
for p in ("BenchmarkTools","Plots","PyCall","Conda")
    haskey(Pkg.installed(),p) || Pkg.add(p)
end

@time sum(a)

@time sum(a)

@time sum(a)

# ------------------------------------------------------------------------------------------
# The `@time` macro can yield noisy results, so it's not our best choice for benchmarking!
#
# Luckily, Julia has a `BenchmarkTools.jl` package to make benchmarking easy and accurate:
# ------------------------------------------------------------------------------------------

using BenchmarkTools

# ------------------------------------------------------------------------------------------
# #  1. The C language
#
# C is often considered the gold standard: difficult on the human, nice for the machine.
# Getting within a factor of 2 of C is often satisfying. Nonetheless, even within C, there
# are many kinds of optimizations possible that a naive C writer may or may not get the
# advantage of.
#
# The current author does not speak C, so he does not read the cell below, but is happy to
# know that you can put C code in a Julia session, compile it, and run it. Note that the
# `"""` wrap a multi-line string.
# ------------------------------------------------------------------------------------------

using Libdl

C_code = """
#include <stddef.h>
double c_sum(size_t n, double *X) {
    double s = 0.0;
    for (size_t i = 0; i < n; ++i) {
        s += X[i];
    }
    return s;
}
"""

const Clib = tempname()   # make a temporary file
# compile to a shared library by piping C_code to gcc
# (works only if you have gcc installed):
open(`gcc -std=c99 -fPIC -O3 -msse3 -xc -shared -o $(Clib * "." * Libdl.dlext) -`, "w") do f
    print(f, C_code) 
end
# define a Julia function that calls the C function:
c_sum(X::Array{Float64}) = ccall(("c_sum", Clib), Float64, (Csize_t, Ptr{Float64}), length(X), X)

c_sum(a)

c_sum(a) ≈ sum(a) # type \approx and then <TAB> to get the ≈ symbolb

c_sum(a) - sum(a)  

≈  # alias for the `isapprox` function

?isapprox

# ------------------------------------------------------------------------------------------
# We can now benchmark the C code directly from Julia:
# ------------------------------------------------------------------------------------------

c_bench = @benchmark c_sum($a)

println("C: Fastest time was $(minimum(c_bench.times) / 1e6) msec")

d = Dict()  # a "dictionary", i.e. an associative array
d["C"] = minimum(c_bench.times) / 1e6  # in milliseconds
d

using Plots, Statistics
default(fmt = :png)

t = c_bench.times / 1e6 # times in milliseconds
m, σ = minimum(t), std(t)

histogram(t, bins=500,
    xlim=(m - 0.01, m + σ),
    xlabel="milliseconds", ylabel="count", label="")

# ------------------------------------------------------------------------------------------
# # 2. Python's built in `sum`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The `PyCall` package provides a Julia interface to Python:
# ------------------------------------------------------------------------------------------

using PyCall

# Call a low-level PyCall function to get a Python list, because
# by default PyCall will convert to a NumPy array instead (we benchmark NumPy below):

apy_list = PyCall.array2py(a)

# get the Python built-in "sum" function:
pysum = pybuiltin("sum")

pysum(a)

pysum(a) ≈ sum(a)

py_list_bench = @benchmark $pysum($apy_list)

d["Python built-in"] = minimum(py_list_bench.times) / 1e6
d

# ------------------------------------------------------------------------------------------
# # 3. Python: `numpy`
#
# ## Takes advantage of hardware "SIMD", but only works when it works.
#
# `numpy` is an optimized C library, callable from Python.
# It may be installed within Julia as follows:
# ------------------------------------------------------------------------------------------

using Conda

numpy_sum = pyimport("numpy")."sum"
apy_numpy = PyObject(a) # converts to a numpy array by default

numpy_sum(apy_list) # python thing

py_numpy_bench = @benchmark $numpy_sum($apy_numpy)

numpy_sum(apy_list) ≈ sum(a)

d["Python numpy"] = minimum(py_numpy_bench.times) / 1e6
d

# ------------------------------------------------------------------------------------------
# # 4. Python, hand-written
# ------------------------------------------------------------------------------------------

py"""
def py_sum(A):
    s = 0.0
    for a in A:
        s += a
    return s
"""

sum_py = py"py_sum"

sum_py(apy_list)

py_hand = @benchmark $sum_py($apy_list)

sum_py(apy_list) ≈ sum(a)

d["Python hand-written"] = minimum(py_hand.times) / 1e6
d

# ------------------------------------------------------------------------------------------
# # 5. Julia (built-in)
#
# ## Written directly in Julia, not in C!
# ------------------------------------------------------------------------------------------

@which sum(a)

sum(a)

j_bench = @benchmark sum($a)

d["Julia built-in"] = minimum(j_bench.times) / 1e6
d

# ------------------------------------------------------------------------------------------
# # 6. Julia (hand-written)
# ------------------------------------------------------------------------------------------

function mysum(A)   
    s = 0.0 # s = zero(eltype(a))
    for a in A
        s += a
    end
    s
end

mysum(a)

j_bench_hand = @benchmark mysum($a)

d["Julia hand-written"] = minimum(j_bench_hand.times) / 1e6
d

# ------------------------------------------------------------------------------------------
# # 7. Julia (hand-written w. simd)
# ------------------------------------------------------------------------------------------

function mysum_simd(A)   
    s = 0.0 # s = zero(eltype(A))
    @simd for a in A
        s += a
    end
    s
end

mysum_simd(a)

j_bench_hand_simd = @benchmark mysum_simd($a)

d["Julia hand-written simd"] = minimum(j_bench_hand_simd.times) / 1e6
d

# ------------------------------------------------------------------------------------------
# # Summary
# ------------------------------------------------------------------------------------------

for (key, value) in sort(collect(d), by=last)
    println(rpad(key, 25, "."), lpad(round(value, digits=1), 6, "."))
end


