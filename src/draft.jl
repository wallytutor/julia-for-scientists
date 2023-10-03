# -*- coding: utf-8 -*-
using CairoMakie
using LinearAlgebra
using Printf
using Trapz

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
    A = 4.84e-05exp(-38.0x₁) / (1.0 - 5.0x₁)
    E = 155_000.0 - 570_000.0x₁
    return A * exp(- E / (R * T))
end

function harmonic(k::Vector{Float64})::Vector{Float64}
    ke, kw = k[1:end-1], k[2:end-0]
    return @. 2 * ke * kw / (ke + kw)
end

function masstomolefraction(w)
    return w * (w / 0.012 + (1 - w) / 0.055)^(-1) / 0.012
end

function moletomassfraction(x)
    return 0.012 * x / (0.012*x + (1 - x) * 0.055)
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

    β = τ / δ
    γ = d[1] / δ

    M.dl[:] = -(β / δ) * d
    M.du[:] = -(β / δ) * d

    M.d[:] .= 1.0
    M.d[1:end-1] -= M.du
    M.d[2:end-0] -= M.dl

    M.d[1]  = 1 + β * (h + γ)
    M.du[1] = β * γ

    return nothing
end

h = 1.0e-01
T = 1173.15

# 16NCD13
# yₑ = 0.0100
# y₀ = 0.0016
# 23MCD5
yₑ = 0.0095
y₀ = 0.0023

x∞  = masstomolefraction(yₑ)
x₁₀ = masstomolefraction(y₀)

N = 2000
L = 0.0015

M = 200
tend = 7200.0
τ = tend / M

domain = HalfCellBoundaryFVM(; L = L, N = N)
A, b = createproblem(N+1)

maxiter = 100
αᵣ = 0.6
εᵣ = 1.0e-12

x = x₁₀ * ones(N+1)
u = copy(x)

iterperstep = -ones(Int64, M+1)
residualstep = -ones(Float64, M+1)
residualglob = -ones(Float64, (M+1)*maxiter)
globaliter = 0

for (step, ts) in enumerate(0.0:τ:tend)
    b[:] = x[:]
    b[1] += (τ / domain.δ) * h * x∞

    for numiter in 1:maxiter
        globaliter += 1

        updatematrix!(A, x, T, τ, domain.δ, h)

        Δx = (1-αᵣ) * (A \ b - x)
        x[:] += Δx

        residualglob[globaliter] = ε = maximum(abs.(Δx))

        if ε <= εᵣ
            residualstep[step] = ε
            iterperstep[step] = numiter
            break
        elseif numiter == maxiter
            @warn "[$(@sprintf("%.6e", ts))s] $(numiter) iterações ⟹ $(ε)"
        end
    end
end

fig = let
    z = domain.z
    y = moletomassfraction.(x)
    m = 1000 * 7890 * trapz(z, y.-y₀)
    fig = Figure(resolution = (720, 500))
    ax = Axis(fig[1, 1])
    ax.xlabel = "Posição [mm]"
    ax.ylabel = "Porcentagem mássica [%]"
    ax.title = "Ganho de massa $(@sprintf("%.1f", m)) g/m²"
    ax.xticks = 0.0:0.3:1.5
    ax.yticks = 0.0:0.2:1.0
    xlims!(ax, (0.0, 1.5))
    ylims!(ax, (0.0, 1.0))
    lines!(ax, 1000z, 100y)
    stairs!(ax, 1000z, 100y, color = :black, step = :center)
    fig
end

fig = let
    rg = log10.(residualglob[residualglob .> 0.0])
    rs = log10.(residualstep[residualstep .> 0.0])
    ig = 1:size(rg)[1]
    is = cumsum(iterperstep)
    fig = Figure(resolution = (720, 500))
    ax = Axis(fig[1, 1], yscale = identity)
    ax.xlabel = "Iteração global"
    ax.ylabel = "log10(Resíduo)"
    ax.title = "Máximo de iterações $(maximum(iterperstep))"
    ax.yticks = -13:2:-1
    xlims!(ax, (0, convert(Int64, ceil(ig[end]/1000)*1000)))
    ylims!(ax, (-13, -1))
    lines!(ax, ig, rg, color = :black, linewidth = 0.5, label = "Interno")
    lines!(ax, is, rs, color = :red,   linewidth = 3.0, label = "Externo")
    axislegend(position = :rt)
    fig
end
