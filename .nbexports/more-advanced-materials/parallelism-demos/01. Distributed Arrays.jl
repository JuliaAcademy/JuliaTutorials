# ------------------------------------------------------------------------------------------
# # Distributed Arrays
# ------------------------------------------------------------------------------------------

using JuliaRunClient

initializeCluster(12)

@everywhere using DistributedArrays

a=dzeros(12,12)

a=dfill(5.0, 12, 12)

b=drand(1000,1000)

procs(b)

@time sum(b)

convert(Array{Float64}, a)

?DArray

@everywhere function par(I)
    # create our local patch
    # I is a tuple of intervals, each interval is
    # regarded as a 1D array with integer entries
    # size(I[1], 1) gives the number of entries in I[1]
    # size(I[2], 1) gives the number of entries in I[2]
    d=(size(I[1], 1), size(I[2], 1))
    m = fill(myid(), d)
    return m
end

m = DArray(par, (800, 800))

m.indexes

rank(m)

mm = @spawnat 2 rank(localpart(m))
fetch(mm)

# ------------------------------------------------------------------------------------------
# #### Credits
#   * http://www.csd.uwo.ca/~moreno/cs2101a_moreno/Parallel_computing_with_Julia.pdf
#   *
# ------------------------------------------------------------------------------------------

releaseCluster()
