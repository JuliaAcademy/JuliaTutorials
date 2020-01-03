# ------------------------------------------------------------------------------------------
# # An Intro to DifferentialEquations.jl
#
# ## Basic Introduction Via Ordinary Differential Equations
#
# This notebook will get you started with DifferentialEquations.jl by introducing you to the
# functionality for solving ordinary differential equations (ODEs). The corresponding
# documentation page is the [ODE
# tutorial](http://docs.juliadiffeq.org/latest/tutorials/ode_example.html). While some of
# the syntax may be different for other types of equations, the same general principles hold
# in each case. Our goal is to give a gentle and thorough introduction that highlights these
# principles in a way that will help you generalize what you have learned.
#
# ### Background
#
# If you are new to the study of differential equations, it can be helpful to do a quick
# background read on [the definition of ordinary differential
# equations](https://en.wikipedia.org/wiki/Ordinary_differential_equation). We define an
# ordinary differential equation as an equation which describes the way that a variable $u$
# changes, that is
#
# $$ u' = f(u,p,t) $$
#
# where $p$ are the parameters of the model, $t$ is the time variable, and $f$ is the
# nonlinear model of how $u$ changes. The initial value problem also includes the
# information about the starting value:
#
# $$ u(t_0) = u_0 $$
#
# Together, if you know the starting value and you know how the value will change with time,
# then you know what the value will be at any time point in the future. This is the
# intuitive definition of a differential equation.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### First Model: Exponential Growth
#
# Our first model will be the canonical exponential growth model. This model says that the
# rate of change is proportional to the current value, and is this:
#
# $$ u' = au $$
#
# where we have a starting value $u(0)=u_0$. Let's say we put 1 dollar into Bitcoin which is
# increasing at a rate of $98\%$ per year. Then calling now $t=0$ and measuring time in
# years, our model is:
#
# $$ u' = 0.98u $$
#
# and $u(0) = 1.0$. We encode this into Julia by noticing that, in this setup, we match the
# general form when
#
# $$ f(u,p,t) = 0.98u $$
#
# with $ u_0 = 1.0 $. If we want to solve this model on a time span from `t=0.0` to `t=1.0`,
# then we define an `ODEProblem` by specifying this function `f`, this initial condition
# `u0`, and this time span as follows:
# ------------------------------------------------------------------------------------------

using DifferentialEquations
f(u,p,t) = 0.98u
u0 = 1.0
tspan = (0.0,1.0)
prob = ODEProblem(f,u0,tspan)

# ------------------------------------------------------------------------------------------
# To solve our `ODEProblem` we use the command `solve`.
# ------------------------------------------------------------------------------------------

sol = solve(prob)

# ------------------------------------------------------------------------------------------
# and that's it: we have succesfully solved our first ODE!
#
# #### Analyzing the Solution
#
# Of course, the solution type is not interesting in and of itself. We want to understand
# the solution! The documentation page which explains in detail the functions for analyzing
# the solution is the [Solution
# Handling](http://docs.juliadiffeq.org/latest/basics/solution.html) page. Here we will
# describe some of the basics. You can plot the solution using the plot recipe provided by
# [Plots.jl](http://docs.juliaplots.org/latest/):
# ------------------------------------------------------------------------------------------

using Plots; gr()
plot(sol)

# ------------------------------------------------------------------------------------------
# From the picture we see that the solution is an exponential curve, which matches our
# intuition. As a plot recipe, we can annotate the result using any of the [Plots.jl
# attributes](http://docs.juliaplots.org/latest/attributes/). For example:
# ------------------------------------------------------------------------------------------

plot(sol,linewidth=5,title="Solution to the linear ODE with a thick line",
     xaxis="Time (t)",yaxis="u(t) (in μm)",label="My Thick Line!") # legend=false

# ------------------------------------------------------------------------------------------
# Using the mutating `plot!` command we can add other pieces to our plot. For this ODE we
# know that the true solution is $u(t) = u_0 exp(at)$, so let's add some of the true
# solution to our plot:
# ------------------------------------------------------------------------------------------

