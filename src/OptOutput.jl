module OptOutput

using DataStructures
using DataFrames
using JSON3
using CSV

include("parse_mps.jl")
include("transform_data.jl")
include("extract_data.jl")

function process_optimization_results(mps_path::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[])
    mps_string = read(mps_path, String)
    all_results = extract_data(mps_string, primal_solution, dual_solution)

    named_unique, prefix_dim_names = create_predefined_values(all_results)
    transformed_dict, dim_to_index, index_to_dim = transform_dict(all_results, named_unique, prefix_dim_names)

    dataframes = create_dataframes(transformed_dict, index_to_dim, prefix_dim_names, symbols)

    return dataframes, all_results
end

function save_results(dataframes::Dict{String, DataFrame}, output_dir::String="output")
    mkpath(output_dir)

    for (symbol, df) in dataframes
        CSV.write(joinpath(output_dir, "$(symbol).csv"), df)
    end
end

export process_optimization_results,
        create_predefined_values,
        create_dataframes,
        transform_dict,
        read_solution,
        save_results,
        extract_data
end