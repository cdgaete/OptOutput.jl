
function extract_variables_and_equations_from_mps(mps_file_path::String, symbols::Vector{String}=String[])
    model = readqps(mps_file_path)
    
    variables = OrderedDict{String, Tuple{Int, Bool}}()
    equations = OrderedDict{String, Tuple{Int, Bool}}()
    symbol_set = isempty(symbols) ? nothing : Set(symbols)

    for (index, var_name) in enumerate(model.varnames)
        var_prefix = split(var_name, '[', limit=2)[1]
        variables[var_name] = (index, symbol_set === nothing || var_prefix in symbol_set)
    end

    for (index, con_name) in enumerate(model.connames)
        eq_prefix = split(con_name, '[', limit=2)[1]
        equations[con_name] = (index, symbol_set === nothing || eq_prefix in symbol_set)
    end

    return variables, equations, model
end