
function add_intent_to_member_variables(member_variables, n1, n1_sn, n2, n2_sn, speed, topology, sn, name="Your intent")
    dict = Dict(
        "name" => name,
        "node_1" => n1,
        "node_1_subnet" => n1_sn,
        "node_2" => n2,
        "node_2_subnet" => n2_sn,
        "speed" => speed,
        "topology" => topology,
        "subnet" => sn,
        "rolling_number" => time()
    )
    member_variables.loaded_intents[name] = dict

    sorted = sort(collect(zip(keys(member_variables.loaded_intents), values(member_variables.loaded_intents))), by=q -> q[2]["rolling_number"])
    member_variables.interactables["intents"]["menus"]["loaded_intents"].options = [v["name"] for (k, v) in sorted]
    member_variables.interactables["intents"]["menus"]["loaded_intents"].i_selected = length([v["name"] for (k, v) in sorted])
end


function init_control_panel_intents(member_variables)
    fig = member_variables.fig
    #Menus

    

    member_variables.interactables["intents"]["menus"]["topology"] = Menu(fig[1, 1][1, 1][1, 2:3], options=["4nets", "nobel-germany", "nobel-germany-france-topzoo"],
        default=member_variables.interactables_observables["intents"]["menus"]["topology"][])

    subnet_amount = get_subnet_amount(member_variables.interactables["intents"]["menus"]["topology"].selection[])
    member_variables.interactables["intents"]["menus"]["subnet"] = Menu(fig[1, 1][1, 1][2, 0:1], options=[i for i in 1:subnet_amount],
        default=member_variables.interactables_observables["intents"]["menus"]["subnet"][])
    member_variables.interactables["intents"]["menus"]["node_1"] = Menu(fig[1, 1][1, 1][2, 2], options=[i for i in 1:10], default=member_variables.interactables_observables["intents"]["menus"]["node_1"][])
    member_variables.interactables["intents"]["menus"]["node_1_subnet"] = Menu(fig[1, 1][1, 1][2, 3], options=[i for i in 1:subnet_amount], default=member_variables.interactables_observables["intents"]["menus"]["node_1_subnet"][])
    member_variables.interactables["intents"]["menus"]["node_2"] = Menu(fig[1, 1][1, 1][3, 2], options=[i for i in 1:10], default=member_variables.interactables_observables["intents"]["menus"]["node_2"][])
    member_variables.interactables["intents"]["menus"]["node_2_subnet"] = Menu(fig[1, 1][1, 1][3, 3], options=[i for i in 1:subnet_amount], default=member_variables.interactables_observables["intents"]["menus"]["node_2_subnet"][])
    member_variables.interactables["intents"]["menus"]["speed"] = Menu(fig[1, 1][1, 1][4, 2:3], options=[1, 2, 3, 4], default=member_variables.interactables_observables["intents"]["menus"]["speed"][])

    member_variables.interactables["intents"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 4:5],
        options=[v["name"] for (k, v) in member_variables.loaded_intents], default=member_variables.interactables_observables["intents"]["menus"]["loaded_intents"][])

    #Buttons
    member_variables.interactables["intents"]["buttons"]["create_new_intent"] = Button(fig[1, 1][1, 1][2, 4:5], label="Create")
    member_variables.interactables["intents"]["buttons"]["save_intent"] = Button(fig[1, 1][1, 1][3, 4:5], label="Save")
    member_variables.interactables["intents"]["buttons"]["delete_intent"] = Button(fig[1, 1][1, 1][4, 4:5], label="Delete")





    #Button Listeners
    on(member_variables.interactables["intents"]["buttons"]["create_new_intent"].clicks) do s
        _v = member_variables.interactables["intents"]["menus"]
        add_intent_to_member_variables(member_variables,
            _v["node_1"].selection[],
            _v["node_1_subnet"].selection[],
            _v["node_2"].selection[],
            _v["node_2_subnet"].selection[],
            _v["speed"].selection[],
            _v["topology"].selection[],
            _v["subnet"].selection[], string(rand(1:500)))

        println()
        for _a in ["node_1", "node_1_subnet", "node_2", "node_2_subnet", "topology", "subnet", "speed"]
            println(_v[_a].selection[])
        end
    end

    on(member_variables.interactables["intents"]["buttons"]["save_intent"].clicks) do s
        current_intent_dict = member_variables.loaded_intents[member_variables.interactables["intents"]["menus"]["loaded_intents"].selection[]]
        for _a in ["node_1", "node_1_subnet", "node_2", "node_2_subnet", "topology", "subnet", "speed"]
            current_intent_dict[_a] = member_variables.interactables["intents"]["menus"][_a].selection[]
        end
    end

    on(member_variables.interactables["intents"]["buttons"]["delete_intent"].clicks) do s
        current_intent_dict_key = member_variables.interactables["intents"]["menus"]["loaded_intents"].selection[]
        delete!(member_variables.loaded_intents, current_intent_dict_key)


        member_variables.interactables["intents"]["menus"]["loaded_intents"].i_selected = length(member_variables.loaded_intents)
        sorted = sort(collect(zip(keys(member_variables.loaded_intents), values(member_variables.loaded_intents))), by=q -> q[2]["rolling_number"])
        member_variables.interactables["intents"]["menus"]["loaded_intents"].options = [v["name"] for (k, v) in sorted]

    end


    #Menu Listeners

    on(member_variables.interactables["intents"]["menus"]["topology"].selection) do s
        subnet_amount = get_subnet_amount(s)
        member_variables.interactables["intents"]["menus"]["node_1_subnet"].options=[i for i in 1:subnet_amount]
        member_variables.interactables["intents"]["menus"]["node_2_subnet"].options=[i for i in 1:subnet_amount]

    end

    on(member_variables.interactables["intents"]["menus"]["loaded_intents"].selection) do s
        for _v in ["node_1", "node_1_subnet", "node_2", "node_2_subnet", "topology", "subnet", "speed"]
            #= index = findall(y -> y["name"] == s, member_variables.loaded_intents)[1]
            index_2 = findall(z -> z == member_variables.loaded_intents[index][_v], member_variables.interactables["intents"]["menus"][_v].options[])[1] =#
            member_variables.interactables["intents"]["menus"][_v].i_selected = findall(z -> z == member_variables.loaded_intents[s][_v], member_variables.interactables["intents"]["menus"][_v].options[])[1]


        end

        println()

    end


    for (k, v) in member_variables.interactables["intents"]["menus"]
        on(v.selection) do s
            #println(k)
            member_variables.interactables_observables["intents"]["menus"][k][] = s
        end
    end

end