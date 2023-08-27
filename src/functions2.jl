


Base.@kwdef mutable struct MemberVariables
    fig

    graphs

    interactables
    interactables_observables

    displayed_graphs

    loaded_intents

end

function generate_grid_layout!(fig)
    fig[1:2, 1:2] = GridLayout()
    fig[1, 1][1:2, 1:2] = GridLayout()
end

function delete_all_interactables_from_screen(member_variables)

    for (k, v) in member_variables.interactables
        for (k2, v2) in v
            if typeof(v2) in [Makie.Menu, Makie.Button]
                delete!(v2)
            else
                for (k3, v3) in v2
                    if typeof(v3) in [Makie.Menu, Makie.Button]
                        delete!(v3)
                    end
                end
            end
        end
    end
end




function initialize_control_panel(member_variables)

    delete_all_interactables_from_screen(member_variables)

    fig = member_variables.fig
    member_variables.interactables["general"]["menu"] = Menu(fig[1, 1][1, 1][1, 0:1], options=["intents", "draw"], default=member_variables.interactables_observables["general"]["menu"][])

    # check what type of control panel needs to be displayed 
    if member_variables.interactables_observables["general"]["menu"][] == "intents"
        init_control_panel_intents(member_variables)

    elseif member_variables.interactables_observables["general"]["menu"][] == "draw"
        init_control_panel_drawing(member_variables)
    end

    #add listerners for observables
    for (k, v) in member_variables.interactables
        for (k2, v2) in v
            if typeof(v2) == Makie.Menu
                on(v2.selection) do s
                    println(s)
                    member_variables.interactables_observables[k][k2][] = s
                end
            end
        end
    end



end



function main(fig)
    member_variables = init_member_variables(fig)

    generate_grid_layout!(fig)
    initialize_control_panel(member_variables)

    on(member_variables.interactables_observables["general"]["menu"]) do s
        initialize_control_panel(member_variables)
    end



end

function init_member_variables(fig)
    member_variables = MemberVariables(
        fig=fig,
        graphs=Dict(
            
        ),
        interactables=Dict(
            "general" => Dict(
                "menu" => Menu(fig[1, 1][1, 1][1, 1], options=["a"])
            ),
            "intents" => Dict(
                "buttons" => Dict(
                    "create_new_intent" => Button(fig[1, 1][1, 1][1, 1], label="a"),
                    "save_intent" => Button(fig[1, 1][1, 1][1, 1], label="a"),
                    "delete_intent" => Button(fig[1, 1][1, 1][1, 1], label="a")
                ),
                "menus" => Dict(
                    "topology" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "subnet" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "node_1" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "node_1_subnet" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "node_2" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "node_2_subnet" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "speed" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "intent_list" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "loaded_intents" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                )
            ),
            "drawing" => Dict(
                "menus" => Dict(
                    "loaded_intents" => Menu(fig[1, 1][1, 1][1, 1], options=["a"]),
                    "draw_position" => Menu(fig[1, 1][1, 1][1, 1], options=["a"])
                ),
                "buttons" => Dict(
                    "draw" => Button(fig[1, 1][1, 1][1, 1], label="a")
                )
            )
        ),
        interactables_observables=Dict(
            "general" => Dict(
                "menu" => Observable("intents")
            ),
            "intents" => Dict(
                "menus" => Dict(
                    "topology" => Observable("4nets"),
                    "subnet" => Observable(1),
                    "node_1" => Observable(1),
                    "node_1_subnet" => Observable(1),
                    "node_2" => Observable(1),
                    "node_2_subnet" => Observable(1),
                    "speed" => Observable(1),
                    "intent_list" => Observable(2),
                    "loaded_intents" => Observable("default intent")
                ))
        ), displayed_graphs=nothing,
        loaded_intents=Dict(
            "default intent" =>
                Dict(
                    "name" => "default intent",
                    "node_1" => 1,
                    "node_1_subnet" => 1,
                    "node_2" => 1,
                    "node_2_subnet" => 1, "speed" => 1,
                    "topology" => "4nets",
                    "subnet" => 1,
                    "rolling_number" => time()
                )
        )
    )

    return member_variables
end

function startup()
    fig = Figure(resolution=(1600, 1000))
    main(fig)

    fig
end