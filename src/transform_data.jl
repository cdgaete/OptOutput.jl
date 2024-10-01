function group_and_union_similar_sets(input_dict::Dict{String, Vector{Set{String}}})
    # Flatten all sets into a single vector
    all_sets = Set{String}[]
    for sets in values(input_dict)
        append!(all_sets, sets)
    end
    
    # Create a dictionary to store groups
    groups = DefaultDict{Set{String}, Vector{Set{String}}}(Vector{Set{String}})
    
    # Group sets with identical elements
    for s in all_sets
        key = Set(s)
        push!(groups[key], s)
    end
    
    # Merge groups with overlapping elements and create unions
    merged_groups = Set{String}[]
    while !isempty(groups)
        current_group = pop!(groups).second
        changed = true
        while changed
            changed = false
            for (key, group) in groups
                if any(s1 -> any(s2 -> !isempty(intersect(s1, s2)), group), current_group)
                    append!(current_group, group)
                    delete!(groups, key)
                    changed = true
                    break
                end
            end
        end
        # Create a union of all sets in the current group
        push!(merged_groups, union(current_group...))
    end
    
    return merged_groups
end

function create_predefined_values(input_dict, named_unique=nothing)
    # Step 1: Extract dimensions for each prefix
    prefix_dimensions = Dict{String, Vector{Set{String}}}()
    
    for key in keys(input_dict)
        if !contains(key, "[")  # Handle scalar variables
            prefix_dimensions[key] = Vector{Set{String}}()
            continue
        end
        
        prefix, dims = split(key, "[", limit=2)
        dims = split(strip(dims, ['[', ']']), ",")
        
        if !haskey(prefix_dimensions, prefix)
            prefix_dimensions[prefix] = [Set{String}() for _ in 1:length(dims)]
        end
        
        for (i, dim) in enumerate(dims)
            push!(prefix_dimensions[prefix][i], strip(dim))
        end
    end

    if isnothing(named_unique)
        merged_groups = group_and_union_similar_sets(prefix_dimensions)
        
        # Assign names to each set
        named_unique = Dict("dim$(i)" => set for (i, set) in enumerate(merged_groups))
    end
    
    # Identify prefix dimensions with corresponding dimension names
    prefix_dim_names = Dict{String, Vector{String}}()
    
    for (prefix, dimensions) in prefix_dimensions
        if isempty(dimensions)  # Handle scalar variables
            prefix_dim_names[prefix] = String[]
            continue
        end
        
        dim_names = String[]
        for dim_set in dimensions
            found = false
            for (name, set) in named_unique
                if dim_set ⊆ Set(set)  # Convert to Set for subset check
                    push!(dim_names, name)
                    found = true
                    break
                end
            end
            if !found
                push!(dim_names, "unknown")
            end
        end
        prefix_dim_names[prefix] = dim_names
    end

    named_unique = Dict(name => sort(collect(Set(set))) for (name, set) in named_unique)
    
    return named_unique, prefix_dim_names
end

function transform_dict(input_dict, predefined_values, case_dimensions)
    dim_to_index = OrderedDict()
    index_to_dim = OrderedDict()

    for (case, dimensions) in case_dimensions
        dim_to_index[case] = OrderedDict()
        index_to_dim[case] = OrderedDict()
        for dim in dimensions
            if haskey(predefined_values, dim)
                sorted_values = sort(collect(predefined_values[dim]))
                dim_to_index[case][dim] = Dict(val => i for (i, val) in enumerate(sorted_values))
                index_to_dim[case][dim] = Dict(i => val for (i, val) in enumerate(sorted_values))
            end
        end
    end

    function parse_key(key)
        parts = split(key, r"[\[\],]"; keepempty=false)
        case = parts[1]
        dim_values = [get(get(dim_to_index, case, Dict())[dim], parts[i+1], 0)
                      for (i, dim) in enumerate(get(case_dimensions, case, [])) if i < length(parts)]
        return case, dim_values
    end

    result = Dict{String, Dict{String, Union{Vector{Float64}, Vector{Int}}}}()
    for (key, value) in input_dict
        case, dim_values = parse_key(key)
        if !haskey(result, case)
            result[case] = Dict{String, Union{Vector{Float64}, Vector{Int}}}()
            result[case]["value"] = Vector{Float64}()
        end
        for (i, dim) in enumerate(get(case_dimensions, case, []))
            if i <= length(dim_values) && dim_values[i] != 0
                if !haskey(result[case], dim)
                    result[case][dim] = Vector{Int}()
                end
                push!(result[case][dim], dim_values[i])
            end
        end
        push!(result[case]["value"], Float64(value))
    end

    return result, dim_to_index, index_to_dim
end

function create_dataframes(transformed_dict, index_to_dim, case_dimensions, cases::Vector{String}=String[])
    dataframes = Dict{String, DataFrame}()

    if isempty(cases)
        cases = collect(keys(transformed_dict))
    end

    for case in cases
        if !haskey(transformed_dict, case)
            @warn "Case '$case' not found in the transformed data. Skipping."
            continue
        end

        data = transformed_dict[case]
        df = DataFrame()

        for dim in get(case_dimensions, case, [])
            if haskey(data, dim)
                df[!, dim] = [index_to_dim[case][dim][i] for i in data[dim]]
            end
        end

        df[!, "value"] = data["value"]

        if !isempty(get(case_dimensions, case, []))
            sort!(df, [col for col in names(df) if col != "value"])
        end

        dataframes[case] = df
    end

    return dataframes
end