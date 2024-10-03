using QPSReader

# Function to print model details
function print_model_details(model::QPSData)
    println("Problem name: ", model.name)
    println("Number of variables: ", model.nvar)
    println("Number of constraints: ", model.ncon)
    println("Objective sense: ", model.objsense)
    println("Objective constant term: ", model.c0)
end

# Read the MPS file
mps_file = "example/output_dims/model.mps"
model = readqps(mps_file)

println("Model details:")
print_model_details(model)

# Print variable names and their types
println("\nVariables:")
for (i, (name, type)) in enumerate(zip(model.varnames, model.vartypes))
    println("$name: $type")
    if i >= 5  # Print only the first 5 variables
        println("...")
        break
    end
end

# Print constraint names and their types
println("\nConstraints:")
for (i, (name, type)) in enumerate(zip(model.connames, model.contypes))
    println("$name: $type")
    if i >= 5  # Print only the first 5 constraints
        println("...")
        break
    end
end

# Print objective coefficients
println("\nObjective coefficients:")
for (i, (var, coef)) in enumerate(zip(model.varnames, model.c))
    println("$var: $coef")
    if i >= 5  # Print only the first 5 coefficients
        println("...")
        break
    end
end

# Print some constraint coefficients
println("\nSome constraint coefficients:")
for i in 1:min(5, length(model.arows))
    row = model.arows[i]
    col = model.acols[i]
    val = model.avals[i]
    println("($(model.connames[row]), $(model.varnames[col])): $val")
end
if length(model.arows) > 5
    println("...")
end

# Print variable bounds
println("\nVariable bounds:")
for (i, (var, lower, upper)) in enumerate(zip(model.varnames, model.lvar, model.uvar))
    println("$var: [$lower, $upper]")
    if i >= 5  # Print only the first 5 bounds
        println("...")
        break
    end
end

# Print constraint bounds
println("\nConstraint bounds:")
for (i, (con, lower, upper)) in enumerate(zip(model.connames, model.lcon, model.ucon))
    println("$con: [$lower, $upper]")
    if i >= 5  # Print only the first 5 bounds
        println("...")
        break
    end
end

# If there's a quadratic objective, print some coefficients
if !isempty(model.qrows)
    println("\nSome quadratic objective coefficients:")
    for i in 1:min(5, length(model.qrows))
        row = model.qrows[i]
        col = model.qcols[i]
        val = model.qvals[i]
        println("($(model.varnames[row]), $(model.varnames[col])): $val")
    end
    if length(model.qrows) > 5
        println("...")
    end
end

# Output:

# [ Info: Using '' as NAME (l. 1)
# [ Info: Using 'OBJ' as objective (l. 3)
# [ Info: Using 'rhs' as RHS (l. 98)
# [ Info: Using 'bounds' as BOUNDS (l. 120)
# Model details:
# Problem name: 
# Number of variables: 24
# Number of constraints: 20
# Objective sense: notset
# Objective constant term: 0.0

# Variables:
# x[A,F1,1]: VTYPE_Continuous
# x[B,F1,1]: VTYPE_Continuous
# x[C,F1,1]: VTYPE_Continuous
# x[A,F2,1]: VTYPE_Continuous
# x[B,F2,1]: VTYPE_Continuous
# ...

# Constraints:
# capacity_constraint[F1,1]: RTYPE_LessThan
# capacity_constraint[F2,1]: RTYPE_LessThan
# capacity_constraint[F1,2]: RTYPE_LessThan
# capacity_constraint[F2,2]: RTYPE_LessThan
# capacity_constraint[F1,3]: RTYPE_LessThan
# ...

# Objective coefficients:
# x[A,F1,1]: 10.0
# x[B,F1,1]: 11.0
# x[C,F1,1]: 13.0
# x[A,F2,1]: 12.0
# x[B,F2,1]: 10.0
# ...

# Some constraint coefficients:
# (capacity_constraint[F1,1], x[A,F1,1]): 1.0
# (demand_constraint[A,1], x[A,F1,1]): 1.0
# (capacity_constraint[F1,1], x[B,F1,1]): 1.0
# (demand_constraint[B,1], x[B,F1,1]): 1.0
# (capacity_constraint[F1,1], x[C,F1,1]): 1.0
# ...

# Variable bounds:
# x[A,F1,1]: [0.0, Inf]
# x[B,F1,1]: [0.0, Inf]
# x[C,F1,1]: [0.0, Inf]
# x[A,F2,1]: [0.0, Inf]
# x[B,F2,1]: [0.0, Inf]
# ...

# Constraint bounds:
# capacity_constraint[F1,1]: [-Inf, 500.0]
# capacity_constraint[F2,1]: [-Inf, 450.0]
# capacity_constraint[F1,2]: [-Inf, 500.0]
# capacity_constraint[F2,2]: [-Inf, 450.0]
# capacity_constraint[F1,3]: [-Inf, 500.0]
# ...
