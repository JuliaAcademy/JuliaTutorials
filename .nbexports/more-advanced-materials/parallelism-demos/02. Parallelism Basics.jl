# ------------------------------------------------------------------------------------------
# # Julia Parallelism Basics
# ------------------------------------------------------------------------------------------

addprocs(2)

nworkers()

workers()

r = remotecall(rand, 2, 2, 2)

 fetch(r)

s = @spawnat 3 1+fetch(r)

fetch(s)

remotecall_fetch(getindex, 2, r, 1, 1)

r = @spawn rand(2,2)

s = @spawn 1+fetch(r)

function rand2(dims...)
    return 2*rand(dims...)
end

rand2(2,2)

r2 = @spawn rand2(2,2)

fetch(r2)

@everywhere function rand2(dims...)
    return 2*rand(dims...)
end

r2 = @spawn rand2(2,2)
fetch(r2)

# ------------------------------------------------------------------------------------------
# ## Data Movement
# ------------------------------------------------------------------------------------------

@time begin 
    A = rand(1000,1000)
    Bref = @spawn A^2
    fetch(Bref)
end

@time begin
    Bref = @spawn rand(1000,1000)^2
    fetch(Bref)
end

# ------------------------------------------------------------------------------------------
# ## Shared Arrays
#
# Shared Arrays are created by mapping the same region in memory to different processes.
# ------------------------------------------------------------------------------------------

s = SharedArray{Float64}(100,100)

localindexes(s)

fetch(@spawnat 2 localindexes(s))

fetch(@spawnat 3 localindexes(s))

for i in workers()
    @spawnat i s[localindexes(s)] = myid()
end

s

fetch(@spawnat 2 s[100,100])

fetch(@spawnat 3 s[1,1])
