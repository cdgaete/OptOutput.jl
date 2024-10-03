function combine_primal_dual_solutions(mps_file_path::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[])
    variables, equations, model = extract_variables_and_equations_from_mps(mps_file_path, symbols)
    
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
    
    # all_results["OBJ"] = dot(model.c, primal_solution) + model.c0
    
    return all_results, model
end

function read_solution_from_file(solution_file_path)
    return parse.(Float64, readlines(solution_file_path))
end