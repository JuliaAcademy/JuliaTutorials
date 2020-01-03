# ------------------------------------------------------------------------------------------
# # Creating a dynamical system
#
# Topics:
# * What *is* a dynamical system in the context of **DynamicalSystems.jl**?
# * How can we define a discrete or continuous system?
# * What are the differences in handling large and small systems?
#     * Handy Dandy definition table!
# * Comment on DifferentialEquations.jl
# * Docstrings
#
# ---
#
# # Dynamical System
#
# A "dynamical system" is a law that describes how some variables should evolve in time.
# This law is described by the "equations of motion" function $\vec{f}$.
#
# There are two types of dynamical systems (in our case):
#
# 1. One is called a map, where time is a discrete quantity (like "steps" or "generations").
# The equations of motion then look something like $\vec{u}_{n+1} = \vec{f}(\vec{u}_n, p,
# n)$ where $n$ is an integer and $p$ are the parameters of the system.
#
# 2. The other type is called an Ordinary Differential Equation (ODE), where time is a
# continuous quantity. Then, the equations of motion give the time derivatives of the
# variables: $\frac{d\vec{u}}{dt} = \vec{f}(\vec{u}, p, t)$.
#
# In both cases $\vec{u}$ is the state of the system, a vector of the variables that define
# the system. For example, $\vec{u}$ may be defined as $(x, y, z)$, or as $(\theta, I)$, or
# as $(V, I, R, C_1, C_2)$, etc.
#
# ---
# 
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Creating a simple discrete system
#
#
# For all intents and purposes, a `DynamicalSystem` is a Julia `struct` that contains all
# the information of a dynamical system:
# 1. Equations of motion function $\vec{f}$
# 3. Initial state.
# 4. Parameter container (if the equations of motion are parameterized).
# 2. *Optional* : Jacobian of the equations of motion.
#
#
# For simplicity let's focus on creating a simple discrete chaotic system, the [Hénon
# map](https://en.wikipedia.org/wiki/H%C3%A9non_map).
#
# The constructor we need is:
#
# ```julia
# DiscreteDynamicalSystem(eom, state, p)
# ```
#
# In order to construct a Hénon map, let's discuss the input arguments we need to pass to
# this constructor!
#
# #### 1. Equations of motion
# The first argument of the above constructor --`eom` -- is a **function** representing the
# equations of motion.
#
# Therefore, the first step in creating a `DynamicalSystem` is to define the equations of
# motion. For the Hénon map they have the form:
#
# $$
# \begin{aligned}
# x_{n+1} &= 1 - ax^2_n+y_n \\
# y_{n+1} & = bx_n
# \end{aligned}
# $$
#
# Now we must make a function out of them. There is some strictness when writing this
# function in Julia. Specifically, it can only be one of two forms: out-of-place (oop) or
# in-place (iip). Here is how to define it:
#
# * **oop** : The `eom` function **must** be in the form `eom(x, p, t) -> SVector`
#   which means that given a state `x::SVector` and some parameter container
#   `p` it returns a
# [`SVector`](http://juliaarrays.github.io/StaticArrays.jl/stable/pages/api.html#SVector-1)
#   (from the [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl) module)
#   containing the next state.
# * **iip** : The `eom` function **must** be in the form `eom!(xnew, x, p, t)`
#   which means that given a state `x::Vector` and some parameter container `p`,
#   it writes in-place the new state in `xnew`.
#
# We advise to use **oop** for systems with dimension < 11, and use **iip** otherwise.
#
# *If you are familiar with [DifferentialEquations.jl](http://docs.juliadiffeq.org/latest/),
# then notice that the equations of motion are defined in an identical manner*
#
# Because the Hénon map is only 2-dimensional, we follow the advice of the documentation and
# take advantage of the [`StaticArrays`](https://github.com/JuliaArrays/StaticArrays.jl)
# module.
# ------------------------------------------------------------------------------------------

using DynamicalSystems
h_eom(x, p, t) = SVector{2}(1.0 - p[1]*x[1]^2 + x[2], p[2]*x[1])

# ------------------------------------------------------------------------------------------
# * Remember: *both* `p` (for parameters) and `t` (for time) must be included in the
# equations of motion function, irrespective of whether they are used or not!
#
# #### 2. State
#
# The second argument for the `DiscreteDynamicalSystem` constructor is a `state`, which
# represents the initial condition for the system:
# ------------------------------------------------------------------------------------------

state = zeros(2) # doesn't matter if we use Vector of SVector for the `state`

# ------------------------------------------------------------------------------------------
# #### 3. Parameters for our EOM
#
# Then, the last argument, `p`, is simply a parameter container.
# ------------------------------------------------------------------------------------------

p = [1.4, 0.3] # p = [a, b] from the equations of motion

