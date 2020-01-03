# ------------------------------------------------------------------------------------------
# # Timeseries Prediction
#
# ** EVERYTHING IN THIS TUTORIAL IS VERY NEW! CONSIDER IT ON AN ALPHA PHASE!**
#
# **APIs are likely to change!**
#
# **Examples shown in this tutorial are also in the repo
# `TimeseriesPrediction.jl/examples`**
#
# Topics:
#
# * Nature of prediction models of **DynamicalSystems.jl**
# * Local model prediction
# * Multi-variate local model Prediction
# * Spatio-temporal Timeseries Prediction
# * Docstrings
#
# ## Nature of prediction models
# Suppose you have a scalar or multi-variate timeseries and you want to predict its future
# behaviour.
#
# You can either take your *neural-network/machine-learning hammer* and lots of computing
# power **or** you can use methods from nonlinear dynamics and chaos.
#
# **DynamicalSystems.jl** follows the second approach. This road is not only surprisingly
# powerful, but also much, **much** simpler.
#
# ---
#
# # Local Model Prediction
#
# Local model prediction does something very simple: it makes a prediction of a state, by
# finding the future of similar (*neighboring*) states! Then it uses the predicted state as
# a new state from which other predictions can be made!
#
# Yeap, that simple.
#
# Let's see how well this method fares in a simple system, the Roessler system (3D &
# chaotic):
#
# $$
# \begin{aligned}
# \dot{x} &= -y-z \\
# \dot{y} &= x+ay \\
# \dot{z} &= b + z(x-c)
# \end{aligned}
# $$
# ------------------------------------------------------------------------------------------

using DynamicalSystems 

# This initial condition gives a good prediction:
u0_good = [0.065081, 0.917503, 0.300242]

ross = Systems.roessler(u0_good)

# ------------------------------------------------------------------------------------------
# Let's get a "measurement" from the roessler system
# ------------------------------------------------------------------------------------------

dt = 0.1 # sampling rate
tf = 1000.0 # final time
tr = trajectory(ross, tf; dt = dt)

# This is the measurement
s = tr[50:end, 2] # we skip the first points, they are transient
# This is the accompanying time vector:
timevec = collect(0:dt:tf)[50:end];

# ------------------------------------------------------------------------------------------
# How does this timeseries look?
# ------------------------------------------------------------------------------------------

using PyPlot; figure(figsize = (8,4))
plot(timevec, s, lw = 1.0);

# ------------------------------------------------------------------------------------------
# Please note: these are chaotic oscillations, the system is *not* periodic for the chosen
# (default) parameter values!
#
# Alright, so we have a recorded some timeseries of length:
# ------------------------------------------------------------------------------------------

length(s)

# ------------------------------------------------------------------------------------------
# And now we want to predict!
#
# Let's see the prediction function in action! The function to use is
# ```julia
# localmodel_tsp(s, D::Int, τ, p::Int; kwargs...)
# ```
# Here `s` is the timeseries to be predicted. `D, τ` are the values of the `Reconstruction`
# that has to be made from `s`. The last argument `p` is simply the amount of points to
# predict!
#
# The `Reconstruction` idea and functions were introduced in the tutorial "Delay Coordinates
# Embedding".
#
# This local model prediction method assumes that the system is on some kind of chaotic
# attractor. This is why it is crucial to reconstruct a signal before using the method!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Let's use only a first part of the timeseries as a "training set"
# ------------------------------------------------------------------------------------------

N = length(s)
N_train = 1000
s_train = s[1:N_train];

# ------------------------------------------------------------------------------------------
# and then use the rest of the timeseries to compare with the prediction
# ------------------------------------------------------------------------------------------

s_test = s[N_train+1:end];

# ------------------------------------------------------------------------------------------
# Here we define the parameters to make a prediction:
# ------------------------------------------------------------------------------------------

τ = 17
D = 3
p = 500

