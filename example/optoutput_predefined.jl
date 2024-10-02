using OptOutput


# Test the function with a sample of your input
sample_input = Dict(
    "EV_ED[DE,ev016,t2013]" => 0.0,
    "EV_GED[DE,ev015,t6469]" => 1087.04,
    "EV_INF_Disabled[DE,ev017,t0883]" => 0.0,
    "ev_maxout_smart[DE,ev015,t6467]" => -120.808,
    "ev_chargelevel_min[DE,ev016,t0883]" => 92.23,
    "G[BE,Run-of-River,t2264]" => 49.6004,
    "G[DE,Offshore_Wind,t2013]" => 26190.0,
    "EV_CHARGE[DE,ev016,t6469]" => 75.5805,
    "EV_CHARGE[DE,ev017,t6467]" => 75.5805,
    "EV_CHARGE[DE,ev015,t2013]" => 75.5805,
    "H2_N_ELY[t6469,BE]" => 0.0,
    "EV_ED[DE,ev016,t0883]" => 0.0,
    "OBJ" => 0.0
)

# Test without providing named_unique
named_unique, prefix_dim_names = create_predefined_values(sample_input)

println("Named Sets:")
for (name, set) in named_unique
    println("$name: $set")
end

println("\nPrefix Dimension Names:")
for (prefix, dim_names) in prefix_dim_names
    println("$prefix: $dim_names")
end

# output:

# Named Sets:
# dim2: ["BE", "DE"]
# dim1: ["t0883", "t2013", "t2264", "t6467", "t6469"]
# dim3: ["ev015", "ev016", "ev017"]
# dim4: ["Offshore_Wind", "Run-of-River"]

# Prefix Dimension Names:
# EV_ED: ["dim2", "dim3", "dim1"]
# EV_GED: ["dim2", "dim3", "dim1"]
# OBJ: String[]
# ev_chargelevel_min: ["dim2", "dim3", "dim1"]
# EV_CHARGE: ["dim2", "dim3", "dim1"]
# G: ["dim2", "dim4", "dim1"]
# EV_INF_Disabled: ["dim2", "dim3", "dim1"]
# ev_maxout_smart: ["dim2", "dim3", "dim1"]
# H2_N_ELY: ["dim1", "dim2"]



# Test with providing named_unique
custom_named_unique = Dict(
    "countries" => ["BE", "DE"],
    "timesteps" => ["t0883", "t2013", "t2264", "t6467", "t6469"],
    "ev_types" => ["ev015", "ev016", "ev017"],
    "technologies" => ["Offshore_Wind", "Run-of-River"]
)

custom_named_unique, custom_prefix_dim_names = create_predefined_values(sample_input, custom_named_unique)

println("\nCustom Named Sets:")
for (name, set) in custom_named_unique
    println("$name: $set")
end

println("\nCustom Prefix Dimension Names:")
for (prefix, dim_names) in custom_prefix_dim_names
    println("$prefix: $dim_names")
end


# output:

# Custom Named Sets:
# countries: ["BE", "DE"]
# ev_types: ["ev015", "ev016", "ev017"]
# technologies: ["Offshore_Wind", "Run-of-River"]
# timesteps: ["t0883", "t2013", "t2264", "t6467", "t6469"]

# Custom Prefix Dimension Names:
# EV_ED: ["countries", "ev_types", "timesteps"]
# EV_GED: ["countries", "ev_types", "timesteps"]
# OBJ: String[]
# ev_chargelevel_min: ["countries", "ev_types", "timesteps"]
# EV_CHARGE: ["countries", "ev_types", "timesteps"]
# G: ["countries", "technologies", "timesteps"]
# EV_INF_Disabled: ["countries", "ev_types", "timesteps"]
# ev_maxout_smart: ["countries", "ev_types", "timesteps"]
# H2_N_ELY: ["timesteps", "countries"]