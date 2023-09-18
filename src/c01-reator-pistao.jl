### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using CairoMakie
    using DocStringExtensions
    using Printf
    using Roots
    using SparseArrays: spdiagm

    import PlutoUI
    PlutoUI.TableOfContents(title="Tópicos")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Reator pistão - Parte 1
"""

# ╔═╡ 67460379-cf1d-43b2-8a89-c34e83d2bdb9
md"""
## Condições globais
"""

# ╔═╡ 53f1cba1-130f-4bb2-bf64-5e948b38b2c7
md"""
## Formulação na temperatura

Os cálculos do [número de Nusselt](https://en.wikipedia.org/wiki/Nusselt_number)...
"""

# ╔═╡ 7c43c2e5-98da-4e35-8f06-1a301f02cfec
md"""
## Formulação na entalpia
"""

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╠═╡ disabled = true
#=╠═╡
# - Guess solution in temperature.
# - Compute RHS and solve for enthalpy.
# - Find temperature root of enthalpy.
# - Repeat.

h(T) = cₚ * T
find_temperature(Tₖ, hₖ) = find_zero(T->h(T)-hₖ, Tₖ)
underrelax(aold, anew, α) = (1 - α) * anew + α * aold

Aᵥ = π * R^2
Aₛ = 2 * π * R * space.δ
ṁ = ρ * u * Aᵥ

α = 0.8
M = spdiagm(0 => ones(N), -1 => -ones(N-1))
C₁ = ĥ * Aₛ / ṁ

# Random initialization of expected solution.
# Force boundary condition (fix this later with computed value!)
T_old = Tₛ * ones(N+1)
T_old[1] = Tₚ

atol = 1.0e-08
maxiter = 100

niter = 0
residuals = []
T_new = similar(T_old)

# XXX: otherwise it always have a huge residual.
T_new[1] = Tₚ

while niter < maxiter
    T_mid = (T_old[1:end-1] + T_old[2:end])/2
    x = C₁ * (Tₛ .- T_mid)

    # Apply boundary condition (h1 = (C*(Ts - T*) + 2h0)/2).
    x[1] = (x[1] + 2 * h(Tₚ)) / 2

    T_new[2:end] = broadcast(find_temperature, T_old[2:end], M \ x)
    T_old[2:end] = underrelax(T_old[2:end], T_new[2:end], α)

    ε = maximum(abs2.(T_old - T_new))
    push!(residuals, ε)

    if ε <= atol
        break
    end

    niter += 1
end

p = plot()
plot!(space.zc, solution.T)
plot!(space.zc, T_old[2:end])
  ╠═╡ =#

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/).
"""

# ╔═╡ 1cf0a5eb-6f80-4105-8f21-a731583a7665
md"""
## Anexos
"""

# ╔═╡ 30f97d5b-e1de-4593-b451-1bd42156a4fc
begin
    Base.@kwdef mutable struct Conditions
        " Número de células na direção do eixo do reator "
        N::Int64 = 100

        "Comprimento do reator [m]"
        L::Float64 = 10.0

        "Raio do reator [m]"
        R::Float64 = 0.005

        "Temperatura de entrada do fluido [K]"
        Tₚ::Float64 = 300.0

        "Temperatura da parede [K]"
        Tₛ::Float64 = 400.0

        "Velocidade do fluido [m/s]"
        u::Float64 = 1.0

        "Mass específica do fluido [kg/m³]"
        ρ::Float64 = 1000.0

        "Calor específico do fluido [J/(kg.K)]"
        cₚ::Float64 = 4182.0

        "Número de Prandtl do fluido"
        Pr::Float64 = 6.9

        "Viscosidade do fluido [Pa.s]"
        μ::Float64 = 0.001

        "Condutividade térmica do fluido [W/(m.K)]"
        k::Float64 = 0.6
    end

    @doc """
    Condições compartilhadas pelos modelos.

    $(TYPEDFIELDS)
    """ Conditions
end

# ╔═╡ 03dc6676-49f2-486d-a7f2-deac6ce83f29
"Coordenadas dos centros das células [m]"
function cellcenters(L, δ)
    return collect(0.5δ:δ:L-0.5δ)
end

# ╔═╡ 530a7c51-e3ad-429a-890f-136fa63ff404
"Coordenadas dos limites das células [m]"
function cellwalls(L, δ)
    return collect(0.0:δ:L)
end

# ╔═╡ 4ac709ca-586c-41f8-a239-90b4c885ad7e
"Traça temperatura ao longo do reator"
function reactorplot(; L)
    fig = Figure(resolution = (720, 500))
    ax = Axis(fig[1, 1],
              xticks = range(0.0, L, 6),
              ylabel = "Temperatura [K]",
              xlabel = "Posição [m]")
    xlims!(ax, (0, L))
    return fig, ax
end

# ╔═╡ 91728930-3bde-476c-b398-75948c524312
"Número de Reynolds diametral"
function condition_ReD(c)
    return 2 * c.ρ * c.u * c.R / c.μ
end

# ╔═╡ 8b69fbf0-73f8-4297-b810-7cc17486712e
"Equação de Gnielinski para número de Nusselt"
function gnielinski_Nu(Re, Pr)
    @assert 3000.0 <= Re <= 5.0e+06
    @assert 0.5 <= Pr <= 2000.0

    f = (0.79 * log(Re) - 1.64)^(-2)
    g = f / 8

    num = g * (Re - 1000) * Pr
    den = 1.0 + 12.7 * (Pr^(2/3)-1) * g^(1/2)
    return num / den
end

# ╔═╡ cba4b197-9cbf-4c6d-9a5c-79dd212953dc
"Equação de Dittus-Boelter para número de Nusselt"
function dittusboelter_Nu(Re, Pr, L, D; what = :heating)
    @assert 10000.0 <= Re
    @assert 0.6 <= Pr <= 160.0
    @assert 10.0 <= L/D

    n = (what == :heating) ? 0.4 : 0.4
    return 0.023 * Re^(4/5) * Pr^n
end

# ╔═╡ f9687d19-1fc9-40b1-97b1-365b80061a1b
"Estima coeficient de troca convectiva do escoamento"
function computehtc(c; method = :g)
    Pr = c.Pr
    Re = condition_ReD(c)
    Nu = 3.66

    if Re > 3000
        Nug = gnielinski_Nu(Re, Pr)
        Nud = dittusboelter_Nu(Re, Pr, c.L, 2*c.R)
        Nu = (method == :g) ? Nug : Nub
    end

    h = Nu * c.k / (2c.R)

    println("""\
        Reynolds ................... $(Re)
        Nusselt (Gnielinsk) ........ $(Nug)
        Nusselt (Dittus-Boelter) ... $(Nud)
        Nusselt (usado aqui) ....... $(Nu)
        h .......................... $(h) W/(m².K)\
        """
    )

    return h
end

# ╔═╡ 18173d9d-c877-4115-9839-a2db6da464c4
fig = let
    c = Conditions()

    # FIXME factor 2 to match CFD!
    ĥ = 2computehtc(c)

    fig, ax = reactorplot(; L = c.L)

    for N in [10, 100, 500]
        c.N = N
        δ = c.L / c.N

        Aᵥ = π * c.R^2
        Aₛ = 2π * c.R * δ

        a₁ = c.ρ * c.u * Aᵥ * c.cₚ
        a₂ = ĥ * Aₛ

        A⁺ = a₁ + 0.5a₂
        A⁻ = a₁ - 0.5a₂

        C₁ = a₂ * c.Tₛ
        C₂ = C₁ + 2A⁻ * c.Tₚ

        d₀ = A⁺ * ones(c.N)
        d₀[1] = 2a₁

        d₁ = -A⁻ * ones(c.N - 1)

        C = C₁ * ones(c.N)
        C[1] = C₂

        M = spdiagm(0 => d₀, -1 => d₁)
        T = M \ C

        z = cellwalls(c.L, δ)[1:end-1]
        stairs!(ax, z, T, label = "N = $(c.N)", step = :post)

        global Tend = @sprintf("%.1f", T[end])
    end

    ax.title = "Temperature final = $(Tend) K"
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
    fig
end;

# ╔═╡ 2a5c963b-80c4-4f31-a997-542cef9a2f03
fig

# ╔═╡ f9b1527e-0d91-490b-95f6-13b649fe61db
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─67460379-cf1d-43b2-8a89-c34e83d2bdb9
# ╟─53f1cba1-130f-4bb2-bf64-5e948b38b2c7
# ╠═18173d9d-c877-4115-9839-a2db6da464c4
# ╟─2a5c963b-80c4-4f31-a997-542cef9a2f03
# ╟─7c43c2e5-98da-4e35-8f06-1a301f02cfec
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─1cf0a5eb-6f80-4105-8f21-a731583a7665
# ╟─30f97d5b-e1de-4593-b451-1bd42156a4fc
# ╟─03dc6676-49f2-486d-a7f2-deac6ce83f29
# ╟─530a7c51-e3ad-429a-890f-136fa63ff404
# ╟─4ac709ca-586c-41f8-a239-90b4c885ad7e
# ╟─91728930-3bde-476c-b398-75948c524312
# ╟─8b69fbf0-73f8-4297-b810-7cc17486712e
# ╟─cba4b197-9cbf-4c6d-9a5c-79dd212953dc
# ╟─f9687d19-1fc9-40b1-97b1-365b80061a1b
# ╟─f9b1527e-0d91-490b-95f6-13b649fe61db
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
