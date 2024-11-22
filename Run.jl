using Printf

function print_all_errors_for_vscode(e, parent_file="", parent_line=0)
    # Check if the error is a LoadError
    if e isa LoadError
        type_error = typeof(e.error)

        # Print the current LoadError
        println("$(e.file):$(e.line) - $(type_error)")
        # Recursively process the nested error
        print_all_errors_for_vscode(e.error, e.file, e.line)
    elseif e isa UndefVarError
        # Print UndefVarError
        println("$parent_file:$parent_line - $(e.var)")
    else
        # Handle generic errors
        println("$parent_file:$parent_line - $(e)")
    end
end

try
    # Run your script or code
    include("src/PKO.jl")  # Replace this with your actual script or function
catch e
    print_all_errors_for_vscode(e)
end