# ------------------------------------------------------------------------------------------
# These 3 things are enough to make a `DynamicalSystem`:
# ------------------------------------------------------------------------------------------

henon = DiscreteDynamicalSystem(h_eom, state, p)

# ------------------------------------------------------------------------------------------
# ## Getting a trajectory
#
# Now that we have created the system, the first (and most basic) thing to do is to simply
# plot its time evolution and see what it looks like.
#
# The `trajectory` function is a convenient tool that evolves the system and returns the
# output at equally spaced time intervals. The call signature is simply:
#
# ```julia
# trajectory(ds::DynamicalSystem, T [, u]; kwargs...)
# ```
# which evolves a system for total time `T`, optionally starting from a different state `u`.
# ------------------------------------------------------------------------------------------

# trajectory from initial condition
tr = trajectory(henon, 100000)

# trajectory from a different starting point
tr2 = trajectory(henon, 100000, 0.01rand(2))

using PyPlot
figure(figsize=(6,4))
plot(tr[:, 1], tr[:, 2], lw = 0.0, marker = "o", ms = 0.1, alpha = 0.5);
plot(tr2[:, 1], tr2[:, 2], lw = 0.0, marker = "o", ms = 0.1, alpha = 0.5);
xlabel("x"); ylabel("y");

# ------------------------------------------------------------------------------------------
# ## Crash-course on `Dataset`
#
# `trajectory` returns an object that is a `Dataset`:
# ------------------------------------------------------------------------------------------

tr = trajectory(henon, 100000)
println(typeof(tr))
println(summary(tr))

# ------------------------------------------------------------------------------------------
# `Dataset` instances handle most data in **DynamicalSystems.jl**. `Dataset` is a wrapper of
# a `Vector` of `SVector`s (statically sized vectors).
# ------------------------------------------------------------------------------------------

typeof(tr.data) # this is where the `Dataset` has the data

# ------------------------------------------------------------------------------------------
# When accessed with one index, a `Dataset` behaves as a vector of vectors
# ------------------------------------------------------------------------------------------

tr[1] # variables at first time point

tr[1:5]

# ------------------------------------------------------------------------------------------
# When accessed with two indices, a `Dataset` behaves like a matrix with each column being
# the timeseries of each dynamic variable
# ------------------------------------------------------------------------------------------

tr[:, 1] # timeseries of first variable

tr[1:56, 2] # time points 1:56 of second variable

tr[12, 1] # value of first variable at 12th timepoint

tr[1:10, 1:2] # using two ranges returns a `Dataset`

# ------------------------------------------------------------------------------------------
# # Adding a Jacobian
#
# Let's see `henon` again:
# ------------------------------------------------------------------------------------------

henon

# ------------------------------------------------------------------------------------------
# * The last line, "`jacobian:  ForwardDiff`"
# says that the Jacobian function of the equations of motion was computed automatically
# using the module
# [`ForwardDiff`](http://www.juliadiff.org/ForwardDiff.jl/stable/user/api.html).
# * The Jacobian function is a crucial component of a dynamical system, and that is why if
# it is not given, it is computed automatically.
#
#
#
# Even though the automatic computation is very efficient, the best possible performance
# will come if you pass a "hard-coded" jacobian:
# ------------------------------------------------------------------------------------------

h_jacobian(x, p, t) = @SMatrix [-2*p[1]*x[1] 1.0; p[2] 0.0]

# ------------------------------------------------------------------------------------------
# * Notice that for **out-of-place** systems, the Jacobian must also have the same form as
# the equations of motion, namely to return an `SMatrix`.
#
# Now, we can pass this Jacobian function to the `DiscreteDynamicalSystem` constructor as a
# 4th argument:
# ------------------------------------------------------------------------------------------

henon_with_jac = DiscreteDynamicalSystem(h_eom, state, p, h_jacobian)

# ------------------------------------------------------------------------------------------
# To see the difference in performance, let's call this Jacobian function
# ------------------------------------------------------------------------------------------

using BenchmarkTools
a = rand(SVector{2})
@btime $(henon_with_jac.jacobian)($a, $henon.prob.p, 0);
@btime $(henon.jacobian)($a, $henon.prob.p, 0);

# ------------------------------------------------------------------------------------------
# You can see that even though `ForwardDiff` is truly performant, the hard-coded version is
# much faster.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Continuous System
# * The process of creating a continuous system is identical to that of a discrete system,
# except that the constructor `ContinuousDynamicalSystem` is used instead.
# * In this case the function `eom` returns the time derivatives and not a "next state".
#
#
# ---
#
#
#
# * We will take the opportunity to show the process of using in-place equations of motion
# for a continuous system, which is aimed to be used for large systems (dimensionality $\ge$
# 10).
#
# * In addition, the system we will use (Henon-Heiles) does not have any parameters.
# $$
# \begin{aligned}
# \dot{x} &= p_x \\
# \dot{y} &= p_y \\
# \dot{p}_x &= -x -2 xy \\
# \dot{p}_y &= -y - (x^2 - y^2)
# \end{aligned}
# $$
# ------------------------------------------------------------------------------------------

