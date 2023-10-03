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

# ╔═╡ c6449b68-c542-4a8d-b34a-99be9dfed38a
let
    P = 0.1 * 270.0
    T = collect(300.0:5:1000.0)
    h = map((t)->SpecificH(P, t), T)

    let
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, T, h)
        ax.xlabel = "Temperatura [K]"
        ax.ylabel = "Entalpia específica [kJ/kg]"
        ax.xticks = 400:100:1000
        ax.yticks = 500:500:4000
        xlims!(ax, (400, 1000))
        ylims!(ax, (500, 4000))
        fig
    end
end

# ╔═╡ 763992dd-0ab7-422e-8983-a398725326e7
"Integra reator pistão circular no espaço das entalpias."
function solveenthalpypfr(; mesh::AbstractDomainFVM, P::T, A::T, Tₛ::T, Tₚ::T,
                            ĥ::T, u::T, ρ::T, h::Function, M::Int64 = 100,
                            α::Float64 = 0.4, ε::Float64 = 1.0e-10,
                            alg::Any = Order16(), vars...) where T
    N = length(mesh.z) - 1
    Tm = Tₚ * ones(N + 1)

    a = (ĥ * P * mesh.δ) / (ρ * u * A)
    K = 2spdiagm(-1 => -ones(N-1), 0 => ones(N))

    b = (2a * Tₛ) * ones(N)
    b[1] += 2h(Tₚ)

    # Aloca e inicia em negativo o vetor de residuos. Isso
    # é interessante para o gráfico aonde podemos eliminar
    # os elementos negativos que não tem sentido físico.
    residual = -ones(M)

    @time for niter in 1:M
        # Calcula o vetor `b` do lado direito e resolve o sistema.
        h̄ = K \ (b - a * (Tm[1:end-1] + Tm[2:end]))

        # Encontra as novas temperaturas resolvendo uma equação não-linear
        # para cada nova entalpia calculada resolvendo `A*h=b`.
        U = map((Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ, alg), Tm[2:end], h̄)

        # Incremento da solução.
        Δ = (1-α) * (U - Tm[2:end])

        # Relaxa solução para evitar divergência.
        Tm[2:end] += Δ

        # Verica progresso da solução.
        residual[niter] = maximum(abs.(Δ))

        # Verifica status da convergência.
        if (residual[niter] <= ε)
            @info("Convergiu após $(niter) iterações")
            break
        end
    end

    return Tm, residual
end

# ╔═╡ f2f7bae5-3bcc-426b-9c29-2d4b96abbf74
let
    L = 1.0
    mesh = ImmersedConditionsFVM(; L = L, N = 50)

    D = 0.0254 / 1
    P = π * D
    A = π * D^2 / 4

    Tₛ = 1000.0
    ṁ = 60.0 / 3600.0

    Pₚ = 0.1 * 270.0
    Tₚ = 300.0
    ρₚ = 1.0 / SpecificV(Pₚ, Tₚ)
    uₚ = ṁ / (ρₚ * A)

    z = mesh.z
    ĥ = 2000.0

    # TODO search literature for supercritical!
    # ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    function h(t)
        1000 * try
            SpecificH(Pₚ, t)
        catch DomainError
            SpecificH(Pₚ, Tₛ)
        end
    end

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
        M = 50,
        α = 0.999,
        ε = 1.0e-03,
        alg = Order16()
    )

    T, residuals = solveenthalpypfr(; pars...)


    fig1 = let
        yrng = (300.0, 400.0)
        Tend = @sprintf("%.2f", T[end])
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        stairs!(ax, z, T, color = :black, linewidth = 1,
                label = "Numérica", step = :center)
        xlims!(ax, (0, L))
        ax.title = "Temperatura final = $(Tend) K"
        ax.xlabel = "Posição [m]"
        ax.ylabel = "Temperatura [K]"
        ax.xticks = range(0.0, L, 6)
        ax.yticks = range(yrng..., 6)
        ylims!(ax, yrng)
        axislegend(position = :rb)
        fig
    end

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

end

# ╔═╡ daab21e0-e9f8-4b75-b335-785553a0e064
md"""
## Pacotes
"""

# ╔═╡ 2a144465-21e6-4bcc-8c09-2a41d6ed79f2


# ╔═╡ Cell order:
# ╟─db0cf709-c127-42e0-9e3d-6e988a1e659d
# ╟─451f21a0-22ae-452f-937c-01f6617209ea
# ╟─c6449b68-c542-4a8d-b34a-99be9dfed38a
# ╠═763992dd-0ab7-422e-8983-a398725326e7
# ╠═f2f7bae5-3bcc-426b-9c29-2d4b96abbf74
# ╟─daab21e0-e9f8-4b75-b335-785553a0e064
# ╠═dc471220-61ee-11ee-0281-f991a063e50c
# ╠═2a144465-21e6-4bcc-8c09-2a41d6ed79f2
