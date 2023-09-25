# -*- coding: utf-8 -*-
using JuliaFormatter
using Pluto: ServerSession, SessionActions
using Pluto: generate_html

function convertnotebook(s::ServerSession, nbname::String)
    nbpath = joinpath(@__DIR__, "src/$(nbname).jl")
    pgpath = "docs/$(nbname).html"
    
    if !format_file(nbpath)
        @error "file not formatted: $(nbpath)"
    end
    
    if isfile(pgpath) && !FORCE
        VERBOSE > 2 && @info "file exists: $(pgpath)"
        return
    end
    
    VERBOSE > 0 && @info "working on $(nbname)"
    nb = SessionActions.open(s, nbpath; run_async=false)
    write(pgpath, generate_html(nb))
    SessionActions.shutdown(s, nb)
end

function workflow(nblist::Vector{String})
    s = ServerSession()
    s.options.server.launch_browser = false

    for nbname in nblist
        convertnotebook(s, nbname)
    end
end

VERBOSE = 3

FORCE = false

notebooks_ready = [
    "index"
    "000-preambulo-e-pluto"
    "001-primeiros-passos"
    "002-manipulacao-textual"
    "003-estruturas-de-dados"
    "004-estruturas-de-dados"
    "a01-colaboracao-cientifica"
    "c01-reator-pistao"
]

workflow(notebooks_ready)
