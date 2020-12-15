using GLM
using DataFrames
using StatsBase
using Optim
ρ = 0.8
intercept = 0.0
N = 20 

# generate synthetic data 
global x = randn(N)
y = randn(N) .* sqrt(1.0 - ρ^2) .+ data[:,2] .* ρ .+ intercept
data = DataFrame(y=y,x=x)

# Using GLM
model = lm(@formula(y~x), data)
coef_init = [-1.0,2.0]


f(coef_init) = coef_init[1] .*x .+ coef_init[2]
function return_rmsd(coef_init)
    rmsd(x, f(coef_init))
end
results = optimize(return_rmsd, coef_init)
results.minimizer # coeff estimates from conventional optimization 