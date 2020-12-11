# A Simple Random-Walk Model 
using Distributions
using Plots 
# Simulation Parameters

nreps = 10000
nsamples = 2000

# Fixed Parameters
drift = 0.0
std = 0.3
criterion = 3
rnorm = Normal(drift, std)
fixed_parms = [drift,std,criterion, rnorm]



function random_walk(nreps::Int64,nsamples::Int64, fixed_parms...)
    # Initializing free parameters 
    latencies = fill(0, nreps)
    responses = fill(0, nreps)
    evidence = zeros(nreps, nsamples+1)

    for i in 1:nreps
        evidence[i, :] = accumulate(+,pushfirst!(rand(rnorm, nsamples),0))
        p = findfirst(abs.(evidence[1,:]) .> drift)
        responses[i] = sign(evidence[i,p])
        latencies[i] = p 
    end 
end

##### Plot a few random-walk paths
random_walk(nreps,nsamples, fixed_parms...)

plot(evidence[1:5,latencies[1:5] .- 1], 
    legend =false,
    ylims = [-criterion - 0.5, criterion + 0.5],
    xlims = [1, 50])