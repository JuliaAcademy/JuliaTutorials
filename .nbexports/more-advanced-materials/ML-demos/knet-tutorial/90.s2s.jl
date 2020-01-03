# ------------------------------------------------------------------------------------------
# # Sequence to sequence model (S2S)
# (c) Deniz Yuret, 2018. Based on ([Sutskever et al.
# 2014](https://papers.nips.cc/paper/5346-sequence-to-sequence-learning-with-neural-
# networks.pdf)).
# S2S models learn to map input sequences to output sequences using an encoder and a decoder
# RNN. Note that this is an instructional example written in low-level Julia/Knet and it is
# slow to train. For a faster and high-level implementation please see `@doc RNN`.
# ------------------------------------------------------------------------------------------

using Pkg; haskey(Pkg.installed(),"Knet") || Pkg.add("Knet")
using Knet

# ------------------------------------------------------------------------------------------
# <img src="images/seq2seq.png"/>(<a href="https://papers.nips.cc/paper/5346-sequence-to-
# sequence-learning-with-neural-networks.pdf">image source</a>)
# ------------------------------------------------------------------------------------------

# S2S model definition

function initmodel(H, V; atype=(gpu()>=0 ? KnetArray{Float32} : Array{Float32}))
    init(d...)=atype(xavier(d...))
    model = Dict{Symbol,Any}()
    model[:state0] = [ init(1,H), init(1,H) ]
    model[:embed1] = init(V,H)
    model[:encode] = [ init(2H,4H), init(1,4H) ]
    model[:embed2] = init(V,H)
    model[:decode] = [ init(2H,4H), init(1,4H) ]
    model[:output] = [ init(H,V), init(1,V) ]
    return model
end;

# S2S loss function and its gradient

function s2s(model, inputs, outputs)
    state = initstate(inputs[1], model[:state0])
    for input in inputs
        input = onehotrows(input, model[:embed1])
        input = input * model[:embed1]
        state = lstm(model[:encode], state, input)
    end
    EOS = eosmatrix(outputs[1], model[:embed2])
    input = EOS * model[:embed2]
    sumlogp = 0
    for output in outputs
        state = lstm(model[:decode], state, input)
        ypred = predict(model[:output], state[1])
        ygold = onehotrows(output, model[:embed2])
        sumlogp += sum(ygold .* logp(ypred,dims=2))
        input = ygold * model[:embed2]
    end
    state = lstm(model[:decode], state, input)
    ypred = predict(model[:output], state[1])
    sumlogp += sum(EOS .* logp(ypred,dims=2))
    return -sumlogp
end

s2sgrad = gradloss(s2s);

# ------------------------------------------------------------------------------------------
# <img src="images/s2s-dims.png"/>(<a
# href="https://docs.google.com/drawings/d/1BR871g8k4jpI-
# mKeXiJfpY5Jl5cKcognvH7hHSugQds/edit?usp=sharing">image source</a>)
# ------------------------------------------------------------------------------------------

# A LSTM implementation in Knet

function lstm(param, state, input)
    weight,bias = param
    hidden,cell = state
    h       = size(hidden,2)
    gates   = hcat(input,hidden) * weight .+ bias
    forget  = sigm.(gates[:,1:h])
    ingate  = sigm.(gates[:,1+h:2h])
    outgate = sigm.(gates[:,1+2h:3h])
    change  = tanh.(gates[:,1+3h:4h])
    cell    = cell .* forget + ingate .* change
    hidden  = outgate .* tanh.(cell)
    return (hidden,cell)
end;

# S2S helper functions

function predict(param, input)
    input * param[1] .+ param[2]
end

function initstate(idx, state0)
    h,c = state0
    h = h .+ fill!(similar(value(h), length(idx), length(h)), 0)
    c = c .+ fill!(similar(value(c), length(idx), length(c)), 0)
    return (h,c)
end

function onehotrows(idx, embeddings)
    nrows,ncols = length(idx), size(embeddings,1)
    z = zeros(Float32,nrows,ncols)
    @inbounds for i=1:nrows
        z[i,idx[i]] = 1
    end
    oftype(value(embeddings),z)
end

let EOS=nothing; global eosmatrix
function eosmatrix(idx, embeddings)
    nrows,ncols = length(idx), size(embeddings,1)
    if EOS==nothing || size(EOS) != (nrows,ncols)
        EOS = zeros(Float32,nrows,ncols)
        EOS[:,1] .= 1
        EOS = oftype(value(embeddings), EOS)
    end
    return EOS
end
end;

# Use reversing English words as an example task
# This loads them from /usr/share/dict/words and converts each character to an int.

function readdata(file="words")
    isfile(file) || (file=download("http://people.csail.mit.edu/deniz/models/tutorial/words","words"))
    global strings = map(chomp,readlines(file))
    global tok2int = Dict{Char,Int}()
    global int2tok = Vector{Char}()
    push!(int2tok,'\n'); tok2int['\n']=1 # We use '\n'=>1 as the EOS token                                                 
    sequences = Vector{Vector{Int}}()
    for w in strings
        s = Vector{Int}()
        for c in collect(w)
            if !haskey(tok2int,c)
                push!(int2tok,c)
                tok2int[c] = length(int2tok)
            end
            push!(s, tok2int[c])
        end
        push!(sequences, s)
    end
    return sequences
end;

sequences = readdata();
for x in (sequences, strings, int2tok, tok2int); println(summary(x)); end
for x in strings[501:505]; println(x); end

# Minibatch sequences putting equal length sequences together:

function minibatch(sequences, batchsize)
    table = Dict{Int,Vector{Vector{Int}}}()
    data = Any[]
    for s in sequences
        n = length(s)
        nsequences = get!(table, n, Any[])
        push!(nsequences, s)
        if length(nsequences) == batchsize
            push!(data, [[ nsequences[i][j] for i in 1:batchsize] for j in 1:n ])
            empty!(nsequences)
        end
    end
    return data
end

batchsize, statesize, vocabsize = 128, 128, length(int2tok)
data = minibatch(sequences,batchsize)
summary(data)

# Training loop

function train(model, data, opts)
    sumloss = cntloss = 0
    for sequence in data
        grads,loss = s2sgrad(model, sequence, reverse(sequence))
        update!(model, grads, opts)
        sumloss += loss
        cntloss += (1+length(sequence)) * length(sequence[1])
    end
    return sumloss/cntloss
end

file = "rnnreverse113.jld2"; model = opts = nothing; Knet.gc() # clean memory from previous run
if (print("Train from scratch? ");readline()[1]=='y')
    # Initialize model and optimization parameters
    model = initmodel(statesize,vocabsize)
    opts = optimizers(model,Adam)
    @time for epoch=1:10
        @time loss = train(model,data,opts) # ~17 sec/epoch
        println((epoch,loss))
    end
    Knet.save(file,"model",model)
else
    isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file",file)
    model = Knet.load(file,"model")
end
summary(model)

# Test on some examples:

function translate(model, str)
    state = model[:state0]
    for c in collect(str)
        input = onehotrows(tok2int[c], model[:embed1])
        input = input * model[:embed1]
        state = lstm(model[:encode], state, input)
    end
    input = eosmatrix(1, model[:embed2]) * model[:embed2]
    output = Char[]
    for i=1:100 #while true                                                                                                
        state = lstm(model[:decode], state, input)
        pred = predict(model[:output], state[1])
        i = argmax(vec(Array(pred)))
        i == 1 && break
        push!(output, int2tok[i])
        input = onehotrows(i, model[:embed2]) * model[:embed2]
    end
    String(output)
end;

translate(model,"capricorn")


