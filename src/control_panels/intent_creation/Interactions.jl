
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

    member_variables.interactables["intents"]["menus"]["topology"] = Menu(fig[1, 1][1, 1][1, 2:3], options=get_graph_names(),
        default=member_variables.interactables_observables["intents"]["menus"]["topology"][])

    subnet_amount = get_subnet_amount(member_variables.interactables["intents"]["menus"]["topology"].selection[])
    member_variables.interactables["intents"]["menus"]["subnet"] = Menu(fig[1, 1][1, 1][2, 0:1], options=[i for i in 1:subnet_amount],
        default=member_variables.interactables_observables["intents"]["menus"]["subnet"][])
    member_variables.interactables["intents"]["menus"]["node_1"] = Menu(fig[1, 1][1, 1][2, 2], options=[i for i in 1:10], default=member_variables.interactables_observables["intents"]["menus"]["node_1"][])
    member_variables.interactables["intents"]["menus"]["node_1_subnet"] = Menu(fig[1, 1][1, 1][2, 3], options=[i for i in 1:subnet_amount], default=member_variables.interactables_observables["intents"]["menus"]["node_1_subnet"][])
    member_variables.interactables["intents"]["menus"]["node_2"] = Menu(fig[1, 1][1, 1][3, 2], options=[i for i in 1:10], default=member_variables.interactables_observables["intents"]["menus"]["node_2"][])
    member_variables.interactables["intents"]["menus"]["node_2_subnet"] = Menu(fig[1, 1][1, 1][3, 3], options=[i for i in 1:subnet_amount], default=member_variables.interactables_observables["intents"]["menus"]["node_2_subnet"][])
    member_variables.interactables["intents"]["menus"]["speed"] = Menu(fig[1, 1][1, 1][4, 2:3], options=[1, 2, 3, 4], default=member_variables.interactables_observables["intents"]["menus"]["speed"][])

    if length(member_variables.loaded_intents) > 0
        member_variables.interactables["intents"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 4:5], options=[v["name"] for v in member_variables.loaded_intents])
    else
        member_variables.interactables["intents"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 4:5])
    end

    if length(member_variables.ibns) > 0
        member_variables.interactables["intents"]["menus"]["ibn"] = Menu(fig[1, 1][1, 1][3, 0:1], options=[["New Net"]; [v["name"] for v in member_variables.ibns]])
    else
        member_variables.interactables["intents"]["menus"]["ibn"] = Menu(fig[1, 1][1, 1][3, 0:1], options=["New Net"])
    end

    #Buttons
    member_variables.interactables["intents"]["buttons"]["create_new_intent"] = Button(fig[1, 1][1, 1][2, 4:5], label="Create")
    member_variables.interactables["intents"]["buttons"]["refresh_top"] = Button(fig[1, 1][1, 1][4, 4:5], label="Refresh Top")





    #Button Listeners
    on(member_variables.interactables["intents"]["buttons"]["create_new_intent"].clicks) do s
        _v = member_variables.interactables["intents"]["menus"]

        if member_variables.interactables["intents"]["menus"]["ibn"].selection[] == "New Net"
            idi, ibn = init_intent(_v["node_1"].selection[],
                _v["node_1_subnet"].selection[],
                _v["node_2"].selection[],
                _v["node_2_subnet"].selection[],
                _v["speed"].selection[],
                _v["topology"].selection[],
                _v["subnet"].selection[],
                myibns=nothing)

            counter = 1

            for i in 1:length(member_variables.ibns)
                if occursin(_v["topology"].selection[], member_variables.ibns[i]["name"])
                    counter += 1
                end
            end

            name = _v["topology"].selection[] * " " * string(counter)
            append!(member_variables.ibns, [Dict("name" => name, "ibn" => ibn)])
            member_variables.interactables["intents"]["menus"]["ibn"].options = [member_variables.interactables["intents"]["menus"]["ibn"].options[]; name]

            intent_name = name * ", " * string(idi.value, base=16)

        else
            ibn_ar_index = findall(x -> x["name"] == member_variables.interactables["intents"]["menus"]["ibn"].selection[], member_variables.ibns)[1]


            idi, ibn = init_intent(_v["node_1"].selection[],
                _v["node_1_subnet"].selection[],
                _v["node_2"].selection[],
                _v["node_2_subnet"].selection[],
                _v["speed"].selection[],
                _v["topology"].selection[],
                _v["subnet"].selection[],
                myibns=member_variables.ibns[ibn_ar_index]["ibn"])

            intent_name = member_variables.ibns[ibn_ar_index]["name"] * ", " * string(idi.value, base=16)

        end






        append!(member_variables.loaded_intents, [Dict("id" => idi, "ibn" => ibn, "name" => intent_name)])

        member_variables.interactables["intents"]["menus"]["loaded_intents"].options = [member_variables.interactables["intents"]["menus"]["loaded_intents"].options[]; intent_name]

        println()
        println(member_variables.ibns[1]["name"])
        println(intent_name)
        println(string(idi.value, base=16))
        for _a in ["node_1", "node_1_subnet", "node_2", "node_2_subnet", "topology", "subnet", "speed"]
            println(_a, ":   ", _v[_a].selection[])
        end
    end


    on(member_variables.interactables["intents"]["buttons"]["refresh_top"].clicks) do s
        member_variables.interactables["intents"]["menus"]["topology"].options[] = get_graph_names()
    end


    #Menu Listeners

    on(member_variables.interactables["intents"]["menus"]["topology"].selection) do s
        subnet_amount = get_subnet_amount(s)
        member_variables.interactables["intents"]["menus"]["node_1_subnet"].options = [i for i in 1:subnet_amount]
        member_variables.interactables["intents"]["menus"]["node_2_subnet"].options = [i for i in 1:subnet_amount]

    end

    on(member_variables.interactables["intents"]["menus"]["ibn"].selection) do s

    end


    for (k, v) in member_variables.interactables["intents"]["menus"]
        if !(k in ["ibn"])
            on(v.selection) do s
                member_variables.interactables_observables["intents"]["menus"][k][] = s
            end
        end
    end

end