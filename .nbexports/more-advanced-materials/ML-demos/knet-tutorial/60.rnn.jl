# ------------------------------------------------------------------------------------------
# # Introduction to Recurrent Neural Networks
# (c) Deniz Yuret, 2019
# * Objectives: learn about RNNs, the RNN layer, compare with MLP on a tagging task.
# * Prerequisites: [MLP models](40.mlp.ipynb)
# * New functions:
# [RNN](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.RNN),
# [adam](http://denizyuret.github.io/Knet.jl/latest/reference/#Knet.adam)
#
# ![image](https://github.com/denizyuret/Knet.jl/blob/master/docs/src/images/RNN-
# unrolled.png?raw=true)([image
# source](http://colah.github.io/posts/2015-08-Understanding-LSTMs))
#
# In this notebook we will see how to implement a recurrent neural network (RNN) in Knet. In
# RNNs, connections between units form a directed cycle, which allows them to keep a
# persistent state over time. This gives them the ability to process sequences of arbitrary
# length one element at a time, while keeping track of what happened at previous elements.
# One can view the current state of the RNN as a representation for the sequence processed
# so far.
#
# We will build a part-of-speech tagger using a large annotated corpus of English. We will
# represent words with numeric vectors appropriate as inputs to a neural network. These word
# vectors will be initialized randomly and learned during training just like other model
# parameters. We will compare three network architectures: (1) an MLP which tags each word
# independently of its neighbors, (2) a simple RNN that can represent the neighboring words
# to the left, (3) a bidirectional RNN that can represent both left and right contexts. As
# can be expected 1 < 2 < 3 in performance. More surprisingly, the three models are very
# similar to each other: we will see their model diagrams are identical except for the
# horizontal connections that carry information across the sequence.
# ------------------------------------------------------------------------------------------

# Setup display width, load packages, import symbols
ENV["COLUMNS"] = 72
using Pkg; for p in ("Knet","Plots"); haskey(Pkg.installed(),p) || Pkg.add(p); end
using Random: shuffle!
using Base.Iterators: flatten
using Knet: Knet, AutoGrad, param, param0, mat, RNN, relu, Data, adam, progress, nll, zeroone

# ------------------------------------------------------------------------------------------
# ## The Brown Corpus
# To introduce recurrent neural networks (RNNs) we will train a part-of-speech tagger using
# the [Brown Corpus](https://en.wikipedia.org/wiki/Brown_Corpus). We will train three
# models: a MLP, a unidirectional RNN, a bidirectional RNN and observe significant
# performance differences.
# ------------------------------------------------------------------------------------------

include(Knet.dir("data/nltk.jl"))
(data,words,tags) = brown()
println("The Brown Corpus has $(length(data)) sentences, $(sum(length(p[1]) for p in data)) tokens, with a word vocabulary of $(length(words)) and a tag vocabulary of $(length(tags)).")

# ------------------------------------------------------------------------------------------
# `data` is an array of `(w,t)` pairs each representing a sentence, where `w` is a sequence
# of word ids, and `t` is a sequence of tag ids. `words` and `tags` contain the strings for
# the ids.
# ------------------------------------------------------------------------------------------

println.(summary.((data,words,tags)));

# ------------------------------------------------------------------------------------------
# Here is what the first sentence looks like with ids and with strings:
# ------------------------------------------------------------------------------------------

(w,t) = first(data)
display(permutedims(Int[w t]))
display(permutedims([words[w] tags[t]]))

# ------------------------------------------------------------------------------------------
# ## Chain of layers
# ------------------------------------------------------------------------------------------

# Let's define a chain of layers
struct Chain
    layers
    Chain(layers...) = new(layers)
end
(c::Chain)(x) = (for l in c.layers; x = l(x); end; x)
(c::Chain)(x,y) = nll(c(x),y)

# ------------------------------------------------------------------------------------------
# ## Dense layers
# ------------------------------------------------------------------------------------------

# Redefine dense layer (See mlp.ipynb):
struct Dense; w; b; f; end
Dense(i::Int,o::Int,f=identity) = Dense(param(o,i), param0(o), f)
(d::Dense)(x) = d.f.(d.w * mat(x,dims=1) .+ d.b)

