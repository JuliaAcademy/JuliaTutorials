# ------------------------------------------------------------------------------------------
# # Optimizing DiffEq Code
#
# In this notebook we will walk through some of the main tools for optimizing your code in
# order to efficiently solve DifferentialEquations.jl. User-side optimizations are important
# because, for sufficiently difficult problems, most of the time will be spent inside of
# your `f` function, the function you are trying to solve. "Efficient" integrators are those
# that reduce the required number of `f` calls to hit the error tolerance. The main ideas
# for optimizing your DiffEq code, or any Julia function, are the following:
#
# - Make it non-allocating
# - Use StaticArrays for small arrays
# - Use broadcast fusion
# - Make it type-stable
# - Reduce redundant calculations
# - Make use of BLAS calls
# - Optimize algorithm choice
#
# We'll discuss these strategies in the context of small and large systems. Let's start with
# small systems.
#
# ## Optimizing Small Systems (<100 DEs)
#
# Let's take the classic Lorenz system from before. Let's start by naively writing the
# system in its out-of-place form:
# ------------------------------------------------------------------------------------------

function lorenz(u,p,t)
 dx = 10.0*(u[2]-u[1])
 dy = u[1]*(28.0-u[3]) - u[2]
 dz = u[1]*u[2] - (8/3)*u[3]
 [dx,dy,dz]
end

# ------------------------------------------------------------------------------------------
# Here, `lorenz` returns an object, `[dx,dy,dz]`, which is created within the body of
# `lorenz`.
#
# This is a common code pattern from high-level languages like MATLAB, SciPy, or R's
# deSolve. However, the issue with this form is that it allocates a vector, `[dx,dy,dz]`, at
# each step. Let's benchmark the solution process with this choice of function:
# ------------------------------------------------------------------------------------------

using DifferentialEquations, BenchmarkTools
u0 = [1.0;0.0;0.0]
tspan = (0.0,100.0)
prob = ODEProblem(lorenz,u0,tspan)
@benchmark solve(prob,Tsit5())

# ------------------------------------------------------------------------------------------
# The BenchmarkTools package's `@benchmark` runs the code multiple times to get an accurate
# measurement. The minimum time is the time it takes when your OS and other background
# processes aren't getting in the way. Notice that in this case it takes about 5ms to solve
# and allocates around 11.11 MiB. However, if we were to use this inside of a real user code
# we'd see a lot of time spent doing garbage collection (GC) to clean up all of the arrays
# we made. Even if we turn off saving we have these allocations.
# ------------------------------------------------------------------------------------------

@benchmark solve(prob,Tsit5(),save_everystep=false)

# ------------------------------------------------------------------------------------------
# The problem of course is that arrays are created every time our derivative function is
# called. This function is called multiple times per step and is thus the main source of
# memory usage. To fix this, we can use the in-place form to ***make our code non-
# allocating***:
# ------------------------------------------------------------------------------------------

function lorenz!(du,u,p,t)
 du[1] = 10.0*(u[2]-u[1])
 du[2] = u[1]*(28.0-u[3]) - u[2]
 du[3] = u[1]*u[2] - (8/3)*u[3]
end

# ------------------------------------------------------------------------------------------
# Here, instead of creating an array each time, we utilized the cache array `du`. When the
# inplace form is used, DifferentialEquations.jl takes a different internal route that
# minimizes the internal allocations as well. When we benchmark this function, we will see
# quite a difference.
# ------------------------------------------------------------------------------------------

u0 = [1.0;0.0;0.0]
tspan = (0.0,100.0)
prob = ODEProblem(lorenz!,u0,tspan)
@benchmark solve(prob,Tsit5())

@benchmark solve(prob,Tsit5(),save_everystep=false)

# ------------------------------------------------------------------------------------------
# There is a 4x time difference just from that change! Notice there are still some
# allocations and this is due to the construction of the integration cache. But this doesn't
# scale with the problem size:
# ------------------------------------------------------------------------------------------

tspan = (0.0,500.0) # 5x longer than before
prob = ODEProblem(lorenz!,u0,tspan)
@benchmark solve(prob,Tsit5(),save_everystep=false)

