# ------------------------------------------------------------------------------------------
# # Sequence classification model for IMDB Sentiment Analysis
# (c) Deniz Yuret, 2019
# * Objectives: Learn the structure of the IMDB dataset and train a simple RNN model.
# * Prerequisites: [RNN models](60.rnn.ipynb)
# ------------------------------------------------------------------------------------------

# Set display width, load packages, import symbols
ENV["COLUMNS"] = 72
using Pkg; haskey(Pkg.installed(),"Knet") || Pkg.add("Knet")
using Statistics: mean
using Knet: Knet, AutoGrad, RNN, param, dropout, minibatch, nll, accuracy, progress!, adam, save, load, gc

# Set constants for the model and training
EPOCHS=3          # Number of training epochs
BATCHSIZE=64      # Number of instances in a minibatch
EMBEDSIZE=125     # Word embedding size
NUMHIDDEN=100     # Hidden layer size
MAXLEN=150        # maximum size of the word sequence, pad shorter sequences, truncate longer ones
VOCABSIZE=30000   # maximum vocabulary size, keep the most frequent 30K, map the rest to UNK token
NUMCLASS=2        # number of output classes
DROPOUT=0.5       # Dropout rate
LR=0.001          # Learning rate
BETA_1=0.9        # Adam optimization parameter
BETA_2=0.999      # Adam optimization parameter
EPS=1e-08         # Adam optimization parameter

# ------------------------------------------------------------------------------------------
# ## Load and view data
# ------------------------------------------------------------------------------------------

include(Knet.dir("data","imdb.jl"))   # defines imdb loader

@doc imdb

@time (xtrn,ytrn,xtst,ytst,imdbdict)=imdb(maxlen=MAXLEN,maxval=VOCABSIZE);

println.(summary.((xtrn,ytrn,xtst,ytst,imdbdict)));

# Words are encoded with integers
rand(xtrn)'

# Each word sequence is padded or truncated to length 150
length.(xtrn)'

# Define a function that can print the actual words:
imdbvocab = Array{String}(undef,length(imdbdict))
for (k,v) in imdbdict; imdbvocab[v]=k; end
imdbvocab[VOCABSIZE-2:VOCABSIZE] = ["<unk>","<s>","<pad>"]
function reviewstring(x,y=0)
    x = x[x.!=VOCABSIZE] # remove pads
    """$(("Sample","Negative","Positive")[y+1]) review:\n$(join(imdbvocab[x]," "))"""
end

# Hit Ctrl-Enter to see random reviews:
r = rand(1:length(xtrn))
println(reviewstring(xtrn[r],ytrn[r]))

# Here are the labels: 1=negative, 2=positive
ytrn'

# ------------------------------------------------------------------------------------------
# ## Define the model
# ------------------------------------------------------------------------------------------

struct SequenceClassifier; input; rnn; output; pdrop; end

SequenceClassifier(input::Int, embed::Int, hidden::Int, output::Int; pdrop=0) =
    SequenceClassifier(param(embed,input), RNN(embed,hidden,rnnType=:gru), param(output,hidden), pdrop)

function (sc::SequenceClassifier)(input)
    embed = sc.input[:, permutedims(hcat(input...))]
    embed = dropout(embed,sc.pdrop)
    hidden = sc.rnn(embed)
    hidden = dropout(hidden,sc.pdrop)
    return sc.output * hidden[:,:,end]
end

(sc::SequenceClassifier)(input,output) = nll(sc(input),output)

# ------------------------------------------------------------------------------------------
# ## Experiment
# ------------------------------------------------------------------------------------------

dtrn = minibatch(xtrn,ytrn,BATCHSIZE;shuffle=true)
dtst = minibatch(xtst,ytst,BATCHSIZE)
length.((dtrn,dtst))

# For running experiments
function trainresults(file,maker; o...)
    if (print("Train from scratch? "); readline()[1]=='y')
        model = maker()
        progress!(adam(model,repeat(dtrn,EPOCHS);lr=LR,beta1=BETA_1,beta2=BETA_2,eps=EPS))
        Knet.save(file,"model",model)
        Knet.gc() # To save gpu memory
    else
        isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file",file)
        model = Knet.load(file,"model")
    end
    return model
end

maker() = SequenceClassifier(VOCABSIZE,EMBEDSIZE,NUMHIDDEN,NUMCLASS,pdrop=DROPOUT)
# model = maker()
# nll(model,dtrn), nll(model,dtst), accuracy(model,dtrn), accuracy(model,dtst)
# (0.69312066f0, 0.69312423f0, 0.5135817307692307, 0.5096153846153846)

# 2.51e-01  100.00%┣████████████████████┫ 1170/1170 [00:16/00:16, 75.46i/s]
model = trainresults("imdbmodel113.jld2",maker);

#nll(model,dtrn), nll(model,dtst), accuracy(model,dtrn), accuracy(model,dtst)
# (0.059155148f0, 0.3877507f0, 0.9846153846153847, 0.8583733974358975)

# ------------------------------------------------------------------------------------------
# ## Playground
# ------------------------------------------------------------------------------------------

predictstring(x)="\nPrediction: " * ("Negative","Positive")[argmax(Array(vec(model([x]))))]
UNK = VOCABSIZE-2
str2ids(s::String)=[(i=get(imdbdict,w,UNK); i>=UNK ? UNK : i) for w in split(lowercase(s))]

# Here we can see predictions for random reviews from the test set; hit Ctrl-Enter to sample:
r = rand(1:length(xtst))
println(reviewstring(xtst[r],ytst[r]))
println(predictstring(xtst[r]))

# Here the user can enter their own reviews and classify them:
println(predictstring(str2ids(readline(stdin))))
