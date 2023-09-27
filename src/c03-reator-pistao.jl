### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ fe2c3680-5b91-11ee-282c-c74d3b01ef9b
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using DocStringExtensions
    using Polynomials
    using Printf
    using Roots
    using SparseArrays: spdiagm
    using SparseArrays: SparseMatrixCSC

    import PlutoUI
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ f33f5453-dd05-4a4e-ae12-695320fcd70d
md"""
# Reator pistão - Parte 2
"""

# ╔═╡ f3b7d46f-0fcc-4f68-9822-f83e977b87ee
md"""
## Reator conceitual incompressível
"""

# ╔═╡ 7912192d-1528-48ce-9adc-7e6a26b25c51
md"""
## Reator com fase sólida e gás
"""

# ╔═╡ 975744de-7ab0-4bfa-abe5-3741ec7ec1cf
md"""
## Anexos
"""

# ╔═╡ 27233ad1-a588-48d6-9103-901a71936074
md"""
### Estruturas de dados
"""

# ╔═╡ c9194590-0fc7-4d68-9b19-9ee8d415fbda
"Estrutura com memória do estado de um reator.

$(TYPEDFIELDS)
"
struct PFRData
    "Vetor das coordenadas das células do reator [m]."
    z::Vector{Float64}

    "Temperatura do fluido das células do reator [K]."
    T::Vector{Float64}

    "Entalpia em função da temperatura [J/kg]."
    h::Function

    "Coeficiente do problema."
    a::Float64

    "Memória para vetor do problema."
    b::Vector{Float64}

    "Matriz do problema."
    K::SparseMatrixCSC{Float64, Int64}

    "Fluxo mássico através do reator [kg/s]."
    ṁ::Float64

    """	Construtor interno dos dados de reatores.

    - `h`  : Entalpia em função da temperatura [J/kg]
    - `T₀` : Temperatura inicial do fluido [K].
    - `L`  : Comprimento do reator [m].
    - `N`  : Número de células no sistema, incluindo limites.
    - `P`  : Perímetro da seção [m].
    - `A`  : Área da seção [m²].
    - `ĥ`  : Coeficiente de troca convectiva [W/(m².K)].
    - `u`  : Velocidade do fluido [m/s].
    - `ρ`  : Densidade do fluido [kg/m³].
    """
    function PFRData(;
            h::Function,
            T₀::Float64,
            L::Float64,
            N::Int64,
            P::Float64,
            A::Float64,
            ĥ::Float64,
            u::Float64,
            ρ::Float64
        )
        δ = L / N
        z = collect(0.0:δ:L)
        T = T₀ * ones(N+1)
        K = 2spdiagm(-1=>-ones(N-1), 0=>ones(N))
        ṁ = ρ * u * A
        a = (ĥ * P * δ) / ṁ
        b = ones(N)
        T[1] = T₀
        return new(z, T, h, a, b, K, ṁ)
    end
end

# ╔═╡ 5007aa03-6db0-4626-a73c-9172fef2c4ea
md"""
### Criação de exemplos
"""

# ╔═╡ be3a4933-516e-4867-a801-4df4f695432a
md"""
### Funções físicas
"""

# ╔═╡ a842401e-77d0-4f2b-8ef1-06a7799531e2
function innerloop(
    r::PFRData,
    Ts::Vector{Float64},
    M::Int64,
    α::Float64,
    tol::Float64
)::Bool
    T = @view r.T[1:end]
    b = @view r.b[1:end]
    a, K, h = r.a, r.K, r.h

    f = (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ)

    niter = 0
    while (niter < M)
        niter += 1

        b[1:end] = a * (2Ts - T[1:end-1] - T[2:end])
        b[1] += 2h(T[1])

        U = map(f, T[2:end], K\b)
        ΔT = (1-α) * (U - T[2:end])
        ε = maximum(abs.(ΔT))
        T[2:end] += ΔT

        if (ε <= tol)
            return true
        end
    end
    return false
end

