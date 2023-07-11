#=
MINDFulGLMakieApp:
- Julia version: 1.9.1
- Author: Niels
- Date: 2023-07-8
=#


export MINDFulGLMakieApp

module MINDFulGLMakieApp
    using GLMakie


    function generate_grid_layout!(fig)
        fig[1:2, 1:2] = GridLayout()
    end


    function generate_control_panel!(fig)
        fig[1, 1][1:2, 1:2] = GridLayout()

    end

    function add_interactors_to_control_panel(fig)
        subgl = [GridLayout() GridLayout(); GridLayout() GridLayout()]
        subgl[1, 1][1,1] = tb = Textbox(fig, placeholder = "Frequency: ", validator = Float64, tellwidth = false)

        subgl[2, 1][1:2, 1:2] = draw_buttons = [Button(fig, width = 100, label = "Draw to: $i, $j") for i in 1:2, j in 1:2]


        subgl[1, 2][1,1] = fullscreen_button = Button(fig, width = 100, label = "Fullscreen")
        subgl[1, 2][1,2] = fullscreen_button = Button(fig, width = 100, label = "Side by side")
        subgl[1, 2][2,1] = fullscreen_button = Button(fig, width = 100, label = "Pop out")

        sub = GridLayout()
        sub[1:2, 1:2] = subgl
        fig[1, 1] = sub

        return tb, draw_buttons, fullscreen_button


    end

    function draw_graph(type_of_graph, position, observable_frequncies, fig, graphs)
        if type_of_graph == "sine"

            frequency = observable_frequncies[1][]
            xs = 0:0.01:10
            sinecurve = @lift(sin.($frequency .* xs))


            fig[position[1], position[2]] = graphs[[1 3 ; 2 4][position[1], position[2]]][] =  Axis(fig[position[1], position[2]], alignmode = Outside(50))
            lines!(xs, sinecurve)

        end


    end

    function initialize_listeners(fig, tb, frequencies, draw_buttons, draw_buttons_clicked, graphs)
        on(tb.stored_string) do s
            for i in 1:4
                frequencies[i][] = parse(Float64,s)

            end

        end

        for  i in 1:4
            on(draw_buttons[i].clicks) do b
                #println(draw_buttons_clicked[i][])

                if graphs[i][] == false
                    draw_graph("sine", [(1,1), (2,1), (1,2), (2,2)][i], frequencies, fig, graphs)

                else

                    delete!(graphs[i][])
                    graphs[i][] = false

                end



            end

        end

    end


    # function initialize_fullscreen_listeners(fig, fullscreen_button, fullscreen_button_obversable, draw_buttons)
    #     on(fullscreen_button.clicks) do b
    #         #println(tmp)
    #         println(fullscreen_button_obversable)
    #         if fullscreen_button_obversable[] == false
    #             #delete all buttons
    #             global tmp = fig[1, 1]
    #
    #             delete!(draw_buttons[1])
    #             delete!(draw_buttons[2])
    #             delete!(draw_buttons[3])
    #             delete!(draw_buttons[4])
    #
    #             fullscreen_button_obversable[] = true
    #         else
    #
    #             fig[1, 1] = tmp
    #         end
    #
    #
    #
    #
    #
    #     end
    # end


    function main(fig)


        frequencies = [Observable(1.0) for i in 1:4]
        draw_button_clicked = [Observable(false) for i in 1:4]
        graphs = [Observable{Any}(false) for i in 1:4]
        fullscreen_button_obversable = Observable(false)
        side_by_side_button_observable = Observable(false)
        pop_out_button_observable = Observable(false)



        generate_grid_layout!(fig)

        generate_control_panel!(fig)

        #println(fig[1, 1])

        tb, draw_buttons, fullscreen_button = add_interactors_to_control_panel(fig)

        initialize_listeners(fig, tb, frequencies, draw_buttons, draw_button_clicked, graphs)
        #initialize_fullscreen_listeners(fig, fullscreen_button, fullscreen_button_obversable, draw_buttons)

        #draw_graph("sine", (1,2), frequencies, fig)

        colsize!(fig.layout,1, Relative(1 / 2))
        rowsize!(fig.layout,1, Relative(1 / 2))

        fig

    end

    function startup()
        fig = Figure(resolution = (1600, 1000))

        main(fig)

        fig
    end


end
