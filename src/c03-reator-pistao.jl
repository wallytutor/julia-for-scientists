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

    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end;

# ╔═╡ f33f5453-dd05-4a4e-ae12-695320fcd70d
md"""
# Reator pistão - Parte 3

As ideias gerais para a simulação de um reator formulado na entalpia tendo sido introduzidas na *Parte 2*, vamos agora aplicar o mesmo algoritmo de solução para um problema menos trivial: integração de reatores em contra-corrente com trocas térmicas. Esse é o caso, por exemplo, em uma serpentina dupla em contato mecânico. Esse sistema pode ser aproximado por um par de reatores pistão em contra-corrente se tomada propriamente em conta a resistência térmica dos dutos.

Outro caso clássico que pode ser as vezes tratado desta forma é o modelo de forno rotativo para produção de cimento, como discutido por [Hanein *et al.* (2017)](https://doi.org/10.1080/17436753.2017.1303261). Outro exemplo é fornecido por [Bulfin (2019)](https://doi.org/10.1039/C8CP07077F) para a síntese de ceria. [Kerkhof (2007)](https://doi.org/10.1016/j.ces.2006.12.047) apresenta uma abordagem mais geral introduzindo troca de massa entre partículas.

Ainda precisamos tratar de tópicos mais básicos antes de implementar modelos similares ao longo dessa série, mas espero que a literatura citada sirva como motivação para o estudo.

Neste notebook trataremos dois casos: (I)... TODO

$(toc)
"""

# ╔═╡ dcfd8b59-429f-4c99-9eae-1aa34fa87033
const reactor = notedata.c03.reactor

# ╔═╡ 9f94f21d-2805-4b30-8451-7b09b575081c
const fluid1 = notedata.c03.fluid1

# ╔═╡ cc1a6701-8907-440a-a77b-b89ec6abac65
const operations1 = notedata.c03.operations1

# ╔═╡ f1cc566b-87bb-42be-a0a5-c160f326817f
const operations2 = notedata.c03.operations2

# ╔═╡ 04cf5b92-d10b-43f5-8fc5-1e549105ef9d
md"""
## Reatores em contra-corrente I

O par escolhido para exemplificar o comportamento de contra-corrente dos reatores
pistão tem por característica de que cada reator ocupa a metade de um cilindro de diâmetro `D` = $(reactor.D) m de forma que o perímetro de troca é igual o diâmetro e a área transversal a metade daquela do cilindro. A temperatura inicial do fluido no reator (1) que escoa da esquerda para a direita é de $(operations1.Tₚ) K e naquele em contra-corrente (2) é de $(operations2.Tₚ) K.

O fluido do reator (2) tem um calor específico que é o triplo daquele do reator (1).
"""

# ╔═╡ 9a529019-9cfc-4018-a7ce-051e6dbdd85e
"Cria um par padronizado de reatores para simulação exemplo."
function createprfpair(; N = 10)
    shared = (
        N = N, 
        L = reactor.L,
        P = reactor.D,
        A = 0.5π * (reactor.D/2)^2,
        ρ = fluid1.ρ
    )
    
    r₁ = IncompressibleEnthalpyPFRModel(;
        shared...,	
        T = operations1.Tₚ,
        u = operations1.u,
        ĥ = computehtc(; reactor..., fluid1..., u = operations1.u),
        h = (T) -> 1.0fluid1.cₚ * T + 1000.0
    )

    r₂ = IncompressibleEnthalpyPFRModel(;
        shared...,	
        T = operations2.Tₚ,
        u = operations2.u,
        # THINK ABOUT THIS!
        # ĥ = computehtc(; reactor..., fluid1..., u = operations2.u),
        ĥ = computehtc(; reactor..., fluid1..., u = operations1.u),
        h = (T) -> 3.0fluid1.cₚ * T + 1000.0,
    )

    return r₁ , r₂
end

# ╔═╡ 887b33b5-7f9d-43ff-ae86-20ae6f04735e
struct CounterFlowPFRModel
    myself::IncompressibleEnthalpyPFRModel
    neighbor::IncompressibleEnthalpyPFRModel
end