# ╔═╡ 5a492522-9db4-44bc-80d4-6aca529560de
"""
Simula reator pistão formulado na entalpia.

- `r`  : Reator a ser simulado.
- `Tₛ` : Temperatura da superfície do reator [K].
- `M`  : Máximo número de iterações para a solução.
- `α`  : Fator de relaxação da solução entre iterações.
- `ε`  : Tolerância absoluta da solução.
"""
function solveenthalpypfr(;
    r::PFRData,
    Tₛ::Vector{Float64},
    M::Int64 = 100,
    α::Float64 = 0.95,
    ε::Float64 = 1.0e-06,
)::Bool
    residual = -1.0
    niter = 0

    T = @view r.T[1:end]
    b = @view r.b[1:end]
    a = r.a
    h = r.h

    f = (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ)

    while (niter < M)
        niter += 1

        # Atualiza condições limites do problema.
        b[1:end] = a * (2Tₛ - T[1:end-1] - T[2:end])
        b[1] += 2h(T[1])

        # Calcula nova temperatura (trial).
        U = map(f, T[2:end], r.K \ b)

        # Incremento da solução.
        Δ = (1-α) * (U - T[2:end])

        # Relaxa solução para evitar divergência.
        T[2:end] += Δ

        # Verica progresso da solução.
        residual = maximum(abs.(Δ))

        if (residual <= ε)
            # @debug("Laço interno convergiu após $(niter) iterações")
            return true
        end
    end

    # @debug("Laço interno: após $(niter) iterações → $(residual)")
    return false
end

# ╔═╡ 57c91e12-cc67-41ea-8554-8135123940bd
"Interpola temperaturas de superfície nas interfaces."
function getsurfacetemperature(r)
    T = reverse(r.T)
    return (T[1:end-1] + T[2:end]) / 2
end

# ╔═╡ 75843461-2fef-43b6-9560-cdf7a587534e
"Variação de entalpia entre entrada e saída do reator."
function enthalpychange(r::PFRData)::Float64
    return r.h(r.T[end]) - r.h(r.T[1])
end

# ╔═╡ 916238a8-093d-4dec-b95a-edcbf8b766e3
"Resíduo relativo da conservação da entalpia."
function enthalpyresidual(ra, rb)
    Δha = ra.ṁ * enthalpychange(ra)
    Δhb = rb.ṁ * enthalpychange(rb)
    return abs(Δhb + Δha) / abs(Δhb)
end

# ╔═╡ b03d62c2-db2e-4de7-8242-9a159e664e80
function counterflowsolver(
    ra::PFRData,
    rb::PFRData;
    inner::Int64 = 5,
    outer::Int64 = 500,
    relax::Float64 = 0.95,
    Δhmax::Float64 = 1.0e-08,
    ΔTmax::Float64 = 1.0e-08,
)
    fa = (Tₖ, hₖ) -> find_zero(t -> ra.h(t) - hₖ, Tₖ)
    fb = (Tₖ, hₖ) -> find_zero(t -> rb.h(t) - hₖ, Tₖ)
    # maxsteps = outer * inner
    # residualsa = -ones(maxsteps)
    # residualsb = -ones(maxsteps)

    @time for nouter in 1:outer
        Ts = getsurfacetemperature(rb)
        ca = innerloop(ra, Ts, inner, relax, ΔTmax)

        Ts = getsurfacetemperature(ra)
        cb = innerloop(rb, Ts, inner, relax, ΔTmax)

        if enthalpyresidual(ra, rb) < Δhmax
            @info("Laço externo convergiu após $(nouter) iterações")
            break
        end
    end

    @info("Conservação da entalpia = $(enthalpyresidual(ra, rb))")
end

# ╔═╡ 1e48a850-f92c-4a7e-aef8-8e52e45eba30
md"""
### Funções gráficas
"""

# ╔═╡ 05457a3d-ec99-4e06-a969-a6e3804f62d4
"Base para traçar temperatura ao longo do reator."
function createpfrplot(; L)
    fig = Figure(resolution = (720, 500))
    ax = Axis(
        fig[1, 1],
        xticks = range(0.0, L, 6),
        ylabel = "Temperatura [K]",
        xlabel = "Posição [m]",
    )
    xlims!(ax, (0, L))
    return fig, ax
end

# ╔═╡ 0e2360a8-0653-4faa-b909-1ab84ca9fbac
md"""
### Dados
"""

# ╔═╡ f307de6d-f197-47d6-a1a6-b1262e7569e0
"Constante dos gases ideais [J/(mol.K)]"
const GAS_CONSTANT = 8.314_462_618_153_24

