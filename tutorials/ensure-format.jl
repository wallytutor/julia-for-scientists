# -*- coding: utf-8 -*-
using JuliaFormatter

@assert format_file("$(@__DIR__)/000-preambulo-e-pluto.jl")
@assert format_file("$(@__DIR__)/001-primeiros-passos.jl")
@assert format_file("$(@__DIR__)/002-manipulacao-textual.jl")
@assert format_file("$(@__DIR__)/003-estruturas-de-dados.jl")
@assert format_file("$(@__DIR__)/004-estruturas-de-dados.jl")
