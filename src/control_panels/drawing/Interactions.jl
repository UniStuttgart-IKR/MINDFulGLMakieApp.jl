function init_control_panel_drawing(member_variables)
    fig = member_variables.fig
    #Menus
    member_variables.interactables["drawing"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 2:3],
        options=[v["name"] for v in member_variables.loaded_intents])
    member_variables.interactables["drawing"]["menus"]["draw_position"] = Menu(fig[1, 1][1, 1][1, 4:5],
        options=[i for i in 1:member_variables.grid_length*member_variables.grid_length-1])
    member_variables.interactables["drawing"]["menus"]["intent-visualization"] = Menu(fig[1, 1][1, 1][2, 2:3],
        options=["ibnplot", "intentplot"])
    member_variables.interactables["drawing"]["menus"]["grid-size"] = Menu(fig[1, 1][1, 1][3, 2:3],
        options=["2x2", "3x3", "4x4"])


    #Buttons
    member_variables.interactables["drawing"]["buttons"]["draw"] = Button(fig[1, 1][1, 1][2, 4:5], label="Draw")
    member_variables.interactables["drawing"]["buttons"]["delete"] = Button(fig[1, 1][1, 1][3, 4:5], label="Delete")
    member_variables.interactables["drawing"]["buttons"]["fullscreen"] = Button(fig[1, 1][1, 1][4, 4:5], label="Fullscreen")

    member_variables.interactables["drawing"]["buttons"]["move"] = Button(fig[1, 1][1, 1][5, 4:5], label="Move")




    #Button Listeners
    on(member_variables.interactables["drawing"]["buttons"]["draw"].clicks) do s
        draw(wrap_current_draw_args_in_dict(member_variables), member_variables)
    end

    on(member_variables.interactables["drawing"]["buttons"]["delete"].clicks) do s
        pos = member_variables.interactables["drawing"]["menus"]["draw_position"].selection[]
        delete!(member_variables.graphs[pos]["args"]["a"])
        delete!(member_variables.graphs, pos)
    end

    on(member_variables.interactables["drawing"]["buttons"]["fullscreen"].clicks) do s
        member_variables.interactables_observables["drawing"]["buttons"]["fullscreen"][] = !member_variables.interactables_observables["drawing"]["buttons"]["fullscreen"][]
        println(member_variables.interactables_observables["drawing"]["buttons"]["fullscreen"][])
    end

    on(member_variables.interactables["drawing"]["buttons"]["move"].clicks) do s
        #f = copy(member_variables.fig)
    end

    #Menu Listeners

    on(member_variables.interactables["intents"]["menus"]["loaded_intents"].selection) do s
        member_variables.interactables_observables["intents"]["menus"]["loaded_intents"][] = s
    end

    on(member_variables.interactables["drawing"]["menus"]["grid-size"].selection) do s
        ind_ar = ["2x2", "3x3", "4x4"]
        side_length = [2, 3, 4][findfirst(x -> x == s, ind_ar)]
        member_variables.fig[1:side_length, 1:side_length] = GridLayout()

        member_variables.grid_length = side_length

        member_variables.interactables["drawing"]["menus"]["draw_position"].options = [i for i in 1:member_variables.grid_length*member_variables.grid_length-1]

        delete_all_graphs_from_screen(member_variables)
        for (k, v) in member_variables.graphs
            if k > member_variables.grid_length * member_variables.grid_length - 1
                println("Deleting graph " * string(k) * ", doesn't fit to screen!")
                delete!(member_variables.graphs[k]["args"]["a"])
                delete!(member_variables.graphs, k)
            else
                draw(member_variables.graphs[k]["args"], member_variables)
            end

        end

        println(member_variables.fig[1, 2])
        println(GLMakie.trim!(member_variables.fig.layout))

    end


end

function wrap_current_draw_args_in_dict(member_variables)
    pos = member_variables.interactables["drawing"]["menus"]["draw_position"].selection[]
    graph_type = member_variables.interactables["drawing"]["menus"]["intent-visualization"].selection[]

    if pos in keys(member_variables.graphs)
        println("Not clear canvas!")
        return
    end


    intent = find_intent_in_loaded_by_name(member_variables, member_variables.interactables["drawing"]["menus"]["loaded_intents"].selection[])

    args = Dict(
        "graph_type" => graph_type,
        "intent" => intent,
        "pos" => pos
    )

    member_variables.graphs[pos] = Dict(
        "args" => args
    )

    return args

end


function draw(args, member_variables)
    if args === nothing
        return
    end


    pos = args["pos"]
    pos_1, pos_2 = get_pos1_pos2(pos, member_variables.grid_length)

    a = Axis(member_variables.fig[pos_1, pos_2])# title="Graph " * string(pos) * ", " * "Topology: " * args["intent_args"]["topology"] * ", Subnet: " * string(args["intent_args"]["subnet"]))
    member_variables.graphs[pos]["args"]["a"] = a

    plot_mindful(args["graph_type"], a, args["intent"]["ibn"], args["intent"]["id"])







end