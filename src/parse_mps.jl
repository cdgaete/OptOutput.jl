using Distributed
using OrderedCollections

function extract_variables_and_equations_from_mps_parallel(mps_string::String, symbols::Vector{String}=String[], num_workers::Int=4)
    lines = split(mps_string, "\n")
    chunk_size = ceil(Int, length(lines) / num_workers)
    chunks = [lines[i:min(i+chunk_size-1, end)] for i in 1:chunk_size:length(lines)]

    results = @distributed (merge) for chunk in chunks
        extract_variables_and_equations_from_chunk(chunk, symbols)
    end

    variables, equations = results
    return variables, equations
end

function extract_variables_and_equations_from_chunk(chunk::Vector{String}, symbols::Vector{String})
    variables = OrderedDict{String, Tuple{Int, Bool}}()
    equations = OrderedDict{String, Tuple{Int, Bool}}()
    current_section = ""
    symbol_set = isempty(symbols) ? nothing : Set(symbols)
    var_index = 0
    eq_index = 0

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

    return (variables, equations)
end

function extract_variables_and_equations_from_mps(mps_string::String, symbols::Vector{String}=String[])
    variables = OrderedDict{String, Int}()
    equations = OrderedDict{String, Int}()
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
            eq_prefix = split(parts[2], '[', limit=2)[1]
            if symbol_set === nothing || eq_prefix in symbol_set
                eq_index += 1
                equations[parts[2]] = eq_index
            end
        elseif current_section == "COLUMNS" && length(parts) >= 2
            var_prefix = split(parts[1], '[', limit=2)[1]
            if symbol_set === nothing || var_prefix in symbol_set
                if !haskey(variables, parts[1])
                    var_index += 1
                    variables[parts[1]] = var_index
                end
            end
        end
    end

    return variables, equations
end