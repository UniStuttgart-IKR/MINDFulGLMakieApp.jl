#=
MINDFulGLMakieApp:
- Julia version: 1.9.1
- Author: Niels
- Date: 2023-07-8
=#


export MINDFulGLMakieApp

module MINDFulGLMakieApp
    using GLMakie
    #using DataStructures

    include("HelpFunctions.jl")
    include("functions2.jl")
    include("control_panels/intents/Interactions.jl")
    include("control_panels/drawing/Interactions.jl")
    include("notebook_functions/MINDFulGraphs.jl")
    include("notebook_functions/IntentDAG.jl")


end
