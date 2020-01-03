# ------------------------------------------------------------------------------------------
# # Autodiff:  <br> Calculus  from another angle
# (and the special role played by Julia's multiple dispatch and compiler technology)
#
# (Alan Edelman, 2017)
#
#
#   The first time I heard about automatic differentiation, it was easy for me to imagine
# what it was.  I was wrong.  In my head, I thought it was straightforward symbolic
# differentiation applied to code.  I kind of imagined it was like executing Mathematica or
# Maple, or even just automatically doing what I learned to do in my calculus class.
#   <img src="derfunc.gif" width="230">
#   .... and anyway if it was not that, then it must be finite differences, like one learns
# in a numerical computing class.
#
# <img src="http://image.mathcaptain.com/cms/images/122/Diff%202.png" width="150">
#
# 
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Babylonian sqrt
#
# I would like to use a simple example, computation of sqrt(x), where for me how autodiff
# works came as both a mathematical surprise, and a computing wonder.  The example is  the
# Babylonian algorithm, known to man for millenia, to compute sqrt(x):
#
#
#  > Repeat $ t \leftarrow  (t+x/t) / 2 $ until $t$ converges to $\sqrt{x}$.
#
#  Each iteration has one add and two divides. For illustration purposes, 10 iterations
# suffice.
# ------------------------------------------------------------------------------------------

function Babylonian(x; N = 10) 
    t = (1+x)/2
    for i = 2:N; t=(t + x/t)/2  end    
    t
end  

Babylonian(π), √π   # \pi + <tab> , and \sqrt + <tab> 

# ------------------------------------------------------------------------------------------
# Check that it works:
# ------------------------------------------------------------------------------------------

x=2; Babylonian(x),√x  # Type \sqrt+<tab> to get the symbol

using Plots
gr()

i = 0:.01:49

plot([x->Babylonian(x,N=i) for i=1:5],i,label=["Iteration $j" for i=1:1,j=1:5])

plot!(sqrt,i,c="black",label="sqrt",
      title = "Those Babylonians really knew how to √")

# ------------------------------------------------------------------------------------------
# ## ...and now the derivative, almost by magic
# ------------------------------------------------------------------------------------------

struct D <: Number  # D is a function-derivative pair
    f::Tuple{Float64,Float64}
end

# ------------------------------------------------------------------------------------------
# Sum Rule: (x+y)' = x' + y' <br>
# Quotient Rule: (x/y)' = (yx'-xy') / y^2
# ------------------------------------------------------------------------------------------

import Base: +, /, convert, promote_rule
+(x::D, y::D) = D(x.f .+ y.f)
/(x::D, y::D) = D((x.f[1]/y.f[1], (y.f[1]*x.f[2] - x.f[1]*y.f[2])/y.f[1]^2))
convert(::Type{D}, x::Real) = D((x,zero(x)))
promote_rule(::Type{D}, ::Type{<:Number}) = D

x=2; Babylonian(D((x,1))),(√x,.5/√x)

i = .2:.01:49
plot([x->Babylonian(D((x,1.0)),N=i).f[2] for i=1:5],i)
plot!(x->.5/√x,i,c="black",label="d(sqrt(x))/dx",
    title = " Babylonians Differentiated")

# ------------------------------------------------------------------------------------------
# ## It just works!
#
# How does it work?  We will explain in a moment.  Right now marvel that it does.  Note we
# did not
# import any autodiff package.  Everything is just basic vanilla Julia.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Symbolically
#
# We haven't yet explained how it works, but it may be of some value to understand that the
# below is mathematically
# equivalent, though not what the computation is doing.
#
# Notice in the below that Babylonian works on SymPy symbols.
# ------------------------------------------------------------------------------------------

# using Pkg; Pkg.add("SymPy")
using SymPy

symbols("x");

x = symbols("x")
display("Iterations as a function of x")
for k = 1:5
 display( simplify(Babylonian(x,N=k)))
end

display("Derivatives as a function of x")
for k = 1:5
 display(simplify(diff(simplify(Babylonian(x,N=k)),x)))
end

# ------------------------------------------------------------------------------------------
# ## How autodiff is getting the answer
# Let us by hand take the "derivative" of the Babylonian iteration with respect to x.
# Specifically t′=dt/dx
# ------------------------------------------------------------------------------------------