# ╔═╡ 77bc010d-9f24-407c-b1c6-38e89f4e774b
begin
    function matrix(r::IncompressibleEnthalpyPFRModel)
        return r.fvdata.A
    end
    function vector(r::IncompressibleEnthalpyPFRModel)
        return r.fvdata.b
    end
    function coefs(r::IncompressibleEnthalpyPFRModel)
        return r.fvdata.c
    end
    function temperature(r::IncompressibleEnthalpyPFRModel)
        return r.fvdata.x
    end
    function massflowrate(r::IncompressibleEnthalpyPFRModel)
        return r.ṁ
    end
    function enthalpyfn(r::IncompressibleEnthalpyPFRModel)
        return r.enthalpy
    end
    function thisreactor(cf::CounterFlowPFRModel)
        return cf.myself
    end
    function otherreactor(cf::CounterFlowPFRModel)
        return cf.neighbor
    end
    function annexed(cf::CounterFlowPFRModel)
        return CounterFlowPFRModel(cf.neighbor, cf.myself)
    end
    function temperature(cf::CounterFlowPFRModel)
        return temperature(cf.myself)
    end
    function neighbortemperature(cf::CounterFlowPFRModel)
        return reverse(temperature(cf.neighbor))
    end
    function surfacetemperature(cf::CounterFlowPFRModel)
        T = neighbortemperature(cf)
        return 0.5 * (T[1:end-1] + T[2:end])
    end
    function updatetemperature(A, b, a, T, S, f, h, α)
        b[1:end] = a * (2S - T[1:end-1] - T[2:end])
        b[1] += 2h(T[1])
        Tm = map(f, T[2:end], A\b)
        ΔT = (1-α) * (Tm - T[2:end])
        εm = maximum(abs.(ΔT))
        T[2:end] += ΔT
        return εm
    end
    function enthalpyrate(r::IncompressibleEnthalpyPFRModel)
        ḣ(h, ṁ, T) = ṁ * (h(T[end]) - h(T[1]))
        return ḣ(enthalpyfn(r), massflowrate(r), temperature(r))
    end
    function enthalpyresidual(cf::CounterFlowPFRModel)
        Δha = enthalpyrate(thisreactor(cf))
        Δhb = enthalpyrate(otherreactor(cf))
        return abs(Δhb + Δha) / abs(Δha)
    end
    function innerloop(;
        cf::CounterFlowPFRModel,
        M::Int64 = 1,
        α::Float64 = 0.95,
        ε::Float64 = 1.0e-08
    )::Nothing
        S = surfacetemperature(cf)
        r = thisreactor(cf)
        T = temperature(r)
        A = matrix(r)
        b = vector(r)
        a = coefs(r)[1]
        h = enthalpyfn(r)
        f = (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ)
    
        niter = 0
        while (niter < M)
            niter += 1
            εm = updatetemperature(A, b, a, T, S, f, h, α)
            if (εm <= ε)
                return
            end
        end
    end
    function outerloop(
            cf::CounterFlowPFRModel;
            inner::Int64 = 5,
            outer::Int64 = 500,
            relax::Float64 = 0.95,
            Δhmax::Float64 = 1.0e-08,
            ΔTmax::Float64 = 1.0e-08,
        )
        ra = cf
        rb = annexed(ra)

        # maxsteps = outer * inner
        # residualsa = -ones(maxsteps)
        # residualsb = -ones(maxsteps)
    
        @info("Conservação da entalpia = $(enthalpyresidual(cf))")
        
        @time for nouter in 1:outer
            innerloop(; cf = ra, M = inner, α = relax, ε = ΔTmax)
            innerloop(; cf = rb, M = inner, α = relax, ε = ΔTmax)
    
            if enthalpyresidual(cf) < Δhmax
                @info("Laço externo convergiu após $(nouter) iterações")
                break
            end
        end
        @info("Conservação da entalpia = $(enthalpyresidual(cf))")
    end
end

# ╔═╡ b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
ra, rb = let
    r₁, r₂ = createprfpair(; N = 500)
    cf = CounterFlowPFRModel(r₁, r₂)

    outerloop(cf;
        inner = 10,
        outer = 500,
        relax = 0.99,
        Δhmax = 1.0e-08,
        ΔTmax = 1.0e-08
    )

    temperature(cf), neighbortemperature(cf)
end

