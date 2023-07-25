

function get_graph_names()
    files = readdir("data/")
    println("Available topologies: " * join(files, ", "))


    files_wo_ending = [replace(files[i], ".graphml" => "") for i in 1:length(files)]
    print(files_wo_ending)

    return files_wo_ending
end