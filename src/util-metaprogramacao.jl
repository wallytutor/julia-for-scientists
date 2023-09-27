# -*- coding: utf-8 -*-
using CairoMakie

macro makeplot(ex)
    return quote
        eval(:( fig = Figure(resolution = (720, 500)) ))
        eval(:( ax = Axis(fig[1, 1]) ))
        eval( $ex )
        eval(:( axislegend(position = :rb) ))
        eval(:( fig ))
    end
end

@info("Verifique `util-metaprogramacao.jl` para mais detalhes...")