# ------------------------------------------------------------------------------------------
# ## Word Embeddings
# `data` has each sentence tokenized into an array of words and each word mapped to a
# `UInt16` id. To use these words as inputs to a neural network we further map each word to
# a Float32 vector. We will keep these vectors in the columns of a size (X,V) matrix where X
# is the embedding dimension and V is the vocabulary size. The vectors will be initialized
# randomly, and trained just like any other network parameter. Let's define an embedding
# layer for this purpose:
# ------------------------------------------------------------------------------------------

struct Embed; w; end
Embed(vocabsize::Int,embedsize::Int) = Embed(param(embedsize,vocabsize))
(e::Embed)(x) = e.w[:,x]

# ------------------------------------------------------------------------------------------
# This is what the words, word ids and embeddings for a sentence looks like: (note the
# identical id and embedding for the 2nd and 5th words)
# ------------------------------------------------------------------------------------------

embedlayer = Embed(length(words),8)
(w,t) = data[52855]
display(permutedims(words[w]))
display(permutedims(Int.(w)))
display(embedlayer(w))

# ------------------------------------------------------------------------------------------
# ## RNN layers
# ------------------------------------------------------------------------------------------

@doc RNN

# ------------------------------------------------------------------------------------------
# ## The three taggers: MLP, RNN, biRNN
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Tagger0 (MLP)
# This is what Tagger0 looks like. Every tag is predicted independently. The prediction of
# each tag only depends on the corresponding word.
# <img src="https://docs.google.com/drawings/d/e/2PACX-1vTfV4-TB0KwjDbFKpj3rL0tfeApEh9XXaDJ1
# OF3emNVAmc_-hvgqpEBuA_K0FsNuxymZrv3ztScXxqF/pub?w=378&h=336"/>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Tagger1 (RNN)
# In Tagger1, the RNN layer takes its previous output as an additional input. The prediction
# of each tag is based on words to the left.
# <img src="https://docs.google.com/drawings/d/e/2PACX-1vTaizzCISuSxihPCjndr7xMVwklsrefi9zn7
# ZArCvsR8fb5V4DGKtusyIzn3Ujp3QbAJgUz1WSlLvIJ/pub?w=548&h=339"/>
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Tagger2 (biRNN)
# In Tagger2 there are two RNNs: the forward RNN reads the sequence from left to right, the
# backward RNN reads it from right to left. The prediction of each tag is dependent on all
# the words in the sentence.
# <img src="https://docs.google.com/drawings/d/e/2PACX-1vQawvnCj6odRF2oakF_TgXd8gLxSsfQP8-2Z
# dBdEIpfgIyPq0Zp_EF6zcFJf6JlGhfiKQvdVyg-Weq2/pub?w=566&h=335"/>
# ------------------------------------------------------------------------------------------

Tagger0(vocab,embed,hidden,output)=  # MLP Tagger
    Chain(Embed(vocab,embed),Dense(embed,hidden,relu),Dense(hidden,output))
Tagger1(vocab,embed,hidden,output)=  # RNN Tagger
    Chain(Embed(vocab,embed),RNN(embed,hidden,rnnType=:relu),Dense(hidden,output))
Tagger2(vocab,embed,hidden,output)=  # biRNN Tagger
    Chain(Embed(vocab,embed),RNN(embed,hidden,rnnType=:relu,bidirectional=true),Dense(2hidden,output));

# ------------------------------------------------------------------------------------------
# ## Sequence Minibatching
# Minibatching is a bit more complicated with sequences compared to simple classification
# problems, this section can be skipped on a first reading. In addition to the input and
# minibatch sizes, there is also the time dimension to consider. To keep things simple we
# will concatenate all sentences into one big sequence, then split this sequence into equal
# sized chunks. The input to the tagger will be size (B,T) where B is the minibatch size,
# and T is the chunk size. The input to the RNN layer will be size (X,B,T) where X is the
# embedding size.
# ------------------------------------------------------------------------------------------

BATCHSIZE = 64
SEQLENGTH = 32;

function seqbatch(x,y,B,T)
    N = length(x) ÷ B
    x = permutedims(reshape(x[1:N*B],N,B))
    y = permutedims(reshape(y[1:N*B],N,B))
    d = []; for i in 0:T:N-T
        push!(d, (x[:,i+1:i+T], y[:,i+1:i+T]))
    end
    return d