# ╔═╡ d76d9e69-8830-4190-994f-49689d44b506
"Comprimento do reator [m]"
const L::Float64 = 10.0

# ╔═╡ d24c4ccc-70a3-4e37-a800-e57d54df3b48
"Ilustração padronizada para a simulação exemplo."
function plotpfrpair(r₁, r₂; ylim = (300, 400), loc = :rb)
    z₁ = r₁.z
    z₂ = L .- z₁

    fig, ax = createpfrplot(; L = L)
    stairs!(ax, z₁, r₁.T, label = "r₁", color = :blue, step = :center)
    stairs!(ax, z₂, r₂.T, label = "r₂", color = :red, step = :center)
    ax.yticks = range(ylim..., 6)
    ylims!(ax, ylim)
    axislegend(position = loc)
    fig
end

# ╔═╡ d684dc5e-d78d-484f-a820-317406d9a41a
"Plot results of standard PFR solution"
function plotgassolidpfr(; gas, sol = nothing)
    xlaba = "Position [m]"
    ylab1 = "Temperature [K]"
    ylab2 = "Velocity [m/s]"
    ylab3 = "Density [kg/m³]"
    ylab4 = "Pressure [Pa]"

    xlims = (0.0, L)
    xticks = range(xlims..., 6)

    fig = Figure(resolution = (1000, 700))
    axes = fig[1, 1] = GridLayout()

    ax1 = Axis(axes[1, 1], ylabel = ylab1, xlabel = xlaba, xticks = xticks)
    ax2 = Axis(axes[2, 1], ylabel = ylab2, xlabel = xlaba, xticks = xticks)
    ax3 = Axis(axes[1, 2], ylabel = ylab3, xlabel = xlaba, xticks = xticks)
    ax4 = Axis(axes[2, 2], ylabel = ylab4, xlabel = xlaba, xticks = xticks)

    xlims!(ax1, xlims)
    xlims!(ax2, xlims)
    xlims!(ax3, xlims)
    xlims!(ax4, xlims)

    linkxaxes!(ax1, ax2, ax3, ax4)

    z = gas[:z]
    T = gas[:T]
    u = gas[:u]
    Ρ = gas[:Ρ]
    p = gas[:p] .- 101_325.0

    lines!(ax1, z, T, label = "Gas")
    lines!(ax2, z, u, label = "Gas")
    lines!(ax3, z, Ρ, label = "Gas")
    lines!(ax4, z, p, label = "Gas")

    if !isnothing(sol)
        z = reverse(sol[:z])
        T = sol[:T]
        u = sol[:u]

        lines!(ax1, z, T, label = "Solid")
        lines!(ax2, z, u, label = "Solid")
    end

    axislegend(ax1)
    axislegend(ax2)
    axislegend(ax3)
    axislegend(ax4)

    return fig
end

# ╔═╡ 243ce122-61cf-4697-9f13-1710afef8e5c
"Raio do reator [m]"
const R::Float64 = 0.010

# ╔═╡ 25f64410-97d0-43f7-a8b1-de0983265a7c
"Temperatura de entrada do fluido no reator 1 [K]"
const T₁::Float64 = 300.0

# ╔═╡ 012242f9-962d-46fe-9619-46906d2d8478
"Temperatura de entrada do fluido no reator 2 [K]"
const T₂::Float64 = 400.0

# ╔═╡ fe7b4804-e952-41ff-b2fd-20972035c747
"Velocidade do fluido [m/s]"
const u::Float64 = 1.0

# ╔═╡ 0e2aa152-976d-400b-ae25-71f37c90e01c
"Mass específica do fluido [kg/m³]"
const ρˡ::Float64 = 1000.0

# ╔═╡ e125fd83-5fd1-4c5c-b466-22fd3375ff4a
"Mass específica do sólido [kg/m³]"
const ρˢ::Float64 = 3000.0

# ╔═╡ 901d3be7-9a5c-4638-98ca-b4bb0ce355ed
"Calor específico do fluido [J/(kg.K)]"
const cₚˡ::Float64 = 4182.0

# ╔═╡ a65e3986-9683-463b-b4d7-c78f80750328
"Cria um par padronizado de reatores para simulação exemplo.

