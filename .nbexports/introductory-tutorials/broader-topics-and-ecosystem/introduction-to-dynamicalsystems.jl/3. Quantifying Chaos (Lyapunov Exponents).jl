# ------------------------------------------------------------------------------------------
# # Quantifying Chaos for a Dynamical System
#
# Topics:
# * Introduction to Lyapunov exponents
# * Maximum Lyapunov Exponent
# * Lyapunov Spectrum
#
# **WARNING** - Compilation of functions in this tutorial takes *a lot of time*.
#
# ---
#
# In the previous tutorial we saw that for example the Shinriki oscillator showed something
# that "could be chaotic behavior" for a specific parameter value. How can we quantify that?
#
# # Lyapunov exponents
# * Lyapunov exponents measure the exponential separation rate of trajectories that are
# (initially) close.
#     * Consider the following picture, where two nearby trajectories are evolved in time:
#
#
#
# <img src="lyapunov.png" alt="Sketch of the Lyapunov exponent" style="width: 500px;"/>
#
#
# * $\lambda$ denotes the "maximum Lyapunov exponent".
# * A $D$-dimensional system has $D$ exponents.
# * In general, a trajectory is called "chaotic" if
#     1. it follows nonlinear dynamics
#     2. it is *bounded* (does not escape to infinity)
#     2. it has a positive Lyapunov exponent
#
# *(please be aware that the above is an over-simplification! See the textbooks cited in our
# documentation for more)*
#
# ---
# ------------------------------------------------------------------------------------------

using DynamicalSystems, BenchmarkTools, PyPlot

# ------------------------------------------------------------------------------------------
# Before computing Lyapunov exponents, we'll demonstrate the concept of exponential
# separation using a simple map: the *towel map*
#
# $$
# \begin{aligned}
# x_{n+1} &= a x_n (1-x_n) -0.05 (y_n +0.35) (1-2z_n) \\
# y_{n+1} &= 0.1 \left( \left( y_n +0.35 \right)\left( 1+2z_n\right) -1 \right)
# \left( 1 -1.9 x_n \right) \\
# z_{n+1} &= 3.78 z_n (1-z_n) + b y_n
# \end{aligned}
# $$
# ------------------------------------------------------------------------------------------

towel = Systems.towel()

# ------------------------------------------------------------------------------------------
# First we'll generate a trajectory for the towel map, `tr1`, from the default initial
# condition,
# ------------------------------------------------------------------------------------------

tr1 = trajectory(towel, 100)
summary(tr1)

# ------------------------------------------------------------------------------------------
# and then we will generate a second trajectory, `tr2`, with a starting point slightly
# shifted from the initial condition of `tr1`.
# ------------------------------------------------------------------------------------------

u2 = get_state(towel) + (1e-9 * rand(3))
tr2 = trajectory(towel, 100, u2)
summary(tr2)

figure(figsize=(8,5))

# Plot the x-coordinate of the two trajectories:
ax1 = subplot(2,1,1)
plot(tr1[:, 1], alpha = 0.5)
plot(tr2[:, 1], alpha = 0.5)
ylabel("x")

# Plot their distance in a semilog plot:
ax2 = subplot(2,1,2, sharex = ax1)
d = [norm(tr1[i] - tr2[i]) for i in 1:length(tr2)]
ylabel("d")
xlabel("n")
semilogy(d);

# ------------------------------------------------------------------------------------------
# # Maximum Lyapunov Exponent
# `lyapunov` is a function that calculates the maximum Lyapunov exponent for a
# `DynamicalSystem` (for a given starting point).
#
# Since `lyapunov` is not a trivial function, it is best to read the documentation string
# first:
# ------------------------------------------------------------------------------------------

?lyapunov

# ------------------------------------------------------------------------------------------
# ---
#
# Let's apply this to the example of the previous section, the Shinriki oscillator!
#
# *Reminder:* we found something that "could" be chaotic behavior for the parameter `R1 =
# 21.0`
# 
# ------------------------------------------------------------------------------------------

shi = Systems.shinriki(;R1 = 21.0)

lyapunov(shi, 1000.0, Ttr = 10.0)

# ------------------------------------------------------------------------------------------
# Positive Lyapunov exponent!?!? That is definitely chaotic behavior, right?
#
# *Right?*
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's increase accuracy of computation, as well as the transient time, to see whether an
# orbit actually enters a limit cycle.
# ------------------------------------------------------------------------------------------

lyapunov(shi, 2000.0, Ttr = 1000.0)

# ------------------------------------------------------------------------------------------
# **surprise**
#
# Let's find out whats going on!
#
# To see why the lyapunov exponent was positive in one case and negative in another, we can
# produce a more detailed orbit diagram, around the "critical" value of `R = 21.0`.
# ------------------------------------------------------------------------------------------

