# Based on https://github.com/fchollet/keras/raw/master/keras/datasets/imdb.py
# Also see https://github.com/fchollet/keras/raw/master/examples/imdb_lstm.py
# Also see https://github.com/ilkarman/DeepLearningFrameworks/raw/master/common/utils.py

if ENV["HOME"] == "/mnt/juliabox"
    Pkg.dir(path...)=joinpath("/home/jrun/.julia/v0.6",path...)
else
    for p in ("PyCall","JSON","JLD","Knet")
        Pkg.installed(p) == nothing && Pkg.add(p)
    end
end

using PyCall,JSON,JLD,Knet

"""

    imdb()

Load the IMDB Movie reviews sentiment classification dataset from
https://keras.io/datasets and return (xtrn,ytrn,xtst,ytst,dict) tuple.

# Keyword Arguments:
- url=https://s3.amazonaws.com/text-datasets: where to download the data (imdb.npz) from.
- dir=Pkg.dir("Knet/data"): where to cache the data.
- maxval=nothing: max number of token values to include. Words are ranked by how often they occur (in the training set) and only the most frequent words are kept. nothing means keep all, equivalent to maxval = vocabSize + pad + stoken.
- maxlen=nothing: truncate sequences after this length. nothing means do not truncate.
- seed=0: random seed for sample shuffling. Use system seed if 0.
- pad=true: whether to pad short sequences (padding is done at the beginning of sequences). pad_token = maxval.
- stoken=true: whether to add a start token to the beginning of each sequence. start_token = maxval - pad.
- oov=true: whether to replace words >= oov_token with oov_token (the alternative is to skip them). oov_token = maxval - pad - stoken.

"""
function imdb(;
              url = "https://s3.amazonaws.com/text-datasets",
              dir = "./",
              data="imdb.npz",
              dict="imdb_word_index.json",
              jld="imdbdata.jld",
              maxval=nothing,
              maxlen=nothing,
              seed=0, oov=true, stoken=true, pad=true
              )
    global _imdb_xtrn,_imdb_ytrn,_imdb_xtst,_imdb_ytst,_imdb_dict
    if !isdefined(:_imdb_xtrn)
        isdir(dir) || mkpath(dir)
        jldpath = joinpath(dir,jld)
        if !isfile(jldpath)
            info("Downloading IMDB...")
            datapath = joinpath(dir,data)
            dictpath = joinpath(dir,dict)
            isfile(datapath) || download("$url/$data",datapath)
            isfile(dictpath) || download("$url/$dict",dictpath)
            @pyimport numpy as np
            d = np.load(datapath)
            _imdb_xtrn = map(a->np.asarray(a,dtype=np.int32), get(d, "x_train"))
            _imdb_ytrn = Array{Int8}(get(d, "y_train") .+ 1)
            _imdb_xtst = map(a->np.asarray(a,dtype=np.int32), get(d, "x_test"))
            _imdb_ytst = Array{Int8}(get(d, "y_test") .+ 1)
            _imdb_dict = Dict{String,Int32}(JSON.parsefile(dictpath))
            JLD.@save jldpath _imdb_xtrn _imdb_ytrn _imdb_xtst _imdb_ytst _imdb_dict
            #rm(datapath)
            #rm(dictpath)
        end
        info("Loading IMDB...")
        JLD.@load jldpath _imdb_xtrn _imdb_ytrn _imdb_xtst _imdb_ytst _imdb_dict
    end
    if seed != 0; srand(seed); end
    xs = [_imdb_xtrn;_imdb_xtst]
    if maxlen == nothing; maxlen = maximum(map(length,xs)); end
    if maxval == nothing; maxval = maximum(map(maximum,xs)) + pad + stoken; end
    if pad; pad_token = maxval; maxval -= 1; end
    if stoken; start_token = maxval; maxval -= 1; end
    if oov; oov_token = maxval; end
    function _imdb_helper(x,y)
        rp = randperm(length(x))
        newy = y[rp]
        newx = similar(x)
        for i in 1:length(x)
            xi = x[rp[i]]
            if oov
                xi = map(w->(w<=oov_token ? w : oov_token), xi)
            else
                xi = filter(w->(w<=oov_token), xi)
            end
            if stoken
                xi = [ start_token; xi ]
            end
            if length(xi) > maxlen
                xi = xi[end-maxlen+1:end]
            end
            if pad && length(xi) < maxlen
                xi = append!(repmat([pad_token], maxlen-length(xi)), xi)
            end
            newx[i] = xi
        end
        newx,newy
    end
    xtrn,ytrn = _imdb_helper(_imdb_xtrn,_imdb_ytrn)
    xtst,ytst = _imdb_helper(_imdb_xtst,_imdb_ytst)
    return xtrn,ytrn,xtst,ytst,_imdb_dict
end

function loadmodel(url="http://people.csail.mit.edu/deniz/models/nlp-demos/imdbmodel.jld",localfile="imdbmodel.jld")
    if !isfile(localfile)
        info("Downloading $url")
        download(url,localfile)
    end
    info("Loading model")
    d = load(localfile)
    weights = d["weights"];rnnSpec=d["rnnSpec"];
    return weights,rnnSpec
end

function predict(weights, inputs, rnnSpec)
    rnnWeights, inputMatrix, outputMatrix = weights # (1,1,W), (X,V), (2,H)
    indices = hcat(inputs...)' # (B,T)
    rnnInput = inputMatrix[:,indices] # (X,B,T)
    rnnOutput = rnnforw(rnnSpec, rnnWeights, rnnInput)[1] # (H,B,T)
    return outputMatrix * rnnOutput[:,:,end] # (2,H) * (H,B) = (2,B)
end

function invert(vocab)
       int2tok = Array{String}(length(vocab))
       for (k,v) in vocab; int2tok[v] = k; end
       return int2tok
end

function reviewstring(x,y=0)
    x = x[x.!=MAXFEATURES] # remove pads
    """$(("Sample","Negative","Positive")[y+1]) review:\n$(join(imdbarray[x]," "))"""
end

function predictstring(x)
    y = predict(weights, [x], rnnSpec)
    c = indmax(Array(y))
    ("Negative","Positive")[c]
end

BATCHSIZE=64
SEED=1311194
MAXLEN=150 #maximum size of the word sequence
MAXFEATURES=30000 #vocabulary size
PAD=MAXFEATURES
SOS=MAXFEATURES-1
UNK=MAXFEATURES-2
(xtrn,ytrn,xtst,ytst,imdbdict)=imdb(maxlen=MAXLEN,maxval=MAXFEATURES,seed=SEED)
imdbarray = invert(imdbdict)
imdbarray[MAXFEATURES-2:MAXFEATURES] = ["<unk>","<s>","<pad>"]
weights,rnnSpec = loadmodel()
nothing