using OptOutput


mps_path = "example/data/model.mps";
@time primal_solution = read_solution_from_file("example/data/model_primal.txt");
@time dual_solution = read_solution_from_file("example/data/model_dual.txt");

# Option 1: Use individual functions

@time all_results, qps_model = combine_primal_dual_solutions(mps_path, primal_solution, dual_solution); # 44s

@time named_unique, named_dimensions = create_named_sets_and_dimensions(all_results); # 8s

@time structured_data, dim_to_index, index_to_dim = structure_optimization_results(all_results, named_unique, named_dimensions); # 11s

@time dataframes = create_result_dataframes(structured_data, index_to_dim, named_dimensions);

@time save_results_to_csv(dataframes, "example/output_load")

# Option 2: Use a single function

# dataframes, all_results, qps_model = process_optimization_results(mps_string, primal_solution, dual_solution)
# save_results_to_csv(dataframes, "example/output_load")
