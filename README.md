# OptOutput.jl

OptOutput.jl is a Julia package designed to process and organize optimization results, particularly for large-scale linear programming models. It focuses on parsing MPS files and solver outputs, transforming optimization variables and constraints into a structured format. This tool is especially useful for handling results from solvers like [cuPDLP.jl](https://github.com/jinwen-yang/cuPDLP.jl) that may not have direct JuMP integration.

## Key Functions

- Parse MPS format strings to extract variable and constraint information
- Process primal and dual solutions from optimization solvers
- Organize results into DataFrames, separating multi-dimensional variables and constraints
- Generate named sets and dimensions for improved data organization
- Save results to CSV files for further analysis


## Explanation through Examples

Let's consider a simple energy system model with generators (GEN) and capacity (CAP) variables. In the MPS format, these might be represented as:

```
GEN[A1,B1]    obj
GEN[A1,B2]    obj
GEN[A2,B1]    obj
GEN[A2,B2]    obj
CAP[B1]       obj
CAP[B2]       obj
...
```

After processing with OptOutput.jl, the package would:

1. Recognize the dimensions:
   - `dim1` (A1, A2) for GEN
   - `dim2` (B1, B2) for both GEN and CAP

2. Create structured DataFrames:

For GEN:
```julia
julia> dataframes["GEN"]
4×3 DataFrame
 Row │ dim1  dim2  value 
     │ Any   Any   Float64
─────┼─────────────────────
   1 │ A1    B1        0.0
   2 │ A1    B2        0.0
   3 │ A2    B1        0.0
   4 │ A2    B2        0.0
```

For CAP:
```julia
julia> dataframes["CAP"]
2×2 DataFrame
 Row │ dim2  value 
     │ Any   Float64
─────┼──────────────
   1 │ B1        0.0
   2 │ B2        0.0
```

This structure allows for easy manipulation and analysis of the optimization results. For instance, you could easily filter or aggregate results:

```julia
# Filter GEN results for dim1 == "A1"
gen_a1 = dataframes["GEN"][dataframes["GEN"].dim1 .== "A1", :]

# Sum CAP values
total_cap = sum(dataframes["CAP"].value)
```

OptOutput.jl simplifies working with these results, especially for large-scale models with many variables and constraints spanning multiple dimensions.


## Quick Installation

You can install OptOutput.jl using the following command:

```julia
using Pkg
Pkg.add(url="https://github.com/cdgaete/OptOutput.jl")
```

In the future we expect to using Julia's package manager. It would be so:

```julia
using Pkg
Pkg.add("OptOutput")
```

## Usage

Here's an example of how to use OptOutput.jl with an external solver:

```julia
using JuMP
using OptOutput
using YourExternalSolver  # Replace with your actual solver package

# Create and solve your JuMP model
model = create_your_model()
optimize!(model)

# Write the model to an MPS file
write_to_file(model, "model.mps")

# Get primal and dual solutions from your solver
primal_solution = value.(all_variables(model))
dual_solution = dual.(all_constraints(model, include_variable_in_set_constraints=false))

# Process the optimization results
dataframes, all_results, qps_model = process_optimization_results("model.mps", primal_solution, dual_solution)

# Optionally save results to CSV files
save_results_to_csv(dataframes, "output_directory")

# Work with the resulting DataFrames
for (case, df) in dataframes
    println("Case: $case")
    println(df)
    println()
end
```

There is a complete example of how to use OptOutput.jl with cuPDLP.jl [here](example/optoutput_cupdlp_dims.jl)

## Advanced Usage

### Custom Dimension Naming

You can provide custom names for dimensions:

```julia
custom_named_sets = Dict(
    "countries" => ["BE", "DE"],
    "timesteps" => ["t0883", "t2013", "t2264", "t6467", "t6469"],
    "ev_types" => ["ev015", "ev016", "ev017"],
    "technologies" => ["Offshore_Wind", "Run-of-River"]
)

named_sets, prefix_dim_names = create_named_sets_and_dimensions(all_results, custom_named_sets)
```

### Filtering Results

You can filter results by specifying symbols of interest:

```julia
symbols_of_interest = ["EV_CHARGE", "G", "H2_N_ELY"]
dataframes, all_results, qps_model = process_optimization_results("model.mps", primal_solution, dual_solution, symbols_of_interest)
```

## API Reference

- `process_optimization_results(mps_path, primal_solution, dual_solution, symbols=String[])`: Main function to process optimization results
- `create_named_sets_and_dimensions(input_dict, named_sets=nothing, symbols=String[])`: Create named sets and dimensions from input data
- `structure_optimization_results(input_dict, named_sets, variable_dimensions)`: Structure optimization results into a more accessible format
- `create_result_dataframes(structured_results, index_to_dim, variable_dimensions, cases=String[])`: Create DataFrames from structured results
- `save_results_to_csv(dataframes, output_dir="output")`: Save DataFrames to CSV files
- `combine_primal_dual_solutions(mps_string, primal_solution, dual_solution)`: Combine primal and dual solutions with variable and equation names
- `read_solution_from_file(solution_file_path)`: Read a solution from a file

## Contributing

Contributions to OptOutput.jl are welcome! Please feel free to submit issues, pull requests, or suggestions to improve the package.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