plot!(sol.t, t->1.0*exp(0.98t),lw=3,ls=:dash,label="True Solution!")

# ------------------------------------------------------------------------------------------
# In the previous command I demonstrated `sol.t`, which grabs the array of time points that
# the solution was saved at:
# ------------------------------------------------------------------------------------------

sol.t

# ------------------------------------------------------------------------------------------
# We can get the array of solution values using `sol.u`:
# ------------------------------------------------------------------------------------------

sol.u

# ------------------------------------------------------------------------------------------
# `sol.u[i]` is the value of the solution at time `sol.t[i]`. We can compute arrays of
# functions of the solution values using standard comprehensions, like:
# ------------------------------------------------------------------------------------------

[t+u for (u,t) in tuples(sol)]

# ------------------------------------------------------------------------------------------
# However, one interesting feature is that, by default, the solution is a continuous
# function. If we check the print out again:
# ------------------------------------------------------------------------------------------

sol

# ------------------------------------------------------------------------------------------
# you see that it says that the solution has a 4th order interpolation, meaning that it is a
# continuous function of 4th order accuracy. We can call the solution as a function of time
# `sol(t)`. For example, to get the value at `t=0.45`, we can use the command:
# ------------------------------------------------------------------------------------------

sol(0.45)

# ------------------------------------------------------------------------------------------
# #### Controlling the Solver
#
# DifferentialEquations.jl has a common set of solver controls among its algorithms which
# can be found [at the Common Solver
# Options](http://docs.juliadiffeq.org/latest/basics/common_solver_opts.html) page. We will
# detail some of the most widely used options.
#
# The most useful options are the tolerances `abstol` and `reltol`. These tell the internal
# adaptive time stepping engine how precise of a solution you want. Generally, `reltol` is
# the relative accuracy while `abstol` is the accuracy when `u` is near zero. These
# tolerances are local tolerances and thus are not global guarantees. However, a good rule
# of thumb is that the total solution accuracy is 1-2 digits less than the relative
# tolerances. Thus for the defaults `abstol=1e-6` and `reltol=1e-3`, you can expect a global
# accuracy of about 1-2 digits. If we want to get around 6 digits of accuracy, we can use
# the commands:
# ------------------------------------------------------------------------------------------

sol = solve(prob,abstol=1e-8,reltol=1e-8)

# ------------------------------------------------------------------------------------------
# Now we can see no visible difference against the true solution:
# ------------------------------------------------------------------------------------------

plot(sol)
plot!(sol.t, t->1.0*exp(0.98t),lw=3,ls=:dash,label="True Solution!")

# ------------------------------------------------------------------------------------------
# Notice that by decreasing the tolerance, the number of steps the solver had to take was
# `9` instead of the previous `5`. There is a trade off between accuracy and speed, and it
# is up to you to determine what is the right balance for your problem.
#
# Another common option is to use `saveat` to make the solver save at specific time points.
# For example, if we want the solution at an even grid of `t=0.1k` for integers `k`, we
# would use the command:
# ------------------------------------------------------------------------------------------

sol = solve(prob,saveat=0.1)

# ------------------------------------------------------------------------------------------
# Notice that when `saveat` is used the continuous output variables are no longer saved and
# thus `sol(t)`, the interpolation, is only first order. We can save at an uneven grid of
# points by passing a collection of values to `saveat`. For example:
# ------------------------------------------------------------------------------------------

sol = solve(prob,saveat=[0.2,0.7,0.9])

# ------------------------------------------------------------------------------------------
# By default it always saves the first and last values, but we can turn this off as well:
# ------------------------------------------------------------------------------------------

sol = solve(prob,saveat=[0.2,0.7,0.9],save_start = false, save_end = false)

# ------------------------------------------------------------------------------------------
# If we need to reduce the amount of saving, we can also turn off the continuous output
# directly via `dense=false`:
# ------------------------------------------------------------------------------------------

sol = solve(prob,dense=false)

# ------------------------------------------------------------------------------------------
# and to turn off all intermediate saving we can use `save_everystep=false`:
# ------------------------------------------------------------------------------------------

sol = solve(prob,save_everystep=false)