s_pred = localmodel_tsp(s_train, D, τ, p)
# prediction always includes last point of `s_train`

# ------------------------------------------------------------------------------------------
# Let's plot!
# ------------------------------------------------------------------------------------------

figure(figsize=(8,4))
past = 100
plot(timevec[N_train-past:N_train+1], s[N_train-past:N_train+1], color = "C1", label = "timeseries")
plot(timevec[N_train:N_train+p], s[N_train:N_train+p], color = "C3", label = "real future")
plot(timevec[N_train:N_train+p], s_pred, color = "C0", linestyle = "dashed", alpha = 0.5, label = "prediction")
legend(); xlabel("\$t\$"); ylabel("\$y\$")
println("Prediction of $(p) points from $(N_train) points. i.c.: $(get_state(ross))")

# ------------------------------------------------------------------------------------------
# Of course the prediction depends strongly on:
#
# * Choosing proper `Reconstruction` parameters
# * The initial condition
#
# How did I know that the value of `τ=17` was good?
# ------------------------------------------------------------------------------------------

estimate_delay(s, "first_zero")

# ------------------------------------------------------------------------------------------
# The function `localmodel_tsp` also accepts some keyword arguments which I did not discuss.
# These are:
#
#   * `method = AverageLocalModel(2)` : Subtype of [`AbstractLocalModel`](@ref).
#   * `ntype = FixedMassNeighborhood(2)` : Subtype of [`AbstractNeighborhood`](@ref).
#   * `stepsize = 1` : Prediction step size.
#
# We already know what does the `ntype` keyword does: it chooses a neighborhood type.
#
# The `method` keyword chooses the method of the local prediction. There are two methods,
# the `AverageLocalModel`, which we already used by default, as well as the
# `LinearLocalModel`. Their docstrings are at the end of this tutorial.
#
# Without explanations, their call signatures are:
# ```julia
# AverageLocalModel(n::Int)
# LinearLocalModel(n::Int, μ::Real)
# LinearLocalModel(n::Int, s_min::Real, s_max::Real)
# ```
# ------------------------------------------------------------------------------------------

using BenchmarkTools
@btime localmodel_tsp($s_train, $D, $τ, $p)
println("Time for predicting $(p) points from $(N_train) points.")

# ------------------------------------------------------------------------------------------
# Let's bundle all the production-prediction-plotting process into one function and play
# around!
# ------------------------------------------------------------------------------------------

function predict_roessler(N_train, p, method, u0 = rand(3); ntype = FixedMassNeighborhood(5))
    
    ds = Systems.roessler(u0)
    dt = 0.1
    tr = trajectory(ds, (N_train+p)÷dt; dt = dt)
    
    s = tr[:, 2] # actually, any of the 3 variables of the Roessler work well
    
    s_train = s[1:N_train]
    s_test = s[N_train+1:end]

    # parameters to predict:
    τ = 17
    D = 3

    s_pred = localmodel_tsp(s_train, D, τ, p; method = method, ntype = ntype)
    
    figure(figsize=(8,4))
    past = 100
    plot(timevec[N_train-past:N_train+1], s[N_train-past:N_train+1], color = "C1", label = "timeseries")
    plot(timevec[N_train:N_train+p], s[N_train:N_train+p], color = "C3", label = "real future")
    plot(timevec[N_train:N_train+p], s_pred, color = "C0", linestyle = "dashed", alpha = 0.5, label = "prediction")
    legend(); xlabel("\$t\$"); ylabel("\$y\$")   
    mprint = Base.datatype_name(typeof(method))
    println("N_train = $(N_train), p = $(p), method = $(mprint), u0 = $(u0)")
    return
end

predict_roessler(3000, 500, LinearLocalModel(2, 5.0))
# Linear Local model is slower than Average local model, and in general not that
# much more powerful.

