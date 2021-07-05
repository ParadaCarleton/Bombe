module LeaveOneOut

    using ParetoSmooth
    using Statistics
    using StructArrays
    using Tullio
    using VectorizationBase

    export psis_loo, PsisLoo, Loo, AbstractLoo

    const LOO_METHODS = ["psis"]
    

    function psis_loo(log_likelihood::ArrayType,
        score::Function=identity;  # Default to log_likelihood (elpd) score function 
        rel_eff=similar(loo, 0)
        ) where {F<:AbstractFloat, ArrayType<:AbstractArray{F, 3}}
        

        dims = size(log_likelihood)
        data_size = dims[1]
        mcmc_count = dims[2] * dims[3]  # total number of samples from posterior
        # score_array::ArrayType = similar(log_likelihood)
        # score_array .= score(log_likelihood)
        score_array = log_likelihood

        psis_object = psis(log_likelihood, rel_eff)
        weights = psis_object.weights
        ξ = psis_object.pareto_k
        ess = psis_object.ess

        @tullio pointwise_ev[i] := weights[i,j,k] * score_array[i,j,k]
        # Replace with quantile mcse estimate from R LOO package?
        @tullio pointwise_mcse[i] := sqrt <|
            (weights[i,j,k] * score_array[i,j,k] .- pointwise_ev[i])^2 ./ (ess[i] - 1)
        @tullio pointwise_naive[i] := log_likelihood[i,j,k] |> _ / mcmc_count
        pointwise_p_eff = pointwise_ev - pointwise_naive
        points = (
            estimate = pointwise_ev, 
            mcse = pointwise_mcse,
            p_eff = pointwise_p_eff, 
            pareto_k = ξ
            )
        pointwise = StructArray{LooPoint{F}}(points)


        @tullio ev := points.estimate[i]
        @tullio ev_naive := pointwise_naive[i]
        p_eff = ev - ev_naive
        
        ev_se = std(pointwise_ev; mean=ev) / sqrt(data_size)
        p_eff_se = std(pointwise_p_eff; mean=p_eff) / sqrt(data_size)

        vals = Dict("Score Est"=>ev, "Parameters (Eff)"=>p_eff, 
                     "SE(Score Est)"=>ev_se, "SE(Parameters)"=>p_eff_se
                    )

        return PsisLoo(vals, pointwise, psis_object)

    end
    
    # Pointwise entries
    struct LooPoint{F<:AbstractFloat}
        estimate::F
        mcse::F
        p_eff::F
        pareto_k::F
    end

    abstract type AbstractLoo end

    struct PsisLoo{
        F<:AbstractFloat,
        AF<:AbstractArray{F},
        VF<:AbstractVector{F},
        I<:Integer,
        VI<:AbstractVector{I},
    } <: AbstractLoo
        estimates::Dict{String,F}
        pointwise::StructArray{LooPoint{F}}
        psis_object::Psis{F,AF,VF,I,VI}
    end


end