# ------------------------------------------------------------------------------------------
# More advanced saving behaviors, such as saving functionals of the solution, are handled
# via the `SavingCallback` in the [Callback Library](http://docs.juliadiffeq.org/latest/feat
# ures/callback_library.html#SavingCallback-1) which will be addressed later in the
# tutorial.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Choosing Solver Algorithms
#
# There is no best algorithm for numerically solving a differential equation. When you call
# `solve(prob)`, DifferentialEquations.jl makes a guess at a good algorithm for your
# problem, given the properties that you ask for (the tolerances, the saving information,
# etc.). However, in many cases you may want more direct control. A later notebook will help
# introduce the various *algorithms* in DifferentialEquations.jl, but for now let's
# introduce the *syntax*.
#
# The most crucial determining factor in choosing a numerical method is the stiffness of the
# model. Stiffness is roughly characterized by a Jacobian `f` with large eigenvalues. That's
# quite mathematical, and we can think of it more intuitively: if you have big numbers in
# `f` (like parameters of order `1e5`), then it's probably stiff. Or, as the creator of the
# MATLAB ODE Suite, Lawrence Shampine, likes to define it, if the standard algorithms are
# slow, then it's stiff. We will go into more depth about diagnosing stiffness in a later
# tutorial, but for now note that if you believe your model may be stiff, you can hint this
# to the algorithm chooser via `alg_hints = [:stiff]`.
# ------------------------------------------------------------------------------------------

sol = solve(prob,alg_hints=[:stiff])

# ------------------------------------------------------------------------------------------
# Stiff algorithms have to solve implicit equations and linear systems at each step so they
# should only be used when required.
#
# If we want to choose an algorithm directly, you can pass the algorithm type after the
# problem as `solve(prob,alg)`. For example, let's solve this problem using the `Tsit5()`
# algorithm, and just for show let's change the relative tolerance to `1e-6` at the same
# time:
# ------------------------------------------------------------------------------------------

sol = solve(prob,Tsit5(),reltol=1e-6)

# ------------------------------------------------------------------------------------------
# ### Systems of ODEs: The Lorenz Equation
#
# Now let's move to a system of ODEs. The [Lorenz
# equation](https://en.wikipedia.org/wiki/Lorenz_system) is the famous "butterfly attractor"
# that spawned chaos theory. It is defined by the system of ODEs:
#
# $$ \frac{dx}{dt} = \sigma (y - x) $$
# $$ \frac{dy}{dt} = x (\rho - z) -y $$
# $$ \frac{dz}{dt} = xy - \beta z $$
#
# To define a system of differential equations in DifferentialEquations.jl, we define our
# `f` as a vector function with a vector initial condition. Thus, for the vector `u =
# [x,y,z]'`, we have the derivative function:
# ------------------------------------------------------------------------------------------

function lorenz!(du,u,p,t)
    σ,ρ,β = p
    du[1] = σ*(u[2]-u[1])
    du[2] = u[1]*(ρ-u[3]) - u[2]
    du[3] = u[1]*u[2] - β*u[3]    
end

# ------------------------------------------------------------------------------------------
# Notice here we used the in-place format which writes the output to the preallocated vector
# `du`. For systems of equations the in-place format is faster. We use the initial condition
# $u_0 = [1.0,0.0,0.0]$ as follows:
# ------------------------------------------------------------------------------------------

u0 = [1.0,0.0,0.0]

# ------------------------------------------------------------------------------------------
# Lastly, for this model we made use of the parameters `p`. We need to set this value in the
# `ODEProblem` as well. For our model we want to solve using the parameters $\sigma = 10$,
# $\rho = 28$, and $\beta = 8/3$, and thus we build the parameter collection:
# ------------------------------------------------------------------------------------------

p = (10,28,8/3) # we could also make this an array, or any other type!

# ------------------------------------------------------------------------------------------
# Now we generate the `ODEProblem` type. In this case, since we have parameters, we add the
# parameter values to the end of the constructor call. Let's solve this on a time span of
# `t=0` to `t=100`:
# ------------------------------------------------------------------------------------------

