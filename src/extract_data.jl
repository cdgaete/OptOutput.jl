function combine_primal_dual_solutions(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[])
    variables, equations = extract_variables_and_equations_from_mps(mps_string, symbols)
    
    all_results = OrderedDict{String, Float64}()
    
    for (var, index) in variables
        all_results[var] = primal_solution[index]
    end
    
    for (eq, index) in equations
        all_results[eq] = dual_solution[index]
    end
    
    return all_results
end

function read_solution_from_file(solution_file_path)
    return parse.(Float64, readlines(solution_file_path))
end