# ------------------------------------------------------------------------------------------
# #  Choosing an ODE Algorithm
#
# While the default algorithms, along with `alg_hints = [:stiff]`, will suffice in most
# cases, there are times when you may need to exert more control. The purpose of this part
# of the tutorial is to introduce you to some of the most widely used algorithm choices and
# when they should be used. The corresponding page of the documentation is the [ODE
# Solvers](http://docs.juliadiffeq.org/latest/solvers/ode_solve.html) page which goes into
# more depth.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Diagnosing Stiffness
#
# One of the key things to know for algorithm choices is whether your problem is stiff.
# Let's take for example the driven Van Der Pol equation:
# ------------------------------------------------------------------------------------------

using DifferentialEquations
van! = @ode_def VanDerPol begin
  dy = μ*((1-x^2)*y - x)
  dx = 1*y
end μ

prob = ODEProblem(van!,[0.0,2.0],(0.0,6.3),1e6)

# ------------------------------------------------------------------------------------------
# One indicating factor that should alert you to the fact that this model may be stiff is
# the fact that the parameter is `1e6`: large parameters generally mean stiff models. If we
# try to solve this with the default method:
# ------------------------------------------------------------------------------------------

sol = solve(prob)

# ------------------------------------------------------------------------------------------
# Here it shows that maximum iterations were reached. Another thing that can happen is that
# the solution can return that the solver was unstable (exploded to infinity) or that `dt`
# became too small. If these happen, the first thing to do is to check that your model is
# correct. It could very well be that you made an error that causes the model to be
# unstable!
#
# If the model is the problem, then stiffness could be the reason. We can thus hint to the
# solver to use an appropriate method:
# ------------------------------------------------------------------------------------------

sol = solve(prob,alg_hints = [:stiff])

# ------------------------------------------------------------------------------------------
# Another way to understand stiffness is to look at the solution.
# ------------------------------------------------------------------------------------------

using Plots; gr()
sol = solve(prob,alg_hints = [:stiff],reltol=1e-6)
plot(sol,denseplot=false)

# ------------------------------------------------------------------------------------------
# Let's zoom in on the y-axis to see what's going on:
# ------------------------------------------------------------------------------------------

plot(sol,ylims = (-10.0,10.0))

# ------------------------------------------------------------------------------------------
# Notice how there are some extreme vertical shifts that occur. These vertical shifts are
# places where the derivative term is very large, and this is indicative of stiffness. This
# is an extreme example to highlight the behavior, but this general idea can be carried over
# to your problem. When in doubt, simply try timing using both a stiff solver and a non-
# stiff solver and see which is more efficient.
#
# To try this out, let's use BenchmarkTools, a package that let's us relatively reliably
# time code blocks.
# ------------------------------------------------------------------------------------------

using BenchmarkTools

# ------------------------------------------------------------------------------------------
# Let's compare the performance of non-stiff and stiff solvers on the Lorenz equation, which
# we saw in the last notebook, "ODEIntroduction".
#
# First, let's grab all our information about the Lorenz equation from the last notebook.
# ------------------------------------------------------------------------------------------

function lorenz!(du,u,p,t)
    σ,ρ,β = p
    du[1] = σ*(u[2]-u[1])
    du[2] = u[1]*(ρ-u[3]) - u[2]
    du[3] = u[1]*u[2] - β*u[3]    
end
u0 = [1.0,0.0,0.0]
p = (10,28,8/3)
tspan = (0.0,100.0)
prob = ODEProblem(lorenz!,u0,tspan,p)

# ------------------------------------------------------------------------------------------
# And now, let's use the `@btime` macro from benchmark tools to compare the use of non-stiff
# and stiff solvers on this problem.
# ------------------------------------------------------------------------------------------

@btime solve(prob);

@btime solve(prob,alg_hints = [:stiff]);

# ------------------------------------------------------------------------------------------
# In this particular case, we can see that non-stiff solvers get us to the solution much
# more quickly.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## The Recommended Methods
#
# When picking a method, the general rules are as follows:
#
# - Higher order is more efficient at lower tolerances, lower order is more efficient at
# higher tolerances
# - Adaptivity is essential in most real-world scenarios
# - Runge-Kutta methods do well with non-stiff equations, Rosenbrock methods do well with
# small stiff equations, BDF methods do well with large stiff equations
#
# While there are always exceptions to the rule, those are good guiding principles. Based on
# those, a simple way to choose methods is:
#
# - The default is `Tsit5()`, a non-stiff Runge-Kutta method of Order 5
# - If you use low tolerances (`1e-8`), try `Vern7()` or `Vern9()`
# - If you use high tolerances, try `BS3()`
# - If the problem is stiff, try `Rosenbrock23()`, `Rodas4()`, or `CVODE_BDF()`
#
# (This is a simplified version of the default algorithm chooser)
#
# ## Comparison to other Software
#
# If you are familiar with MATLAB, SciPy, or R's DESolve, here's a quick translation start
# to have transfer your knowledge over.
#
# - ode23 –> BS3()
# - ode45/dopri5 –> DP5(), though in most cases Tsit5() is more efficient
# - ode23s –> Rosenbrock23(), though in most cases Rodas4() is more efficient
# - ode113 –> CVODE_Adams(), though in many cases Vern7() is more efficient
# - dop853 –> DP8(), though in most cases Vern7() is more efficient
# - ode15s/vode –> CVODE_BDF(), though in many cases Rodas4() or radau() are more efficient
# - ode23t –> Trapezoid() for efficiency and GenericTrapezoid() for robustness
# - ode23tb –> TRBDF2
# - lsoda –> lsoda() (requires Pkg.add("LSODA"); using LSODA)
# - ode15i –> IDA(), though in many cases Rodas4() can handle the DAE and is significantly
# more efficient
# ------------------------------------------------------------------------------------------
