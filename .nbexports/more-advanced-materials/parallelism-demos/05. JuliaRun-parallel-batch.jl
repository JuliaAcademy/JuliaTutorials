# ------------------------------------------------------------------------------------------
# ## Juliabox is based on JuliaRun
#
# The distributed compute facilities in JuliaBox are provided by
# [JuliaRun](https://juliacomputing.com/products/juliarun.html), Julia Computing's solution
# for scaling Julia processes. There are available in JuliaBox via the `JuliaRunClient`
# package, which allows you to run interactive or batch distributed processes.
#
# For the free edition of JuliaBox, users are limited to 2 CPU cores. For running larger
# clusters, please contact `juliabox@juliacomputing.com`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Understanding the cluster
#
# `JuliaRunClient` provides a `Context` object which is the entry point into the cluster.
# All operations need a reference to this object
# ------------------------------------------------------------------------------------------

using JuliaRunClient
ctx = Context()

# ------------------------------------------------------------------------------------------
# Let's see if we can connect to the cluster
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# #### Running batch job
#
# JuliaRun is well suited to run batch processes in a distributed environment. We have below
# an example of running the Monte Carlo Pi computation as batch job.
#
# First, we create an instance of a `JuliaParBatch` object, with name _mcpi_
# ------------------------------------------------------------------------------------------

job = JuliaParBatch("mcpi")

# ------------------------------------------------------------------------------------------
# We then _submit_ the job to the *JuliaRun* system, providing it with the scripts to run on
# the master and worker nodes, as well as the attached filesystem volume names. Update
# `num_workers`, `master_cpu`, `master_mem`,`worker_cpu` and `worker_memory`  as
# appropriate.
# ------------------------------------------------------------------------------------------

num_workers=2
master_cpu=1
master_mem="2Gi"
worker_cpu=1
worker_memory="2Gi"

@result submitJob(ctx, job; start_script="/juliabox/scripts/mcpi_pmap_master.jl",
        run_volume="juliabox", image="juliabox", nworkers=num_workers,
        cpu=master_cpu, memory=master_mem,
        shell="/juliabox/scripts/master.sh", worker_shell="/juliabox/scripts/worker.sh",
        worker_cpu=worker_cpu, worker_memory=worker_memory,
        worker_start_script="/juliabox/scripts/mcpi_pmap_worker.jl")

# Wait for a while
sleep(25)

# ------------------------------------------------------------------------------------------
# While the job is running, we can query it's status.
# ------------------------------------------------------------------------------------------

@result getJobStatus(ctx, job)

# ------------------------------------------------------------------------------------------
# The logs for the job is visible on the shared filesystem
# ------------------------------------------------------------------------------------------

# Wait for a while to see the output
sleep(20)

;tail /mnt/juliabox/logs/output1

# ------------------------------------------------------------------------------------------
# Once the job is completed, we can clean it up and free it's resources. Again, this is
# important to do for cost reasons.
# ------------------------------------------------------------------------------------------

@result deleteJob(ctx, job; force=true)

;rm -f /mnt/juliabox/logs/output1


