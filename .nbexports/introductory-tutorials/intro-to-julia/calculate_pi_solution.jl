# ------------------------------------------------------------------------------------------
# ## How can we calculate $\pi$?
#
# Given a square of length $2r$, the square's area is
#
# $$A_{square} = (2r)^2 = 4r^2$$
#
# whereas the area of a circle with radius $r$ is
# $$A_{circle} = \pi r^2$$
#
# <img src="images/area_ratio.png" alt="Drawing" style="width: 400px;"/>
#
# Therefore the ratio of the area of the circle to that of the square above is
#
# $$\frac{A_{circle}}{A_{square}} = \frac{\pi r^2}{4r^2} = \frac{\pi}{4}$$
#
# and we can define $\pi$ as
#
# $$\pi = 4\frac{A_{circle}}{A_{square}}$$
#
# This suggests a way to calculate $\pi$: if we have a square and the largest circle that
# fits inside that square, we can determine the ratio of areas of a circle and a square. We
# can calculate this ratio using a monte carlo simulation. We select random points inside a
# square, and we keep track of how often those points also fall inside the circle that fits
# perfectly inside that square.
#
# Given a large enough sampling points, $\frac{A_{circle}}{A_{square}}$ will be equal to the
# fraction of randomly chosen points inside the square that also fall inside the circle.
# Then we can figure out $\pi$!
#
# #### Pseudo-code
#
# Given the above, our algorithm for determining $\pi$ looks like this:
#
# 1. For each of $N$ iterations,
#     1. Select a random point inside a square of area $4r^2$ as Cartesian, $(x, y)$,
# coordinates.
#     1. Determine if the point also falls inside the circle embedded within this square of
# area $\pi r^2$.
#     1. Keep track of whether or not this point fell inside the circle. At the end of $N$
# iterations, you want to know $M$ -- the number of the $N$ random points that fell inside
# the circle!
# 1. Calculate $\pi$ as $4\frac{M}{N}$
#
# #### Exercise
#
# Write a function that calculates $\pi$ using Julia.
#
# The algorithm above should work for any value of $r$ that you choose to use. Make sure you
# make $N$ big enough that the value of $\pi$ is correct to at least a couple numbers after
# the decimal point!
#
# *Hint*:
#
# This will probably be easier if you center your circle and square at the coordinate (0, 0)
# and use a radius of 1. For example, to choose random coordinates within your square at
# position (x, y), you may want to choose x and y so that they are each a value between -1
# and +1. Then any point within a distance of 1 from (0, 0) will fall inside the circle!
#
# <img src="images/hint.png" alt="Drawing" style="width: 400px;"/>
#
#
# #### Solution
#
# In what follows are two functions, `calculate_pi` and `calculate_pi_2`. They use the same
# algorithm to determine `pi` with a couple minor differences in execution. Each of these
# functions is then called to show that as the number of samples, `N`, increases, our value
# for `pi` becomes more precise.
# ------------------------------------------------------------------------------------------

"""
calculate_pi(N = 1000)

Return the value of pi, calculated using a Monte Carlo simulation with N samples. N defaults to 1000.
The radius of the circle, r, defaults to 1.
"""
function calculate_pi(N = 1000)
    how_often_in_circle = 0
    for i in 1:N
        # Generate a random point (x, y) inside the square centered at (0, 0) 
        # that has corners at (-1, 1), (-1, 1), (1, -1), and (1, 1)
        x, y = rand([-1, 1])*rand(), rand([-1, 1])*rand()
        # Check if the distance to (x, y) from (0, 0) is less than the radius of 1
        if sqrt(x^2 + y^2) < 1
            how_often_in_circle += 1
        end
    end
    return 4 * how_often_in_circle / N
end

calculate_pi.([10, 100, 1000, 10000, 100_000, 1_000_000_000])

"""
calculate_pi_2(N = 1000)

Return the value of pi, calculated using a Monte Carlo simulation with N samples. N defaults to 1000.
The radius of the circle, r, defaults to 1.
"""
function calculate_pi_2(N = 1000)
    how_often_in_circle = 0
    for i in 1:N
        # Generate a random point (x, y) inside the square centered at (0, 0) 
        # that has corners at (-1, 1), (-1, 1), (1, -1), and (1, 1)
        x = 1-2*rand()
        y = 1-2*rand()
        # Check if the distance to (x, y) from (0, 0) is less than the radius of 1
        if x^2 + y^2 < 1
            how_often_in_circle += 1
        end
    end
    return 4 * how_often_in_circle / N
end

calculate_pi.([10, 100, 1000, 10000, 100_000, 1_000_000_000])