# ------------------------------------------------------------------------------------------
# # Multi-Variate Prediction
#
# On purpose I was always referring to `s` as "timeseries". There is no reason for `s` to be
# scalar though, this prediction method works just as well when predicting multiple
# timeseries. And the call signature does not change at all!
#
# The following example demonstrates the prediction of the Lorenz96 model
#
# $$
# \frac{dx_i}{dt} = (x_{i+1}-x_{i-2})x_{i-1} - x_i + F
# $$
#
# a system that displays high-dimensional chaos and is thus very difficult to predict!
# ------------------------------------------------------------------------------------------

using DynamicalSystems, PyPlot

#Generate timeseries set
ds = Systems.lorenz96(5; F=8.)
ic = get_state(ds)
Δt = 0.05
s = trajectory(ds, 2100; dt=Δt)[:,1:2]

#Set Training and Test Set
N_train = 40000
p = 200
s_train = s[1:N_train,1:2]
s_test  = s[N_train:N_train+p,1:2]

#Embedding Parameters
D = 5; # total dimension of reconstruction is D*2 ! ! !
x = s[:, 1]
τ = estimate_delay(x, "first_zero")
println("Delay time estimation: $(τ)")

#Prediction
method = LinearLocalModel(2, 2.5)
method = AverageLocalModel(2)
ntype = FixedMassNeighborhood(5)
s_pred  = localmodel_tsp(s_train, D, τ, p; method = method, ntype = ntype)


figure(figsize=(12,4))
ax = subplot(121)
plot((N_train:N_train+p)*Δt, s_test[:,1], label="signal")
plot((N_train:N_train+p)*Δt, s_pred[:,1], label="prediction")
ylabel("\$x_1(n)\$")
xlabel("\$t\$")
legend()
ax = subplot(122)
plot((N_train:N_train+p)*Δt, s_test[:,2], label="signal")
plot((N_train:N_train+p)*Δt, s_pred[:,2], label="prediction")
ylabel("\$x_2(n)\$")
xlabel("\$t\$")
legend()
tight_layout();
println("Prediction p=$p of Lorenz96 Model (5 Nodes) from $N_train points")
println("i.c.: $ic")

# ------------------------------------------------------------------------------------------
# # Spatio Temporal Timeseries prediction
#
# Spatio-temporal systems are systems that depend on both space and time, i.e. *fields*
# (like Partial Differential Equations). These systems can also be predicted using these
# local model methods!
#
# In the following sections we will see 3 examples, but there won't be any code shown for
# the last example (because its humongus).
#
# See `TimeseriesPrediction.jl/examples` repository for more examples!
#
# ## Barkley Model
# The Barkley model consists of 2 coupled fields each having 2 spatial dimensions, and is
# considered one of the simplest spatio-temporal systems
#
# $$
# \begin{align}
# \frac{\partial u }{\partial t} =& \frac{1}{\epsilon} u (1-u)\left(u-\frac{v+b}{a}\right) +
# \nabla^2 u\nonumber \\
# \frac{\partial v }{\partial t} =& u - v
# \end{align}
# $$
# 
# ------------------------------------------------------------------------------------------

