function init_control_panel_drawing(member_variables)
    fig = member_variables.fig
    #Menus
    member_variables.interactables["drawing"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 2:3],
        options=[v["name"] for (k, v) in member_variables.loaded_intents], default=member_variables.interactables_observables["intents"]["menus"]["loaded_intents"][])
    member_variables.interactables["drawing"]["menus"]["draw_position"] = Menu(fig[1, 1][1, 1][1, 4:5],
        options=[i for i in 1:member_variables.grid_length*member_variables.grid_length-1])
    member_variables.interactables["drawing"]["menus"]["intent-visualization"] = Menu(fig[1, 1][1, 1][2, 2:3],
        options=["Unin Tree", "Tree", "Visualization", "DAG vis int", "DAG tree", "DAG vis ml"])
    member_variables.interactables["drawing"]["menus"]["grid-size"] = Menu(fig[1, 1][1, 1][3, 2:3],
        options=["2x2", "3x3", "4x4"])


    #Buttons
    member_variables.interactables["drawing"]["buttons"]["draw"] = Button(fig[1, 1][1, 1][2, 4:5], label="Draw")
    member_variables.interactables["drawing"]["buttons"]["delete"] = Button(fig[1, 1][1, 1][3, 4:5], label="Delete")
    member_variables.interactables["drawing"]["buttons"]["fullscreen"] = Button(fig[1, 1][1, 1][4, 4:5], label="Fullscreen")






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


    #Menu Listeners

    on(member_variables.interactables["intents"]["menus"]["loaded_intents"].selection) do s
        member_variables.interactables_observables["intents"]["menus"]["loaded_intents"][] = s
    end

    on(member_variables.interactables["drawing"]["menus"]["grid-size"].selection) do s
        ind_ar = ["2x2", "3x3", "4x4"]
        side_length = [2,3,4][findfirst(x -> x == s, ind_ar)]
        member_variables.fig[1:side_length, 1:side_length] = GridLayout()

        member_variables.grid_length = side_length

        member_variables.interactables["drawing"]["menus"]["draw_position"].options = [i for i in 1:member_variables.grid_length*member_variables.grid_length-1]

        delete_all_graphs_from_screen(member_variables)
        for (k,v) in member_variables.graphs 
            if k > member_variables.grid_length *  member_variables.grid_length - 1
                println("Deleting graph " * string(k) * ", doesn't fit to screen!")
                delete!(member_variables.graphs[k]["args"]["a"])
                delete!(member_variables.graphs, k)
            else
                draw(member_variables.graphs[k]["args"], member_variables)
            end
            
        end

        println(member_variables.fig[1,2])
        println(GLMakie.trim!(member_variables.fig.layout))

    end


end

function wrap_current_draw_args_in_dict(member_variables)
    used_intent_args = member_variables.loaded_intents[member_variables.interactables["drawing"]["menus"]["loaded_intents"].selection[]]
    pos = member_variables.interactables["drawing"]["menus"]["draw_position"].selection[]
    graph_type = member_variables.interactables["drawing"]["menus"]["intent-visualization"].selection[]

    if pos in keys(member_variables.graphs)
        println("Not clear canvas!")
        return
    end




    intent_args = Dict(
        "node_1" => used_intent_args["node_1"],
        "node_2" => used_intent_args["node_2"],
        "node_1_subnet" => used_intent_args["node_1_subnet"],
        "node_2_subnet" => used_intent_args["node_2_subnet"],
        "speed" => used_intent_args["speed"],
        "topology" => used_intent_args["topology"],
        "subnet" => used_intent_args["subnet"]
    )

    args = Dict(
        "graph_type" => graph_type,
        "intent_args" => intent_args,
        "pos" => pos
    )

    member_variables.graphs[pos] = Dict(
        "args" => args
    )

    return args

end


function draw(args, member_variables; fullscreen=false, new_axis=true)
    if args === nothing
        return
    end

    if fullscreen == true

        a = Axis(member_variables.fig[2, 1:2])
        args = copy(args)
        args["a"] = a

        member_variables.fullscreen_graph[1] = a

    else
        pos = args["pos"]
        pos_1, pos_2 = get_pos1_pos2(pos, member_variables.grid_length)

        a = Axis(member_variables.fig[pos_1, pos_2], title="Graph " * string(pos) * ", " * "Topology: " * args["intent_args"]["topology"] * ", Subnet: " * string(args["intent_args"]["subnet"]))
        member_variables.graphs[pos]["args"]["a"] = a

    end




    if args["graph_type"] in ["DAG vis int", "DAG tree", "DAG vis ml"]
        get_intent_dag_graph(args["a"], args["intent_args"], args["graph_type"])
    elseif args["graph_type"] in ["Unin Tree", "Tree", "Visualization"]
        generate_ibns(args["a"], args["intent_args"]["topology"], args["graph_type"], pos=args["intent_args"]["subnet"], intent_args=args["intent_args"])
    end

end