# ------------------------------------------------------------------------------------------
# since that's all just setup allocations.
#
# #### But if the system is small we can optimize even more.
#
# Allocations are only expensive if they are "heap allocations". For a more in-depth
# definition of heap allocations, [there are a lot of sources online](http://net-
# informations.com/faq/net/stack-heap.htm). But a good working definition is that heap
# allocations are variable-sized slabs of memory which have to be pointed to, and this
# pointer indirection costs time. Additionally, the heap has to be managed and the garbage
# controllers has to actively keep track of what's on the heap.
#
# However, there's an alternative to heap allocations, known as stack allocations. The stack
# is statically-sized (known at compile time) and thus its accesses are quick. Additionally,
# the exact block of memory is known in advance by the compiler, and thus re-using the
# memory is cheap. This means that allocating on the stack has essentially no cost!
#
# Arrays have to be heap allocated because their size (and thus the amount of memory they
# take up) is determined at runtime. But there are structures in Julia which are stack-
# allocated. `struct`s for example are stack-allocated "value-type"s. `Tuple`s are a stack-
# allocated collection. The most useful data structure for DiffEq though is the
# `StaticArray` from the package
# [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl). These arrays have their
# length determined at compile-time. They are created using macros attached to normal array
# expressions, for example:
# ------------------------------------------------------------------------------------------

using StaticArrays
A = @SVector [2.0,3.0,5.0]

# ------------------------------------------------------------------------------------------
# Notice that the `3` after `SVector` gives the size of the `SVector`. It cannot be changed.
# Additionally, `SVector`s are immutable, so we have to create a new `SVector` to change
# values. But remember, we don't have to worry about allocations because this data structure
# is stack-allocated. `SArray`s have a lot of extra optimizations as well: they have fast
# matrix multiplication, fast QR factorizations, etc. which directly make use of the
# information about the size of the array. Thus, when possible they should be used.
#
# Unfortunately static arrays can only be used for sufficiently small arrays. After a
# certain size, they are forced to heap allocate after some instructions and their compile
# time balloons. Thus static arrays shouldn't be used if your system has more than 100
# variables. Additionally, only the native Julia algorithms can fully utilize static arrays.
#
# Let's ***optimize `lorenz` using static arrays***. Note that in this case, we want to use
# the out-of-place allocating form, but this time we want to output a static array:
# ------------------------------------------------------------------------------------------

function lorenz_static(u,p,t)
 dx = 10.0*(u[2]-u[1])
 dy = u[1]*(28.0-u[3]) - u[2]
 dz = u[1]*u[2] - (8/3)*u[3]
 @SVector [dx,dy,dz]
end

# ------------------------------------------------------------------------------------------
# To make the solver internally use static arrays, we simply give it a static array as the
# initial condition:
# ------------------------------------------------------------------------------------------

u0 = @SVector [1.0,0.0,0.0]
tspan = (0.0,100.0)
prob = ODEProblem(lorenz_static,u0,tspan)
@benchmark solve(prob,Tsit5())

@benchmark solve(prob,Tsit5(),save_everystep=false)

# ------------------------------------------------------------------------------------------
# And that's pretty much all there is to it. With static arrays you don't have to worry
# about allocating, so use operations like `*` and don't worry about fusing operations
# (discussed in the next section). Do "the vectorized code" of R/MATLAB/Python and your code
# in this case will be fast, or directly use the numbers/values.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# Implement the out-of-place array, in-place array, and out-of-place static array forms for
# the [Henon-Heiles System](https://en.wikipedia.org/wiki/H%C3%A9non%E2%80%93Heiles_system)
# and time the results.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Optimizing Large Systems
#
# ### Interlude: Managing Allocations with Broadcast Fusion
#
# When your system is sufficiently large, or you have to make use of a non-native Julia
# algorithm, you have to make use of `Array`s. In order to use arrays in the most efficient
# manner, you need to be careful about temporary allocations. Vectorized calculations
# naturally have plenty of temporary array allocations. This is because a vectorized
# calculation outputs a vector. Thus:
# ------------------------------------------------------------------------------------------

A = rand(1000,1000); B = rand(1000,1000); C = rand(1000,1000)
test(A,B,C) = A + B + C
@benchmark test(A,B,C)

# ------------------------------------------------------------------------------------------
# That expression `A + B + C` creates 2 arrays. It first creates one for the output of `A +
# B`, then uses that result array to `+ C` to get the final result. 2 arrays! We don't want
# that! The first thing to do to fix this is to use broadcast fusion. [Broadcast
# fusion](https://julialang.org/blog/2017/01/moredots) puts expressions together. For
# example, instead of doing the `+` operations separately, if we were to add them all at the
# same time, then we would only have a single array that's created. For example:
# ------------------------------------------------------------------------------------------

