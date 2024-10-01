module OptOutput

using JuMP
using DataStructures
using DataFrames
using JSON3

include("parse_mps.jl")
include("transform_data.jl")
include("extract_data.jl")


function process_optimization_model(model::Model)
    # Get the MPS string representation of the model
    io = IOBuffer()
    write_to_file(model, io, format=MOI.FileFormats.MPS.Model)
    mps_string = String(take!(io))

    # Solve the model
    optimize!(model)

    # Get primal and dual solutions
    primal_solution = value.(all_variables(model))
    dual_solution = dual.(all_constraints(model, AffExpr, MOI.EqualTo{Float64}))

    # Extract data
    variable_results, equation_results = extract_data(mps_string, primal_solution, dual_solution)

    # Transform data
    predefined_values = create_predefined_values(variable_results)
    case_dimensions = create_case_dimensions(variable_results, predefined_values)
    transformed_dict, dim_to_index, index_to_dim = transform_dict(variable_results, predefined_values, case_dimensions)

    # Create DataFrames
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

export process_optimization_model,
       save_intermediate_results,
       save_final_results

end # module