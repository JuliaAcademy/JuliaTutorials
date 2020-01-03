# ------------------------------------------------------------------------------------------
# # Character based RNN language model
# (c) Deniz Yuret, 2019. Based on http://karpathy.github.io/2015/05/21/rnn-effectiveness.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# * Objectives: Learn to define and train a character based language model and generate text
# from it. Minibatch blocks of text. Keep a persistent RNN state between updates. Train a
# Shakespeare generator and a Julia programmer using the same type of model.
# * Prerequisites: [RNN basics](60.rnn.ipynb), [Iterators](25.iterators.ipynb)
# * New functions:
# [converge](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.converge)
# ------------------------------------------------------------------------------------------

# Set display width, load packages, import symbols
ENV["COLUMNS"]=72
using Pkg; haskey(Pkg.installed(),"Knet") || Pkg.add("Knet")
using Statistics: mean
using Base.Iterators: cycle
using Knet: Knet, AutoGrad, Data, param, param0, mat, RNN, dropout, value, nll, adam, minibatch, progress!, converge

# ------------------------------------------------------------------------------------------
# ## Define the model
# ------------------------------------------------------------------------------------------

struct Embed; w; end

Embed(vocab::Int,embed::Int)=Embed(param(embed,vocab))

(e::Embed)(x) = e.w[:,x]  # (B,T)->(X,B,T)->rnn->(H,B,T)

struct Linear; w; b; end

Linear(input::Int, output::Int)=Linear(param(output,input), param0(output))

(l::Linear)(x) = l.w * mat(x,dims=1) .+ l.b  # (H,B,T)->(H,B*T)->(V,B*T)

# Let's define a chain of layers
struct Chain
    layers
    Chain(layers...) = new(layers)
end
(c::Chain)(x) = (for l in c.layers; x = l(x); end; x)
(c::Chain)(x,y) = nll(c(x),y)
(c::Chain)(d::Data) = mean(c(x,y) for (x,y) in d)

# The h=0,c=0 options to RNN enable a persistent state between iterations
CharLM(vocab::Int,embed::Int,hidden::Int; o...) = 
    Chain(Embed(vocab,embed), RNN(embed,hidden;h=0,c=0,o...), Linear(hidden,vocab))

# ------------------------------------------------------------------------------------------
# ## Train and test utilities
# ------------------------------------------------------------------------------------------

# For running experiments
function trainresults(file,maker,chars)
    if (print("Train from scratch? "); readline()[1]=='y')
        model = maker()
        a = adam(model,cycle(dtrn))
        b = (exp(model(dtst)) for _ in every(100,a))
        c = converge(b, alpha=0.1)
        progress!(c, alpha=1)
        Knet.save(file,"model",model,"chars",chars)
    else
        isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file",file)
        model,chars = Knet.load(file,"model","chars")
    end
    Knet.gc() # To save gpu memory
    return model,chars
end

every(n,itr) = (x for (i,x) in enumerate(itr) if i%n == 0);

# To generate text from trained models
function generate(model,chars,n)
    function sample(y)
        p = Array(exp.(y)); r = rand()*sum(p)
        for j=1:length(p); (r -= p[j]) < 0 && return j; end
    end
    x = 1
    reset!(model)
    for i=1:n
        y = model([x])
        x = sample(y)
        print(chars[x])
    end
    println()
end

reset!(m::Chain)=(for r in m.layers; r isa RNN && (r.c=r.h=0); end);

# ------------------------------------------------------------------------------------------
# ## The Complete Works of William Shakespeare
# ------------------------------------------------------------------------------------------

RNNTYPE = :lstm
BATCHSIZE = 256
SEQLENGTH = 100
VOCABSIZE = 84
INPUTSIZE = 168
HIDDENSIZE = 334
NUMLAYERS = 1;

# Load 'The Complete Works of William Shakespeare'
include(Knet.dir("data","gutenberg.jl"))
trn,tst,shakechars = shakespeare()
map(summary,(trn,tst,shakechars))

# Print a sample
println(string(shakechars[trn[1020:1210]]...))

# Minibatch data
function mb(a)
    N = length(a) ÷ BATCHSIZE
    x = reshape(a[1:N*BATCHSIZE],N,BATCHSIZE)' # reshape full data to (B,N) with contiguous rows
    minibatch(x[:,1:N-1], x[:,2:N], SEQLENGTH) # split into (B,T) blocks 
end
dtrn,dtst = mb.((trn,tst))
length.((dtrn,dtst))

summary.(first(dtrn))  # each x and y have dimensions (BATCHSIZE,SEQLENGTH)

# 3.30e+00  ┣   /       /       /       /       /    ┫ 122 [04:46, 2.35s/i]
Knet.gc()
shakemaker() = CharLM(VOCABSIZE, INPUTSIZE, HIDDENSIZE; rnnType=RNNTYPE, numLayers=NUMLAYERS)
shakemodel,shakechars = trainresults("shakespeare113.jld2", shakemaker, shakechars);

#exp(shakemodel(dtst))  # Perplexity = 3.30

generate(shakemodel,shakechars,1000)

# ------------------------------------------------------------------------------------------
# ## Julia programmer
# ------------------------------------------------------------------------------------------

RNNTYPE = :lstm
BATCHSIZE = 64
SEQLENGTH = 64
INPUTSIZE = 512
VOCABSIZE = 128
HIDDENSIZE = 512
NUMLAYERS = 2;

# Read julia base library source code
base = joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia")
text = ""
for (root,dirs,files) in walkdir(base)
    for f in files
        f[end-2:end] == ".jl" || continue
        text *= read(joinpath(root,f), String)
    end
    # println((root,length(files),all(f->contains(f,".jl"),files)))
end
length(text)

# Find unique chars, sort by frequency, assign integer ids.
charcnt = Dict{Char,Int}()
for c in text; charcnt[c]=1+get(charcnt,c,0); end
juliachars = sort(collect(keys(charcnt)), by=(x->charcnt[x]), rev=true)
charid = Dict{Char,Int}()
for i=1:length(juliachars); charid[juliachars[i]]=i; end
hcat(juliachars, map(c->charcnt[c],juliachars))

# Keep only VOCABSIZE most frequent chars, split into train and test
data = map(c->charid[c], collect(text))
data[data .> VOCABSIZE] .= VOCABSIZE
ntst = 1<<19
tst = data[1:ntst]
trn = data[1+ntst:end]
length.((data,trn,tst))

# Print a sample
r = rand(1:(length(trn)-1000))
println(string(juliachars[trn[r:r+1000]]...)) 

# Minibatch data
function mb(a)
    N = length(a) ÷ BATCHSIZE
    x = reshape(a[1:N*BATCHSIZE],N,BATCHSIZE)' # reshape full data to (B,N) with contiguous rows
    minibatch(x[:,1:N-1], x[:,2:N], SEQLENGTH) # split into (B,T) blocks 
end
dtrn,dtst = mb.((trn,tst))
length.((dtrn,dtst))

summary.(first(dtrn))  # each x and y have dimensions (BATCHSIZE,SEQLENGTH)

# 3.25e+00  ┣       /       /       /       /       /┫ 126 [05:43, 2.72s/i]
juliamaker() = CharLM(VOCABSIZE, INPUTSIZE, HIDDENSIZE; rnnType=RNNTYPE, numLayers=NUMLAYERS)
juliamodel,juliachars = trainresults("juliacharlm113.jld2", juliamaker, juliachars);

#exp(juliamodel(dtst))  # Perplexity = 3.27

generate(juliamodel,juliachars,1000)


