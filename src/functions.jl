#import MINDFulGraphs: generate_ibns
include("MINDFulGraphs.jl")


const red_colour = RGBf(185 / 255, 29 / 255, 70 / 255)
const green_colour = RGBf(13 / 255, 151 / 255, 22 / 255)
const gray_colour = RGBf(245 / 255, 245 / 255, 245 / 255)

function hello_world()
    println("hello world 22")
end



function generate_grid_layout!(fig)
    fig[1:2, 1:2] = GridLayout()
end


function generate_control_panel!(fig)
    fig[1, 1][1:2, 1:2] = GridLayout()
end

function add_interactors_to_control_panel(fig; draw_fullscreen_button=true, draw_draw_buttons=true)
    subgl = [GridLayout() GridLayout(); GridLayout() GridLayout()]

    if draw_draw_buttons == true
        global draw_options_buttons
        subgl[1, 1][1:2, 1:2] = draw_options_buttons = [Button(fig, width=100, label=("IBN " * ["1" "2"; "3" "4"][i, j]), buttoncolor=button_colours["draw_option_buttons"][[1 2; 3 4][i, j]]) for i in 1:2, j in 1:2]
        subgl[2, 1][1:2, 1:2] = draw_buttons = [Button(fig, width=100, label="Draw to: $i, $j") for i in 1:2, j in 1:2]

        for i in 1:2
            for j in 1:2
                on(draw_options_buttons[i, j].clicks) do b
                    #println()
                    if ibn_button_observable["states"][[1 2; 3 4][i, j]][] == false
                        
                        
                        ibn_button_observable["states"][[1 2; 3 4][i, j]][] = true
                        ibn_button_observable["selected"][] = [1 2; 3 4][i, j]
                        button_colours["draw_option_buttons"][[1 2; 3 4][i, j]][] = green_colour



                    else
                        ibn_button_observable["states"][[1 2; 3 4][i, j]][] = false
                        ibn_button_observable["selected"][] = 0
                        button_colours["draw_option_buttons"][[1 2; 3 4][i, j]][] = gray_colour




                    end



                end
            end

        end




    end

    subgl[1, 2][1, 1] = fullscreen_button = Button(fig, width=100, label="Fullscreen")
    #         subgl[1, 2][1,2] = fullscreen_button = Button(fig, width = 100, label = "Side by side")
    #         subgl[1, 2][2,1] = fullscreen_button = Button(fig, width = 100, label = "Pop out")

    sub = GridLayout()
    sub[1:2, 1:2] = subgl
    fig[1, 1] = sub

    if draw_fullscreen_button == true && draw_draw_buttons == true
        return draw_buttons, fullscreen_button
    elseif draw_fullscreen_button == false && draw_draw_buttons == true
        return draw_buttons
    elseif draw_fullscreen_button == true && draw_draw_buttons == false
        return fullscreen_button

    end
end

function draw_graph(type_of_graph, position, fig, graphs; fullscreen=false)
    if type_of_graph == "sine"

        #frequency = observable_frequncies[1][]
        #xs = 0:0.01:10
        #sinecurve = @lift(sin.($frequency .* xs))


        #fig[position[1], position[2]] = graphs[[1 3 ; 2 4][position[1], position[2]]][] =  Axis(fig[position[1], position[2]], alignmode = Outside(50))
        #lines!(xs, sinecurve)

    elseif type_of_graph == 0
        a = Axis(fig[position[1], position[2]])
        graphs[[1 3; 2 4][position[1], position[2]]][] = a
        p = generate_ibns(a)
    
    else
        a = Axis(fig[position[1], position[2]])
        graphs[[1 3; 2 4][position[1], position[2]]][] = a
        p = generate_ibns(a; pos=ibn_button_observable["selected"][])

        if type_of_graph != 0
            println(type_of_graph)

            button_colours["draw_option_buttons"][ibn_button_observable["selected"][]][] = gray_colour
            ibn_button_observable["states"][ibn_button_observable["selected"][]][] = false
            ibn_button_observable["selected"][] = 0
        end
        


    end


end

