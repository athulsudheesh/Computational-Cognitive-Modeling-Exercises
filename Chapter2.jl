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


# Random Walk Simulation 
function random_walk(nreps::Int64,nsamples::Int64, fixed_parms...)
    # Initializing free parameters 
    latencies = fill(0, nreps)
    responses = fill(0, nreps)
    evidence = zeros(nreps, nsamples+1)

    for i in 1:nreps
        evidence[i, :] = accumulate(+,pushfirst!(rand(rnorm, nsamples),0))
        p = findfirst(abs.(evidence[i,:]) .> criterion)
        responses[i] = sign(evidence[i,p])
        latencies[i] = p 
    end 
    return evidence, responses, latencies
end

## Plot the random walk path 
function plot_rw_path(evidence, latencies, criterion)
    plot([evidence[i, 1:(latencies[i])] for i in 1:5],
        legend = false, 
        ylims = [-criterion - 0.5, criterion + 0.5], 
        xlims = maximum(latencies[1:5]), 
        xlabel = "Decision Time", 
        ylabel = "Evidence", 
        grid = false)
hline!([criterion, -criterion], line =:dash)
end


evidence, responses, latencies = random_walk(nreps,nsamples, fixed_parms...)
plot_rw_path(evidence, latencies, criterion)

# savefig("random_walk_path.png")