# ╔═╡ 92d55286-e273-41f2-a856-45f094ecbd33
# function counterflowsolver(
#     ra::IncompressibleEnthalpyPFRModel,
#     rb::IncompressibleEnthalpyPFRModel;
#     inner::Int64 = 5,
#     outer::Int64 = 500,
#     relax::Float64 = 0.95,
#     Δhmax::Float64 = 1.0e-08,
#     ΔTmax::Float64 = 1.0e-08,
# )
#     fa = (Tₖ, hₖ) -> find_zero(t -> ra.h(t) - hₖ, Tₖ)
#     fb = (Tₖ, hₖ) -> find_zero(t -> rb.h(t) - hₖ, Tₖ)
#     # maxsteps = outer * inner
#     # residualsa = -ones(maxsteps)
#     # residualsb = -ones(maxsteps)

#     @time for nouter in 1:outer
#         Ts = getsurfacetemperature(rb)
#         innerloop(ra, Ts, inner, relax, ΔTmax)

#         Ts = getsurfacetemperature(ra)
#         innerloop(rb, Ts, inner, relax, ΔTmax)

#         if 0.0 < enthalpyresidual(ra, rb) < Δhmax
#             @info("Laço externo convergiu após $(nouter) iterações")
#             break
#         end
#     end

#     @info("Conservação da entalpia = $(enthalpyresidual(ra, rb))")
# end

# ╔═╡ 9d825afc-21de-4de5-b293-4e28638dc7cc
# "Resíduo relativo da conservação da entalpia."
function enthalpyresidual(ra, rb)
    Δha = ra.ṁ * enthalpychange(ra)
    Δhb = rb.ṁ * enthalpychange(rb)
    return abs(Δhb + Δha) / abs(Δhb)
end

# ╔═╡ 397322c6-2d5b-4808-b243-1cd018e7150f
# "Variação de entalpia entre entrada e saída do reator."


# ╔═╡ e8bf2c23-e999-44af-ad2b-243bfc5c8f52


# ╔═╡ 4186d2eb-0da6-4f68-ba41-e92bf7423041


# ╔═╡ eed9710f-ba5e-4961-8215-177a9d4c4752


# ╔═╡ f3b7d46f-0fcc-4f68-9822-f83e977b87ee
md"""
## Reator conceitual incompressível
"""

# ╔═╡ e5d12839-8167-4ddf-843f-f8ad0f682126
# let
#     inner = 5
#     ε = 1.0e-08
#     α = 0.9

#     outer = 500
#     δhmax = 1.0e-08

#     shared = (α = α, ε = ε, M = inner)

#     N = 2000
#     r₁, r₂ = createprfpair(N)

#     @time for k in 1:outer
#         Tₛ₁ = getsurfacetemperature(r₂)
#         c₁ = solveenthalpypfr(; r = r₁, Tₛ = Tₛ₁, shared...)

#         Tₛ₂ = getsurfacetemperature(r₁)
#         c₂ = solveenthalpypfr(; r = r₂, Tₛ = Tₛ₂, shared...)

#         δh = enthalpyresidual(r₁, r₂)

#         if c₁ && c₂ && δh < δhmax
#             @info("Laço externo convergiu após $(k) iterações")
#             break
#         end
#     end

#     @info("Conservação da entalpia = $(enthalpyresidual(r₁, r₂))")
#     plotpfrpair(r₁, r₂; ylim = (300, 400), loc = :rb)
# end

# ╔═╡ 7912192d-1528-48ce-9adc-7e6a26b25c51
md"""
## Reator com fase sólida e gás
"""

# ╔═╡ c69be00a-40d4-4c25-aa47-ffb38ccaecec
# let
#     inner = 5
#     ε = 1.0e-08
#     α = 0.95

#     outer = 500
#     δhmax = 1.0e-08

#     shared = (α = α, ε = ε, M = inner)

#     N = 500
#     r₁, r₂ = createprfgassolidpair(N)


#     @time for k in 1:outer
#         Tₛ₁ = getsurfacetemperature(r₂)
#         c₁ = solveenthalpypfr(; r = r₁, Tₛ = Tₛ₁, shared...)

#         Tₛ₂ = getsurfacetemperature(r₁)
#         c₂ = solveenthalpypfr(; r = r₂, Tₛ = Tₛ₂, shared...)

#         δh = enthalpyresidual(r₁, r₂)

#         if c₁ && c₂ && δh < δhmax
#             @info("Laço externo convergiu após $(k) iterações")
#             break
#         end
#     end

