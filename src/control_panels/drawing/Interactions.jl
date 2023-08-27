function init_control_panel_drawing(member_variables)
    fig = member_variables.fig
    #Menus
    member_variables.interactables["drawing"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 2:3],
        options=[v["name"] for (k, v) in member_variables.loaded_intents], default=member_variables.interactables_observables["intents"]["menus"]["loaded_intents"][])
    member_variables.interactables["drawing"]["menus"]["draw_position"] = Menu(fig[1, 1][1, 1][1, 4:5],
        options=[1, 2, 3])
    member_variables.interactables["drawing"]["menus"]["intent-visualization"] = Menu(fig[1, 1][1, 1][2, 2:3],
        options=["Unin Tree", "Tree", "Visualization"])


    #Buttons
    member_variables.interactables["drawing"]["buttons"]["draw"] = Button(fig[1, 1][1, 1][2, 4:5], label="Draw")
    member_variables.interactables["drawing"]["buttons"]["delete"] = Button(fig[1, 1][1, 1][3, 4:5], label="Delete")






    #Button Listeners
    on(member_variables.interactables["drawing"]["buttons"]["draw"].clicks) do s
        draw(member_variables)
    end

    on(member_variables.interactables["drawing"]["buttons"]["delete"].clicks) do s
        pos = member_variables.interactables["drawing"]["menus"]["draw_position"].selection[]
        delete!(member_variables.graphs[pos])
        delete!(member_variables.graphs, pos)
    end


    #Menu Listeners

    on(member_variables.interactables["intents"]["menus"]["loaded_intents"].selection) do s
        member_variables.interactables_observables["intents"]["menus"]["loaded_intents"][] = s
    end


end


function draw(member_variables)
    


    used_intent_args = member_variables.loaded_intents[member_variables.interactables["drawing"]["menus"]["loaded_intents"].selection[]]
    pos = member_variables.interactables["drawing"]["menus"]["draw_position"].selection[]

    if pos in keys(member_variables.graphs)
        println("Not clear canvas!")
        return
    end
    
    pos_1 = [2, 1, 2][pos]
    pos_2 = [1, 2, 2][pos]
    a = Axis(member_variables.fig[pos_1, pos_2], title="Graph " * string([1 3; 2 4][pos_1, pos_2]) * ", " * "Topology: " * used_intent_args["topology"] * ", Subnet: " * string(used_intent_args["subnet"]))

    #println(fieldnames(typeof(member_variables.graphs[pos])))
    #println(member_variables.graphs[pos])

    member_variables.graphs[pos] = a

    intent_args = Dict(
        "node_1" => used_intent_args["node_1"],
        "node_2" => used_intent_args["node_2"],
        "node_1_ibn" => used_intent_args["node_1_subnet"],
        "node_2_ibn" => used_intent_args["node_2_subnet"],
        "speed" => used_intent_args["speed"]
    )


    generate_ibns(a, used_intent_args["topology"], member_variables.interactables["drawing"]["menus"]["intent-visualization"].selection[], pos=used_intent_args["subnet"], intent_args=intent_args)

end