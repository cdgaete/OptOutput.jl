function parse_mps_sections(mps_string::String)
    variables = String[]
    equations = String[]
    current_section = ""

    for line in split(mps_string, "\n")
        if startswith(line, "ROWS")
            current_section = "ROWS"
            continue
        elseif startswith(line, "COLUMNS")
            current_section = "COLUMNS"
            continue
        elseif startswith(line, "RHS") || startswith(line, "BOUNDS")
            break
        end

        parts = split(strip(line))
        if current_section == "ROWS" && length(parts) >= 2
            push!(equations, parts[2])
        elseif current_section == "COLUMNS" && length(parts) >= 2
            push!(variables, parts[1])
        end
    end

    return unique!(variables), unique!(equations)
end