# -*- coding: utf-8 -*-
using CairoMakie
using SparseArrays

const R = 8.314_462_618_153_24

struct HalfCellBoundaryFVM
    "Coordenadas dos centros das células [m]."
    z::Vector{Float64}

    "Coordenadas dos limites das células [m]."
    w::Vector{Float64}

    "Comprimento de uma célula [m]."
    δ::Float64

    function HalfCellBoundaryFVM(; L::Float64, N::Int64)
        δ = L / N
        z = collect(0.0:δ:L)
        w = collect(0.5δ:δ:L-0.5δ)
        return new(z, w, δ)
    end
end

function diffcoef₁(T::Float64, x₁::Float64)::Float64
    Ax = 4.84e-05exp(-38.0x₁) / (1.0 - 5.0x₁)
    Ex = 155_000.0 - 570_000.0x₁
    return Ax * exp(- Ex / (R * T))
end

function harmonic(k::Vector{Float64})::Vector{Float64}
    ke, kw = k[1:end-1], k[2:end-0]
    return @. 2 * ke * kw / (ke + kw)
end

function masstomolefraction(w)
    return w * (w / 0.012 + (1 - w) / 0.055)^(-1) / 0.012
end



T = 1173.15
x₁₀ = masstomolefraction(0.0016)

N = 10
L = 0.0015

τ = 1.0
tend = 10800.0

domain = HalfCellBoundaryFVM(; L = L, N = N)

x = x₁₀ * ones(N)
D = map((x)->diffcoef₁(T, x), x)
d = harmonic(D)

β = τ / domain.δ^2
ae = β * d
aw = β * d
ap = @. 1.0 + ae + aw

A = spdiagm(0 => ap, -1 => -ae, +1 => -aw)