function dBabylonian(x; N = 10) 
    t = (1+x)/2
    t′ = 1/2
    for i = 1:N;  
        t = (t+x/t)/2; 
        t′= (t′+(t-x*t′)/t^2)/2; 
    end    
    t′
end  

x = π; dBabylonian(x), .5/√x

# ------------------------------------------------------------------------------------------
# What just happened?  Answer: We created an iteration by hand for t′ given our iteration
# for t. Then we ran the iteration alongside the iteration for t.
# ------------------------------------------------------------------------------------------

Babylonian(D((x,1)))

# ------------------------------------------------------------------------------------------
# How did this work?  It created the same derivative iteration, using very general rules
# that are set once and need not be written by hand.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Important:: The derivative is substituted before the JIT compiler, and thus efficient
# compiled code is executed.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Dual Number Notation
#
# Instead of D(a,b) we can write a + b ϵ, where ϵ satisfies ϵ^2=0.  (Some people like to
# recall imaginary numbers where an i is introduced with i^2=-1.)
#
# Others like to think of how engineers just drop the O(ϵ^2) terms.
#
# The four rules are
#
# $ (a+b\epsilon) \pm (c+d\epsilon) = (a \pm c) + (b \pm d)\epsilon$
#
# $ (a+b\epsilon) * (c+d\epsilon) = (ac) + (bc+ad)\epsilon$
#
# $ (a+b\epsilon) / (c+d\epsilon) = (a/c) + (bc-ad)/c^2 \epsilon $
# 
# ------------------------------------------------------------------------------------------

Base.show(io::IO,x::D) = print(io,x.f[1]," + ",x.f[2]," ϵ")

# Add the last two rules
import Base: -,*
-(x::D, y::D) = D(x.f .- y.f)
*(x::D, y::D) = D((x.f[1]*y.f[1], (x.f[2]*y.f[1] + x.f[1]*y.f[2])))

ϵ  = D((0,1))

@code_native(ϵ^2)

ϵ * ϵ

1/(1+ϵ)  # Exact power series:  1-ϵ+ϵ²-ϵ³-...

(1+ϵ)^10 ## Note this just works (we didn't teach Julia about exponentiation)!!

# ------------------------------------------------------------------------------------------
# ## Generalization to arbitrary roots
# ------------------------------------------------------------------------------------------

function nthroot(x, n=2; t=1, N = 10) 
    for i = 1:N;   t += (x/t^(n-1)-t)/n; end   
    t
end  

nthroot(2,3), ∛2 # take a cube root

nthroot(7,12), 7^(1/12)

x = 17.0
nthroot(x+ϵ,3), ∛x, 1/x^(2/3)/3

# ------------------------------------------------------------------------------------------
# ## Forward Diff
# Now that you understand it, you can use the official package
# ------------------------------------------------------------------------------------------

# using Pkg; Pkg.add("ForwardDiff")
using ForwardDiff

ForwardDiff.derivative(sqrt, 2)

ForwardDiff.derivative(Babylonian, 2)

@which ForwardDiff.derivative(sqrt, 2)

# ------------------------------------------------------------------------------------------
# ## Close Look at Convergence
# ------------------------------------------------------------------------------------------

setprecision(3000)
round.(Float64.(log10.([Babylonian(BigFloat(2),N=k) for k=1:10] .- √BigFloat(2))); digits=3)

struct D1{T} <: Number  # D is a function-derivative pair
    f::Tuple{T,T}
end

z = D((2.0,1.0))
z1 = D1((BigFloat(2.0),BigFloat(1.0)))

import Base: +, /, convert, promote_rule
+(x::D1, y::D1) = D1(x.f .+ y.f)
/(x::D1, y::D1) = D1((x.f[1]/y.f[1], (y.f[1]*x.f[2] - x.f[1]*y.f[2])/y.f[1]^2))
convert(::Type{D1{T}}, x::Real) where {T} = D1((convert(T, x), zero(T)))
promote_rule(::Type{D1{T}}, ::Type{S}) where {T,S<:Number} = D1{promote_type(T,S)}

A = randn(3,3)

x = randn(3)

ForwardDiff.gradient(x->x'A*x,x)

(A+A')*x