# Henon-heiles famous system
# in-place form of equations of motion
# du is the derivatives vector, u is the state vector
function hheom!(du, u, p, t)
    du[1] = u[3]
    du[2] = u[4]
    du[3] = -u[1] - 2u[1]*u[2]
    du[4] = -u[2] - (u[1]^2 - u[2]^2)
    return nothing
end

# pass `nothing` as the parameters, because the system doesn't have any
hh = ContinuousDynamicalSystem(hheom!, [0, -0.25, 0.42081, 0], nothing)

# ------------------------------------------------------------------------------------------
# Great, now we can get a trajectory of this system, by solving using
# DifferentialEquations.jl
# ------------------------------------------------------------------------------------------

tr = trajectory(hh, 100.0, dt = 0.05)

figure(figsize = (6,4))
plot(tr[:, 1], tr[:, 2]);
xlabel("\$q_1\$"); ylabel("\$q_2\$");

# ------------------------------------------------------------------------------------------
# # Handy Dandy definition table
#
# Depending on whether your system is small or large, you want to use out-of-place or in-
# place equations of motion. The Jacobian function (if you wish to provide it) must also be
# of the same form.
#
# Here is a handy table that summarizes what the definitions should look like:
#
# |          System Type         |    equations of motion    |            Jacobian
# |
# |:----------------------------:|:-------------------------:|:-----------------------------
# -:|
# | in-place (big systems)       | `eom!(du, u, p, t)`       | `jacobian!(J, u, p, t)`
# |
# | out-of-place (small systems) | `eom(u, p, t) -> SVector` | `jacobian(u, p, t) ->
# SMatrix` |
# 
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Time-evolution of systems & DifferentialEquations.jl
# Discrete systems are evolved using internal algorithms. However, all time evolution of
# continuous systems is done through the
# [DifferentialEquations.jl](http://docs.juliadiffeq.org/latest/) library. In fact,
# `trajectory` for continuous systems simply wraps `solve` with some extra arguments.
#
# Keep in mind that by default all continuous systems are evolved using the solver `Vern9()`
# (9th order Verner solver) with tolerances `abstol = reltol = 1e-9`. This is especially
# important when one wants to compare benchmarks with different packages.
#
# It is almost certain that if you use **DynamicalSystems.jl** you want to use also
# DifferentialEquations.jl, due to the huge list of available features.
#
#
# ## When to use **DynamicalSystems.jl**?
# At this point in the tutorial you might be thinking:
# > How is DynamicalSystems.jl different from DifferentialEquations.jl? Seems the same to me
# so far...
#
# That's because we haven't seen any special features of **DynamicalSystems.jl** yet!
# `trajectory` is nothing more than a "convenient shortcut".
#
# The [contents page](https://juliadynamics.github.io/DynamicalSystems.jl/latest/#contents)
# of the documentation does a good job describing what is possible through
# **DynamicalSystems.jl**.
#
# In addition, for usage with DifferentialEquations.jl, we can create specialized
# integrators that evolve the system and the tangent space, or many states of the system in
# parallel (at *exactly* same times):
# * `tangent_integrator`
# * `parallel_integrator`
#
# These functions work for both continuous and discrete systems and also work regardless of
# whether the system is in-place (large), out-of-place (small) or auto-differentiated.
# Special attention has also been given to the performance of the integrators.
#
# Also, keep in mind that regardless of whether you use a `DynamicalSystem` to produce a
# timeseries or not, more than half of the **DynamicalSystems.jl** library is using
# numerical data as an input. Most of the time this numerical data is expected in the form
# of an `AbstractDataset` instance, which is what `trajectory` returns.
#
# ## Using DifferentialEquations.jl from a `DynamicalSystem`
#
# It is *very* likely that other features of DifferentialEquations.jl will be useful to
# someone using **DynamicalSystems.jl**. However, you can still use DifferentialEquations.jl
# *after* you have defined a continuous dynamical system, because the field `prob` gives an
# `ODEProblem`:
# ------------------------------------------------------------------------------------------

hh.prob

# ------------------------------------------------------------------------------------------
# * **please be careful when using this problem directly, because as you can see the
# `tspan[end]` field is `Inf`!!!**
#
#
# * One final comment: using Callbacks is *not* possible with **DynamicalSystems.jl**,
# because the the equations of motion function has to be assumed differentiable
# "everywhere".
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Docstrings
# ------------------------------------------------------------------------------------------

?DynamicalSystem

?trajectory

?Dataset
