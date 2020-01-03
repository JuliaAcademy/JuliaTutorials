# ------------------------------------------------------------------------------------------
# # Callbacks and Events
#
# In working with a differential equation, our system will evolve through many states.
# Particular states of the system may be of interest to us, and we say that an ***"event"***
# is triggered when our system reaches these states. For example, events may include the
# moment when our system reaches a particular temperature or velocity. We ***handle*** these
# events with ***callbacks***, which tell us what to do once an event has been triggered.
#
# These callbacks allow for a lot more than event handling, however. For example, we can use
# callbacks to achieve high-level behavior like exactly preserve conservation laws and save
# the trace of a matrix at pre-defined time points. This extra functionality allows us to
# use the callback system as a modding system for the DiffEq ecosystem's solvers.
#
# This tutorial is an introduction to the callback and event handling system in
# DifferentialEquations.jl, documented in the [Event Handling and Callback
# Functions](http://docs.juliadiffeq.org/latest/features/callback_functions.html) page of
# the documentation. We will also introduce you to some of the most widely used callbacks in
# the [Callback Library](http://docs.juliadiffeq.org/latest/features/callback_library.html),
# which is a library of pre-built mods.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Events and Continuous Callbacks
#
# Event handling is done through continuous callbacks. Callbacks take a function,
# `condition`, which triggers an `affect!` when `condition == 0`. These callbacks are called
# "continuous" because they will utilize rootfinding on the interpolation to find the
# "exact" time point at which the condition takes place and apply the `affect!` at that time
# point.
#
# ***Let's use a bouncing ball as a simple system to explain events and callbacks.*** Let's
# take Newton's model of a ball falling towards the Earth's surface via a gravitational
# constant `g`. In this case, the velocity is changing via `-g`, and position is changing
# via the velocity. Therefore we receive the system of ODEs:
# ------------------------------------------------------------------------------------------

using DifferentialEquations
ball! = @ode_def BallBounce begin
  dy =  v
  dv = -g
end g

# ------------------------------------------------------------------------------------------
# We want the callback to trigger when `y=0` since that's when the ball will hit the Earth's
# surface -- our event. We do this with the condition:
# ------------------------------------------------------------------------------------------

function condition(u,t,integrator) # Event when event_f(u,t) == 0
  u[1]
end

# ------------------------------------------------------------------------------------------
# Recall that the `condition` will trigger when it evaluates to zero, and here it will
# evaluate to zero when `u[1] == 0`, which occurs when `v == 0`. *Now we have to say what we
# want the callback to do.* Callbacks make use of the [Integrator
# Interface](http://docs.juliadiffeq.org/latest/basics/integrator.html). Instead of giving a
# full description, a quick and usable rundown is:
#
# - Values are strored in `integrator.u`
# - Times are stored in `integrator.t`
# - The parameters are stored in `integrator.p`
# - `integrator(t)` performs an interpolation in the current interval between
# `integrator.tprev` and `integrator.t` (and allows extrapolation)
# - User-defined options (tolerances, etc.) are stored in `integrator.opts`
# - `integrator.sol` is the current solution object. Note that `integrator.sol.prob` is the
# current problem
#
# While there's a lot more on the integrator interface page, that's a working knowledge of
# what's there.
#
# What we want to do with our `affect!` is to "make the ball bounce". Mathematically
# speaking, the ball bounces when the sign of the velocity flips. As an added behavior,
# let's also use a small friction constant to dampen the ball's velocity. This way only a
# percentage of the velocity will be retained when the event is triggered and the callback
# is used.  We'll define this behavior in the `affect!` function:
# ------------------------------------------------------------------------------------------

function affect!(integrator)
    integrator.u[2] = -integrator.p[2] * integrator.u[2]
end

# ------------------------------------------------------------------------------------------
# `integrator.u[2]` is the second value of our model, which is `v` or velocity, and
# `integrator.p[2]`, is our friction coefficient.
#
# Therefore `affect!` can be read as follows: `affect!` will take the current value of
# velocity, and multiply it `-1` multiplied by our friction coefficient. Therefore the ball
# will change direction and its velocity will dampen when `affect!` is called.
#
# Now let's build the `ContinuousCallback`:
# ------------------------------------------------------------------------------------------

bounce_cb = ContinuousCallback(condition,affect!)

# ------------------------------------------------------------------------------------------
# Now let's make an `ODEProblem` which has our callback:
# ------------------------------------------------------------------------------------------