tspan = (0.0,100.0)
prob = ODEProblem(lorenz!,u0,tspan,p)

# ------------------------------------------------------------------------------------------
# Now, just as before, we solve the problem:
# ------------------------------------------------------------------------------------------

sol = solve(prob)

# ------------------------------------------------------------------------------------------
# The same solution handling features apply to this case. Thus `sol.t` stores the time
# points and `sol.u` is an array storing the solution at the corresponding time points.
#
# However, there are a few extra features which are good to know when dealing with systems
# of equations. First of all, `sol` also acts like an array. `sol[i]` returns the solution
# at the `i`th time point.
# ------------------------------------------------------------------------------------------

sol.t[10],sol[10]

# ------------------------------------------------------------------------------------------
# Additionally, the solution acts like a matrix where `sol[j,i]` is the value of the `j`th
# variable at time `i`:
# ------------------------------------------------------------------------------------------

sol[2,10]

# ------------------------------------------------------------------------------------------
# We can get a real matrix by performing a conversion:
# ------------------------------------------------------------------------------------------

A = convert(Array,sol)

# ------------------------------------------------------------------------------------------
# This is the same as sol, i.e. `sol[i,j] = A[i,j]`, but now it's a true matrix. Plotting
# will by default show the time series for each variable:
# ------------------------------------------------------------------------------------------

plot(sol)

# ------------------------------------------------------------------------------------------
# If we instead want to plot values against each other, we can use the `vars` command. Let's
# plot variable `1` against variable `2` against variable `3`:
# ------------------------------------------------------------------------------------------

plot(sol,vars=(1,2,3))

# ------------------------------------------------------------------------------------------
# This is the classic Lorenz attractor plot, where the `x` axis is `u[1]`, the `y` axis is
# `u[2]`, and the `z` axis is `u[3]`. Note that the plot recipe by default uses the
# interpolation, but we can turn this off:
# ------------------------------------------------------------------------------------------

plot(sol,vars=(1,2,3),denseplot=false)

# ------------------------------------------------------------------------------------------
# Yikes! This shows how calculating the continuous solution has saved a lot of computational
# effort by computing only a sparse solution and filling in the values! Note that in vars,
# `0=time`, and thus we can plot the time series of a single component like:
# ------------------------------------------------------------------------------------------

plot(sol,vars=(0,2))

# ------------------------------------------------------------------------------------------
# ### A DSL for Parameterized Functions
#
# In many cases you may be defining a lot of functions with parameters. There exists the
# domain-specific language (DSL) defined by the `@ode_def` macro for helping with this
# common problem. For example, we can define the Lotka-Volterra equation:
#
# $$ \frac{dx}{dt} = ax - bxy $$
# $$ \frac{dy}{dt} = -cy + dxy $$
#
# as follows:
# ------------------------------------------------------------------------------------------

function lotka_volterra!(du,u,p,t)
  du[1] = p[1]*u[1] - p[2]*u[1]*u[2]
  du[2] = -p[3]*u[2] + p[4]*u[1]*u[2]
end

# ------------------------------------------------------------------------------------------
# However, that can be hard to follow since there's a lot of "programming" getting in the
# way. Instead, you can use the `@ode_def` macro:
# ------------------------------------------------------------------------------------------

lv! = @ode_def LotkaVolterra begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a b c d

# ------------------------------------------------------------------------------------------
# We can then use the result just like an ODE function from before:
# ------------------------------------------------------------------------------------------

u0 = [1.0,1.0]
p = (1.5,1.0,3.0,1.0)
tspan = (0.0,10.0)
prob = ODEProblem(lv!,u0,tspan,p)
sol = solve(prob)
plot(sol)

# ------------------------------------------------------------------------------------------
# Not only is the DSL convenient syntax, but it does some magic behind the scenes. For
# example, further parts of the tutorial will describe how solvers for stiff differential
# equations have to make use of the Jacobian in calculations. Here, the DSL uses symbolic
# differentiation to automatically derive that function:
# ------------------------------------------------------------------------------------------

lv!.Jex