test2(A,B,C) = map((a,b,c)->a+b+c,A,B,C)
@benchmark test2(A,B,C)

# ------------------------------------------------------------------------------------------
# Puts the whole expression into a single function call, and thus only one array is required
# to store output. This is the same as writing the loop:
# ------------------------------------------------------------------------------------------

function test3(A,B,C)
    D = similar(A)
    @inbounds for i in eachindex(A)
        D[i] = A[i] + B[i] + C[i]
    end
    D
end
@benchmark test3(A,B,C)

# ------------------------------------------------------------------------------------------
# However, Julia's broadcast is syntactic sugar for this. If multiple expressions have a
# `.`, then it will put those vectorized operations together. Thus:
# ------------------------------------------------------------------------------------------

test4(A,B,C) = A .+ B .+ C
@benchmark test4(A,B,C)

# ------------------------------------------------------------------------------------------
# is a version with only 1 array created (the output). Note that `.`s can be used with
# function calls as well:
# ------------------------------------------------------------------------------------------

sin.(A) .+ sin.(B)

# ------------------------------------------------------------------------------------------
# Also, the `@.` macro applys a dot to every operator:
# ------------------------------------------------------------------------------------------

test5(A,B,C) = @. A + B + C #only one array allocated
@benchmark test5(A,B,C)

# ------------------------------------------------------------------------------------------
# Using these tools we can get rid of our intermediate array allocations for many vectorized
# function calls. But we are still allocating the output array. To get rid of that
# allocation, we can instead use mutation. Mutating broadcast is done via `.=`. For example,
# if we pre-allocate the output:
# ------------------------------------------------------------------------------------------

D = zeros(1000,1000);

# ------------------------------------------------------------------------------------------
# Then we can keep re-using this cache for subsequent calculations. The mutating
# broadcasting form is:
# ------------------------------------------------------------------------------------------

test6!(D,A,B,C) = D .= A .+ B .+ C #only one array allocated
@benchmark test6!(D,A,B,C)

# ------------------------------------------------------------------------------------------
# If we use `@.` before the `=`, then it will turn it into `.=`:
# ------------------------------------------------------------------------------------------

test7!(D,A,B,C) = @. D = A + B + C #only one array allocated
@benchmark test7!(D,A,B,C)

# ------------------------------------------------------------------------------------------
# Notice that in this case, there is no "output", and instead the values inside of `D` are
# what are changed (like with the DiffEq inplace function). Many Julia functions have a
# mutating form which is denoted with a `!`. For example, the mutating form of the `map` is
# `map!`:
# ------------------------------------------------------------------------------------------

test8!(D,A,B,C) = map!((a,b,c)->a+b+c,D,A,B,C)
@benchmark test8!(D,A,B,C)

# ------------------------------------------------------------------------------------------
# Some operations require using an alternate mutating form in order to be fast. For example,
# matrix multiplication via `*` allocates a temporary:
# ------------------------------------------------------------------------------------------

@benchmark A*B

# ------------------------------------------------------------------------------------------
# Instead, we can use the mutating form `A_mul_B!` into a cache array to avoid allocating
# the output:
# ------------------------------------------------------------------------------------------

@benchmark A_mul_B!(D,A,B) # same as D = A * B

# ------------------------------------------------------------------------------------------
# For repeated calculations this reduced allocation can stop GC cycles and thus lead to more
# efficient code. Additionally, ***we can fuse together higher level linear algebra
# operations using BLAS***. The package
# [SugarBLAS.jl](https://github.com/lopezm94/SugarBLAS.jl) makes it easy to write higher
# level operations like `alpha*B*A + beta*C` as mutating BLAS calls.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Example Optimization: Gierer-Meinhardt Reaction-Diffusion PDE Discretization
#
# Let's optimize the solution of a Reaction-Diffusion PDE's discretization. In its
# discretized form, this is the ODE:
#
# $$ du = D_1 (A_y u + u A_x) + \frac{au^2}{v} + \bar{u} - \alpha u $$
# $$ dv = D_2 (A_y v + v A_x) + a u^2 + \beta v $$
#
# where $u$, $v$, and $A$ are matrices. Here, we will use the simplified version where $A$
# is the tridiagonal stencil $[1,-2,1]$, i.e. it's the 2D discretization of the LaPlacian.
# The native code would be something along the lines of:
# ------------------------------------------------------------------------------------------

