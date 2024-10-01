module OptOutput

using DataStructures
using DataFrames
using JSON3
using CSV

include("parse_mps.jl")
include("transform_data.jl")
include("extract_data.jl")

function process_optimization_results(mps_path::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, cases::Vector{String}=String[])
    mps_string = read(mps_path, String)
    all_results = extract_data(mps_string, primal_solution, dual_solution)

    predefined_values = create_predefined_values(all_results)
    case_dimensions = create_case_dimensions(all_results, predefined_values)
    transformed_dict, dim_to_index, index_to_dim = transform_dict(all_results, predefined_values, case_dimensions)

    dataframes = create_dataframes(transformed_dict, index_to_dim, case_dimensions, cases)

    return dataframes, all_results
end

function save_results(dataframes::Dict{String, DataFrame}, output_dir::String="output")
    mkpath(output_dir)

    for (case, df) in dataframes
        CSV.write(joinpath(output_dir, "$(case).csv"), df)
    end
end

export process_optimization_results,
       save_results,
       create_predefined_values,
       create_case_dimensions,
       transform_dict

end