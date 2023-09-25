### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ fe2c3680-5b91-11ee-282c-c74d3b01ef9b
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using CairoMakie
    using DocStringExtensions
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

# ╔═╡ 975744de-7ab0-4bfa-abe5-3741ec7ec1cf
md"""
## Anexos
"""

# ╔═╡ be3a4933-516e-4867-a801-4df4f695432a
md"""
### Funções
"""

# ╔═╡ c9194590-0fc7-4d68-9b19-9ee8d415fbda
"Estrutura com memória do estado de um reator."
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
        a = (ĥ * P * δ) / (ρ * u * A)
        b = ones(N)

        T[1] = T₀

        return new(z, T, h, a, b, K)
    end
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
    α::Float64 = 0.4,
    ε::Float64 = 1.0e-06,
)
    residual = -ones(M)
    niter = 0

    T = @view r.T[1:end]
    b = @view r.b[1:end]

    while (niter < M)
        niter += 1

        b[1:end] = 2r.a * Tₛ[2:end]
        b[1] += 2r.h(T[1])

        h̄ = r.K \ (b - r.a * (T[1:end-1] + T[2:end]))

        U = map((Tₖ, hₖ) -> find_zero(t -> r.h(t) - hₖ, Tₖ), T[2:end], h̄)

        Δ = T[2:end] - U

        T[2:end] = U + α * Δ

        residual[niter] = maximum(abs.(Δ))

        if (residual[niter] <= ε)
            return niter
        end
    end

    error("Simulação falhou em convergir")
end

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

# ╔═╡ d76d9e69-8830-4190-994f-49689d44b506
"Comprimento do reator [m]"
const L::Float64 = 10.0

# ╔═╡ d24c4ccc-70a3-4e37-a800-e57d54df3b48
"Ilustração padronizada para a simulação exemplo."
function plotpfrpair(r₁, r₂)
    z₁ = r₁.z
    z₂ = L .- z₁

    fig, ax = createpfrplot(; L = L)
    stairs!(ax, z₁, r₁.T, label = "r₁", color = :blue, step = :center)
    stairs!(ax, z₂, r₂.T, label = "r₂", color = :red, step = :center)
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
    fig
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
const ρ::Float64 = 1000.0

# ╔═╡ 901d3be7-9a5c-4638-98ca-b4bb0ce355ed
"Calor específico do fluido [J/(kg.K)]"
const cₚ::Float64 = 4182.0

# ╔═╡ a65e3986-9683-463b-b4d7-c78f80750328
"Cria um par padronizado de reatores para simulação exemplo.

O par escolhido para exemplificar o comportamento de contra-corrente dos reatores
pistão tem por característica de que cada reator ocupa a metade de um cilindro de
raio `R` = $(R) m de forma que o perímetro de troca é igual o diâmetro e a área
transversal a metade daquela do cilindro. A temperatura inicial do fluido no reator
`r₁` é de $(T₁) K e no reator `r₂` é de $(T₂) K. Fluido do reator `r₂` tem um calor
específico que é o dobro daquele de `r₁`.
"
function createprfpair(N)
    P = 2R
    A = 0.5π * R^2
    ĥ = 5000.0

    shared = (L = L, N = N, P = P, A = A,
              ĥ = ĥ, u = u, ρ = ρ)

    r₁ = PFRData(; h = (T) -> 1cₚ * T, T₀ = T₁, shared...)
    r₂ = PFRData(; h = (T) -> 2cₚ * T, T₀ = T₂, shared...)

    return r₁, r₂
end

# ╔═╡ e5d12839-8167-4ddf-843f-f8ad0f682126
let
    N = 100
    r₁, r₂ = createprfpair(N)

    @time for _ in 1:20
        solveenthalpypfr(; r = r₁, Tₛ = reverse(r₂.T))
        solveenthalpypfr(; r = r₂, Tₛ = reverse(r₁.T))
    end

    plotpfrpair(r₁, r₂)
end

# ╔═╡ 54aa6060-a605-4a05-83f1-2b672f1d148f
md"""
### Pacotes
"""

# ╔═╡ Cell order:
# ╟─f33f5453-dd05-4a4e-ae12-695320fcd70d
# ╠═e5d12839-8167-4ddf-843f-f8ad0f682126
# ╟─975744de-7ab0-4bfa-abe5-3741ec7ec1cf
# ╟─be3a4933-516e-4867-a801-4df4f695432a
# ╟─c9194590-0fc7-4d68-9b19-9ee8d415fbda
# ╟─5a492522-9db4-44bc-80d4-6aca529560de
# ╟─05457a3d-ec99-4e06-a969-a6e3804f62d4
# ╟─a65e3986-9683-463b-b4d7-c78f80750328
# ╟─d24c4ccc-70a3-4e37-a800-e57d54df3b48
# ╟─0e2360a8-0653-4faa-b909-1ab84ca9fbac
# ╟─d76d9e69-8830-4190-994f-49689d44b506
# ╟─243ce122-61cf-4697-9f13-1710afef8e5c
# ╟─25f64410-97d0-43f7-a8b1-de0983265a7c
# ╟─012242f9-962d-46fe-9619-46906d2d8478
# ╟─fe7b4804-e952-41ff-b2fd-20972035c747
# ╟─0e2aa152-976d-400b-ae25-71f37c90e01c
# ╟─901d3be7-9a5c-4638-98ca-b4bb0ce355ed
# ╟─54aa6060-a605-4a05-83f1-2b672f1d148f
# ╟─fe2c3680-5b91-11ee-282c-c74d3b01ef9b
