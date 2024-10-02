using DataStructures

function combine_primal_dual_solutions(mps_string::String, primal_solution::Vector{Float64}, dual_solution::Vector{Float64}, symbols::Vector{String}=String[])
    variables, equations = extract_variables_and_equations_from_mps(mps_string)
    
    symbol_set = Set(symbols)
    
    all_results = OrderedDict{String, Float64}()
    
    for (i, var) in enumerate(variables)
        prefix = split(var, '[', limit=2)[1]
        if isempty(symbols) || prefix in symbol_set
            all_results[var] = primal_solution[i]
        end
    end
    
    for (i, eq) in enumerate(equations)
        prefix = split(eq, '[', limit=2)[1]
        if isempty(symbols) || prefix in symbol_set
            all_results[eq] = dual_solution[i]
        end
    end
    
    return all_results
end

function read_solution_from_file(solution_file_path)
    return parse.(Float64, readlines(solution_file_path))
end