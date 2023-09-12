function init_control_panel_intent_actions(member_variables)
    fig = member_variables.fig
    #Menus
    member_variables.interactables["intent_actions"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 2:5],
        options=[v["name"] for v in member_variables.loaded_intents])
    member_variables.interactables["intent_actions"]["menus"]["compilation_algorithm"] = Menu(fig[1, 1][1, 1][2, 2:5],
        options=["shortestavailpath", "jointrmsagenerilizeddijkstra", "longestavailpath"])

    #Buttons

    member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"] = Button(fig[1, 1][1, 1][2, 0:1], label="Compile")
    member_variables.interactables["intent_actions"]["buttons"]["install_intent"] = Button(fig[1, 1][1, 1][3, 0:1], label="Install")

    state = get_intent_state(find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[]))
    member_variables.interactables["intents"]["buttons"]["intent_state"] = Button(fig[1, 1][1, 1][3, 2:5], label="Intent state: " * string(state.state), buttoncolor=RGBf(1, 1, 1), buttoncolor_active=RGBf(1, 1, 1), buttoncolor_hover=RGBf(1, 1, 1))



    #Button Listeners
    on(member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"].clicks) do s
        intent = find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[])
        algorithm = member_variables.interactables["intent_actions"]["menus"]["compilation_algorithm"].selection[]

        intent["algo"] = algorithm

        deploy_intent(intent["ibn"][1], intent["id"], algorithm)
        update_displayed_intent_state(member_variables, intent=intent)

        update_compile_and_install_button_color(member_variables)
    end

    on(member_variables.interactables["intent_actions"]["buttons"]["install_intent"].clicks) do s
        intent = find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[])

        install_intent(intent["ibn"][1], intent["id"])
        update_displayed_intent_state(member_variables, intent=intent)

        update_compile_and_install_button_color(member_variables)
    end


    #Menu Listeners
    on(member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection) do s
        if member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].i_selected[] != 0
            update_displayed_intent_state(member_variables; intent=find_intent_in_loaded_by_name(member_variables, s))
        end
    end


    #change default labels

    prompts = Dict(
        "loaded_intents" => "Loaded Intents",
        "compilation_algorithm" => "Compilation Algorithm"
    )
    for x in ["loaded_intents", "compilation_algorithm"]
        member_variables.interactables["intent_actions"]["menus"][x].prompt = prompts[x]
        member_variables.interactables["intent_actions"]["menus"][x].i_selected[] = 0
    end

    update_menu_colors_ia(member_variables)

    #listeners to update colors every time
    for x in ["loaded_intents", "compilation_algorithm"]
        on(member_variables.interactables["intent_actions"]["menus"][x].selection) do s
            update_menu_colors_ia(member_variables)
        end
    end



end

function find_intent_in_loaded_by_name(member_variables, name)
    loaded_intent_ar_index = findall(x -> x["name"] == name, member_variables.loaded_intents)[1]
    intent = member_variables.loaded_intents[loaded_intent_ar_index]

    return intent
end

function get_intent_state(intent)
    return getintentnode(intent["ibn"][1], intent["id"])
end

function update_displayed_intent_state(member_variables; state=nothing, intent=nothing)
    if state === nothing
        state = get_intent_state(intent)
    end

    member_variables.interactables["intents"]["buttons"]["intent_state"].label = "Intent state: " * string(state.state)
end

function update_menu_colors_ia(member_variables)
    keys = ["loaded_intents", "compilation_algorithm"]
    green_count = 0
    for x in keys
        if member_variables.interactables["intent_actions"]["menus"][x].i_selected[] == 0
            member_variables.interactables["intent_actions"]["menus"][x].textcolor = colors.red
        else
            member_variables.interactables["intent_actions"]["menus"][x].textcolor = colors.green
            green_count += 1
        end
    end

    if green_count == length(keys)
        member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"].labelcolor = colors.green
    end

    update_compile_and_install_button_color(member_variables)
end

function update_compile_and_install_button_color(member_variables)
    if member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].i_selected[] > 0
        intent = find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[])
        intent_state = string(get_intent_state(intent).state)

        println(intent_state)

        if intent_state == "uncompiled"
            member_variables.interactables["intent_actions"]["buttons"]["install_intent"].labelcolor = colors.red

        elseif intent_state == "compiled"
            member_variables.interactables["intent_actions"]["buttons"]["install_intent"].labelcolor = colors.green
            member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"].labelcolor = colors.red
        elseif intent_state == "installed"
            member_variables.interactables["intent_actions"]["buttons"]["install_intent"].labelcolor = colors.red
            member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"].labelcolor = colors.red

        end
    else
        member_variables.interactables["intent_actions"]["buttons"]["install_intent"].labelcolor = colors.red
        member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"].labelcolor = colors.red
    end
end