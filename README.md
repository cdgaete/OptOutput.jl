# OptOutput.jl

OptOutput.jl is a Julia package that provides utility functions for collecting optimization results in tabular format (DataFrames) from MPS files and solver outputs. It supports extracting primal and dual value results and transforming them into easily accessible data structures.

## Features

- Parse MPS format strings
- Extract primal and dual solutions
- Transform optimization results into structured data
- Generate DataFrames for easy data manipulation and analysis
- Optional saving of results to CSV files

## Installation

You can install OptOutput.jl using Julia's package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```
pkg> add OptOutput
```

## Usage

Here's a basic example of how to use OptOutput.jl with an external solver:

```julia
using JuMP
using OptOutput
using YourExternalSolver  # Replace with your actual solver package

# Create your JuMP model
model = Model()
@variable(model, x >= 0)
@variable(model, 0 <= y <= 3)
@variable(model, z <= 1)
@objective(model, Min, 12x + 20y - z)
@constraint(model, c1, 6x + 8y >= 100)
@constraint(model, c2, 7x + 12y >= 120)
@constraint(model, c3, x + y <= 20)

# Write the model to an MPS file
write_to_file(model, "model.mps")

# Solve the model using your external solver
# This is just an example, replace with your actual solver call
primal_solution, dual_solution = solve_with_external_solver("model.mps")

# Process the optimization results
dataframes, all_results = process_optimization_results("model.mps", primal_solution, dual_solution)

# Optionally save results to CSV files
save_results_to_csv(dataframes, "output_directory")

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