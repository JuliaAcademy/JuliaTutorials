# ------------------------------------------------------------------------------------------
# # Visual Q&A Demo
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Setup
# 1-Adds required packages to Julia.
# 2-Downloads sample data and a pretrained model.
# ------------------------------------------------------------------------------------------

include("demosetup.jl")

# ------------------------------------------------------------------------------------------
# ## Initialization
# 1-Loads the sample demo data (image features,questions,vocabulary).
# 2-Loads the pretrained model.
# ------------------------------------------------------------------------------------------

include("src/newmacnetwork.jl")
feats,qstsns,(w2i,a2i,i2w,i2a) = loadDemoData("data/demo/");
_,wrun,r,_,p = loadmodel("models/macnet.jld";onlywrun=true);
if !(typeof(first(wrun)) <: atype)
    wrun = map(atype,wrun);
end;

# ------------------------------------------------------------------------------------------
# ## Sample Data
# 1-Randomly selects (question,image) pair from the sample data
# 2-Make predictions for the question and checks whether the prediction is correct
# ------------------------------------------------------------------------------------------

rnd        = rand(1:length(qstsns))
inst       = qstsns[rnd]
feat       = feats[:,:,:,rnd:rnd]
question   = Array{Int}(inst[2])
answer     = inst[3];
family     = inst[4];
results,prediction = singlerun(wrun,r,feat,question;p=p);
answer==prediction

img = load("data/demo/CLEVR_v1.0/images/val/$(inst[1])")

textq  = i2w[question];
println("Question: ",join(textq," "))
texta  = i2a[answer];
println("Answer: $(texta)\nPrediction: $(i2a[prediction]) ")

# ------------------------------------------------------------------------------------------
# ## User Data
# You can enter your own question about the image and test whether the prediction is correct
# ------------------------------------------------------------------------------------------

userinput = readline(STDIN)
words = split(userinput) # tokenize(userinput)
question = [get!(w2i,wr,1) for wr in words]
results,prediction = singlerun(wrun,r,feat,question;p=p);
println("Question: $(join(i2w[question]," "))")
println("Prediction: $(i2a[prediction])")

# ------------------------------------------------------------------------------------------
# ## Visualize
# `visualize` function visualizes attention maps for each time step of the mac network
# ------------------------------------------------------------------------------------------

visualize(img,results;p=p)


