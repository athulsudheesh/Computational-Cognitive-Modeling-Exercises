using GLM
using DataFrames
using StatsBase
using Optim
using Plots
using MixedModels
using Random
using Distributions

ρ = 0.8
intercept = 0.0
N = 20 

# generate synthetic data
data = zeros(N,2) 
global x = randn(N)
y = randn(N) .* sqrt(1.0 - ρ^2) .+ data[:,2] .* ρ .+ intercept
data = DataFrame(y=y,x=x)

# Using GLM
model = lm(@formula(y~x), data)
coef_init = [-1.0,2.0]


fun(coef_init) = coef_init[1] .*x .+ coef_init[2]

results = optimize(x -> rmsd(y,fun(x)), coef_init)
results.minimizer # coeff estimates from conventional optimization 

#TODO: Implement plot to illustrate curve fitting... 

# ==================================================================

# Carpenter et al. (2008) study 
function powerdiscrepency(param, rec, ri)
    pow_pred = zeros(length(ri))
    if all(elements < 0 || elements > 1 for elements in param)
        return 1e6
    end
    pow_pred .= param[1] .* (param[2] .* ri .+1).^(-param[3])
    return sqrt(sum((pow_pred .- rec).^2) / length(ri))
end

rec = [0.93, 0.88, 0.86, 0.66, 0.47, 0.34]
ri = [0.0035, 1.0, 2.0, 7.0, 14.0, 42]
#Initializing starting values 
sparams = [1.0, 0.5, 0.7]


pout = optimize(x -> powerdiscrepency(x, rec, ri), sparams)
pout.minimizer # estimates
pow_pred = pout.minimizer[1] .* (pout.minimizer[2] .* Int.(0:1:maximum(ri)) .+1).^(-pout.minimizer[3])

# Plot 
scatter(ri,rec,
            xlabel = "Retention Interval (days)", 
            ylabel = "Proportion Items Retained",
            markerstrokewidth=1, alpha=0.75,
            ylims = [0.3,1], xlims = [0,43], framestyle=:box,
            grid = false, legend=false, xticks=(0:3:45), yaxis=0, yticks=(0:0.1:1))

plot!(Int.(0:1:maximum(ri)),pow_pred, fa =2)

## Parametric Bootstrap Analysis 
nbs = 1000
ns = 55

bsamples = Array{Float64}(undef, 1000, length(sparams))
for i in 1:nbs
    idx = sample(1:6,6)
    new_rec =  mean(rand.(Binomial.(1,pow_pred),6))
    bsamples[i,:] = optimize(x -> powerdiscrepency(x, new_rec, ri), sparams).minimizer
end
sparams