# Generate the constants
p = (1.0,1.0,1.0,10.0,0.001,100.0) # a,α,ubar,β,D1,D2
N = 100
Ax = full(Tridiagonal([1.0 for i in 1:N-1],[-2.0 for i in 1:N],[1.0 for i in 1:N-1]))
Ay = copy(Ax)
Ax[2,1] = 2.0
Ax[end-1,end] = 2.0
Ay[1,2] = 2.0
Ay[end,end-1] = 2.0                                

function basic_version!(dr,r,p,t)
  a,α,ubar,β,D1,D2 = p
  u = r[:,:,1]
  v = r[:,:,2]
  Du = D1*(Ay*u + u*Ax)
  Dv = D2*(Ay*v + v*Ax)
  dr[:,:,1] = Du + a*u*u./v + ubar - α*u
  dr[:,:,2] = Dv + a*u*u - β*v   
end

a,α,ubar,β,D1,D2 = p
uss = (ubar+β)/α
vss = (a/β)*uss^2
r0 = zeros(100,100,2)
r0[:,:,1] = uss+0.1*rand()
r0[:,:,2] = vss

prob = ODEProblem(basic_version!,r0,(0.0,0.1),p)

# ------------------------------------------------------------------------------------------
# In this version we have encoded our initial condition to be a 3-dimensional array, with
# `u[:,:,1]` being the `A` part and `u[:,:,2]` being the `B` part.
# ------------------------------------------------------------------------------------------

@benchmark solve(prob,Tsit5())

# ------------------------------------------------------------------------------------------
# While this version isn't very efficient,
#
# #### We recommend writing the "high-level" code first, and iteratively optimizing it!
#
# The first thing that we can do is get rid of the slicing allocations. The operation
# `r[:,:,1]` creates a temporary array instead of a "view", i.e. a pointer to the already
# existing memory. To make it a view, add `@view`. Note that we have to be careful with
# views because they point to the same memory, and thus changing a view changes the original
# values:
# ------------------------------------------------------------------------------------------

A = rand(4)
@show A
B = @view A[1:3]
B[2] = 2
@show A

# ------------------------------------------------------------------------------------------
# Notice that changing `B` changed `A`. This is something to be careful of, but at the same
# time we want to use this since we want to modify the output `dr`. Additionally, the last
# statement is a purely element-wise operation, and thus we can make use of broadcast fusion
# there. Let's rewrite `basic_version!` to ***avoid slicing allocations*** and to ***use
# broadcast fusion***:
# ------------------------------------------------------------------------------------------

function gm2!(dr,r,p,t)
  a,α,ubar,β,D1,D2 = p
  u = @view r[:,:,1]
  v = @view r[:,:,2]
  du = @view dr[:,:,1]
  dv = @view dr[:,:,2]
  Du = D1*(Ay*u + u*Ax)
  Dv = D2*(Ay*v + v*Ax)
  @. du = Du + a*u*u./v + ubar - α*u
  @. dv = Dv + a*u*u - β*v   
end
prob = ODEProblem(gm2!,r0,(0.0,0.1),p)
@benchmark solve(prob,Tsit5())

# ------------------------------------------------------------------------------------------
# Now, most of the allocations are taking place in `Du = D1*(Ay*u + u*Ax)` since those
# operations are vectorized and not mutating. We should instead replace the matrix
# multiplications with `A_mul_B!`. When doing so, we will need to have cache variables to
# write into. This looks like:
# ------------------------------------------------------------------------------------------

Ayu = zeros(N,N)
uAx = zeros(N,N)
Du = zeros(N,N)
Ayv = zeros(N,N)
vAx = zeros(N,N)
Dv = zeros(N,N)
function gm3!(dr,r,p,t)
  a,α,ubar,β,D1,D2 = p
  u = @view r[:,:,1]
  v = @view r[:,:,2]
  du = @view dr[:,:,1]
  dv = @view dr[:,:,2]
  A_mul_B!(Ayu,Ay,u)
  A_mul_B!(uAx,u,Ax)
  A_mul_B!(Ayv,Ay,v)
  A_mul_B!(vAx,v,Ax)
  @. Du = D1*(Ayu + uAx)
  @. Dv = D2*(Ayv + vAx)
  @. du = Du + a*u*u./v + ubar - α*u
  @. dv = Dv + a*u*u - β*v   
end
prob = ODEProblem(gm3!,r0,(0.0,0.1),p)
@benchmark solve(prob,Tsit5())