# ------------------------------------------------------------------------------------------
# The DSL can derive many other functions; this ability is used to speed up the solvers. An
# extension to DifferentialEquations.jl, [Latexify.jl](https://korsbo.github.io/Latexify.jl/
# latest/tutorials/parameterizedfunctions.html), allows you to extract these pieces as LaTeX
# expressions.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Internal Types
#
# The last basic user-interface feature to explore is the choice of types.
# DifferentialEquations.jl respects your input types to determine the internal types that
# are used. Thus since in the previous cases, when we used `Float64` values for the initial
# condition, this meant that the internal values would be solved using `Float64`. We made
# sure that time was specified via `Float64` values, meaning that time steps would utilize
# 64-bit floats as well. But, by simply changing these types we can change what is used
# internally.
#
# As a quick example, let's say we want to solve an ODE defined by a matrix. To do this, we
# can simply use a matrix as input.
# ------------------------------------------------------------------------------------------

A  = [1. 0  0 -5
      4 -2  4 -3
     -4  0  0  1
      5 -2  2  3]
u0 = rand(4,2)
tspan = (0.0,1.0)
f(u,p,t) = A*u
prob = ODEProblem(f,u0,tspan)
sol = solve(prob)

# ------------------------------------------------------------------------------------------
# There is no real difference from what we did before, but now in this case `u0` is a `4x2`
# matrix. Because of that, the solution at each time point is matrix:
# ------------------------------------------------------------------------------------------

sol[3]

# ------------------------------------------------------------------------------------------
# In DifferentialEquations.jl, you can use any type that defines `+`, `-`, `*`, `/`, and has
# an appropriate `norm`. For example, if we want arbitrary precision floating point numbers,
# we can change the input to be a matrix of `BigFloat`:
# ------------------------------------------------------------------------------------------

big_u0 = big.(u0)

# ------------------------------------------------------------------------------------------
# and we can solve the `ODEProblem` with arbitrary precision numbers by using that initial
# condition:
# ------------------------------------------------------------------------------------------

prob = ODEProblem(f,big_u0,tspan)
sol = solve(prob)

sol[1,3]

# ------------------------------------------------------------------------------------------
# To really make use of this, we would want to change `abstol` and `reltol` to be small!
# Notice that the type for "time" is different than the type for the dependent variables,
# and this can be used to optimize the algorithm via keeping multiple precisions. We can
# convert time to be arbitrary precision as well by defining our time span with `BigFloat`
# variables:
# 
# ------------------------------------------------------------------------------------------

prob = ODEProblem(f,big_u0,big.(tspan))
sol = solve(prob)

# ------------------------------------------------------------------------------------------
# Let's end by showing a more complicated use of types. For small arrays, it's usually
# faster to do operations on static arrays via the package
# [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl). The syntax is similar
# to that of normal arrays, but for these special arrays we utilize the `@SMatrix` macro to
# indicate we want to create a static array.
# ------------------------------------------------------------------------------------------

using StaticArrays
A  = @SMatrix [ 1.0  0.0 0.0 -5.0
                4.0 -2.0 4.0 -3.0
               -4.0  0.0 0.0  1.0
                5.0 -2.0 2.0  3.0]
u0 = @SMatrix rand(4,2)
tspan = (0.0,1.0)
f(u,p,t) = A*u
prob = ODEProblem(f,u0,tspan)
sol = solve(prob)

sol[3]

# ------------------------------------------------------------------------------------------
# ## Conclusion
#
# These are the basic controls in DifferentialEquations.jl. All equations are defined via a
# problem type, and the `solve` command is used with an algorithm choice (or the default) to
# get a solution. Every solution acts the same, like an array `sol[i]` with `sol.t[i]`, and
# also like a continuous function `sol(t)` with a nice plot command `plot(sol)`. The Common
# Solver Options can be used to control the solver for any equation type. Lastly, the types
# used in the numerical solving are determined by the input types, and this can be used to
# solve with arbitrary precision and add additional optimizations (this can be used to solve
# via GPUs for example!). While this was shown on ODEs, these techniques generalize to other
# types of equations as well.
# ------------------------------------------------------------------------------------------
