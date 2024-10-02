function map_solution_to_sections(sections, solution)
    @assert length(sections) == length(solution) "Sections and solution must have the same length"
    return Dict(section => sol for (section, sol) in zip(sections, solution))
end

function extract_data(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64})
    variables, equations = parse_mps_sections(mps_string)

    variable_results = map_solution_to_sections(variables, primal_solution)
    equation_results = map_solution_to_sections(equations, dual_solution)

    all_results = merge(variable_results, equation_results)

    return all_results
end

function read_solution(solution_file_path)
    return parse.(Float64, readlines(solution_file_path))
end