# ------------------------------------------------------------------------------------------
# But our temporary variables are global variables. We need to either declare the caches as
# `const` or localize them. We can localize them by adding them to the parameters, `p`. It's
# easier for the compiler to reason about local variables than global variables.
# ***Localizing variables helps to ensure type stability***.
# ------------------------------------------------------------------------------------------

p = (1.0,1.0,1.0,10.0,0.001,100.0,Ayu,uAx,Du,Ayv,vAx,Dv) # a,α,ubar,β,D1,D2
function gm4!(dr,r,p,t)
  a,α,ubar,β,D1,D2,Ayu,uAx,Du,Ayv,vAx,Dv = p
  u = @view r[:,:,1]
  v = @view r[:,:,2]
  du = @view dr[:,:,1]
  dv = @view dr[:,:,2]
  A_mul_B!(Ayu,Ay,u)
  A_mul_B!(uAx,u,Ax)
  A_mul_B!(Ayv,Ay,v)
  A_mul_B!(vAx,v,Ax)
  @. Du = D1*(Ayu + uAx)
  @. Dv = D2*(Ayv + vAx)
  @. du = Du + a*u*u./v + ubar - α*u
  @. dv = Dv + a*u*u - β*v   
end
prob = ODEProblem(gm4!,r0,(0.0,0.1),p)
@benchmark solve(prob,Tsit5())

# ------------------------------------------------------------------------------------------
# We could then use the BLAS `gemmv` to optimize the matrix multiplications some more, but
# instead let's devectorize the stencil.
# ------------------------------------------------------------------------------------------

p = (1.0,1.0,1.0,10.0,0.001,100.0,N)
function fast_gm!(du,u,p,t)
  a,α,ubar,β,D1,D2,N = p

  @inbounds for j in 2:N-1, i in 2:N-1
    du[i,j,1] = D1*(u[i-1,j,1] + u[i+1,j,1] + u[i,j+1,1] + u[i,j-1,1] - 4u[i,j,1]) +
              a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
  end

  @inbounds for j in 2:N-1, i in 2:N-1
    du[i,j,2] = D2*(u[i-1,j,2] + u[i+1,j,2] + u[i,j+1,2] + u[i,j-1,2] - 4u[i,j,2]) +
            a*u[i,j,1]^2 - β*u[i,j,2]
  end

  @inbounds for j in 2:N-1
    i = 1
    du[1,j,1] = D1*(2u[i+1,j,1] + u[i,j+1,1] + u[i,j-1,1] - 4u[i,j,1]) +
            a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
  end
  @inbounds for j in 2:N-1
    i = 1
    du[1,j,2] = D2*(2u[i+1,j,2] + u[i,j+1,2] + u[i,j-1,2] - 4u[i,j,2]) +
            a*u[i,j,1]^2 - β*u[i,j,2]
  end
  @inbounds for j in 2:N-1
    i = N
    du[end,j,1] = D1*(2u[i-1,j,1] + u[i,j+1,1] + u[i,j-1,1] - 4u[i,j,1]) +
           a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
  end
  @inbounds for j in 2:N-1
    i = N
    du[end,j,2] = D2*(2u[i-1,j,2] + u[i,j+1,2] + u[i,j-1,2] - 4u[i,j,2]) +
           a*u[i,j,1]^2 - β*u[i,j,2]
  end

  @inbounds for i in 2:N-1
    j = 1
    du[i,1,1] = D1*(u[i-1,j,1] + u[i+1,j,1] + 2u[i,j+1,1] - 4u[i,j,1]) +
              a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
  end
  @inbounds for i in 2:N-1
    j = 1
    du[i,1,2] = D2*(u[i-1,j,2] + u[i+1,j,2] + 2u[i,j+1,2] - 4u[i,j,2]) +
              a*u[i,j,1]^2 - β*u[i,j,2]
  end
  @inbounds for i in 2:N-1
    j = N
    du[i,end,1] = D1*(u[i-1,j,1] + u[i+1,j,1] + 2u[i,j-1,1] - 4u[i,j,1]) +
             a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
  end
  @inbounds for i in 2:N-1
    j = N
    du[i,end,2] = D2*(u[i-1,j,2] + u[i+1,j,2] + 2u[i,j-1,2] - 4u[i,j,2]) +
             a*u[i,j,1]^2 - β*u[i,j,2]
  end

  @inbounds begin
    i = 1; j = 1
    du[1,1,1] = D1*(2u[i+1,j,1] + 2u[i,j+1,1] - 4u[i,j,1]) +
              a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
    du[1,1,2] = D2*(2u[i+1,j,2] + 2u[i,j+1,2] - 4u[i,j,2]) +
              a*u[i,j,1]^2 - β*u[i,j,2]

    i = 1; j = N
    du[1,N,1] = D1*(2u[i+1,j,1] + 2u[i,j-1,1] - 4u[i,j,1]) +
             a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
    du[1,N,2] = D2*(2u[i+1,j,2] + 2u[i,j-1,2] - 4u[i,j,2]) +
             a*u[i,j,1]^2 - β*u[i,j,2]

    i = N; j = 1
    du[N,1,1] = D1*(2u[i-1,j,1] + 2u[i,j+1,1] - 4u[i,j,1]) +
             a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
    du[N,1,2] = D2*(2u[i-1,j,2] + 2u[i,j+1,2] - 4u[i,j,2]) +
             a*u[i,j,1]^2 - β*u[i,j,2]

    i = N; j = N
    du[end,end,1] = D1*(2u[i-1,j,1] + 2u[i,j-1,1] - 4u[i,j,1]) +
             a*u[i,j,1]^2/u[i,j,2] + ubar - α*u[i,j,1]
    du[end,end,2] = D2*(2u[i-1,j,2] + 2u[i,j-1,2] - 4u[i,j,2]) +
             a*u[i,j,1]^2 - β*u[i,j,2]
   end