O par escolhido para exemplificar o comportamento de contra-corrente dos reatores
pistão tem por característica de que cada reator ocupa a metade de um cilindro de
raio `R` = $(R) m de forma que o perímetro de troca é igual o diâmetro e a área
transversal a metade daquela do cilindro. A temperatura inicial do fluido no reator
`r₁` é de $(T₁) K e no reator `r₂` é de $(T₂) K. Fluido do reator `r₂` tem um calor
específico que é o triplo daquele de `r₁`.
"
function createprfpair(N)
    P = 2R
    A = 0.5π * R^2
    ĥ = 5000.0

    shared = (L = L, N = N, P = P, A = A,
              ĥ = ĥ, u = u, ρ = ρˡ)

    r₁ = PFRData(; h = (T) -> 1cₚˡ * T, T₀ = T₁, shared...)
    r₂ = PFRData(; h = (T) -> 3cₚˡ * T, T₀ = T₂, shared...)

    return r₁, r₂
end

# ╔═╡ e5d12839-8167-4ddf-843f-f8ad0f682126
let
    inner = 5
    ε = 1.0e-08
    α = 0.9

    outer = 500
    δhmax = 1.0e-08

    shared = (α = α, ε = ε, M = inner)

    N = 2000
    r₁, r₂ = createprfpair(N)

    @time for k in 1:outer
        Tₛ₁ = getsurfacetemperature(r₂)
        c₁ = solveenthalpypfr(; r = r₁, Tₛ = Tₛ₁, shared...)

        Tₛ₂ = getsurfacetemperature(r₁)
        c₂ = solveenthalpypfr(; r = r₂, Tₛ = Tₛ₂, shared...)

        δh = enthalpyresidual(r₁, r₂)

        if c₁ && c₂ && δh < δhmax
            @info("Laço externo convergiu após $(k) iterações")
            break
        end
    end

    @info("Conservação da entalpia = $(enthalpyresidual(r₁, r₂))")
    plotpfrpair(r₁, r₂; ylim = (300, 400), loc = :rb)
end

# ╔═╡ 595edaed-4a16-43f4-b3b2-4803f06f93e7
"Calor específico do gás [J/(kg.K)]"
const cₚᵍ = Polynomial([
    959.8458126240355,
    0.3029051601580761,
    3.988896105280984e-05,
    -6.093647929461819e-08,
    1.0991100692950414e-11
], :T)

# ╔═╡ b7f5a299-360e-455c-9886-bcd2b4791a25
"Variação de entalpia do sólido [J/(kg.K)]"
const hˢ = (T) -> 900.0T

# ╔═╡ b30e0fb9-d505-41e5-8a7d-1e8f2cbc2bbc
"Variação de entalpia do gás [J/(kg.K)]"
const hᵍ = integrate(cₚᵍ)

# ╔═╡ 630ba246-b5fb-4f9d-a9d2-b2edb471ada0
"Cria um par padronizado de reatores para simulação exemplo."
function createprfgassolidpair(N; debug = true)
    P = 2R
    A = 0.5π * R^2
    ĥ = 10.0

    shared = (L = L, N = N, P = P, A = A, ĥ = ĥ)

    ratio = 1.5

    Tᵍ = 2000.0
    ρᵍ = (101325.0 * 0.02897530345830224) / (GAS_CONSTANT * Tᵍ)

    uᵍ = 3u
    ṁᵍ = ρᵍ * uᵍ * A

    ṁˢ = ratio * ṁᵍ
    uˢ = ṁˢ / (ρˢ * A)

    r₁ = PFRData(; h = (T) -> hˢ(T), T₀ = T₁, shared..., u = uˢ, ρ = ρˢ)
    r₂ = PFRData(; h = (T) -> hᵍ(T), T₀ = Tᵍ, shared..., u = uᵍ, ρ = ρᵍ)

    if debug
        r₁.T[1:end] = @. r₁.T[1] + (r₁.z / L) * (r₂.T[1] - r₁.T[1])
        r₂.T[1:end] = reverse(r₁.T)
    end

    return r₁, r₂
end

