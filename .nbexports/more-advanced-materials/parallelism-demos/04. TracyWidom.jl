using JuliaRunClient
ctx = Context()
nb = self()

initParallel()

NWRKRS = 2
println("scale up to $NWRKRS")

@result setJobScale(ctx, nb, NWRKRS)
waitForWorkers(NWRKRS)

using StatsBase

@everywhere using StatsBase

@everywhere function montecarlo(howmany, data_generator, bins)
    h  = Histogram(bins)
    for i=1:howmany
        push!(h, data_generator() )
    end
    return h.weights
end

w = @parallel (+) for i=1:nworkers()
  montecarlo(100000, randn, -3:.1:3)
end;

using Plots

@everywhere  function tracywidom_sample(β=2,n=200)
  h=n^(-1/3)
  x=[0:h:10;]
  N=length(x)
  d=(-2/h^2 .-x) +  2/sqrt(h*β)*randn(N) # diagonal
  e=ones(N-1)/h^2                   # subdiagonal
  eigvals(SymTridiagonal(d,e))[N]
end

plot()
for β = [1,2,4]
 bins = -4:.05:0.95
 w=
  @parallel (+) for i=1:nworkers()
      montecarlo(10000,()->tracywidom_sample(β), -4:.05:1)
  end;
plot!(bins, w/sum(w)*bins.step.hi)
end

plot!()

# Scale down
@result setJobScale(ctx, self(), 0)

nworkers()


