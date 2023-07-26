#=
MINDFulGLMakieApp:
- Julia version: 1.9.1
- Author: Niels
- Date: 2023-07-8
=#


export MINDFulGLMakieApp

module MINDFulGLMakieApp
    using GLMakie

    include("MINDFulGraphs.jl")
    include("functions.jl")
    include("HelpFunctions.jl")


end
