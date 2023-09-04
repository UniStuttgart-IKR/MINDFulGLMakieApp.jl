function init_control_panel_intent_actions(member_variables)
    fig = member_variables.fig
    #Menus
    member_variables.interactables["intent_actions"]["menus"]["loaded_intents"] = Menu(fig[1, 1][1, 1][1, 2:3],
        options=[v["name"] for v in member_variables.loaded_intents])
    member_variables.interactables["intent_actions"]["menus"]["compilation_algorithm"] = Menu(fig[1, 1][1, 1][2, 0:3],
        options=["shortestavailpath", "jointrmsagenerilizeddijkstra", "longestavailpath"])

    #Buttons

    member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"] = Button(fig[1, 1][1, 1][2, 4:5], label="Deploy")
    member_variables.interactables["intent_actions"]["buttons"]["install_intent"] = Button(fig[1, 1][1, 1][3, 4:5], label="Install")

    state = get_intent_state(find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[]))
    member_variables.interactables["intents"]["buttons"]["intent_state"] = Button(fig[1, 1][1, 1][1, 4:5], label=string(state.state), buttoncolor = RGBf(1,1,1), buttoncolor_active = RGBf(1,1,1), buttoncolor_hover = RGBf(1,1,1))



    #Button Listeners
    on(member_variables.interactables["intent_actions"]["buttons"]["deploy_intent"].clicks) do s
        intent = find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[])
        algorithm = member_variables.interactables["intent_actions"]["menus"]["compilation_algorithm"].selection[]

        deploy_intent(intent["ibn"][1], intent["id"], algorithm)
        update_displayed_intent_state(member_variables, intent=intent)
    end

    on(member_variables.interactables["intent_actions"]["buttons"]["install_intent"].clicks) do s
        intent = find_intent_in_loaded_by_name(member_variables, member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection[])

        install_intent(intent["ibn"][1], intent["id"])
        update_displayed_intent_state(member_variables, intent=intent)
    end


    #Menu Listeners
    on(member_variables.interactables["intent_actions"]["menus"]["loaded_intents"].selection) do s
        update_displayed_intent_state(member_variables; intent=find_intent_in_loaded_by_name(member_variables, s))
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

    member_variables.interactables["intents"]["buttons"]["intent_state"].label = string(state.state)
end