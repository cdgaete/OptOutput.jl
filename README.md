# OptOutput.jl

OptOutput.jl is a Julia package that provides utility functions for collecting optimization results in tabular format (DataFrames) from JuMP models. It supports extracting primal and dual value results from solvers and transforming them into easily accessible data structures.

## Features

- Parse MPS format strings from JuMP models
- Extract primal and dual solutions
- Transform optimization results into structured data
- Generate DataFrames for easy data manipulation and analysis
- Optional saving of intermediate and final results to disk

## Installation

You can install OptOutput.jl using Julia's package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```
pkg> add OptOutput
```

## Usage

Here's a basic example of how to use OptOutput.jl:

```julia
using JuMP
using OptOutput

# Create and solve your JuMP model
model = Model()
@variable(model, x >= 0)
@variable(model, 0 <= y <= 3)
@variable(model, z <= 1)
@objective(model, Min, 12x + 20y - z)
@constraint(model, c1, 6x + 8y >= 100)
@constraint(model, c2, 7x + 12y >= 120)
@constraint(model, c3, x + y <= 20)

# Process the optimization model
dataframes, variable_results, equation_results = process_optimization_model(model)

# Optionally save intermediate results
save_intermediate_results(variable_results, equation_results)

# Optionally save final results
save_final_results(dataframes)

# Work with the resulting DataFrames
for (case, df) in dataframes
    println("Case: $case")
    println(df)
    println()
end
```

## Contributing

Contributions to OptOutput.jl are welcome! Please feel free to submit issues, pull requests, or suggestions to improve the package.

## License

This project is licensed under the MIT License. See the LICENSE file for details.