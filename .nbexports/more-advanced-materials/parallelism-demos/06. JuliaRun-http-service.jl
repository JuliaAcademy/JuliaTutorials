using JuliaRunClient
ctx = Context()

job = JuliaBatch("mywebserver")

# code for a simple webserver
webserver_script = """
using HttpServer

http = HttpHandler() do req::Request, res::Response
    Response("JuliaRun says hello from " * gethostname())
end

server = Server(http)
run(server, 8000)        
"""

open("/mnt/juliabox/helloweb.jl", "w") do f
    println(f, webserver_script)
end

# start a webserver job, specifying port 8000 to be opened up
@result submitJob(ctx, job; start_script="/mnt/juliabox/helloweb.jl", run_volume="juliabox", image="juliabox", cpu="1", memory="1Gi", shell="/juliabox/scripts/master.sh", ports="8000:8000")

# check that the job has started
@result getJobStatus(ctx, job)

# Get the IP and port that was assigned for the webserver to listen on.
# The webserver may actually be running any of the physical nodes of the cluster.
# And it is running in an isolated container, with its own virtual IP address
# This IP address is accessible only to the user who started the webserver.
ip, portspec = @result getJobEndpoint(ctx, job)

# We can connect to it from here (or anything else run by this user)
using Requests
url = "http://$(ip):$(first(values(portspec)))/"

String(Requests.bytes(get(url)))

# We stop the webserver now
@result deleteJob(ctx, job; force=true)


