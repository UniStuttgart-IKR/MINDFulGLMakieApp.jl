using MINDFul, MINDFulCompanion
using GraphIO, NestedGraphsIO, NestedGraphs, Graphs, MetaGraphs, AttributeGraphs
using GLMakie, MINDFulMakie
using Random, Distributions, Unitful, UUIDs, StatsBase

const MINDF = MINDFul
const MINDFC = MINDFulCompanion

function get_intent_dag_graph(axis, args_dict, type_of_graph)
    """
    #Arguments
    - `type_of_graph`: ["DAG vis int", "DAG tree", "DAG vis ml"]
    """


    myibns = open_topology(args_dict["topology"])
    rng = Random.MersenneTwister(0)
    demands = generatedems(myibns, rng; mu=100)
    demkey1 = (args_dict["node_1_subnet"], args_dict["node_1"], args_dict["node_2_subnet"], args_dict["node_2"])
    demands[demkey1...]

    intentid1 = compileNinstall!(myibns[1], demkey1..., demands[demkey1...])
    issatisfied(myibns[1], intentid1)

    if type_of_graph == "DAG vis int"
        return ibnplot!(axis, myibns, intentidx=[intentid1])
    elseif type_of_graph == "DAG tree"
        return intentplot!(axis, myibns[1], intentid1)
    end

    getintentnode(myibns[1], UUID(0x3))
    MINDF.globalnode(myibns[1], 10)
    getintentnode(myibns[1], UUID(0xf))
    getconstraints(getintent(myibns[1], UUID(0xf)))

    mlgr, fcfun, mlverts = drawmult(myibns, 1)


    if type_of_graph == "DAG vis ml"
        return netgraphplot!(axis, mlgr, multilayer=true, multilayer_vertices=mlverts, layout=fcfun, nlabels=repr.(vertices(mlgr)))
    end




end


function open_topology(topology)
    globalnet = open("data/" * topology * ".graphml") do io
        loadgraph(io, "main", GraphIO.GraphML.GraphMLFormat(), NestedGraphs.NestedGraphFormat())
    end
    simgraph = MINDFul.simgraph(globalnet;
        distance_method=MINDF.euclidean_dist,
        router_lcpool=MINDFC.defaultlinecards(),
        router_lccpool=MINDFC.defaultlinecardchassis(),
        router_lcccap=6,
        transponderset=MINDFC.defaulttransmissionmodules())
    MINDFul.nestedGraph2IBNs!(simgraph)
end

nexttime() = MINDF.COUNTER("time")u"hr"

function generatedemands_normal(vecnum, rng=Random.MersenneTwister(0); mu=200, sigma=50, low=50, high=750)
    distr = truncated(Normal(mu, sigma), low, high)
    [rand(rng, distr) for _ in 1:vecnum]
end

function generatedems(ibns, rng; mu=200)
    demdict = Dict{Tuple{Int,Int,Int,Int},Float64}()
    for ibn1 in ibns
        nv1 = nv(MINDF.getgraph(ibn1))
        bds1 = MINDF.bordernodes(ibn1; subnetwork_view=false)
        for ibn2 in ibns
            nv2 = nv(MINDF.getgraph(ibn2))
            bds2 = MINDF.bordernodes(ibn2; subnetwork_view=false)
            demvec = generatedemands_normal(nv1 * nv2, rng; mu)
            for v1 in 1:nv1
                for v2 in 1:nv2
                    getid(ibn1) == getid(ibn2) && v1 == v2 && continue
                    if v1 ∉ bds1 && v2 ∉ bds2
                        demdict[(getid(ibn1), v1, getid(ibn2), v2)] = demvec[(v1-1)*nv2+v2]
                    end
                end
            end
        end
    end
    demdict
end

function compileNinstall!(ibn::IBN, ds, ns, dt, nt, demval)
    conint = ConnectivityIntent((ds, ns), (dt, nt), demval)
    intentid = addintent!(ibn, conint)
    deploy!(ibn, intentid, MINDF.docompile, MINDF.SimpleIBNModus(), MINDFulCompanion.jointrmsagenerilizeddijkstra!; time=nexttime())
    deploy!(ibn, intentid, MINDF.doinstall, MINDF.SimpleIBNModus(), MINDF.directinstall!; time=nexttime())
    return intentid
end

function compileNinstall!(ibns, demands)
    for ((ds, ns, dt, nt), demval) in demands
        compileNinstall!(ibns[ds], ds, ns, dt, nt, demval)

        # check consistency
        if !all([let
            fv = MINDF.getlink(ibn, e)
            fv.spectrum_src == fv.spectrum_dst
        end for ibn in ibns for e in edges(ibn.ngr)])
            break
        end
    end
end

function drawmult(myibns, ibnid)
    fixedcoords(x) = (args...) -> x
    fcfun = fixedcoords(MINDFulMakie.coordlayout(myibns[ibnid].ngr))
    mlgr = MINDFC.mlnodegraphtomlgraph(myibns[ibnid], 3.2)
    mlverts = NestedGraphs.getmlvertices(mlnodegraphtomlgraph(myibns[ibnid].ngr))
    return mlgr, fcfun, mlverts
end