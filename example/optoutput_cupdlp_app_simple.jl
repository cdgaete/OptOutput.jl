using JuMP
using cuPDLP
using OptOutput

function create_model()
    model = Model()
    @variable(model, x >= 0)
    @variable(model, 0 <= y <= 3)
    @variable(model, z <= 1)
    @objective(model, Min, 12x + 20y - z)
    @constraint(model, c1, 6x + 8y >= 100)
    @constraint(model, c2, 7x + 12y >= 120)
    @constraint(model, c3, x + y <= 20)
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
    output_dir = "output_simple"
    if !isdir(output_dir)
        mkpath(output_dir)
    end

    model = create_model()

    mps_file_path = model_to_mps_file(model, output_dir)

    primal_solution, dual_solution = solve_with_cupdlp(mps_file_path)

    dataframes, all_results = process_optimization_results(mps_file_path, primal_solution, dual_solution)

    save_results(dataframes, output_dir)

    println("Optimization completed. Results saved in the '$(output_dir)' directory.")
end

main()