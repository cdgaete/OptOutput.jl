function map_solution_to_sections(sections, solution)
    return Dict(section => sol for (section, sol) in zip(sections, solution))
end

function extract_data(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64})
    variables, equations = parse_mps_sections(mps_string)

    variable_results = map_solution_to_sections(variables, primal_solution)
    equation_results = map_solution_to_sections(equations, dual_solution)

    return variable_results, equation_results
end