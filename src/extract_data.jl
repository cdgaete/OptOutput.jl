function map_solution_to_variables_and_equations(sections, solution)
    @assert length(sections) == length(solution) "Sections and solution must have the same length"
    return Dict(section => sol for (section, sol) in zip(sections, solution))
end

function combine_primal_dual_solutions(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64})
    variables, equations = extract_variables_and_equations_from_mps(mps_string)

    variable_results = map_solution_to_variables_and_equations(variables, primal_solution)
    equation_results = map_solution_to_variables_and_equations(equations, dual_solution)

    all_results = merge(variable_results, equation_results)

    return all_results
end

function read_solution_from_file(solution_file_path)
    return parse.(Float64, readlines(solution_file_path))
end