module OptOutput

using DataStructures
using DataFrames
using JSON3
using CSV

include("parse_mps.jl")
include("transform_data.jl")
include("extract_data.jl")

function process_optimization_results(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64})
    variable_results, equation_results = extract_data(mps_string, primal_solution, dual_solution)

    predefined_values = create_predefined_values(variable_results)
    case_dimensions = create_case_dimensions(variable_results, predefined_values)
    transformed_dict, dim_to_index, index_to_dim = transform_dict(variable_results, predefined_values, case_dimensions)

    dataframes = create_dataframes(transformed_dict, index_to_dim, case_dimensions)
    

    return dataframes, variable_results, equation_results
end

function save_intermediate_results(variable_results, equation_results, output_dir="output")
    mkpath(output_dir)

    open(joinpath(output_dir, "model_variable_results.json"), "w") do f
        JSON3.write(f, variable_results)
    end

    open(joinpath(output_dir, "model_equation_results.json"), "w") do f
        JSON3.write(f, equation_results)
    end
end

function save_final_results(dataframes, output_dir="output")
    mkpath(output_dir)

    for (case, df) in dataframes
        CSV.write(joinpath(output_dir, "$(case).csv"), df)
    end
end

export process_optimization_results,
       save_intermediate_results,
       save_final_results,
       create_predefined_values,
       create_case_dimensions,
       transform_dict
end