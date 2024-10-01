function create_predefined_values(input_dict)
    predefined_values = Dict{String, Set{String}}()
    for key in keys(input_dict)
        parts = split(key, r"[\[\],]"; keepempty=false)
        if length(parts) > 1
            case = parts[1]
            for (i, part) in enumerate(parts[2:end])
                dim_name = "dim$(i)"
                if !haskey(predefined_values, dim_name)
                    predefined_values[dim_name] = Set{String}()
                end
                push!(predefined_values[dim_name], part)
            end
        end
    end
    return predefined_values
end

function create_case_dimensions(input_dict, predefined_values)
    case_dimensions = OrderedDict{String, Vector{String}}()
    for key in keys(input_dict)
        parts = split(key, r"[\[\],]"; keepempty=false)
        if length(parts) > 1
            case = parts[1]
            if !haskey(case_dimensions, case)
                case_dimensions[case] = String[]
            end
            for (i, part) in enumerate(parts[2:end])
                dim_name = "dim$(i)"
                if dim_name in keys(predefined_values) && part in predefined_values[dim_name] && dim_name ∉ case_dimensions[case]
                    push!(case_dimensions[case], dim_name)
                end
            end
        end
    end
    return case_dimensions
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

function create_dataframes(transformed_dict, index_to_dim, case_dimensions)
    dataframes = Dict{String, DataFrame}()

    for (case, data) in transformed_dict
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