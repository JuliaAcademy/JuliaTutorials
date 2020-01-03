# ------------------------------------------------------------------------------------------
# ## Model complexity
#
# In the last notebook, we saw that we could customize a model by adding a parameter. Doing
# so, we were able to fit that model to a data point. This fit was perfect, insofar as
# numerics would allow.
#
# In the next notebook, we'll see that as we add more data to our data set, fitting a model
# to our data usually becomes more challenging and the result will be less perfect.
#
# For one thing, we will find that we can add complexity to our model to capture added
# complexity in the data. We can do this by adding more parameters to our model. We'll see
# that for a data set with two data points, we can again get a "perfect" fit to our model by
# adding a second parameter to our model.
#
# However, we can't simply add a parameter to our model every time we add a data point to
# our data set, since this will lead to a phenomenon called **overfitting**.
#
# In the image below, we depict a data set that is close to linear, and models that exhibit
# underfitting, fitting well, and overfitting, from left to right:
#
# <img src="data/model_fitting.png" alt="Drawing" style="width: 800px;"/>
#
#
# In the first image, the model accounts for the slope along which the data falls, but not
# the offset.
#
# In the second image, the model accounts for both the slope and offset of the  data. Adding
# this second parameter (the offset) to the model creates a much better fit.
#
# However, we can imagine that a model can have too many parameters, where we begin to fit
# not only the high level features of the data, but also the noise. This overfitting is
# depicted in the third image.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Our aim will be to fit the data well, but avoiding *over*fitting the data!
# ------------------------------------------------------------------------------------------