#     @info("Conservação da entalpia = $(enthalpyresidual(r₁, r₂))")
#     plotpfrpair(r₁, r₂; ylim = (200, 2200), loc = :rb)
# end

# ╔═╡ b46e7129-72e7-470b-b7e8-4a30f5bed259
# let
#     r₁, r₂ = createprfgassolidpair(500)



#     plotpfrpair(r₁, r₂; ylim = (200, 2200), loc = :rb)
# end

# ╔═╡ 975744de-7ab0-4bfa-abe5-3741ec7ec1cf
md"""
## Anexos
"""

# ╔═╡ 5007aa03-6db0-4626-a73c-9172fef2c4ea
md"""
### Criação de exemplos
"""

# ╔═╡ 630ba246-b5fb-4f9d-a9d2-b2edb471ada0
# "Cria um par padronizado de reatores para simulação exemplo."
# function createprfgassolidpair(N; debug = true)
#     P = 2R
#     A = 0.5π * R^2
#     ĥ = 10.0

#     shared = (L = L, N = N, P = P, A = A, ĥ = ĥ)

#     ratio = 1.5

#     Tᵍ = 2000.0
#     ρᵍ = (101325.0 * 0.02897530345830224) / (GAS_CONSTANT * Tᵍ)

#     uᵍ = 3u
#     ṁᵍ = ρᵍ * uᵍ * A

#     ṁˢ = ratio * ṁᵍ
#     uˢ = ṁˢ / (ρˢ * A)

#     r₁ = PFRData(; h = (T) -> hˢ(T), T₀ = T₁, shared..., u = uˢ, ρ = ρˢ)
#     r₂ = PFRData(; h = (T) -> hᵍ(T), T₀ = Tᵍ, shared..., u = uᵍ, ρ = ρᵍ)

#     if debug
#         r₁.T[1:end] = @. r₁.T[1] + (r₁.z / L) * (r₂.T[1] - r₁.T[1])
#         r₂.T[1:end] = reverse(r₁.T)
#     end

#     return r₁, r₂
# end

# ╔═╡ be3a4933-516e-4867-a801-4df4f695432a
md"""
### Funções físicas
"""

# ╔═╡ 5a492522-9db4-44bc-80d4-6aca529560de
# """
# Simula reator pistão formulado na entalpia.

# - `r`  : Reator a ser simulado.
# - `Tₛ` : Temperatura da superfície do reator [K].
# - `M`  : Máximo número de iterações para a solução.
# - `α`  : Fator de relaxação da solução entre iterações.
# - `ε`  : Tolerância absoluta da solução.
# """
# function solveenthalpypfr(;
#     r::PFRData,
#     Tₛ::Vector{Float64},
#     M::Int64 = 100,
#     α::Float64 = 0.95,
#     ε::Float64 = 1.0e-06,
# )::Bool
#     residual = -1.0
#     niter = 0

#     T = @view r.T[1:end]
#     b = @view r.b[1:end]
#     a = r.a
#     h = r.h

#     f = (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ)

#     while (niter < M)
#         niter += 1

#         # Atualiza condições limites do problema.
#         b[1:end] = a * (2Tₛ - T[1:end-1] - T[2:end])
#         b[1] += 2h(T[1])

#         # Calcula nova temperatura (trial).
#         U = map(f, T[2:end], r.K \ b)

#         # Incremento da solução.
#         Δ = (1-α) * (U - T[2:end])

#         # Relaxa solução para evitar divergência.
#         T[2:end] += Δ

#         # Verica progresso da solução.
#         residual = maximum(abs.(Δ))

#         if (residual <= ε)
#             # @debug("Laço interno convergiu após $(niter) iterações")
#             return true
#         end
#     end

#     # @debug("Laço interno: após $(niter) iterações → $(residual)")
#     return false
# end

# ╔═╡ 1e48a850-f92c-4a7e-aef8-8e52e45eba30
md"""
### Funções gráficas
"""

# ╔═╡ d24c4ccc-70a3-4e37-a800-e57d54df3b48
# "Ilustração padronizada para a simulação exemplo."
# function plotpfrpair(r₁, r₂; ylims = (300, 400), loc = :rb)
#     z₁ = r₁.z
#     z₂ = L .- z₁