u0 = [50.0,0.0]
tspan = (0.0,15.0)
p = (9.8,0.9)
prob = ODEProblem(ball!,u0,tspan,p,callback=bounce_cb)

# ------------------------------------------------------------------------------------------
# Notice that we chose a friction constant of `0.9`. Now we can solve the problem and plot
# the solution as we normally would:
# ------------------------------------------------------------------------------------------

sol = solve(prob,Tsit5())
using Plots; gr()
plot(sol)

# ------------------------------------------------------------------------------------------
# and tada, the ball bounces! Notice that the `ContinuousCallback` is using the
# interpolation to apply the effect "exactly" when `v == 0`. This is crucial for model
# correctness, and thus when this property is needed a `ContinuousCallback` should be used.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Exercise 1
#
# In our example we used a constant coefficient of friction, but if we are bouncing the ball
# in the same place we may be smoothing the surface (say, squishing the grass), causing
# there to be less friction after each bounce. In this more advanced model, we want the
# friction coefficient at the next bounce to be `sqrt(friction)` from the previous bounce
# (since `friction < 1`, `sqrt(friction) > friction` and `sqrt(friction) < 1`).
#
# Hint: there are many ways to implement this. One way to do it is to make `p` a `Vector`
# and mutate the friction coefficient in the `affect!`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Discrete Callbacks
#
# A discrete callback checks a `condition` after every integration step and, if true, it
# will apply an `affect!`. For example, let's say that at time `t=2` we want to include that
# a kid kicked the ball, adding `20` to the current velocity. This kind of situation, where
# we want to add a specific behavior which does not require rootfinding, is a good candidate
# for a `DiscreteCallback`. In this case, the `condition` is a boolean for whether to apply
# the `affect!`, so:
# ------------------------------------------------------------------------------------------

function condition_kick(u,t,integrator)
    t == 2
end

# ------------------------------------------------------------------------------------------
# We want the kick to occur at `t=2`, so we check for that time point. When we are at this
# time point, we want to do:
# ------------------------------------------------------------------------------------------

function affect_kick!(integrator)
    integrator.u[2] += 50
end

# ------------------------------------------------------------------------------------------
# Now we build the problem as before:
# ------------------------------------------------------------------------------------------

kick_cb = DiscreteCallback(condition_kick,affect_kick!)
u0 = [50.0,0.0]
tspan = (0.0,10.0)
p = (9.8,0.9)
prob = ODEProblem(ball!,u0,tspan,p,callback=kick_cb)

# ------------------------------------------------------------------------------------------
# Note that, since we are requiring our effect at exactly the time `t=2`, we need to tell
# the integration scheme to step at exactly `t=2` to apply this callback. This is done via
# the option `tstops`, which is like `saveat` but means "stop at these values".
# ------------------------------------------------------------------------------------------

sol = solve(prob,Tsit5(),tstops=[2.0])
plot(sol)

# ------------------------------------------------------------------------------------------
# Note that this example could've been done with a `ContinuousCallback` by checking the
# condition `t-2`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Merging Callbacks with Callback Sets
#
# In some cases you may want to merge callbacks to build up more complex behavior. In our
# previous result, notice that the model is unphysical because the ball goes below zero!
# What we really need to do is add the bounce callback together with the kick. This can be
# achieved through the `CallbackSet`.
# ------------------------------------------------------------------------------------------

cb = CallbackSet(bounce_cb,kick_cb)

# ------------------------------------------------------------------------------------------
# A `CallbackSet` merges their behavior together. The logic is as follows. In a given
# interval, if there are multiple continuous callbacks that would trigger, only the one that
# triggers at the earliest time is used. The time is pulled back to where that continuous
# callback is triggered, and then the `DiscreteCallback`s in the callback set are called in
# order.
# ------------------------------------------------------------------------------------------

u0 = [50.0,0.0]
tspan = (0.0,15.0)
p = (9.8,0.9)
prob = ODEProblem(ball!,u0,tspan,p,callback=cb)
sol = solve(prob,Tsit5(),tstops=[2.0])
plot(sol)

# ------------------------------------------------------------------------------------------
# Notice that we have now merged the behaviors. We can then nest this as deep as we like.
#
# #### Exercise 2
#
# Add to the model a linear wind with resistance that changes the acceleration to `-g + k*v`
# after `t=10`. Do so by adding another parameter and allowing it to be zero until a
# specific time point where a third callback triggers the change.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Integration Termination and Directional Handling
#
# Let's look at another model now -- the model of the [Harmonic
# Oscillator](https://en.wikipedia.org/wiki/Harmonic_oscillator). We can write this as:
# ------------------------------------------------------------------------------------------

