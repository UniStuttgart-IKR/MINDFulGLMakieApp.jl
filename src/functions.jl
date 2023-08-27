#import MINDFulGraphs: generate_ibns



const red_colour = RGBf(185 / 255, 29 / 255, 70 / 255)
const green_colour = RGBf(13 / 255, 151 / 255, 22 / 255)
const gray_colour = RGBf(245 / 255, 245 / 255, 245 / 255)



function generate_grid_layout!(fig)
    fig[1:2, 1:2] = GridLayout()
end


function generate_control_panel!(fig)
    fig[1, 1][1:2, 1:2] = GridLayout()
end

function add_interactors_to_control_panel(member_variables; draw_fullscreen_button=true, draw_draw_buttons=true)
    subgl = [GridLayout() GridLayout() GridLayout(); GridLayout() GridLayout() GridLayout()]


    if draw_draw_buttons == true
        subgl[2, 1][1:2, 2:3] = member_variables.interactables["buttons"]["draw"] = [Button(member_variables.fig, width=100, label="Draw to: $i, $j") for i in 1:2, j in 1:2]

        menu_fullscreen = subgl[2, 1][1, 1] = Menu(member_variables.fig, options=[1, 2, 3, 4])


        member_variables.interactables["label"]["ibn_type"] = subgl[1, 1][2, 1] = Label(member_variables.fig, "IBN Index")
        member_variables.interactables["label"]["topology"] = subgl[1, 1][1, 1] = Label(member_variables.fig, "Topology")
        member_variables.interactables["label"]["graph_type"] = subgl[1, 1][3, 1] = Label(member_variables.fig, "Graph Type")
        member_variables.interactables["label"]["node"] = subgl[1, 1][4, 1] = Label(member_variables.fig, "Nodes")
        member_variables.interactables["label"]["node_ibn"] = subgl[1, 1][5, 1] = Label(member_variables.fig, "IBN Index for Node")
        member_variables.interactables["label"]["speed"] = subgl[1, 1][6, 1] = Label(member_variables.fig, "Speed [Gbps]")




        graph_file_names = get_graph_names()


        member_variables.interactables["menus"]["topology"] = subgl[1, 1][1, 2:3] = Menu(member_variables.fig, options=graph_file_names)
        #member_variables.interactables_observables["menus"]["topology"][] = s

        member_variables.interactables_observables["menus"]["ibn_type_array"][] = [i - 1 for i in 1:get_ibn_size(graph_file_names[1])[1]+1]
        member_variables.interactables["menus"]["ibn_type"] = subgl[1, 1][2, 2:3] = Menu(member_variables.fig, options=member_variables.interactables_observables["menus"]["ibn_type_array"])

        member_variables.interactables["menus"]["graph_type"] = subgl[1, 1][3, 2:3] = Menu(member_variables.fig, options=["ibn", "co_intent", "co_in_intent", "vis_intent", "vis_cd_intent"])

        member_variables.interactables["menus"]["node_1"] = subgl[1, 1][4, 2] = Menu(member_variables.fig, options=[i for i in 1:10])
        member_variables.interactables["menus"]["node_2"] = subgl[1, 1][4, 3] = Menu(member_variables.fig, options=[i for i in 1:10])
        member_variables.interactables["menus"]["node_1_ibn"] = subgl[1, 1][5, 2] = Menu(member_variables.fig, options=[i for i in 1:4])
        member_variables.interactables["menus"]["node_2_ibn"] = subgl[1, 1][5, 3] = Menu(member_variables.fig, options=[i for i in 1:4])
        member_variables.interactables["menus"]["speed"] = subgl[1, 1][6, 2:3] = Menu(member_variables.fig, options=[i * 10 for i in 1:10])



        #println((member_variables.interactables["menus"]["ibn_type"]))



        on(menu_fullscreen.selection) do s
            member_variables.menu_number[] = s
        end

        on(member_variables.interactables["menus"]["ibn_type"].selection) do s
            member_variables.ibn_button_observable["selected"][] = s #  <- remove
            member_variables.interactables_observables["menus"]["ibn_type"][] = s
        end

        on(member_variables.interactables["menus"]["topology"].selection) do s
            member_variables.interactables_observables["menus"]["ibn_type_array"][] = [i - 1 for i in 1:get_ibn_size(s)[1]+1]
            #println(member_variables.interactables_observables["menus"]["ibn_type_array"][])
            println("IBN subnets found: " * string(get_ibn_size(s)[1]))
        end

        on(member_variables.interactables["menus"]["graph_type"].selection) do s
            member_variables.interactables_observables["menus"]["graph_type"][] = s
        end


    end

    subgl[2, 1][2, 1] = member_variables.interactables["buttons"]["fullscreen"] = Button(member_variables.fig, width=100, label="Fullscreen")


    sub = GridLayout()
    sub[1:2, 1:3] = subgl
    member_variables.fig[1, 1] = sub


end

