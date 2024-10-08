module OptOutput

using DataStructures
using DataFrames
using CSV
using QPSReader

include("parse_mps.jl")
include("transform_data.jl")
include("extract_data.jl")

function process_optimization_results(mps_path::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[])
    all_results, model = combine_primal_dual_solutions(mps_path, primal_solution, dual_solution, symbols)

    named_sets, variable_dimensions = create_named_sets_and_dimensions(all_results, nothing, symbols)
    structured_results, dim_to_index, index_to_dim = structure_optimization_results(all_results, named_sets, variable_dimensions)

    result_dataframes = create_result_dataframes(structured_results, index_to_dim, variable_dimensions, symbols)

    return result_dataframes, all_results, model
end

function save_results_to_csv(dataframes::Dict{String, DataFrame}, output_dir::String="output")
    mkpath(output_dir)

    for (symbol, df) in dataframes
        CSV.write(joinpath(output_dir, "$(symbol).csv"), df)
    end
end

export process_optimization_results,
        create_named_sets_and_dimensions,
        create_result_dataframes,
        structure_optimization_results,
        read_solution_from_file,
        save_results_to_csv,
        combine_primal_dual_solutions,
        extract_variables_and_equations_from_mps
end