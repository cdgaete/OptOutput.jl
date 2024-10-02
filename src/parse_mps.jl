function count_variables_and_equations(mps_string::String)
    var_count = 0
    eq_count = 0
    current_section = ""
    seen_vars = Set{String}()

    for line in split(mps_string, "\n")
        if startswith(line, "ROWS")
            current_section = "ROWS"
            continue
        elseif startswith(line, "COLUMNS")
            current_section = "COLUMNS"
            continue
        elseif startswith(line, "RHS") || startswith(line, "BOUNDS") || startswith(line, "RANGES")
            break
        end

        parts = split(strip(line))
        if current_section == "ROWS" && length(parts) >= 2 && parts[1] != "N"
            eq_count += 1
        elseif current_section == "COLUMNS" && length(parts) >= 2
            if parts[1] ∉ seen_vars
                var_count += 1
                push!(seen_vars, parts[1])
            end
        end
    end

    return var_count, eq_count
end

function extract_variables_and_equations_from_mps_parallel(mps_string::String, symbols::Vector{String}=String[], num_workers::Int=4)
    total_vars, total_eqs = count_variables_and_equations(mps_string)
    
    lines = split(mps_string, "\n")
    chunk_size = ceil(Int, length(lines) / num_workers)
    chunks = [String.(lines[i:min(i+chunk_size-1, end)]) for i in 1:chunk_size:length(lines)]

    results = @distributed (vcat) for chunk in chunks
        extract_variables_and_equations_from_chunk(chunk, symbols)
    end

    variables = OrderedDict{String, Tuple{Int, Bool}}()
    equations = OrderedDict{String, Tuple{Int, Bool}}()
    var_index = 0
    eq_index = 0
    
    for (chunk_vars, chunk_eqs) in results
        for (var, (_, include)) in chunk_vars
            if !haskey(variables, var)
                var_index += 1
                variables[var] = (var_index, include)
            end
        end
        for (eq, (_, include)) in chunk_eqs
            if !haskey(equations, eq)
                eq_index += 1
                equations[eq] = (eq_index, include)
            end
        end
    end

    @assert length(variables) == total_vars "Mismatch in variable count: extracted $(length(variables)), expected $total_vars"
    @assert length(equations) == total_eqs "Mismatch in equation count: extracted $(length(equations)), expected $total_eqs"

    @info "Extracted $(length(variables)) variables and $(length(equations)) equations from MPS file"

    return variables, equations
end

function extract_variables_and_equations_from_chunk(chunk::Vector{String}, symbols::Vector{String})
    variables = OrderedDict{String, Tuple{Int, Bool}}()
    equations = OrderedDict{String, Tuple{Int, Bool}}()
    current_section = ""
    symbol_set = isempty(symbols) ? nothing : Set(symbols)

    for line in chunk
        if startswith(line, "ROWS")
            current_section = "ROWS"
            continue
        elseif startswith(line, "COLUMNS")
            current_section = "COLUMNS"
            continue
        elseif startswith(line, "RHS") || startswith(line, "BOUNDS") || startswith(line, "RANGES")
            break
        end

        parts = split(strip(line))
        if current_section == "ROWS" && length(parts) >= 2
            if parts[1] == "N"
                continue
            end
            eq_prefix = split(parts[2], '[', limit=2)[1]
            equations[parts[2]] = (0, symbol_set === nothing || eq_prefix in symbol_set)
        elseif current_section == "COLUMNS" && length(parts) >= 2
            var_prefix = split(parts[1], '[', limit=2)[1]
            if !haskey(variables, parts[1])
                variables[parts[1]] = (0, symbol_set === nothing || var_prefix in symbol_set)
            end
        end
    end

    return (variables, equations)
end

function extract_variables_and_equations_from_mps(mps_string::String, symbols::Vector{String}=String[])
    variables = OrderedDict{String, Tuple{Int, Bool}}()
    equations = OrderedDict{String, Tuple{Int, Bool}}()
    current_section = ""
    symbol_set = isempty(symbols) ? nothing : Set(symbols)
    var_index = 0
    eq_index = 0

    for line in split(mps_string, "\n")
        if startswith(line, "ROWS")
            current_section = "ROWS"
            continue
        elseif startswith(line, "COLUMNS")
            current_section = "COLUMNS"
            continue
        elseif startswith(line, "RHS") || startswith(line, "BOUNDS") || startswith(line, "RANGES")
            break
        end

        parts = split(strip(line))
        if current_section == "ROWS" && length(parts) >= 2
            if parts[1] == "N"
                continue
            end
            eq_index += 1
            eq_prefix = split(parts[2], '[', limit=2)[1]
            equations[parts[2]] = (eq_index, symbol_set === nothing || eq_prefix in symbol_set)
        elseif current_section == "COLUMNS" && length(parts) >= 2
            var_prefix = split(parts[1], '[', limit=2)[1]
            if !haskey(variables, parts[1])
                var_index += 1
                variables[parts[1]] = (var_index, symbol_set === nothing || var_prefix in symbol_set)
            end
        end
    end

    return variables, equations
end