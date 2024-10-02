using JuMP
using cuPDLP
using OptOutput

function create_model()
    model = Model()

    products = ["A", "B", "C"]
    factories = ["F1", "F2"]
    periods = 1:4
    
    production_cost = Dict(
        ("A", "F1") => 10, ("A", "F2") => 12,
        ("B", "F1") => 11, ("B", "F2") => 10,
        ("C", "F1") => 13, ("C", "F2") => 14,
    )
    
    demand = Dict(
        ("A", 1) => 100, ("A", 2) => 120, ("A", 3) => 80,  ("A", 4) => 90,
        ("B", 1) => 80,  ("B", 2) => 90,  ("B", 3) => 100, ("B", 4) => 110,
        ("C", 1) => 120, ("C", 2) => 110, ("C", 3) => 130, ("C", 4) => 100,
    )
    
    capacity = Dict(
        "F1" => 500, "F2" => 450,
    )
    
    @variable(model, x[products, factories, periods] >= 0)
    
    @objective(model, Min, sum(production_cost[p, f] * x[p, f, t] for p in products, f in factories, t in periods))
    
    @constraint(model, demand_constraint[p in products, t in periods],
        sum(x[p, f, t] for f in factories) == demand[p, t])
    
    @constraint(model, capacity_constraint[f in factories, t in periods],
        sum(x[p, f, t] for p in products) <= capacity[f])

    return model
end

function model_to_mps_file(model, output_dir)
    if !isdir(output_dir)
        mkpath(output_dir)
    end
    mps_file_path = joinpath(output_dir, "model.mps")
    write_to_file(model, mps_file_path)
    return mps_file_path
end

function solve_with_cupdlp(mps_file_path)
    lp = cuPDLP.qps_reader_to_standard_form(mps_file_path)

    restart_params = cuPDLP.construct_restart_parameters(
        cuPDLP.ADAPTIVE_KKT,
        cuPDLP.KKT_GREEDY,
        1000,
        0.36,
        0.2,
        0.8,
        0.5,
    )

    termination_params = cuPDLP.construct_termination_criteria(
        eps_optimal_absolute = 1e-4,
        eps_optimal_relative = 1e-4,
        eps_primal_infeasible = 1e-8,
        eps_dual_infeasible = 1e-8,
        time_sec_limit = 3600.0,
        iteration_limit = typemax(Int32),
        kkt_matrix_pass_limit = Inf,
    )

    params = cuPDLP.PdhgParameters(
        10,
        false,
        1.0,
        1.0,
        true,
        2,
        true,
        64,
        termination_params,
        restart_params,
        cuPDLP.AdaptiveStepsizeParams(0.3, 0.6),
    )

    output = cuPDLP.optimize(params, lp)
    return output.primal_solution, output.dual_solution
end

function main()
    output_dir = "example/output_dims"
    if !isdir(output_dir)
        mkpath(output_dir)
    end

    model = create_model()

    mps_file_path = model_to_mps_file(model, output_dir)

    primal_solution, dual_solution = solve_with_cupdlp(mps_file_path)

    dataframes, _ = process_optimization_results(mps_file_path, primal_solution, dual_solution)

    save_results_to_csv(dataframes, output_dir)

    println("Optimization completed. Results saved in the '$(output_dir)' directory.")
end

main()