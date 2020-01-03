# ------------------------------------------------------------------------------------------
# # Orbit Diagrams, Surfaces of Section
# In this tutorial we will be using a `DynamicalSystem` instance to visualize aspects of the
# system.
#
# Topics:
# * `orbitdiagram`
# * `poincaresos`
# * `produce_orbitdiagram`
# * Docstrings
#
# # Orbit Diagram
# An "orbit diagram" is simply a plot that shows the long term behavior of a discrete system
# when a parameter is varied.
#
# This is exactly what the function `orbitdiagram` does:
# 1. Evolves the system for a transient amount of time.
# 2. Evolves & saves the output of the system for a chosen variable.
# 3. Changes/increments a parameter of the equations of motion.
# 4. Repeat steps 1-3 for all given parameter values!
#
# This approach is also related with the (much more advanced) [sensitivity
# analysis](http://docs.juliadiffeq.org/latest/analysis/sensitivity.html) from
# DifferentialEquations.jl
#
# ---
#
# Let's make the super-ultra-famous orbit diagram of the logistic map:
#
# $$x_{n+1} = rx_n(1-x_n)$$
# ------------------------------------------------------------------------------------------

using DynamicalSystems, PyPlot

logimap = Systems.logistic() # Systems module contains pre-defined well-known systems

# ------------------------------------------------------------------------------------------
# ---
#
# The call signature of `orbitdiagram` is:
#
# ```julia
# orbitdiagram(discrete_system, i, p_index, pvalues; n, Ttr, ...)
# ```
# * `i` is the index of the variable we want to save.
# * `p_index` is the index of the parameter we want to change.
# * `pvalues` are the values of the parameter that will change.
# * Keywords `Ttr` and `n` denote for how much transient time to evolve the system and how
# many states to save.
# 
# ------------------------------------------------------------------------------------------

i = 1 # which variable to save (of course logistic map is 1D !)
n = 50 # how many values to save
Ttr = 5000 # transient iterations
p_index = 1
pvalues = 2:0.001:4  # parameter values
output = orbitdiagram(logimap, i, p_index, pvalues; n = n, Ttr = Ttr)
typeof(output)

# ------------------------------------------------------------------------------------------
# * The output is a vector of vectors. Each inner vector has length `n` and contains the
# values of the variable `i` at the given parameter value.
#
# Let's plot interactively!
# ------------------------------------------------------------------------------------------

function bf(pvalues, n, Ttr)
    logi = Systems.logistic()
    output = orbitdiagram(logi, 1, 1, pvalues; n = n, Ttr = Ttr)

    figure(figsize=(6,4))
    for (j, p) in enumerate(pvalues)
        plot(p .* ones(output[j]), output[j], linestyle = "None", # linestyle = None
        marker = "o", ms = 0.2, color = "black")
    end
    xlabel("\$r\$"); ylabel("\$x\$");
    xlim(pvalues[1], pvalues[end])
    # ylim(0, 1)
    return 
end

bf(linspace(2.0, 4.0, 1000), 200, 2000)

bf(linspace(3.5, 3.6, 1000), 200, 2000)

# ------------------------------------------------------------------------------------------
# We can use `BenchmarkTools` to see how much time it takes to generate this orbit diagram
# ------------------------------------------------------------------------------------------

using BenchmarkTools
@btime output = orbitdiagram($logimap, $i, $p_index, $pvalues; n = $n, Ttr = $Ttr);
println("for total points: $(length(pvalues)*(Ttr+n)), out of which $(length(pvalues)*n) are saved")