pvalues = linspace(20.9,21.1,101)
i = 1
plane = (2, 0.0)
tf = 1000.0
p_index = 1

# use extremely long transient time:
output = produce_orbitdiagram(shi, plane, i, p_index, pvalues; tfinal = tf,
                              Ttr = 2000.0, direction = -1, printparams = false);
length(output)

using PyPlot
figure(figsize=(6,4))
for (j, p) in enumerate(pvalues)
    plot(p .* ones(output[j]), output[j], lw = 0,
    marker = "o", ms = 0.2, color = "black")
end
plot([21, 21], [-2.1, 0.1], color = "red", alpha = 0.55)
xlabel("\$R_1\$"); ylabel("\$V_1\$");

# result of orbit diagram at R1 = 21.0
values = output[51] 

# Amount of unique points
un = unique(round.(output[51], 8))
println("Total: $(length(output[51])), unique: $(length(un))")

# ------------------------------------------------------------------------------------------
# ## `lyapunov` for discrete system
#
# * All functions that accept a `DynamicalSystem` work with *any* instance of
# `DynamicalSystem`, regardless of whether it is continuous, discrete, in-place, out-of-
# place or whatever.
# 
# ------------------------------------------------------------------------------------------

# Get the Henon map from the library of pre-defined systems:
hen = Systems.henon()
λ = lyapunov(hen, 10000)

# ------------------------------------------------------------------------------------------
# ---
#
# # Lyapunov Spectrum
#
# Besides the maximum Laypunov exponent, the function `lyapunovs` (with `s` at the end)
# returns the entire Lyapunov spectrum (or as many exponents the user wants).
#
#
#
# Once again, because the function `lyapunovs` is not trivial, we will view the
# documentation string first:
# ------------------------------------------------------------------------------------------

?lyapunovs

# ------------------------------------------------------------------------------------------
# ### Lyapunovs for discrete systems
#
# In our first example of calling `lyapunovs`, let's pass a discrete system.
# ------------------------------------------------------------------------------------------

towel = Systems.towel()
lyapunovs(towel, 2000; Ttr = 200)

# ------------------------------------------------------------------------------------------
# Here we're choosing to compute only the first two exponents.
# ------------------------------------------------------------------------------------------

lyapunovs(towel, 2000, 2; Ttr = 200)

# ------------------------------------------------------------------------------------------
# If you only want the first exponent (maximum), use the `lyapunov` function instead
# ------------------------------------------------------------------------------------------

lyapunov(towel, 2000; Ttr = 200)

# ------------------------------------------------------------------------------------------
# How much time does this take?
# ------------------------------------------------------------------------------------------

using BenchmarkTools
@btime lyapunovs($towel, 2000; Ttr = 200);

@btime lyapunov($towel, 2000; Ttr = 200);

# ------------------------------------------------------------------------------------------
# ### Lyapunov exponents for continuous systems
#
# Next, let's initialize the Lorenz system with random initial condition
# ------------------------------------------------------------------------------------------

lor = Systems.lorenz()

# ------------------------------------------------------------------------------------------
# We'll compute the Lyapunov spectrum with specified initial parallepiped matrix `Q0`:
# ------------------------------------------------------------------------------------------

Q0 = eye(3)
lyapunovs(lor, 2000, Q0; Ttr = 10.0)

# ------------------------------------------------------------------------------------------
# And we find that results "converge" already with 2000 iterations:
# ------------------------------------------------------------------------------------------

lyapunovs(lor, 3000, Q0; Ttr = 10.0)

# ------------------------------------------------------------------------------------------
# * Even the continuous systems are quite performant (note that compilation takes a **lot**
# of time):
# ------------------------------------------------------------------------------------------

@btime lyapunovs($lor, 2000, $Q0; Ttr = 10.0);

# ------------------------------------------------------------------------------------------
# * The above integration is done with a 9th order solver and tolerances of `1e-9`. But you
# can get away with lower tolerances.
#
# Let's load in `OrdinaryDiffEq` and specify keyword arguments for the integrators of
# DifferentialEquations.jl.
# ------------------------------------------------------------------------------------------

using OrdinaryDiffEq
 
dek = Dict(:solver => Tsit5(), :abstol => 1e-6, :reltol => 1e-6)

# ------------------------------------------------------------------------------------------
# And now we can call `lyapunovs` with the keyword `diff_eq_kwargs`
# ------------------------------------------------------------------------------------------

lyapunovs(lor, 2000, Q0; Ttr = 10.0, diff_eq_kwargs = dek)

@btime lyapunovs($lor, 2000.0, $Q0; Ttr = 10.0, diff_eq_kwargs = $dek);