end
prob = ODEProblem(fast_gm!,r0,(0.0,0.1),p)
@benchmark solve(prob,Tsit5())

# ------------------------------------------------------------------------------------------
# Lastly, we can do other things like multithread the main loops, but these optimizations
# get the last 2x-3x out. The main optimizations which apply everywhere are the ones we just
# performed (though the last one only works if your matrix is a stencil. This is known as a
# matrix-free implementation of the PDE discretization).
#
# This gets us to about 20,000x faster than our original MATLAB/SciPy/R vectorized style
# code!
#
# The last thing to do is then ***optimize our algorithm choice***. We have been using
# `Tsit5()` as our test algorithm, but in reality this problem is a stiff PDE discretization
# and thus one recommendation is to use `CVODE_BDF()`. However, instead of using the default
# dense Jacobian, we should make use of the sparse Jacobian afforded by the problem. The
# Jacobian is the matrix $\frac{df_i}{dr_j}$, where $r$ is read by the linear index (i.e.
# down columns). But since the $u$ variables depend on the $v$, the band size here is large,
# and thus this will not do well with a Banded Jacobian solver. Instead, we utilize sparse
# Jacobian algorithms. `CVODE_BDF` allows us to use a sparse Newton-Krylov solver by setting
# `linear_solver = :GMRES` (see [the solver
# documentation](http://docs.juliadiffeq.org/latest/solvers/ode_solve.html#Sundials.jl-1),
# and thus we can solve this problem efficiently. Let's see how this scales as we increase
# the integration time.
# ------------------------------------------------------------------------------------------

prob = ODEProblem(fast_gm!,r0,(0.0,10.0),p)
@benchmark solve(prob,Tsit5())

@benchmark solve(prob,CVODE_BDF(linear_solver=:GMRES))

prob = ODEProblem(fast_gm!,r0,(0.0,100.0),p)
@benchmark solve(prob,Tsit5())

@benchmark solve(prob,CVODE_BDF(linear_solver=:GMRES))

# ------------------------------------------------------------------------------------------
# What's happening is that, because the problem is stiff, the number of steps required by
# the explicit Runge-Kutta method grows rapidly, whereas `CVODE_BDF` is taking large steps.
# Additionally, the `GMRES` linear solver form is quite an efficient way to solve the
# implicit system in this case. This is problem-dependent, and in many cases using a Krylov
# method effectively requires a preconditioner, so you need to play around with testing
# other algorithms and linear solvers to find out what works best with your problem.
#
# ## Conclusion
#
# Julia gives you the tools to optimize the solver "all the way", but you need to make use
# of it. The main thing to avoid is temporary allocations. For small systems, this is
# effectively done via static arrays. For large systems, this is done via in-place
# operations and cache arrays. Either way, the resulting solution can be immensely sped up
# over vectorized formulations by using these principles.
# ------------------------------------------------------------------------------------------
