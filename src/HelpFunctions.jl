

function get_graph_names()
    files = readdir("data/")
    println("Available topologies: " * join(files, ", "))


    files_wo_ending = [replace(files[i], ".graphml" => "") for i in 1:length(files)]

    print(files_wo_ending)
    return files_wo_ending
end



function get_pos1_pos2(pos, grid_length)
    if grid_length == 2
        return [2, 1, 2][pos], [1, 2, 2][pos]
    elseif grid_length == 3
        return [2, 3, 1, 2, 3, 1, 2, 3][pos], [1, 1, 2, 2, 2, 3, 3, 3][pos]
    elseif grid_length == 4
        return [2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4][pos], [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4][pos]
    end
end

function parse_int_from_string(str)
    try
        parsed = parse(Int64, str)
        return parsed
    catch
        return nothing
    end
end

function set_menu_selected(menu; i=1)
    menu.i_selected = 1
end

function testing()
    ar = Any[1]

    append!(ar, ["1"])

    println(ar)  
end

export testing