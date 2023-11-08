# -*- coding: utf-8 -*-
using CairoMakie

macro makeplot1(ex)
    return quote
        let
            eval(:( fig = Figure(resolution = (720, 500)) ))
            eval(:( ax = Axis(fig[1, 1]) ))
            eval( $ex )
            eval(:( axislegend(position = :rb) ))
            eval(:( fig ))
        end
    end
end

macro makeplot2(ex, xlims)
    return quote
        eval(:( fig = Figure(resolution = (720, 500)) ))
        eval(:( ax = Axis(fig[1, 1]) ))
        eval( $ex )
        eval(:( xlims!(ax, $xlims) ))
        eval(:( axislegend(position = :rb) ))
        eval(:( fig ))
    end
end

@info("Verifique `util-metaprogramacao.jl` para mais detalhes...")
