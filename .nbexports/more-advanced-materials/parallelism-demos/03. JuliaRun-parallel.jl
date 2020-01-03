using JuliaRunClient

initializeCluster(2);

function estimate_pi(N, loops)         
    n = sum(pmap((x)->darts_in_circle(N), 1:loops))   
    4 * n / (loops * N)                
end

@everywhere function darts_in_circle(N)  
    n = 0                      
    for i in 1:N                       
        if rand()^2 + rand()^2 < 1     
            n += 1                     
        end                             
    end                                 
    n                                  
end

estimate_pi(10, 2) #compile the function on all nodes

@time estimate_pi(1_000_000, 50)

releaseCluster();

## Ignore if you see a message as below
## ERROR (unhandled task failure): EOFError: read end of file or ERROR (unhandled task failure): read: connection reset by peer (ECONNRESET)

sleep(30)

nworkers()


