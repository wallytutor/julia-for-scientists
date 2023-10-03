### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ dc471220-61ee-11ee-0281-f991a063e50c
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using LsqFit
    using Polynomials
    using Printf
    using Roots
    using SparseArrays: spdiagm
    using SteamTables
    import PlutoUI

    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ db0cf709-c127-42e0-9e3d-6e988a1e659d
md"""
# Reator pistão - Parte 4

$(toc)
"""

# ╔═╡ 451f21a0-22ae-452f-937c-01f6617209ea
let
    P = 0.1 * 270.0
    T = collect(300.0:5:1000.0)
    ρ = map((t)->1.0 / SpecificV(P, t), T)

    let
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, T, ρ)
        ax.xlabel = "Temperatura [K]"
        ax.ylabel = "Mass específica [kg/m³]"
        ax.xticks = 400:100:1000
        ax.yticks = 000:200:1000
        xlims!(ax, (400, 1000))
        ylims!(ax, (000, 1000))
        fig
    end
end

# ╔═╡ 012dc8b2-6286-445d-a5ca-1ac438df5bc4
function modelh(T, a)
    t = @. T - 300.0
    l = @. a[1] + a[2] * t
    z = @. t * cos(atan(a[2]))
    return @. l + a[5] * (1 - exp(-(z/a[3])^a[4]))
end

# ╔═╡ c6449b68-c542-4a8d-b34a-99be9dfed38a
fig, p = let
    P = 27.0
    T = collect(300.0:7.5:1200.0)
    h = map((t)->SpecificH(P, t), T)

    a = [h[1], 4.0, 90, 20.0, 1000]
    fit = curve_fit(modelh, T, h, a)
    p = (T) -> modelh(T, fit.param)

    fig = let
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, T, h)
        lines!(ax, T, modelh(T, fit.param))
        ax.xlabel = "Temperatura [K]"
        ax.ylabel = "Entalpia específica [kJ/kg]"
        ax.xticks = 300:100:1200
        ax.yticks = 000:500:4500
        xlims!(ax, (300, 1200))
        ylims!(ax, (000, 4500))
        fig
    end

    fig, p
end;

# ╔═╡ 3803833c-4340-4e9d-af33-dcefa01d835a
fig

# ╔═╡ 763992dd-0ab7-422e-8983-a398725326e7
"Integra reator pistão circular no espaço das entalpias."
function solveenthalpypfr(; mesh::AbstractDomainFVM, P::T, A::T, Tₛ::T, Tₚ::T,
                            ĥ::T, u::T, ρ::T, h::Function, M::Int64 = 100,
                            α::Float64 = 0.4, ε::Float64 = 1.0e-10,
                            alg::Any = Order16(), vars...) where T
    N = length(mesh.z) - 1

    Tm = Tₚ * ones(N + 1)
    hm = h.(Tm)

    a = (ĥ * P * mesh.δ) / (ρ * u * A)
    K = 2spdiagm(-1 => -ones(N-1), 0 => ones(N))

    b = (2a * Tₛ) * ones(N)
    b[1] += 2h(Tₚ)

    residual = -ones(M)

    @time for niter in 1:M
        Δ = (1-α) * (K\(b - a * (Tm[1:end-1] + Tm[2:end])) - hm[2:end])
        hm[2:end] += Δ

        try
            Tm[2:end] = map(
                (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ, alg, atol=0.1),
                Tm[2:end], hm[2:end]
            )
        catch
            continue
        end

        residual[niter] = maximum(abs.(Δ))

        if (residual[niter] <= ε)
            @info("Convergiu após $(niter) iterações")
            break
        end
    end

    return Tm, residual
end

