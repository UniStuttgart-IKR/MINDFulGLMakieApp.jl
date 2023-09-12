#=
MINDFulGLMakieApp:
- Julia version: 1.9.1
- Author: Niels
- Date: 2023-07-8
=#


export MINDFulGLMakieApp

module MINDFulGLMakieApp
    using GLMakie
    using RemoteREPL
    #using DataStructures

    #@async serve_repl()

    include("HelpFunctions.jl")
    include("functions2.jl")
    include("control_panels/intent_creation/Interactions.jl")
    include("control_panels/drawing/Interactions.jl")
    include("control_panels/intent_actions/IntentActions.jl")
    include("notebook_functions/MINDFulGraphs.jl")
    include("notebook_functions/IntentDAG.jl")
    include("notebook_functions/SimpleNotebook.jl")
    
end