u0 = [1.,0.]
harmonic! = @ode_def HarmonicOscillator begin
   dv = -x
   dx = v
end
tspan = (0.0,10.0)
prob = ODEProblem(harmonic!,u0,tspan)
sol = solve(prob)
plot(sol)

# ------------------------------------------------------------------------------------------
# Let's instead stop the integration when a condition is met. From the [Integrator Interface
# stepping controls](http://docs.juliadiffeq.org/latest/basics/integrator.html#Stepping-
# Controls-1) we see that `terminate!(integrator)` will cause the integration to end. So our
# new `affect!` is simply:
# ------------------------------------------------------------------------------------------

function terminate_affect!(integrator)
    terminate!(integrator)
end

# ------------------------------------------------------------------------------------------
# Let's first stop the integration when the particle moves back to `x=0`. This means we want
# to use the condition:
# ------------------------------------------------------------------------------------------

function terminate_condition(u,t,integrator)
    u[2]
end
terminate_cb = ContinuousCallback(terminate_condition,terminate_affect!)

# ------------------------------------------------------------------------------------------
# Note that instead of adding callbacks to the problem, we can also add them to the `solve`
# command. This will automatically form a `CallbackSet` with any problem-related callbacks
# and naturally allows you to distinguish between model features and integration controls.
# ------------------------------------------------------------------------------------------

sol = solve(prob,callback=terminate_cb)
plot(sol)

# ------------------------------------------------------------------------------------------
# Notice that the harmonic oscilator's true solution here is `sin` and `cosine`, and thus we
# would expect this return to zero to happen at `t=π`:
# ------------------------------------------------------------------------------------------

sol.t[end]

# ------------------------------------------------------------------------------------------
# This is one way to approximate π! Lower tolerances and arbitrary precision numbers can
# make this more exact, but let's not look at that. Instead, what if we wanted to halt the
# integration after exactly one cycle? To do so we would need to ignore the first zero-
# crossing. Luckily in these types of scenarios there's usually a structure to the problem
# that can be exploited. Here, we only want to trigger the `affect!` when crossing from
# positive to negative, and not when crossing from negative to positive. In other words, we
# want our `affect!` to only occur on upcrossings.
#
# If the `ContinuousCallback` constructor is given a single `affect!`, it will occur on both
# upcrossings and downcrossings. If there are two `affect!`s given, then the first is for
# upcrossings and the second is for downcrossings. An `affect!` can be ignored by using
# `nothing`. Together, the "upcrossing-only" version of the effect means that the first
# `affect!` is what we defined above and the second is `nothing`. Therefore we want:
# ------------------------------------------------------------------------------------------

terminate_upcrossing_cb = ContinuousCallback(terminate_condition,terminate_affect!,nothing)

# ------------------------------------------------------------------------------------------
# Which gives us:
# ------------------------------------------------------------------------------------------

sol = solve(prob,callback=terminate_upcrossing_cb)
plot(sol)

# ------------------------------------------------------------------------------------------
# ## Callback Library
#
# As you can see, callbacks can be very useful and through `CallbackSets` we can merge
# together various behaviors. Because of this utility, there is a library of pre-built
# callbacks known as the [Callback
# Library](http://docs.juliadiffeq.org/latest/features/callback_library.html). We will walk
# through a few examples where these callbacks can come in handy.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Manifold Projection
#
# One callback is the manifold projection callback. Essentially, you can define any manifold
# `g(sol)=0` which the solution must live on, and cause the integration to project to that
# manifold after every step. As an example, let's see what happens if we naively run the
# harmonic oscillator for a long time:
# ------------------------------------------------------------------------------------------

tspan = (0.0,10000.0)
prob = ODEProblem(harmonic!,u0,tspan)
sol = solve(prob)
gr(fmt=:png) # Make it a PNG instead of an SVG since there's a lot of points!
plot(sol,vars=(1,2))

plot(sol,vars=(0,1),denseplot=false)

# ------------------------------------------------------------------------------------------
# Notice that what's going on is that the numerical solution is drifting from the true
# solution over this long time scale. This is because the integrator is not conserving
# energy.
# ------------------------------------------------------------------------------------------

plot(sol.t,[u[2]^2 + u[1]^2 for u in sol.u]) # Energy ~ x^2 + v^2