# ╔═╡ f2f7bae5-3bcc-426b-9c29-2d4b96abbf74
let
    L = 5.0
    mesh = ImmersedConditionsFVM(; L = L, N = 200)

    D = 0.0254 / 2
    P = π * D
    A = π * D^2 / 4

    Tₛ = 873.15
    ṁ = 60.0 / 3600.0

    Pₚ = 0.1 * 270.0
    Tₚ = 300.0
    ρₚ = 1.0 / SpecificV(Pₚ, Tₚ)
    uₚ = ṁ / (ρₚ * A)

    z = mesh.z
    ĥ = 4000.0

    # TODO search literature for supercritical!
    # ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    h(t) = 1000p.(t)
    # function h(t)
    #     1000 * try
    #         SpecificH(Pₚ, t)
    #     catch DomainError
    #         SpecificH(Pₚ, 0.96t)
    #     end
    # end

    pars = (
        mesh = mesh,
        P = P,
        A = A,
        Tₛ = Tₛ,
        Tₚ = Tₚ,
        ĥ = ĥ,
        u = uₚ,
        ρ = ρₚ,
        h = h,
        M = 1000,
        α = 0.8,
        ε = 0.5,
        alg = Order16()
    )

    T, residuals = solveenthalpypfr(; pars...)

    println(residuals)
    fig1 = let
        yrng = (300.0, 400.0)
        Tend = @sprintf("%.2f", T[end]-273.15)
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        stairs!(ax, z, T.-273.15,
                color = :black, linewidth = 1,
                label = "Numérica", step = :center)
        xlims!(ax, (0, L))
        ax.title = "Temperatura final = $(Tend) °C"
        ax.xlabel = "Posição [m]"
        ax.ylabel = "Temperatura [°C]"
        ax.xticks = range(0.0, L, 6)
        # ax.yticks = range(yrng..., 6)
        # ylims!(ax, yrng)
        axislegend(position = :rb)
        fig
    end
end

# ╔═╡ 2eadbe40-32a3-4d7c-9b3c-324be6bf8f29
# ρ = ρₚ
# u = uₚ
# M = 20
# α = 0.9
# ε = 1.0e-03

# N = length(mesh.z) - 1
# Tm = Tₚ * ones(N + 1)

# a = (ĥ * P * mesh.δ) / (ρ * u * A)
# K = 2spdiagm(-1 => -ones(N-1), 0 => ones(N))

# b = (2a * Tₛ) * ones(N)
# b[1] += 2h(Tₚ)

# # residual = -ones(M)

# @time for niter in 1:M
# 	h̄ = K \ (b - a * (Tm[1:end-1] + Tm[2:end]))
# 	U = map((Tₖ, hₖ) -> find_zero(
# 			t -> h(t) - hₖ,
# 			Tₖ, Order16()
# 	), Tm[2:end], h̄)
# 	Δ = (1-α) * (U - Tm[2:end])
# 	Tm[2:end] += Δ

# 	# residual[niter] = maximum(abs.(Δ))

# 	# if (residual[niter] <= ε)
# 	# 	@info("Convergiu após $(niter) iterações")
# 	# 	break
# 	# end
# end

# Tm

# ╔═╡ daab21e0-e9f8-4b75-b335-785553a0e064
md"""
## Pacotes
"""

# ╔═╡ 2a144465-21e6-4bcc-8c09-2a41d6ed79f2


# ╔═╡ Cell order:
# ╠═db0cf709-c127-42e0-9e3d-6e988a1e659d
# ╟─451f21a0-22ae-452f-937c-01f6617209ea
# ╠═012dc8b2-6286-445d-a5ca-1ac438df5bc4
# ╟─c6449b68-c542-4a8d-b34a-99be9dfed38a
# ╠═3803833c-4340-4e9d-af33-dcefa01d835a
# ╠═763992dd-0ab7-422e-8983-a398725326e7
# ╠═f2f7bae5-3bcc-426b-9c29-2d4b96abbf74
# ╠═2eadbe40-32a3-4d7c-9b3c-324be6bf8f29
# ╟─daab21e0-e9f8-4b75-b335-785553a0e064
# ╠═dc471220-61ee-11ee-0281-f991a063e50c
# ╠═2a144465-21e6-4bcc-8c09-2a41d6ed79f2