function draw_graph(position, member_variables, topology; fullscreen=0)
    #local topology = member_variables.interactables["menus"]["topology"].selection[]


    #if type of graph is int 
    if fullscreen == 0 #get args from observables
        ibn_type = member_variables.interactables_observables["menus"]["ibn_type"][]
        graph_type = member_variables.interactables_observables["menus"]["graph_type"][]

        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["ibn_type"] = ibn_type
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["topology"] = topology
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["graph_type"] = graph_type

        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["nodes"]["node_1"] = node_1 = member_variables.interactables["menus"]["node_1"].selection[]
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["nodes"]["node_2"] = node_2 = member_variables.interactables["menus"]["node_2"].selection[]
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["nodes"]["node_1_ibn"] = node_1_ibn = member_variables.interactables["menus"]["node_1_ibn"].selection[]
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["nodes"]["node_2_ibn"] = node_2_ibn = member_variables.interactables["menus"]["node_2_ibn"].selection[]
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["nodes"]["speed"] = speed = member_variables.interactables["menus"]["speed"].selection[]



    else #unpack args from fullscreen_graph_information
        ibn_type = member_variables.fullscreen_graph_information[fullscreen]["args"]["ibn_type"]
        topology = member_variables.fullscreen_graph_information[fullscreen]["args"]["topology"]
        graph_type = member_variables.fullscreen_graph_information[fullscreen]["args"]["graph_type"]

        node_1 = member_variables.fullscreen_graph_information[fullscreen]["args"]["nodes"]["node_1"]
        node_2 = member_variables.fullscreen_graph_information[fullscreen]["args"]["nodes"]["node_2"]
        node_1_ibn = member_variables.fullscreen_graph_information[fullscreen]["args"]["nodes"]["node_1_ibn"]
        node_2_ibn = member_variables.fullscreen_graph_information[fullscreen]["args"]["nodes"]["node_2_ibn"]
        speed = member_variables.fullscreen_graph_information[fullscreen]["args"]["nodes"]["speed"]
    end

    a = Axis(member_variables.fig[position[1], position[2]], title="Graph " * string([1 3; 2 4][position[1], position[2]]) * ", " * "Topology: " * topology * ", IBN Index: " * string(ibn_type))
    member_variables.graphs[[1 3; 2 4][position[1], position[2]]][] = a

    if graph_type == "ibn"
        generate_ibns(a, topology, graph_type; pos=ibn_type)
    else
        intent_args = Dict(
            "node_1" => node_1,
            "node_2" => node_2,
            "node_1_ibn" => node_1_ibn,
            "node_2_ibn" => node_2_ibn,
            "speed" => speed
        )



        generate_ibns(a, topology, graph_type; pos=ibn_type, intent_args=intent_args)
    end




end

function initialize_listeners_control_panel(member_variables; draw_button_clicked=false)
    draw_button_clicked = []
    for i in 1:4
        append!(draw_button_clicked, [Observable(false)])
    end


    #draw graphs
    for i in 1:4
        on(member_variables.interactables["buttons"]["draw"][i].clicks) do b

            if member_variables.graphs[i][] == false
                draw_graph([(1, 1), (2, 1), (1, 2), (2, 2)][i], member_variables, member_variables.interactables["menus"]["topology"].selection[])

                member_variables.fullscreen_graph_information[i]["shown"] = true


            else
                delete!(member_variables.graphs[i][])
                member_variables.graphs[i][] = false

                member_variables.fullscreen_graph_information[i]["shown"] = false
            end
        end
    end

    return draw_button_clicked



end


function initialize_fullscreen_listeners(member_variables)
    #fullscreen button clicked
    on(member_variables.interactables["buttons"]["fullscreen"].clicks) do b
        if member_variables.fullscreen_button_obversable[] == false
            member_variables.fullscreen_button_obversable[] = true
        else
            member_variables.fullscreen_button_obversable[] = false
        end
    end
end

function enter_fullscreen(member_variables)

    pos_origin = member_variables.menu_number[]
    #delete all interactables on screen but fullscreen
    for (k1, v1) in member_variables.interactables
        for (k2, v2) in member_variables.interactables[k1]
            println((member_variables.interactables[k1][k2]))
            if typeof(v2) in [Makie.Label, Makie.Menu, Makie.Button]

                delete!(v2)

            elseif typeof(v2) == Matrix{Makie.Button}
                [delete!(v2[i]) for i in 1:4]
            end
        end
    end

    delete!(member_variables.interactables["buttons"]["fullscreen"])

    add_interactors_to_control_panel(member_variables; draw_fullscreen_button=true, draw_draw_buttons=false)
    #initialize_listeners_control_panel(fig, tb, draw_buttons, graphs, draw_button_clicked)
    initialize_fullscreen_listeners(member_variables)

    #= pos_origin = 0
    for (i, g) in enumerate(member_variables.graphs)
        if g[] != false
            pos_origin = i
            break
        end
    end =#

    for g in member_variables.graphs
        try
            delete!(g[])
        catch
        end
    end
    colsize!(member_variables.fig.layout, 1, Relative(0.99))
    rowsize!(member_variables.fig.layout, 1, Relative(0.05))

    colsize!(member_variables.fig.layout, 2, Fixed(0))
    rowsize!(member_variables.fig.layout, 2, Relative(0.95))


    println("pos_origin:" * string(pos_origin, base=10))
    println("IBN type:" * string(member_variables.fullscreen_graph_information[pos_origin]["args"]["ibn_type"], base=10))
    println(member_variables.fullscreen_graph_information)
    draw_graph((2, 1), member_variables, member_variables.fullscreen_graph_information[pos_origin]["args"]["topology"]; fullscreen=pos_origin)
