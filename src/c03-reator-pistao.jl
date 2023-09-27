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

# ╔═╡ 67b0a6ab-c128-4ab6-b588-c2322b0e61e9
md"""
## Reatores em contra corrente

### Condição de troca térmica

No que se segue não se fará hipótese de que ambos os escoamentos se dão com o mesmo fluido ou que no caso de mesmo fluido as velocidades são comparáveis. Neste caso mais geral, o número de Nusselt de cada lado da interface difere e portanto o coeficiente de troca térmica. É portanto necessário estabelecer-se uma condição de fluxo constante na interface das malhas para assegurar a conservação global da energia no sistema... TODO (escrever, já programado)
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
## Estudo de caso I

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

    ĥ₁ = computehtc(; reactor..., fluid1..., u = operations1.u, verbose = false)
    ĥ₂ = computehtc(; reactor..., fluid1..., u = operations2.u, verbose = false)

    r₁ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations1.Tₚ,
        u = operations1.u,
        ĥ = ĥ₁,
        h = (T) -> 1.0fluid1.cₚ * T + 1000.0
    )

    r₂ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations2.Tₚ,
        u = operations2.u,
        ĥ = ĥ₂,
        h = (T) -> 3.0fluid1.cₚ * T + 1000.0,
    )

    return r₁ , r₂
end

# ╔═╡ 9c5365bc-5c88-4e9c-81d3-17586f6ccae3
begin
    @info "IncompressibleEnthalpyPFRModel methods"

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

    function enthalpyrate(r::IncompressibleEnthalpyPFRModel)
        ḣ(h, ṁ, T) = ṁ * (h(T[end]) - h(T[1]))
        return ḣ(enthalpyfn(r), massflowrate(r), temperature(r))
    end
end;

# ╔═╡ 8b677cdd-bd4e-447a-aa78-99b5cab810a6
begin
    @info "CounterFlowPFRModel methods"

    struct CounterFlowPFRModel
        myself::IncompressibleEnthalpyPFRModel
        neighbor::IncompressibleEnthalpyPFRModel
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
        # Energy conservation constraint!
        T1 = temperature(cf)
        T2 = neighbortemperature(cf)

        ĥ1 = cf.myself.ĥ
        ĥ2 = cf.neighbor.ĥ

        Tw1 = 0.5 * (T1[1:end-1] + T1[2:end])
        Tw2 = 0.5 * (T2[1:end-1] + T2[2:end])

        return (ĥ1 * Tw1 + ĥ2 * Tw2) / (ĥ1 + ĥ2)
    end

    function enthalpyresidual(cf::CounterFlowPFRModel)
        Δha = enthalpyrate(thisreactor(cf))
        Δhb = enthalpyrate(otherreactor(cf))
        return abs(Δhb + Δha) / abs(Δha)
    end
end;

# ╔═╡ 77bc010d-9f24-407c-b1c6-38e89f4e774b
begin
    @info "Solution auxiliary methods"

    function updatetemperature(A, b, a, T, S, f, h, α)
        b[1:end] = a * (2S - T[1:end-1] - T[2:end])
        b[1] += 2h(T[1])
        Tm = map(f, T[2:end], A\b)
        ΔT = (1-α) * (Tm - T[2:end])
        εm = maximum(abs.(ΔT))
        T[2:end] += ΔT
        return εm
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
end;

# ╔═╡ 2d296ee3-ed4b-422a-9573-d10bbbdce344
begin
    @info "Post-processing methods"

    "Ilustração padronizada para a simulação exemplo."
    function plotpfrpair(cf::CounterFlowPFRModel; ylims = (300, 400), loc = :rb)
        z1 = thisreactor(cf).mesh.z
        T1 = temperature(cf)
        T2 = neighbortemperature(cf)

        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        stairs!(ax, z1, T1, label = "r₁", color = :blue, step = :center)
        stairs!(ax, z1, T2, label = "r₂", color = :red, step = :center)
        ax.xticks = range(0.0, z1[end], 6)
        ax.yticks = range(ylims..., 6)
        ax.xlabel = "Posição [m]"
        ax.ylabel = "Temperatura [K]"
        xlims!(ax, (0, z1[end]))
        ylims!(ax, ylims)
        axislegend(position = loc)
        fig
    end
end;

# ╔═╡ b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
let
    r₁, r₂ = createprfpair(; N = 1000)
    cf = CounterFlowPFRModel(r₁, r₂)

    outerloop(cf;
        inner = 25,
        outer = 500,
        relax = 0.99,
        Δhmax = 1.0e-06,
        ΔTmax = 1.0e-08
    )

    # temperature(cf), neighbortemperature(cf)
    plotpfrpair(cf)
end

# ╔═╡ f3b7d46f-0fcc-4f68-9822-f83e977b87ee
md"""
## Estudo de caso II
"""

# ╔═╡ 975744de-7ab0-4bfa-abe5-3741ec7ec1cf
md"""
## Anexos
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

# ╔═╡ 0e2360a8-0653-4faa-b909-1ab84ca9fbac
md"""
### Dados
"""

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
# ╟─67b0a6ab-c128-4ab6-b588-c2322b0e61e9
# ╟─04cf5b92-d10b-43f5-8fc5-1e549105ef9d
# ╟─dcfd8b59-429f-4c99-9eae-1aa34fa87033
# ╟─9f94f21d-2805-4b30-8451-7b09b575081c
# ╟─cc1a6701-8907-440a-a77b-b89ec6abac65
# ╟─f1cc566b-87bb-42be-a0a5-c160f326817f
# ╟─9a529019-9cfc-4018-a7ce-051e6dbdd85e
# ╟─9c5365bc-5c88-4e9c-81d3-17586f6ccae3
# ╟─8b677cdd-bd4e-447a-aa78-99b5cab810a6
# ╟─77bc010d-9f24-407c-b1c6-38e89f4e774b
# ╟─2d296ee3-ed4b-422a-9573-d10bbbdce344
# ╟─b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
# ╟─f3b7d46f-0fcc-4f68-9822-f83e977b87ee
# ╟─975744de-7ab0-4bfa-abe5-3741ec7ec1cf
# ╠═e5d12839-8167-4ddf-843f-f8ad0f682126
# ╠═c69be00a-40d4-4c25-aa47-ffb38ccaecec
# ╠═630ba246-b5fb-4f9d-a9d2-b2edb471ada0
# ╟─0e2360a8-0653-4faa-b909-1ab84ca9fbac
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
# ╟─fe2c3680-5b91-11ee-282c-c74d3b01ef9b