end
allw = vcat((x->x[1]).(data)...)
allt = vcat((x->x[2]).(data)...)
d = seqbatch(allw, allt, BATCHSIZE, SEQLENGTH);

# ------------------------------------------------------------------------------------------
# This may be a bit more clear if we look at an example minibatch:
# ------------------------------------------------------------------------------------------

(x,y) = first(d)
words[x]

# ------------------------------------------------------------------------------------------
# ## Embedding a minibatch
# Julia indexing allows us to get the embeddings for this minibatch in one go as an (X,B,T)
# array where X is the embedding size, B is the minibatch size, and T is the subsequence
# length.
# ------------------------------------------------------------------------------------------

embedlayer = Embed(length(words),128)
summary(embedlayer(x))

# ------------------------------------------------------------------------------------------
# ## Experiments
# ------------------------------------------------------------------------------------------

# shuffle and split minibatches into train and test portions
shuffle!(d)
dtst = d[1:10]
dtrn = d[11:end]
length.((dtrn,dtst))

# For running experiments we will use the Adam algorithm which typically converges faster than SGD.
function trainresults(file,maker,savemodel)
    if (print("Train from scratch? "); readline()[1]=='y')
        model = maker()
        takeevery(n,itr) = (x for (i,x) in enumerate(itr) if i % n == 1)
        results = ((nll(model,dtst), zeroone(model,dtst))
                   for x in takeevery(100, progress(adam(model,repeat(dtrn,5)))))
        results = reshape(collect(Float32,flatten(results)),(2,:))
        Knet.save(file,"model",(savemodel ? model : nothing),"results",results)
        Knet.gc() # To save gpu memory
    else
        isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file",file)
        model,results = Knet.load(file,"model","results")
    end
    println(minimum(results,dims=2))
    return model,results
end

VOCABSIZE = length(words)
EMBEDSIZE = 128
HIDDENSIZE = 128
OUTPUTSIZE = length(tags);

# 2.35e-01  100.00%┣┫ 2780/2780 [00:13/00:13, 216.36i/s] [0.295007; 0.0972656]
t0maker() = Tagger0(VOCABSIZE,EMBEDSIZE,HIDDENSIZE,OUTPUTSIZE)
(t0,r0) = trainresults("tagger113a.jld2",t0maker,false);

# 1.49e-01  100.00%┣┫ 2780/2780 [00:19/00:19, 142.58i/s] [0.21358; 0.0616211]
t1maker() = Tagger1(VOCABSIZE,EMBEDSIZE,HIDDENSIZE,OUTPUTSIZE)
(t1,r1) = trainresults("tagger113b.jld2",t1maker,false);

# 9.37e-02  100.00%┣┫ 2780/2780 [00:25/00:25, 109.77i/s] [0.156669; 0.044043]
t2maker() = Tagger2(VOCABSIZE,EMBEDSIZE,HIDDENSIZE,OUTPUTSIZE)
(t2,r2) = trainresults("tagger113c.jld2",t2maker,true);

using Plots; default(fmt=:png,ls=:auto,ymirror=true)

plot([r0[2,:], r1[2,:], r2[2,:]]; xlabel="x100 updates", ylabel="error",
    ylim=(0,0.15), yticks=0:0.01:0.15, labels=["MLP","RNN","biRNN"])

plot([r0[1,:], r1[1,:], r2[1,:]]; xlabel="x100 updates", ylabel="loss",
    ylim=(0,.5), yticks=0:0.1:.5, labels=["MLP","RNN","biRNN"])

# ------------------------------------------------------------------------------------------
# ## Playground
# Below, you can type and tag your own sentences:
# ------------------------------------------------------------------------------------------

wdict=Dict{String,UInt16}(); for (i,w) in enumerate(words); wdict[w]=i; end
unk = UInt16(length(words))
wid(w) = get(wdict,w,unk)
function tag(tagger,s::String)
    w = permutedims(split(s))
    t = tags[(x->x[1]).(argmax(Array(tagger(wid.(w))),dims=1))]
    vcat(w,t)
end

tag(t2,readline())


