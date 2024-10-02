using OptOutput

primal_solution = read_solution("example/data/model_primal.txt");
dual_solution = read_solution("example/data/model_dual.txt");
mps_string = read("example/data/model.mps", String);

all_results = extract_data(mps_string, primal_solution, dual_solution);

named_unique, prefix_dim_names = create_predefined_values(all_results);

transformed_dict, dim_to_index, index_to_dim = transform_dict(all_results, named_unique, prefix_dim_names);

dataframes = create_dataframes(transformed_dict, index_to_dim, prefix_dim_names);

save_results(dataframes, "example/output_load")