# ------------------------------------------------------------------------------------------
# ---
#
# * `orbitdiagram` works with *any* discrete system! Check out the [documentation
# page](https://juliadynamics.github.io/DynamicalSystems.jl/latest/chaos/orbitdiagram/) for
# more!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Poincaré Surface of Section
# This is a technique to reduce a continuous system into a discrete map with 1 fewer
# dimension.
# The wikipedia entry on [Poincaré map](https://en.wikipedia.org/wiki/Poincar%C3%A9_map) has
# a lot of useful info, but the technique itself is very simple:
#
# 1. Define a hyperplane in the phase-space of the system.
# 2. Evolve the continuous system for long times. Each time the trajectory crosses this
# plane, record the state of the system.
# 3. Only crossings with a specific `direction` (either positive or negative) are allowed.
#
# And that's it! The recorded crossings are the Poincaré Surface of Section!
#
# ## Defining a hyperplane
# Let's say that our phase-space is $D$ dimensional. If the state of the system is
# $\mathbf{u} = (u_1, \ldots, u_D)$ then the equation for a hyperplane is
#
# $$
# a_1u_1 + \dots + a_Du_D = \mathbf{a}\cdot\mathbf{u}=b
# $$
# where $\mathbf{a}, b$ are the parameters that define the hyperplane.
#
# ---
#
# Here is the call signature for a function that does this:
#
# ```julia
# poincaresos(continuous_system, plane, tfinal = 100.0; direction = 1, ...)
# ```
# In code, `plane` can be either:
#
# * A `Tuple{Int, <: Number}`, like `(j, r)` : the hyperplane is defined as when the `j`
# variable of the system crosses the value `r`.
# * An `AbstractVector` of length `D+1`. The first `D` elements of the vector correspond to
# $\mathbf{a}$ while the last element is $b$. The hyperplane is defined with its formal
# equation.
#
# ---
#
# As an example, let's see a section of the Lorenz system:
# $$
# \begin{aligned}
# \dot{X} &= \sigma(Y-X) \\
# \dot{Y} &= -XZ + \rho X -Y \\
# \dot{Z} &= XY - \beta Z
# \end{aligned}
# $$
# 
# ------------------------------------------------------------------------------------------

lor = Systems.lorenz()

tr = trajectory(lor, 100.0, dt = 0.01)
figure(figsize = (8,6))
plot3D(columns(tr)...);
xlabel("X"); ylabel("Y"); zlabel("Z");

psos = poincaresos(lor, (2, 0.0), 2000.0) # find where 2nd variable crosses 0.0

figure(figsize = (6,4))
plot(psos[:, 1], psos[:, 3], lw=0.0, marker ="o", ms = 1.0, color = "C1");
xlabel("X"); ylabel("Z");

# ------------------------------------------------------------------------------------------
# * We see that the surface of section is some kind of 1-dimensional object.
# * This is expected, because as we will show in the tutorial "Entropies & Dimensions" the
# Lorenz system (at least for the default parameters) lives in an almost 2-dimensional
# attractor.
#
# * This means that when you take a cut through this object, the result should be
# 1-dimensional!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# **Next, let's visualize the Poincaré Surface of Section in 3D**
# ------------------------------------------------------------------------------------------

"""
    meshgrid(x, y) -> X, Y
Create a meshgrid, such as that used in PyPlot's countour plots.
"""
function meshgrid(vx, vy)
    m, n = length(vy), length(vx)
    vx = reshape(vx, 1, n)
    vy = reshape(vy, m, 1)
    (repmat(vx, m, 1), repmat(vy, 1, n))
end

# ------------------------------------------------------------------------------------------
# We can get the attractor by calculating trajectories:
# ------------------------------------------------------------------------------------------

tr = trajectory(lor, 200.0, dt=0.01)
x, y, z = columns(tr);

# ------------------------------------------------------------------------------------------
# Next, let's make sure we can color points on our 3D plot based on where they are relative
# to a cut we'll make in the plot.
#
# To do this, we'll create a vector, `c`, that will store labels for the colors of all
# points:
# ------------------------------------------------------------------------------------------

c = Vector{String}(length(y))
for i in 1:length(y) # cut points: red
    if -0.1 < y[i] < 0.1
        c[i] = "C3"
    elseif y[i] < 0 
        c[i] = "C0" # in front of cut: blue
    else
        c[i] = "C2" # behind cut: green
    end
end

figure(figsize = (8,6))
# First let's plot the attractor
plot3D(x,y,z, color = "black", lw = 0.2, alpha = 0.25)
scatter3D(x, y, z, color = c, s = 5.0)

# And then plot the PSOS plane:
x = [-20, 20]; z = [0, 40]; 
X, Z = meshgrid(x, z)
Y = zeros(X)

plot_surface(X, Y, Z, alpha = 0.25, color = "C1");
xlabel("X"); ylabel("Y"); zlabel("Z");

# ------------------------------------------------------------------------------------------
# # Producing an orbit diagram
#
# 1. The `orbitdiagram` function does not make sense for continuous systems. In order for
# `orbitdiagram` to have meaning one must have a map.
#
# 2. We can take advantage of the `poincaresos` function, and reduce a continuous system to
# a map.
# 3. Then, we can formally calculate an orbit diagram for a continuous system!
#
# In this example I will use the Shinriki oscillator, which displays a period-doubling route
# to chaos like the logistic map!
# ------------------------------------------------------------------------------------------

