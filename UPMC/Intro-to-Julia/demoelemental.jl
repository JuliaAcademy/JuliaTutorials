# This example can be run with e.g.
# mpirun -np 16 julia demoelemental.jl

using Elemental

A = Elemental.DistMatrix(Float64)

Elemental.gaussian!(A, 4000, 2000)

vals = svdvals(A)

cr = Elemental.MPI.commRank(Elemental.CommWorld)
sleep(cr/10)
println(vals[1])