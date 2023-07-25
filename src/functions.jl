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
        subgl[2, 2][1:2, 1:2] = member_variables.interactables["buttons"]["draw"] = [Button(member_variables.fig, width=100, label="Draw to: $i, $j") for i in 1:2, j in 1:2]

        for i in 1:2
            for j in 1:2

            end

        end

        menu_fullscreen = subgl[2, 1][1, 1] = Menu(member_variables.fig, options=[1, 2, 3, 4])


        member_variables.interactables["label"]["ibn_type"] = subgl[1, 1][2, 1] = Label(member_variables.fig, "IBN Index")
        member_variables.interactables["label"]["topology"] = subgl[1, 1][1, 1] = Label(member_variables.fig, "Topology")


        graph_file_names = get_graph_names()


        member_variables.interactables["menus"]["topology"] = subgl[1, 2][1, 1:2] = Menu(member_variables.fig, options=graph_file_names)
        #member_variables.interactables_observables["menus"]["topology"][] = s

        member_variables.interactables_observables["menus"]["ibn_type_array"][] = [i - 1 for i in 1:get_ibn_size(graph_file_names[1])[1]+1]
        member_variables.interactables["menus"]["ibn_type"] = subgl[1, 2][2, 1:2] = Menu(member_variables.fig, options=member_variables.interactables_observables["menus"]["ibn_type_array"])


        #println((member_variables.interactables["menus"]["ibn_type"]))



        on(menu_fullscreen.selection) do s
            member_variables.menu_number[] = s
        end

        on(member_variables.interactables["menus"]["ibn_type"].selection) do s
            member_variables.ibn_button_observable["selected"][] = s
        end

        on(member_variables.interactables["menus"]["topology"].selection) do s
            member_variables.interactables_observables["menus"]["ibn_type_array"][] = [i - 1 for i in 1:get_ibn_size(s)[1]+1]
            #println(member_variables.interactables_observables["menus"]["ibn_type_array"][])
            println("IBN subnets found: " * string(get_ibn_size(s)[1]))


        end


    end

    subgl[2, 1][2, 1] = member_variables.interactables["buttons"]["fullscreen"] = Button(member_variables.fig, width=100, label="Fullscreen")


    sub = GridLayout()
    sub[1:2, 1:3] = subgl
    member_variables.fig[1, 1] = sub


end

function draw_graph(type_of_graph, position, member_variables, topology; fullscreen=false)
    #local topology = member_variables.interactables["menus"]["topology"].selection[]


    #if type of graph is int 
    if fullscreen == false
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["ibn_type"] = type_of_graph
        member_variables.fullscreen_graph_information[[1 3; 2 4][position[1], position[2]]]["args"]["topology"] = topology
    end

    if type_of_graph == 0
        a = Axis(member_variables.fig[position[1], position[2]], title="Graph " * string([1 3; 2 4][position[1], position[2]]) * ", " * "Topology: " * topology * ", IBN Index: " * string(type_of_graph))
        member_variables.graphs[[1 3; 2 4][position[1], position[2]]][] = a
        p = generate_ibns(a, topology)

    else
        a = Axis(member_variables.fig[position[1], position[2]])
        member_variables.graphs[[1 3; 2 4][position[1], position[2]]][] = a
        p = generate_ibns(a, topology; pos=type_of_graph)

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
                draw_graph(member_variables.ibn_button_observable["selected"][], [(1, 1), (2, 1), (1, 2), (2, 2)][i], member_variables, member_variables.interactables["menus"]["topology"].selection[])

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

function enter_fullscreen(member_variables, pos_origin)
    println("pos_origin:" * string(pos_origin, base=10))
    println("IBN type:" * string(member_variables.fullscreen_graph_information[pos_origin]["args"]["ibn_type"], base=10))
    println(member_variables.fullscreen_graph_information)
    draw_graph(member_variables.fullscreen_graph_information[pos_origin]["args"]["ibn_type"], (2, 1), member_variables, member_variables.fullscreen_graph_information[pos_origin]["args"]["topology"]; fullscreen=true)
end

function exit_fullscreen()

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
                "topology" => 0),
            "label" => Dict(
                "ibn_type" => Any,
                "topology" => 0
            )),
        interactables_observables=Dict(
            "menus" => Dict(
                "topology" => Observable("asd"),
                "ibn_type_array" => Observable([1]))),
        menu_number=Observable(1),
        fullscreen_graph_information=[Dict("args" => Dict("ibn_type" => 0, "topology" => ""), "shown" => false) for i in 1:4],
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


            #delete!(member_variables.interactables["menus"]["ibn_type"])
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


            pos_origin = 0
            for (i, g) in enumerate(member_variables.graphs)
                if g[] != false
                    pos_origin = i
                    break
                end
            end

            for g in member_variables.graphs
                try
                    delete!(g[])
                catch
                end
            end

            enter_fullscreen(member_variables, member_variables.menu_number[])

            colsize!(member_variables.fig.layout, 1, Relative(0.99))
            rowsize!(member_variables.fig.layout, 1, Relative(0.1))

            colsize!(member_variables.fig.layout, 2, Fixed(0))
            rowsize!(member_variables.fig.layout, 2, Relative(0.9))


        else
            delete!(member_variables.interactables["buttons"]["draw"][1])
            delete!(member_variables.interactables["buttons"]["draw"][2])
            delete!(member_variables.interactables["buttons"]["draw"][3])
            delete!(member_variables.interactables["buttons"]["draw"][4])

            delete!(member_variables.interactables["buttons"]["fullscreen"])


            add_interactors_to_control_panel(member_variables)
            initialize_listeners_control_panel(member_variables; member_variables.draw_button_clicked)
            initialize_fullscreen_listeners(member_variables)

            delete!(member_variables.graphs[2][])


            for i in 1:size(member_variables.fullscreen_graph_information)[1]
                if member_variables.fullscreen_graph_information[i]["shown"] == true
                    draw_graph(member_variables.fullscreen_graph_information[i]["args"]["ibn_type"], [(1, 1), (2, 1), (1, 2), (2, 2)][i], member_variables,
                        member_variables.fullscreen_graph_information[i]["args"]["topology"])
                end

            end


            colsize!(member_variables.fig.layout, 1, Relative(0.45))
            rowsize!(member_variables.fig.layout, 1, Relative(0.45))

            colsize!(member_variables.fig.layout, 2, Relative(0.45))
            rowsize!(member_variables.fig.layout, 2, Relative(0.45))


        end


    end


    fig

end

function startup()
    fig = Figure(resolution=(1600, 1000))

    main(fig)

    #         a = Axis(fig[1,1])
    #         p = generate_ibns(a)


    fig
end