# This Algorithm of evolving the Barkley model is taken from
# http://www.scholarpedia.org/article/Barkley_model
function barkley(T, Nx, Ny)
    a = 0.75; b = 0.02; ε = 0.02

    u = zeros(Nx, Ny); v = zeros(Nx, Ny)
    U = Vector{Array{Float64,2}}()
    V = Vector{Array{Float64,2}}()

    #Initial state that creates spirals
    u[40:end,34] = 0.1; u[40:end,35] = 0.5
    u[40:end,36] = 5; v[40:end,34] = 1
    u[1:10,14] = 5; u[1:10,15] = 0.5
    u[1:10,16] = 0.1; v[1:10,17] = 1
    u[27:36,20] = 5; u[27:36,19] = 0.5
    u[27:36,18] = 0.1; v[27:36,17] = 1

    h = 0.75; Δt = 0.1; δ = 0.001
    Σ = zeros(Nx, Ny, 2)
    r = 1; s = 2
    
    function F(u, uth)
        if u < uth
            u/(1-(Δt/ε)*(1-u)*(u-uth))
        else
            (u + (Δt/ε)*u*(u-uth))/(1+(Δt/ε)*u*(u-uth))
        end
    end

    for m=1:T
        for i=1:Nx, j=1:Ny
            if u[i,j] < δ
                u[i,j] = Δt/h^2 * Σ[i,j,r]
                v[i,j] = (1 - Δt)* v[i,j]
            else
                uth = (v[i,j] + b)/a
                v[i,j] = v[i,j] + Δt*(u[i,j] - v[i,j])
                u[i,j] = F(u[i,j], uth) + Δt/h^2 *Σ[i,j,r]
                Σ[i,j,s] -= 4u[i,j]
                i > 1  && (Σ[i-1,j,s] += u[i,j])
                i < Nx && (Σ[i+1,j,s] += u[i,j])
                j > 1  && (Σ[i,j-1,s] += u[i,j])
                j < Ny && (Σ[i,j+1,s] += u[i,j])
            end
            Σ[i,j,r] = 0
        end
        r,s = s,r
        #V[:,:,m] .= v
        #U[:,:,m] .= u
        push!(U,copy(u))
        push!(V,copy(v))
    end
    return U,V
end

Nx = 50
Ny = 50
Tskip = 100
Ttrain = 500
p = 20
T = Tskip + Ttrain + p

U,V = barkley(T, Nx, Ny);

Vtrain = V[Tskip + 1:Tskip + Ttrain]
Vtest  = V[Tskip + Ttrain :  T]

D = 2
τ = 1
B = 2
k = 1
c = 200

Vpred = localmodel_stts(Vtrain, D, τ, p, B, k; boundary=c)
err = [abs.(Vtest[i]-Vpred[i]) for i=1:p+1];
println("Maximum error: $(maximum(maximum.(err)))")

# ------------------------------------------------------------------------------------------
# Plotting the real evolution, prediction, and error side by side (plotting takes a *lot* of
# time) with `Tskip = 200, Ttrain = 1000, p = 200` produces:
#
# ![Barkley prediction](barkley_stts_prediction.gif)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Kuramoto-Sivashinsky
#
# This system consists of only a single field and a single spatial dimension
#
# $$
# y_t =  −y y_x − y_{xx} − y_{xxxx}
# $$
# where the subscripts denote partial derivatives.
#
# We will not show code for this example, but only the results. The code is located at
# `TimeseriesPrediction.jl/examples/KSprediction.jl` and is quite large for a Jupyter
# notebook.
#
# ### Prediction
#
# A typical prediction with parameters `D = 2, τ = 1, Β = 5, k = 1` and system parameters `L
# = 150` (see file for more) looks like this:
#
# ![Prediction of KS system](KS150_tr40000_D2_tau1_B5_k1.png)
#
# The vertical axis, which is *time*, is measured within units of the maximal Lyapunov
# exponent of the system Λ, which is around 0.1.
#
# ### Mean Squared Error of prediction
#
# We now present a measure of the error of the prediction, by averaging the error values
# across all timesteps and across all spatial values, and then normalizing properly
#
# ![Error of prediction](KS_NRMSE_L6_Q64_D1_tau1_B5_k1_nn4_nw3PndWDWSt.png)
#
# The above curves are also *averaged* over 10 different initial conditions and subsequent
# predictions!
#
# The parameters used for the prediction
#
# You can compare it with e.g. figure 5 of this [Physical Review Letters
# article](https://doi.org/10.1103/PhysRevLett.120.024102).
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# # Docstrings
# ------------------------------------------------------------------------------------------

?localmodel_tsp

?AbstractLocalModel

?localmodel_stts

?STReconstruction
