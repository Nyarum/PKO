using Printf

function print_last_error_for_vscode(e, parent_file="", parent_line=0)
    # Check if the error is a LoadError
    if e isa LoadError
        # Process the nested error
        return print_last_error_for_vscode(e.error, e.file, e.line)
    else
        # Handle the final error (deepest level)
        println("$parent_file:$parent_line - $(e)")
    end
end

try
    # Run your script or code
    include("src/PKO.jl")  # Replace this with your actual script or function
catch e
    print_last_error_for_vscode(e)
end
