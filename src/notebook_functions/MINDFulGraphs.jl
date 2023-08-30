#=
MINDFulGraphs:
- Julia version: 1.9.1
- Author: Niels
- Date: 2023-07-11
=#

#module MINDFulGraphs

using MINDFul, GraphIO, NestedGraphsIO, NestedGraphs, Graphs, MetaGraphs

using MINDFulMakie, GLMakie, Unitful

function get_subnet_amount(topology)
    topology *= ".graphml"

    MINDF = MINDFul
    defaultlinecards() = [MINDF.LineCardDummy(10, 100, 26.72), MINDF.LineCardDummy(2, 400, 29.36), MINDF.LineCardDummy(1, 1000, 31.99)]

    defaultlinecardchassis() = [MINDF.LineCardChassisDummy(Vector{MINDF.LineCardDummy}(), 4.7, 16)]

    defaulttransmissionmodules() = [MINDF.TransmissionModuleView("DummyFlexibleTransponder",
            MINDF.TransmissionModuleDummy([MINDF.TransmissionProps(5080.0u"km", 300, 8),
                    MINDF.TransmissionProps(4400.0u"km", 400, 8),
                    MINDF.TransmissionProps(2800.0u"km", 500, 8),
                    MINDF.TransmissionProps(1200.0u"km", 600, 8),
                    MINDF.TransmissionProps(700.0u"km", 700, 10),
                    MINDF.TransmissionProps(400.0u"km", 800, 10)], 0, 20)),
        MINDF.TransmissionModuleView("DummyFlexiblePluggables",
            MINDF.TransmissionModuleDummy([MINDF.TransmissionProps(5840.0u"km", 100, 4),
                    MINDF.TransmissionProps(2880.0u"km", 200, 6),
                    MINDF.TransmissionProps(1600.0u"km", 300, 6),
                    MINDF.TransmissionProps(480.0u"km", 400, 6)], 0, 8))
    ]

    myibns =
        let
            # read in the NestedGraph
            globalnet = open(joinpath("data/" * topology)) do io
                loadgraph(io, "main", GraphIO.GraphML.GraphMLFormat(), NestedGraphs.NestedGraphFormat())
            end

            # convert it to a NestedGraph compliant with the simulation specifications
            simgraph = MINDF.simgraph(globalnet;
                distance_method=MINDF.euclidean_dist,
                router_lcpool=defaultlinecards(),
                router_lccpool=defaultlinecardchassis(),
                router_lcccap=3,
                transponderset=defaulttransmissionmodules())

            # convert it to IBNs
            myibns = MINDFul.nestedGraph2IBNs!(simgraph)
        end

    return size(myibns)[1]
end

function generate_ibns(axis, topology, graph_type; pos=0, intent_args=false)
    topology *= ".graphml"


    MINDF = MINDFul
    defaultlinecards() = [MINDF.LineCardDummy(10, 100, 26.72), MINDF.LineCardDummy(2, 400, 29.36), MINDF.LineCardDummy(1, 1000, 31.99)]

    defaultlinecardchassis() = [MINDF.LineCardChassisDummy(Vector{MINDF.LineCardDummy}(), 4.7, 16)]

    defaulttransmissionmodules() = [MINDF.TransmissionModuleView("DummyFlexibleTransponder",
            MINDF.TransmissionModuleDummy([MINDF.TransmissionProps(5080.0u"km", 300, 8),
                    MINDF.TransmissionProps(4400.0u"km", 400, 8),
                    MINDF.TransmissionProps(2800.0u"km", 500, 8),
                    MINDF.TransmissionProps(1200.0u"km", 600, 8),
                    MINDF.TransmissionProps(700.0u"km", 700, 10),
                    MINDF.TransmissionProps(400.0u"km", 800, 10)], 0, 20)),
        MINDF.TransmissionModuleView("DummyFlexiblePluggables",
            MINDF.TransmissionModuleDummy([MINDF.TransmissionProps(5840.0u"km", 100, 4),
                    MINDF.TransmissionProps(2880.0u"km", 200, 6),
                    MINDF.TransmissionProps(1600.0u"km", 300, 6),
                    MINDF.TransmissionProps(480.0u"km", 400, 6)], 0, 8))
    ]

    myibns =
        let
            # read in the NestedGraph
            globalnet = open(joinpath("data/" * topology)) do io
                loadgraph(io, "main", GraphIO.GraphML.GraphMLFormat(), NestedGraphs.NestedGraphFormat())
            end

            # convert it to a NestedGraph compliant with the simulation specifications
            simgraph = MINDF.simgraph(globalnet;
                distance_method=MINDF.euclidean_dist,
                router_lcpool=defaultlinecards(),
                router_lccpool=defaultlinecardchassis(),
                router_lcccap=3,
                transponderset=defaulttransmissionmodules())

            # convert it to IBNs
            myibns = MINDFul.nestedGraph2IBNs!(simgraph)


        end


    #println(length(myibns))

    #return basic ibn graph
    if graph_type == "ibn"
        if pos == 0
            let
                p = ibnplot!(axis, myibns)
                #hidedecorations!(a)
                return p, length(myibns)
            end
        else
            #println(pos)
            p = ibnplot!(axis, myibns[pos])
            return p, length(myibns)


        end
    else
        println(intent_args)
        myintent = ConnectivityIntent((myibns[intent_args["node_1_subnet"]].id, intent_args["node_1"]), (myibns[intent_args["node_2_subnet"]].id, intent_args["node_2"]), intent_args["speed"])
        idi = addintent!(myibns[pos], myintent)
        nexttime() = MINDF.COUNTER("time")u"hr"

        deploy!(myibns[intent_args["node_1_subnet"]], idi, MINDF.docompile, MINDF.SimpleIBNModus(), MINDF.shortestavailpath!; time=nexttime())

        if pos == 0
            tmp_myibns = myibns
        else
            tmp_myibns = myibns[pos]
        end

        if graph_type == "Unin Tree"
            p = intentplot!(axis, tmp_myibns, idi)
            return p
        else

            if graph_type == "Tree"

                deploy!(myibns[pos], idi, MINDF.doinstall, MINDF.SimpleIBNModus(), MINDF.directinstall!; time=nexttime());
                p = intentplot!(axis, myibns[pos], idi)
                return p
            elseif graph_type == "Visualization"
                p = ibnplot!(axis, myibns, intentidx=[idi])

                println(fieldnames(typeof(myibns[1].ngr)))
                println(myibns[1].ngr.vmap)
                

                return p
            end

        end

    end


end

#end


#export generate_ibns