shinriki_voltage(V) = 2.295e-5*(exp(3.0038*V) - exp(-3.0038*V))
function shinriki_eom(u, p, t)
    R1 = p[1]

    du1 = (1/0.01)*(
    u[1]*(1/6.9 - 1/R1) - shinriki_voltage(u[1] - u[2]) - (u[1] - u[2])/14.5
    )

    du2 = (1/0.1)*(
    shinriki_voltage(u[1] - u[2]) + (u[1] - u[2])/14.5 - u[3]
    )

    du3 = (1/0.32)*(-u[3]*0.1 + u[2])
    return SVector{3}(du1, du2, du3)
end

# Be sure to give a mutable container for the parameter container!
shi = ContinuousDynamicalSystem(shinriki_eom, [-2, 0, 0.2], [22.0])

# ------------------------------------------------------------------------------------------
# Now we can use `shi`, our dynamical system, to calculate trajectory steps and then plot
# the result.
# ------------------------------------------------------------------------------------------

set_parameter!(shi, 1, 20.0) # parameter from 19 to 22
tr = trajectory(shi, 2000.0)
figure(figsize = (8,6))
plot3D(columns(tr[1000:end, :])..., color = "C3", alpha = 0.5, marker = "o", ms = 0.5);

# ------------------------------------------------------------------------------------------
# To get a feeling for the system, let's look at a couple `poicaresos`
# ------------------------------------------------------------------------------------------

figure(figsize=(8,4))
subplot(1,2,1)
# the function set_parameter! is useful here! (see docstring!)
R1 = 19.5
set_parameter!(shi, 1, R1)

# here I use `direction = -1` (makes more sense for the specific system)
psos = poincaresos(shi, (2, 0.0), 1000.0, Ttr = 100.0, direction = -1)

plot(psos[:, 1], psos[:, 3], lw=0.0, marker ="o", ms = 2.0, color = "C3");
xlabel("\$V_1\$"); ylabel("\$I_3\$")
title("R1 = $R1")

R1 = 21.0
set_parameter!(shi, 1, R1)
subplot(1,2,2)
psos = poincaresos(shi, (2, 0.0), 1000.0, Ttr = 100.0, direction = -1)
plot(psos[:, 1], psos[:, 3], lw=0.0, marker ="o", ms = 2.0, color = "C3");
xlabel("\$V_1\$"); 
title("R1 = $R1");

# ------------------------------------------------------------------------------------------
# Hm, this is interesting!
# 1. For some parameters the motion is clearly periodic (due to the distinct number of
# points)
# 2. But at other parameters the motion ***seems to be*** on a 2-dimensional manifold.
#
# **Don't be too quick to judge the second as chaotic though! In the next tutorial
# "Quantifying Chaos" I will show you tools to quantify chaotic behavior!**
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ---
#
# * We would like to see the behavior of the system while varying the parameter, like an
# orbit diagram.
#
# * We can do this by performing successive surfaces of section and then recording the
# values of a chosen variable!
#
# This procedure is bundled in the very convenient function `produce_orbitdiagram`:
#
# ```julia
# produce_orbitdiagram(continuous_system, plane, i, p_index, pvalues; kwargs...)
# ```
#
# The function produces successive `poincaresos` for the `plane`, and records the values of
# the `i`-th variable at the section.
#
# Most other arguments are simply propagated to `poincaresos`.
#
# *Lets use this function for the Shinriki oscillator example:*
#
# First we can store our input arguments for `produce_orbitdiagram` in a few input vars.
# ------------------------------------------------------------------------------------------

pvalues = linspace(19,22,201) # which parameter values to use
p_index = 1 # which parameter to change

i = 1                  # record 1st variable
plane = (2, 0.0)       # find PSOS of 2nd variable when crossing zero
tf = 200.0             # argument passed to poincaresos

# ------------------------------------------------------------------------------------------
# Now we're ready to call `produce_orbitdiagram` and plot the result!
#
# (NOTE: This computation takes some seconds, since it makes 201 PSOS!)
# ------------------------------------------------------------------------------------------

output = produce_orbitdiagram(shi, plane, i, p_index, pvalues; 
                              # all keywords are passed to poincaresos:
                              tfinal = tf, Ttr = 200.0, direction = -1)

figure(figsize=(6,4))
for (j, p) in enumerate(pvalues)
    plot(p .* ones(output[j]), output[j], ls = "None",
    marker = "o", ms = 0.5, color = "black")
