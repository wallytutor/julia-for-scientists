# -*- coding: utf-8 -*-
using JuliaFormatter

@assert format_file("$(@__DIR__)/000-preambulo-e-pluto.jl")
@assert format_file("$(@__DIR__)/001-primeiros-passos.jl")
