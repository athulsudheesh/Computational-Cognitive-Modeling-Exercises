# A Simple Random-Walk Model 
using Distributions

# Simulation Parameters
nreps = 10000
nsamples = 2000

# Fixed Parameters
drift = 0.0
std = 0.3
criterion = 3

# Free Parameters
latencies = fill(0, nreps)
responses = fill(0, nreps)
evidence = zeros(nreps, nsamples+1)

for i in 1:nreps
    evidence[i, :] = accumulate(+,[0 rand(Normal(drift, std), nsamples)...])
    p = findfirst(x-> abs(x) > criterion, evidence[i,:])
    responses[i] = sign(evidence[i,p])
    latencies[i] = p 
end 