# ╔═╡ c69be00a-40d4-4c25-aa47-ffb38ccaecec
let
    inner = 5
    ε = 1.0e-08
    α = 0.95

    outer = 500
    δhmax = 1.0e-08

    shared = (α = α, ε = ε, M = inner)

    N = 500
    r₁, r₂ = createprfgassolidpair(N)


    @time for k in 1:outer
        Tₛ₁ = getsurfacetemperature(r₂)
        c₁ = solveenthalpypfr(; r = r₁, Tₛ = Tₛ₁, shared...)

        Tₛ₂ = getsurfacetemperature(r₁)
        c₂ = solveenthalpypfr(; r = r₂, Tₛ = Tₛ₂, shared...)

        δh = enthalpyresidual(r₁, r₂)

        if c₁ && c₂ && δh < δhmax
            @info("Laço externo convergiu após $(k) iterações")
            break
        end
    end

    @info("Conservação da entalpia = $(enthalpyresidual(r₁, r₂))")
    plotpfrpair(r₁, r₂; ylim = (200, 2200), loc = :rb)
end

# ╔═╡ b46e7129-72e7-470b-b7e8-4a30f5bed259
let
    r₁, r₂ = createprfgassolidpair(500)

    counterflowsolver(r₁, r₂;
        inner = 5,
        outer = 500,
        relax = 0.95,
        Δhmax = 1.0e-08,
        ΔTmax = 1.0e-08
    )

    plotpfrpair(r₁, r₂; ylim = (200, 2200), loc = :rb)
end

# ╔═╡ 54aa6060-a605-4a05-83f1-2b672f1d148f
md"""
### Pacotes
"""

# ╔═╡ Cell order:
# ╟─f33f5453-dd05-4a4e-ae12-695320fcd70d
# ╟─f3b7d46f-0fcc-4f68-9822-f83e977b87ee
# ╟─e5d12839-8167-4ddf-843f-f8ad0f682126
# ╟─7912192d-1528-48ce-9adc-7e6a26b25c51
# ╟─c69be00a-40d4-4c25-aa47-ffb38ccaecec
# ╠═b46e7129-72e7-470b-b7e8-4a30f5bed259
# ╟─975744de-7ab0-4bfa-abe5-3741ec7ec1cf
# ╟─27233ad1-a588-48d6-9103-901a71936074
# ╟─c9194590-0fc7-4d68-9b19-9ee8d415fbda
# ╟─5007aa03-6db0-4626-a73c-9172fef2c4ea
# ╟─a65e3986-9683-463b-b4d7-c78f80750328
# ╟─630ba246-b5fb-4f9d-a9d2-b2edb471ada0
# ╟─be3a4933-516e-4867-a801-4df4f695432a
# ╠═b03d62c2-db2e-4de7-8242-9a159e664e80
# ╠═a842401e-77d0-4f2b-8ef1-06a7799531e2
# ╟─5a492522-9db4-44bc-80d4-6aca529560de
# ╟─57c91e12-cc67-41ea-8554-8135123940bd
# ╟─916238a8-093d-4dec-b95a-edcbf8b766e3
# ╟─75843461-2fef-43b6-9560-cdf7a587534e
# ╟─1e48a850-f92c-4a7e-aef8-8e52e45eba30
# ╟─05457a3d-ec99-4e06-a969-a6e3804f62d4
# ╟─d24c4ccc-70a3-4e37-a800-e57d54df3b48
# ╟─d684dc5e-d78d-484f-a820-317406d9a41a
# ╟─0e2360a8-0653-4faa-b909-1ab84ca9fbac
# ╟─f307de6d-f197-47d6-a1a6-b1262e7569e0
# ╟─d76d9e69-8830-4190-994f-49689d44b506
# ╟─243ce122-61cf-4697-9f13-1710afef8e5c
# ╟─25f64410-97d0-43f7-a8b1-de0983265a7c
# ╟─012242f9-962d-46fe-9619-46906d2d8478
# ╟─fe7b4804-e952-41ff-b2fd-20972035c747
# ╟─0e2aa152-976d-400b-ae25-71f37c90e01c
# ╟─e125fd83-5fd1-4c5c-b466-22fd3375ff4a
# ╟─901d3be7-9a5c-4638-98ca-b4bb0ce355ed
# ╟─595edaed-4a16-43f4-b3b2-4803f06f93e7
# ╟─b7f5a299-360e-455c-9886-bcd2b4791a25
# ╟─b30e0fb9-d505-41e5-8a7d-1e8f2cbc2bbc
# ╟─54aa6060-a605-4a05-83f1-2b672f1d148f
# ╟─fe2c3680-5b91-11ee-282c-c74d3b01ef9b
