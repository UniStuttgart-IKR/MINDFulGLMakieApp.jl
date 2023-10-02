export MINDFulGLMakieApp

module MINDFulGLMakieApp
    using GLMakie
    using RemoteREPL
    #using DataStructures

    #@async serve_repl()

    include("etc/HelpFunctions.jl")
    include("control_panels/PanelHandler.jl")
    include("control_panels/intent_creation/Interactions.jl")
    include("control_panels/drawing/Interactions.jl")
    include("control_panels/intent_actions/IntentActions.jl")
    include("control_panels/ui_options/UIOptions.jl")
    include("notebook_functions/SimpleNotebook.jl")
    include("notebook_functions/MINDFulGraphs.jl")
    
end
