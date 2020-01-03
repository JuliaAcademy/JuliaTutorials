# ------------------------------------------------------------------------------------------
# # Express path to classifying images
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# In this notebook, we will show how to run classification software similar to how Google
# images works.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia allows us to load in various pre-trained models for classifying images, via the
# `Metalhead.jl` package.
# ------------------------------------------------------------------------------------------

using Metalhead  # To run type <shift> + enter
using Metalhead: classify

using Images

# ------------------------------------------------------------------------------------------
# Let's download an image of an elephant:
# ------------------------------------------------------------------------------------------

download("http://www.mikebirkhead.com/images/EyeForAnElephant.jpg", "elephant.jpg")

image = load("elephant.jpg") # open up a new cell type ESC + b (for below)

# ------------------------------------------------------------------------------------------
# We'll use the VGG19 model, which is a deep convolutional neural network trained on a
# subset of the ImageNet database. As this is your first notebook, very likely the words
# "convolutional", and "neural net," and "deep," may seem mysterious.  At the end of this
# course these words will no longer be mysterious.
# ------------------------------------------------------------------------------------------

vgg = VGG19()

# ------------------------------------------------------------------------------------------
# Neural networks contain letters.  Here we will display the layers.
# ------------------------------------------------------------------------------------------

for i=1:28
  println(vgg.layers[i])
end

# ------------------------------------------------------------------------------------------
# To classify the image using the model, we just run the following command, and it returns
# its best guess at a classification:
# ------------------------------------------------------------------------------------------

image

classify(vgg, image)

# ------------------------------------------------------------------------------------------
# Exercise: grab a favorite image, then classify it. Tell us what you got!
# ------------------------------------------------------------------------------------------

# hint: mimic cells 2,3, and 8
# then send us all a text

# ------------------------------------------------------------------------------------------
# We can do the same with any image we have around, for example Alan's dog, Philip:
# ------------------------------------------------------------------------------------------

image = load("data/philip.jpg")

classify(vgg, image)

# ------------------------------------------------------------------------------------------
# ## What is going on here?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# VGG19 classifies images according to the following 1000 different classes:
# ------------------------------------------------------------------------------------------

Metalhead.imagenet_classes[rand(1:1000,1,1)]

# ------------------------------------------------------------------------------------------
# The model is a Convolutional Neural Network (CNN), made up of a sequence of layers of
# "neurons" with interconnections. The huge number of parameters making up these
# interconnections have previously been learnt to correctly predict a set of training images
# representing each class.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Running the model on an image spits out the probability that the model assigns to each
# class:
# ------------------------------------------------------------------------------------------

probs = Metalhead.forward(vgg, image)


# ------------------------------------------------------------------------------------------
# We can now see which are the most likely few labels:
# ------------------------------------------------------------------------------------------

perm = sortperm(probs)
probs[273]

[ Metalhead.imagenet_classes(vgg)[perm] probs[perm] ][end:-1:end-10, :]

# ------------------------------------------------------------------------------------------
# ## What are the questions to get a successful classifier via machine learning?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# The key questions to obtain a successful classifier in machine learning are:
#
# - How do we define a suitable model that can model the data adequately?
#
# - How do we train it on suitably labelled data?
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# These are the questions that this course is designed to address.
# ------------------------------------------------------------------------------------------