function initialize_listeners_control_panel(fig, draw_buttons, graphs; draw_button_clicked=false)
    draw_button_clicked = []
    for i in 1:4
        append!(draw_button_clicked, [Observable(false)])
    end


    #draw graphs
    for i in 1:4
        on(draw_buttons[i].clicks) do b

            if graphs[i][] == false
                draw_graph(ibn_button_observable["selected"][], [(1, 1), (2, 1), (1, 2), (2, 2)][i], fig, graphs)

                fullscreen_graph_information[i]["shown"] = true

            else

                delete!(graphs[i][])
                graphs[i][] = false

                fullscreen_graph_information[i]["shown"] = false

            end



        end

    end

    return draw_button_clicked



end


function initialize_fullscreen_listeners(fig, fullscreen_button, fullscreen_button_obversable)
    #fullscreen button clicked
    on(fullscreen_button.clicks) do b
        if fullscreen_button_obversable[] == false
            fullscreen_button_obversable[] = true
        else
            fullscreen_button_obversable[] = false
        end
    end
end

function enter_fullscreen(fig, graphs, pos)


    draw_graph(0, [(1, 1), (2, 1), (1, 2), (2, 2)][2], fig, graphs)
end

function exit_fullscreen()

end


function main(fig)

    graphs = [Observable{Any}(false) for i in 1:4]
    fullscreen_button_obversable = Observable(false)
    side_by_side_button_observable = Observable(false)
    pop_out_button_observable = Observable(false)

    global fullscreen_graph_information = [Dict("args" => [], "shown" => false) for i in 1:4]


    global ibn_button_observable = Dict("selected" => Observable(0), "states" => [Observable(false) for i in 1:4])
    global button_colours = Dict("draw_option_buttons" => [Observable(gray_colour) for i in 1:4])


    generate_grid_layout!(fig)

    generate_control_panel!(fig)

    #println(fig[1, 1])

    draw_buttons, fullscreen_button = add_interactors_to_control_panel(fig)

    draw_button_clicked = initialize_listeners_control_panel(fig, draw_buttons, graphs)
    initialize_fullscreen_listeners(fig, fullscreen_button, fullscreen_button_obversable)

    colsize!(fig.layout, 1, Relative(0.45))
    rowsize!(fig.layout, 1, Relative(0.45))




    #fullscreen listener
    on(fullscreen_button_obversable) do s

        println(draw_button_clicked)
        if fullscreen_button_obversable[] == true
            #wants to go in fs
            delete!(draw_buttons[1])
            delete!(draw_buttons[2])
            delete!(draw_buttons[3])
            delete!(draw_buttons[4])

            for i in 1:2
                delete!(draw_options_buttons[i, 1])
                delete!(draw_options_buttons[i, 2])
            end


            delete!(fullscreen_button)

            fullscreen_button = add_interactors_to_control_panel(fig; draw_fullscreen_button=true, draw_draw_buttons=false)
            #initialize_listeners_control_panel(fig, tb, draw_buttons, graphs, draw_button_clicked)
            initialize_fullscreen_listeners(fig, fullscreen_button, fullscreen_button_obversable)

            #still need to decide what graph to "keep"

            for g in graphs
                try
                    delete!(g[])
                catch
                end
            end


            enter_fullscreen(fig, graphs, 2)

            colsize!(fig.layout, 1, Relative(0.99))
            rowsize!(fig.layout, 1, Fixed(100))


        else
            delete!(draw_buttons[1])
            delete!(draw_buttons[2])
            delete!(draw_buttons[3])
            delete!(draw_buttons[4])

            delete!(fullscreen_button)


            draw_buttons, fullscreen_button = add_interactors_to_control_panel(fig)
            initialize_listeners_control_panel(fig, draw_buttons, graphs; draw_button_clicked)
            initialize_fullscreen_listeners(fig, fullscreen_button, fullscreen_button_obversable)

            delete!(graphs[2][])


            for i in 1:size(fullscreen_graph_information)[1]
                if fullscreen_graph_information[i]["shown"] == true
                    draw_graph(0, [(1, 1), (2, 1), (1, 2), (2, 2)][i], fig, graphs)
                end

            end


            colsize!(fig.layout, 1, Relative(0.45))
            rowsize!(fig.layout, 1, Relative(0.45))


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