# ------------------------------------------------------------------------------------------
# Some integration techniques like [symplectic
# integrators](http://docs.juliadiffeq.org/latest/solvers/dynamical_solve.html#Symplectic-
# Integrators-1) are designed to mitigate this issue, but instead let's tackle the problem
# by enforcing conservation of energy. To do so, we define our manifold as the one where
# energy equals 1 (since that holds in the initial condition), that is:
# ------------------------------------------------------------------------------------------

function g(resid,u,p,t)
  resid[1] = u[2]^2 + u[1]^2 - 1
  resid[2] = 0
end

# ------------------------------------------------------------------------------------------
# Here the residual measures how far from our desired energy we are, and the number of
# conditions matches the size of our system (we ignored the second one by making the
# residual 0). Thus we define a `ManifoldProjection` callback and add that to the solver:
# ------------------------------------------------------------------------------------------

cb = ManifoldProjection(g)
sol = solve(prob,callback=cb)
plot(sol,vars=(1,2))

plot(sol,vars=(0,1),denseplot=false)

# ------------------------------------------------------------------------------------------
# Now we have "perfect" energy conservation, where if it's ever violated too much the
# solution will get projected back to `energy=1`.
# ------------------------------------------------------------------------------------------

u1,u2 = sol[500]
u2^2 + u1^2

# ------------------------------------------------------------------------------------------
# While choosing different integration schemes and using lower tolerances can achieve this
# effect as well, this can be a nice way to enforce physical constraints and is thus used in
# many disciplines like molecular dynamics. Another such domain constraining callback is the
# [`PositiveCallback()`](http://docs.juliadiffeq.org/latest/features/callback_library.html#P
# ositiveDomain-1) which can be used to enforce positivity of the variables.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### SavingCallback
#
# The `SavingCallback` can be used to allow for special saving behavior. Let's take a linear
# ODE define on a system of 1000x1000 matrices:
# ------------------------------------------------------------------------------------------

prob = ODEProblem((du,u,p,t)->du.=u,rand(1000,1000),(0.0,1.0))

# ------------------------------------------------------------------------------------------
# In fields like quantum mechanics you may only want to know specific properties of the
# solution such as the trace or the norm of the matrix. Saving all of the 1000x1000 matrices
# can be a costly way to get this information! Instead, we can use the `SavingCallback` to
# save the `trace` and `norm` at specified times. To do so, we first define our
# `SavedValues` cache. Our time is in terms of `Float64`, and we want to save tuples of
# `Float64`s (one for the `trace` and one for the `norm`), and thus we generate the cache
# as:
# ------------------------------------------------------------------------------------------

saved_values = SavedValues(Float64, Tuple{Float64,Float64})

# ------------------------------------------------------------------------------------------
# Now we define the `SavingCallback` by giving it a function of `(u,p,t,integrator)` that
# returns the values to save, and the cache:
# ------------------------------------------------------------------------------------------

cb = SavingCallback((u,t,integrator)->(trace(u),norm(u)), saved_values)

# ------------------------------------------------------------------------------------------
# Here we take `u` and save `(trace(u),norm(u))`. When we solve with this callback:
# ------------------------------------------------------------------------------------------

sol = solve(prob, Tsit5(), callback=cb, save_everystep=false, save_start=false, save_end = false) # Turn off normal saving

# ------------------------------------------------------------------------------------------
# Our values are stored in our `saved_values` variable:
# ------------------------------------------------------------------------------------------

saved_values.t

saved_values.saveval

# ------------------------------------------------------------------------------------------
# By default this happened only at the solver's steps. But the `SavingCallback` has similar
# controls as the integrator. For example, if we want to save at every `0.1` seconds, we do
# can so using `saveat`:
# ------------------------------------------------------------------------------------------

saved_values = SavedValues(Float64, Tuple{Float64,Float64}) # New cache
cb = SavingCallback((u,t,integrator)->(trace(u),norm(u)), saved_values, saveat = 0.0:0.1:1.0)
sol = solve(prob, Tsit5(), callback=cb, save_everystep=false, save_start=false, save_end = false) # Turn off normal saving

saved_values.t

saved_values.saveval

# ------------------------------------------------------------------------------------------
# #### Exercise 3
#
# Go back to the Harmonic oscillator. Use the `SavingCallback` to save an array for the
# energy over time, and do this both with and without the `ManifoldProjection`. Plot the
# results to see the difference the projection makes.
# ------------------------------------------------------------------------------------------