end
xlabel("\$R_1\$"); ylabel("\$V_1\$");

# ------------------------------------------------------------------------------------------
# ---
#
# ## Example with parameter-dependent plane
#
# Let's see one more case, using the Gissinger system:
#
# $$
# \begin{aligned}
# \dot{Q} &= \mu Q - VD \\
# \dot{D} &= -\nu D + VQ \\
# \dot{V} &= \Gamma -V + QD
# \end{aligned}
# $$
# 
# ------------------------------------------------------------------------------------------

gis = Systems.gissinger([2.32865, 2.02514, 1.98312]) # initial condition necessary to see structure

set_parameter!(gis, 1, 0.112) # parameter from 0.1 to 0.15
tr = trajectory(gis, 1000.0)
figure(figsize = (8,6))
plot3D(columns(tr)...);

pvalues = linspace(0.1,0.15,201) # which parameter values to use
p_index = 1 # change 2nd parameter, which is μ

i = 2            # record i variable
j = 1            # find PSOS of j variable
offset = -0.75   # offset is important here

tf = 5000.0 

output = produce_orbitdiagram(gis, (j, offset), i, p_index, pvalues; 
                              # all keywords are passed to poincaresos:
                              tfinal = tf, Ttr = 2000.0)

figure(figsize=(8,6))
for (j, p) in enumerate(pvalues)
    length(output[j]) == 0 && continue
    plot(p .* ones(output[j]), output[j], ls = "None",
    marker = "o", ms = 0.5, color = "black", alpha = 0.5)
end
ylim(1,3)
xlabel("\$\\mu\$"); ylabel("\$D\$");

# ------------------------------------------------------------------------------------------
# ---
#
# 1. The above is quite cool, but for this specific system, the "optimal" hyperplane to use
# depends on the parameter `μ`.
#
# 2. In addition, it is not "optimal" to record a specific variable during the crossing, but
# instead a function of the variables.
#
# 3. For this approach, it is better to get the entire `poincaresos`s for each parameter,
# like I show in the following example:
# ------------------------------------------------------------------------------------------

# Define appropriate hyperplane for gissinger system
const ν = 0.1
const Γ = 0.9 # default parameters of the system

# I want hyperperplane defined by these two points: 
Np(μ) = SVector{3}(sqrt(ν + Γ*sqrt(ν/μ)), -sqrt(μ + Γ*sqrt(μ/ν)), -sqrt(μ*ν))
Nm(μ) = SVector{3}(-sqrt(ν + Γ*sqrt(ν/μ)), sqrt(μ + Γ*sqrt(μ/ν)), -sqrt(μ*ν))

# Create hyperplane using normal vector to vector connecting points:
gis_plane(μ) = (d = (Np(μ) - Nm(μ)); [d[2], -d[1], 0, 0])

gis_plane(0.112)

μ = 0.12
set_parameter!(gis, 1, μ)
figure(figsize = (8,6))
psos = poincaresos(gis, gis_plane(μ), 2000.0, Ttr = 2000.0)
plot3D(columns(psos)..., marker = "o", ls = "None", ms = 2.0);

pvalues = linspace(0.1,0.14,201) # which parameter values to use

xs = Vector{Float64}[] # empty vector of vectors

for (i, μ) in enumerate(pvalues)
    set_parameter!(gis, 1, μ)
    N = Np(μ)
    psos = poincaresos(gis, gis_plane(μ), 4000.0, Ttr = 2000.0)
    push!(xs, [norm(N - k) for k in psos])
end


figure(figsize=(8,6))
for (j, p) in enumerate(pvalues)
    length(xs[j]) == 0 && continue
    plot(p .* ones(xs[j]), xs[j], ls = "None",
    marker = "o", ms = 0.2, color = "black", alpha = 0.5)
end
xlabel("\$\\mu\$"); ylabel("\$x\$");

figure(figsize=(8,6))
for (j, p) in enumerate(pvalues)
    length(xs[j]) == 0 && continue
    plot(p .* ones(xs[j]), xs[j], ls = "None",
    marker = "o", ms = 0.2, color = "black", alpha = 0.5)
end
ylim(2.7, 2.9)
xlabel("\$\\mu\$"); ylabel("\$x\$");

# ------------------------------------------------------------------------------------------
# # Docstrings
# ------------------------------------------------------------------------------------------

?orbitdiagram

?poincaresos

?produce_orbitdiagram