#     fig = Figure(resolution = (720, 500))
#     ax = Axis(fig[1, 1])
#     stairs!(ax, z₁, r₁.T, label = "r₁", color = :blue, step = :center)
#     stairs!(ax, z₂, r₂.T, label = "r₂", color = :red, step = :center)
#     ax.xticks = range(0.0, L, 6)
#     ax.yticks = range(ylim..., 6)
#     ax.xlabel = "Posição [m]"
#     ax.ylabel = "Temperatura [K]"
#     xlims!(ax, (0, L))
#     ylims!(ax, ylims)
#     axislegend(position = loc)
#     fig
# end

# ╔═╡ d684dc5e-d78d-484f-a820-317406d9a41a
# "Plot results of standard PFR solution"
# function plotgassolidpfr(; gas, sol = nothing)
#     xlaba = "Position [m]"
#     ylab1 = "Temperature [K]"
#     ylab2 = "Velocity [m/s]"
#     ylab3 = "Density [kg/m³]"
#     ylab4 = "Pressure [Pa]"

#     xlims = (0.0, L)
#     xticks = range(xlims..., 6)

#     fig = Figure(resolution = (1000, 700))
#     axes = fig[1, 1] = GridLayout()

#     ax1 = Axis(axes[1, 1], ylabel = ylab1, xlabel = xlaba, xticks = xticks)
#     ax2 = Axis(axes[2, 1], ylabel = ylab2, xlabel = xlaba, xticks = xticks)
#     ax3 = Axis(axes[1, 2], ylabel = ylab3, xlabel = xlaba, xticks = xticks)
#     ax4 = Axis(axes[2, 2], ylabel = ylab4, xlabel = xlaba, xticks = xticks)

#     xlims!(ax1, xlims)
#     xlims!(ax2, xlims)
#     xlims!(ax3, xlims)
#     xlims!(ax4, xlims)

#     linkxaxes!(ax1, ax2, ax3, ax4)

#     z = gas[:z]
#     T = gas[:T]
#     u = gas[:u]
#     Ρ = gas[:Ρ]
#     p = gas[:p] .- 101_325.0

#     lines!(ax1, z, T, label = "Gas")
#     lines!(ax2, z, u, label = "Gas")
#     lines!(ax3, z, Ρ, label = "Gas")
#     lines!(ax4, z, p, label = "Gas")

#     if !isnothing(sol)
#         z = reverse(sol[:z])
#         T = sol[:T]
#         u = sol[:u]

#         lines!(ax1, z, T, label = "Solid")
#         lines!(ax2, z, u, label = "Solid")
#     end

#     axislegend(ax1)
#     axislegend(ax2)
#     axislegend(ax3)
#     axislegend(ax4)

#     return fig
# end

# ╔═╡ 0e2360a8-0653-4faa-b909-1ab84ca9fbac
md"""
### Dados
"""

# ╔═╡ f307de6d-f197-47d6-a1a6-b1262e7569e0


# ╔═╡ d76d9e69-8830-4190-994f-49689d44b506
# "Comprimento do reator [m]"
# const L::Float64 = 10.0

# ╔═╡ 243ce122-61cf-4697-9f13-1710afef8e5c
# "Raio do reator [m]"
# const R::Float64 = 0.010

# ╔═╡ 25f64410-97d0-43f7-a8b1-de0983265a7c
# "Temperatura de entrada do fluido no reator 1 [K]"
# const T₁::Float64 = 300.0

# ╔═╡ 012242f9-962d-46fe-9619-46906d2d8478
# "Temperatura de entrada do fluido no reator 2 [K]"
# const T₂::Float64 = 400.0

# ╔═╡ fe7b4804-e952-41ff-b2fd-20972035c747
# "Velocidade do fluido [m/s]"
# const u::Float64 = 1.0

# ╔═╡ 0e2aa152-976d-400b-ae25-71f37c90e01c
# "Mass específica do fluido [kg/m³]"
# const ρˡ::Float64 = 1000.0

# ╔═╡ e125fd83-5fd1-4c5c-b466-22fd3375ff4a
# "Mass específica do sólido [kg/m³]"
# const ρˢ::Float64 = 3000.0

# ╔═╡ 901d3be7-9a5c-4638-98ca-b4bb0ce355ed
# "Calor específico do fluido [J/(kg.K)]"
# const cₚˡ::Float64 = 4182.0

