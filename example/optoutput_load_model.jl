using OptOutput

primal_solution = read_solution_from_file("example/data/model_primal.txt");
dual_solution = read_solution_from_file("example/data/model_dual.txt");
mps_string = read("example/data/model.mps", String);

# Option 1: Use individual functions

all_results = combine_primal_dual_solutions(mps_string, primal_solution, dual_solution);

named_unique, named_dimensions = create_named_sets_and_dimensions(all_results);

structured_data, dim_to_index, index_to_dim = structure_optimization_results(all_results, named_unique, named_dimensions);

dataframes = create_result_dataframes(structured_data, index_to_dim, named_dimensions);

save_results_to_csv(dataframes, "example/output_load")

# Option 2: Use a single function

# dataframes, all_results = process_optimization_results(mps_string, primal_solution, dual_solution)
# save_results_to_csv(dataframes, "example/output_load")
