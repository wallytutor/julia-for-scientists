# -*- coding: utf-8 -*-
using CairoMakie
using LinearAlgebra
using Printf

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

function createproblem(N)
    A = Tridiagonal(zeros(N-1), zeros(N), zeros(N-1))
    b = zeros(N)
    return A, b
end

function updatematrix!(
    M::Tridiagonal{Float64, Vector{Float64}},
    x::Vector{Float64},
    T::Float64,
    τ::Float64,
    δ::Float64,
    h::Float64
)::Nothing
    D = map((x)->diffcoef₁(T, x), x)
    d = harmonic(D)

    β = τ / δ^2

    M.dl[:] = -β * d
    M.du[:] = -β * d

    M.d[:] .= 1.0
    M.d[1:end-1] -= M.du
    M.d[2:end-0] -= M.dl

    M.d[1]  = d[1] / δ + h
    M.du[1] = -d[1] / δ
    return nothing
end

h = 1.0e-06
T = 1173.15

x∞  = masstomolefraction(0.0100)
x₁₀ = masstomolefraction(0.0016)

N = 1000
L = 0.0015

τ = 100.0
tend = 10800.0

maxiter = 1000
αᵣ = 0.8
εᵣ = 1.0e-03

x = x₁₀ * ones(N)
u = copy(x)

domain = HalfCellBoundaryFVM(; L = L, N = N)
A, b = createproblem(N)

for t in 0.0:τ:tend
    b[1] = h * x∞
    b[2:end] = x[2:end]

    for i in 1:maxiter
        updatematrix!(A, u, T, τ, domain.δ, h)

        u[:] = A \ b
        Δx = (1-αᵣ) * (u-x)
        ε = maximum(abs.(Δx))
        # @info "Inner $(ε)"

        if t < τ
            x[:] = u[:]
            break
        end

        if ε <= εᵣ
            x[:] = u[:]
            @info "[$(@sprintf("%.6e", t))] Depois de $(i) iterações $(ε)"
            break
        end
    end
end

fig = let
    fig = Figure(resolution = (720, 500))

    ax = Axis(fig[1, 1])
    ax.xlabel = "Posição [mm]"
    ax.ylabel = "Fração molar"

    lines!(ax, domain.w, x)
    fig
end

# stairs!(ax, z, Tₙ, color = :black, linewidth = 1, label = "Numérica",
# step = :center)
# ax.xticks = 1:5:n
# ax.yticks = range(-15, 5, 5)
# xlims!(ax, (1, n))
# ylims!(ax, (-15, 5))
# axislegend(position = :rb)