end

function exit_fullscreen(member_variables)
    [delete!(member_variables.interactables["buttons"]["draw"][i]) for i in 1:4]

    delete!(member_variables.interactables["buttons"]["fullscreen"])


    add_interactors_to_control_panel(member_variables)
    initialize_listeners_control_panel(member_variables; member_variables.draw_button_clicked)
    initialize_fullscreen_listeners(member_variables)

    delete!(member_variables.graphs[2][])

    for i in 1:size(member_variables.fullscreen_graph_information)[1]
        if member_variables.fullscreen_graph_information[i]["shown"] == true
            draw_graph([(1, 1), (2, 1), (1, 2), (2, 2)][i], member_variables,
                member_variables.fullscreen_graph_information[i]["args"]["topology"], fullscreen=i)
        end

    end
    colsize!(member_variables.fig.layout, 1, Relative(0.45))
    rowsize!(member_variables.fig.layout, 1, Relative(0.45))

    colsize!(member_variables.fig.layout, 2, Relative(0.45))
    rowsize!(member_variables.fig.layout, 2, Relative(0.45))

end

Base.@kwdef mutable struct MemberVariables

    fig

    graphs
    fullscreen_button_obversable
    side_by_side_button_observable
    pop_out_button_observable

    interactables
    interactables_observables

    menu_number

    fullscreen_graph_information
    ibn_button_observable

    draw_button_clicked

end


function main(fig)
    generate_grid_layout!(fig)
    generate_control_panel!(fig)

    member_variables = MemberVariables(fig=fig, graphs=[Observable{Any}(false) for i in 1:4],
        fullscreen_button_obversable=Observable(false),
        side_by_side_button_observable=Observable(false),
        pop_out_button_observable=Observable(false),
        interactables=Dict(
            "buttons" => Dict(
                "draw" => Any[Any Any; Any Any],
                "fullscreen" => 0),
            "menus" => Dict(
                "fullscreen" => Any,
                "ibn_type" => 0,
                "topology" => 0,
                "graph_type" => 0,
                "node_1" => 0,
                "node_2" => 0,
                "node_1_ibn" => 0,
                "node_2_ibn" => 0,
                "speed" => 0
            ),
            "label" => Dict(
                "ibn_type" => Any,
                "topology" => 0,
                "graph_type" => 0,
                "node" => 0,
                "node_ibn" => 0,
                "speed" => 0
            )),
        interactables_observables=Dict(
            "menus" => Dict(
                "topology" => Observable("asd"),
                "ibn_type_array" => Observable([1]),
                "ibn_type" => Observable(0),
                "graph_type" => Observable("ibn"),           #ibn = normal ibn, co_intent = compiled intent, co_in_intent = compiled installed intent, vis_intent = visualization of the ..., vis_cd_intent = ...
                "node_1" => Observable(1),
                "node_2" => Observable(1),
                "node_1_ibn" => Observable(1),
                "node_2_ibn" => Observable(1),
                "speed" => Observable(0)
            )),
        menu_number=Observable(1),
        fullscreen_graph_information=[Dict(
            "args" => Dict(
                "graph_type" => "ibn",
                "ibn_type" => 0,
                "topology" => "",
                "nodes" => Dict(
                    "node_1" => 0,
                    "node_2" => 0,
                    "node_1_ibn" => 0,
                    "node_2_ibn" => 0,
                    "speed" => 0
                ),
            ),
            "shown" => false)
                                      for i in 1:4],
        ibn_button_observable=Dict("selected" => Observable(0), "states" => [Observable(false) for i in 1:4]),
        draw_button_clicked=[0 0; 0 0])


    add_interactors_to_control_panel(member_variables)

    member_variables.draw_button_clicked = initialize_listeners_control_panel(member_variables)


    initialize_fullscreen_listeners(member_variables)

    colsize!(fig.layout, 1, Relative(0.45))
    rowsize!(fig.layout, 1, Relative(0.45))

    colsize!(fig.layout, 2, Relative(0.45))
    rowsize!(fig.layout, 2, Relative(0.45))




    #fullscreen listener
    on(member_variables.fullscreen_button_obversable) do s
        if member_variables.fullscreen_button_obversable[] == true
            #wants to go in fs
            enter_fullscreen(member_variables)
        else
            exit_fullscreen(member_variables)
        end


    end


    fig

end

function startup()
    fig = Figure(resolution=(1600, 1000))
    main(fig)

    fig
end