# ╔═╡ 595edaed-4a16-43f4-b3b2-4803f06f93e7
# "Calor específico do gás [J/(kg.K)]"
# const cₚᵍ = Polynomial([
#     959.8458126240355,
#     0.3029051601580761,
#     3.988896105280984e-05,
#     -6.093647929461819e-08,
#     1.0991100692950414e-11
# ], :T)

# ╔═╡ b7f5a299-360e-455c-9886-bcd2b4791a25
# "Variação de entalpia do sólido [J/(kg.K)]"
# const hˢ = (T) -> 900.0T

# ╔═╡ b30e0fb9-d505-41e5-8a7d-1e8f2cbc2bbc
# "Variação de entalpia do gás [J/(kg.K)]"
# const hᵍ = integrate(cₚᵍ)

# ╔═╡ 54aa6060-a605-4a05-83f1-2b672f1d148f
md"""
### Pacotes
"""

# ╔═╡ Cell order:
# ╟─f33f5453-dd05-4a4e-ae12-695320fcd70d
# ╟─04cf5b92-d10b-43f5-8fc5-1e549105ef9d
# ╠═dcfd8b59-429f-4c99-9eae-1aa34fa87033
# ╠═9f94f21d-2805-4b30-8451-7b09b575081c
# ╠═cc1a6701-8907-440a-a77b-b89ec6abac65
# ╠═f1cc566b-87bb-42be-a0a5-c160f326817f
# ╠═9a529019-9cfc-4018-a7ce-051e6dbdd85e
# ╠═887b33b5-7f9d-43ff-ae86-20ae6f04735e
# ╠═77bc010d-9f24-407c-b1c6-38e89f4e774b
# ╠═b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
# ╠═92d55286-e273-41f2-a856-45f094ecbd33
# ╠═9d825afc-21de-4de5-b293-4e28638dc7cc
# ╠═397322c6-2d5b-4808-b243-1cd018e7150f
# ╠═e8bf2c23-e999-44af-ad2b-243bfc5c8f52
# ╠═4186d2eb-0da6-4f68-ba41-e92bf7423041
# ╠═eed9710f-ba5e-4961-8215-177a9d4c4752
# ╟─f3b7d46f-0fcc-4f68-9822-f83e977b87ee
# ╠═e5d12839-8167-4ddf-843f-f8ad0f682126
# ╟─7912192d-1528-48ce-9adc-7e6a26b25c51
# ╠═c69be00a-40d4-4c25-aa47-ffb38ccaecec
# ╠═b46e7129-72e7-470b-b7e8-4a30f5bed259
# ╟─975744de-7ab0-4bfa-abe5-3741ec7ec1cf
# ╟─5007aa03-6db0-4626-a73c-9172fef2c4ea
# ╠═630ba246-b5fb-4f9d-a9d2-b2edb471ada0
# ╟─be3a4933-516e-4867-a801-4df4f695432a
# ╠═5a492522-9db4-44bc-80d4-6aca529560de
# ╟─1e48a850-f92c-4a7e-aef8-8e52e45eba30
# ╠═d24c4ccc-70a3-4e37-a800-e57d54df3b48
# ╠═d684dc5e-d78d-484f-a820-317406d9a41a
# ╟─0e2360a8-0653-4faa-b909-1ab84ca9fbac
# ╠═f307de6d-f197-47d6-a1a6-b1262e7569e0
# ╠═d76d9e69-8830-4190-994f-49689d44b506
# ╠═243ce122-61cf-4697-9f13-1710afef8e5c
# ╠═25f64410-97d0-43f7-a8b1-de0983265a7c
# ╠═012242f9-962d-46fe-9619-46906d2d8478
# ╠═fe7b4804-e952-41ff-b2fd-20972035c747
# ╠═0e2aa152-976d-400b-ae25-71f37c90e01c
# ╠═e125fd83-5fd1-4c5c-b466-22fd3375ff4a
# ╠═901d3be7-9a5c-4638-98ca-b4bb0ce355ed
# ╠═595edaed-4a16-43f4-b3b2-4803f06f93e7
# ╠═b7f5a299-360e-455c-9886-bcd2b4791a25
# ╠═b30e0fb9-d505-41e5-8a7d-1e8f2cbc2bbc
# ╟─54aa6060-a605-4a05-83f1-2b672f1d148f
# ╠═fe2c3680-5b91-11ee-282c-c74d3b01ef9b
