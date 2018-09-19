if ENV["HOME"] == "/mnt/juliabox"
    Pkg.dir(path...)=joinpath("/home/jrun/.julia/v0.6",path...)
else
    for p in ("JLD","Knet")
        Pkg.installed(p) == nothing && Pkg.add(p)
    end
end

using JLD,Knet

info("Loading Shakespeare data")
include(Knet.dir("data","gutenberg.jl"))
trn,tst,chars = shakespeare()
shake_text = String(chars[vcat(trn,tst)])

info("Loading Shakespeare model")
isfile("shakespeare.jld") || download("http://people.csail.mit.edu/deniz/models/nlp-demos/shakespeare.jld","shakespeare.jld")
shake_model = load("shakespeare.jld","model")

info("Reading Julia files")
base = joinpath(Base.JULIA_HOME, Base.DATAROOTDIR, "julia", "base")
julia_text = ""
for (root,dirs,files) in walkdir(base)
    for f in files
        f[end-2:end] == ".jl" || continue
        julia_text *= readstring(joinpath(root,f))
    end
    # println((root,length(files),all(f->contains(f,".jl"),files)))
end

info("Loading Julia model")
isfile("juliacharlm.jld") || download("http://people.csail.mit.edu/deniz/models/nlp-demos/juliacharlm.jld","juliacharlm.jld")
julia_model = load("juliacharlm.jld","model")

# Given the current character, predict the next character
function predict(ws,xs,hx,cx;pdrop=0)
    r,wr,wx,wy,by = ws
    x = wx[:,xs]                                    # xs=(B,T) x=(X,B,T)
    x = dropout(x,pdrop)
    y,hy,cy = rnnforw(r,wr,x,hx,cx,hy=true,cy=true) # y=(H,B,T) hy=cy=(H,B,L)
    y = dropout(y,pdrop)
    y2 = reshape(y,size(y,1),size(y,2)*size(y,3))   # y2=(H,B*T)
    return wy*y2.+by, hy, cy
end

# Sample from trained model
function generate(model,n)
    function sample(y)
        p,r=Array(exp.(y-logsumexp(y))),rand()
        for j=1:length(p); (r -= p[j]) < 0 && return j; end
    end
    h,c = nothing,nothing
    chars = model[end]
    x = findfirst(chars,'\n')
    for i=1:n
        y,h,c = predict(model,[x],h,c)
        x = sample(y)
        print(chars[x])
    end
    println()
end

nothing
