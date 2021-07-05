using Bombe
using Test

import RData

let og_array = RData.load("test/Example_Log_Likelihood_Array.RData")["x"]
    global ll_arr = copy(permutedims(og_array, [3, 1, 2]))
end
let og_weights = RData.load("test/weightMatrix.RData")["weightMatrix"]
    global r_weights = exp.(permutedims(reshape(og_weights, 500, 2, 32), [3, 1, 2]))
end
rel_eff = RData.load("test/Rel_Eff.RData")["rel_eff"]
r_loo = RData.load("test/Example_Loo.RData")["example_loo"]
with_rel_eff = psis_loo(ll_arr; rel_eff = rel_eff)

@testset "Bombe.jl" begin
    
end
