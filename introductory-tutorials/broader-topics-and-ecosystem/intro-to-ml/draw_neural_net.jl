using Plots; gr()

function draw_neuron(x, y, r; c=:blue)

    θs = 0:0.1:2pi
    xs = x .+ r.*cos.(θs)
    ys = y .+ r.*sin.(θs)


    plot!(xs, ys, seriestype=:shape, c=c, alpha=0.5, aspect_ratio=1, leg=false)

end


#neuron_coords(x, N, spacing) = range(-(N - 1)/2 * spacing, spacing, N)

"""
Vertical position of neuron in layer i, position j, with a total of N neurons
"""
neuron_coords(j, N, y_spacing) = (-(N - 1)/2 + j) * y_spacing

function draw_neurons(x, N, spacing, r; c=:blue)

    ys = neuron_coords(x, N, spacing)

    draw_neuron.(x, ys, r; c=c)

end


function draw_layer(x, spacing, N1, N2, r)

    plot!(framestyle=:none, grid=:none)

    first_x = x
    second_x = x + 1

    first = neuron_coords(x + 1, N1, spacing)
    second = neuron_coords(x, N2, spacing)

    draw_neurons(x, N1, 1, r; c=:blue)
    draw_neurons(x+1, N2, 1, r; c=:red)

    for i in 1:N1
        for j in 1:N2

            vec = [second_x - first_x, second[j] - first[i]]
            normalize!(vec)

            start = [first_x, first[i]] + 1.2*r*vec
            finish = [second_x, second[j]] - 1.2*r*vec


            plot!([start[1], finish[1]], [start[2], finish[2]], c=:black, alpha=0.5)
        end
    end

end

#draw_layer(1, 1, 3, 4, 0.2)

function draw_link(x1, y1, x2, y2, r)
    vec = [x2 - x1, y2 - y1]
    normalize!(vec)

    start = [x1, y1] + 1.2 * r * vec
    finish = [x2, y2] - 1.2 * r * vec

    plot!([start[1], finish[1]], [start[2], finish[2]], c=:black, alpha=0.5)
end

"""
Takes a vector of neurons per layer
"""
function draw_network(neurons_per_layer)

    x_spacing = 1
    y_spacing = 1
    r = 0.2

    num_layers = length(neurons_per_layer)

    plot(framestyle=:none, grid=:none)

    # draw input links
    N1 = neurons_per_layer[1]

    for j in 1:N1
        y = neuron_coords(j, N1, y_spacing)
        draw_link(0, y, 1, y, r)
    end

    # draw neurons
    for layer in 1:length(neurons_per_layer)
        N = neurons_per_layer[layer]

        if layer == 1
            c = :green
        elseif layer == num_layers
            c = :red
        else
            c = :blue
        end

        for j in 1:N

            draw_neuron(layer, neuron_coords(j, N, y_spacing), r, c=c)

        end
    end

    # draw links
    for layer in 1:length(neurons_per_layer)-1
        N1 = neurons_per_layer[layer]
        N2 = neurons_per_layer[layer+1]

        for j1 in 1:N1
            for j2 in 1:N2

                draw_link(layer,  neuron_coords(j1, N1, y_spacing), layer+1,
                neuron_coords(j2, N2, y_spacing), r)
            end

        end
    end

    # draw output links
    N_last = neurons_per_layer[end]

    for j in 1:N_last
        y = neuron_coords(j, N_last, y_spacing)
        draw_link(num_layers, y, num_layers+1, y, r)
    end

    plot!()

end

draw_network([3, 2, 2])
