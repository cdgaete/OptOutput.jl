function combine_primal_dual_solutions(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[])
    variables, equations = extract_variables_and_equations_from_mps(mps_string, symbols)
    
    all_results = OrderedDict{String, Float64}()
    
    for (var, (index, include)) in variables
        if include
            all_results[var] = primal_solution[index]
        end
    end
    
    for (eq, (index, include)) in equations
        if include
            all_results[eq] = dual_solution[index]
        end
    end
    
    return all_results
end

function read_solution_from_file(solution_file_path)
    return parse.(Float64, readlines(solution_file_path))
end

function combine_primal_dual_solutions_parallel(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[], num_workers::Int=4)
    variables, equations = extract_variables_and_equations_from_mps_parallel(mps_string, symbols, num_workers)
    
    @assert length(primal_solution) == length(variables) "Mismatch between primal solution length and number of variables"
    @assert length(dual_solution) == length(equations) "Mismatch between dual solution length and number of equations"
    
    all_results = OrderedDict{String, Float64}()

    for (name, (index, include)) in variables
        if include
            all_results[name] = primal_solution[index]
        end
    end

    for (name, (index, include)) in equations
        if include
            all_results[name] = dual_solution[index]
        end
    end
    
    return all_results
end