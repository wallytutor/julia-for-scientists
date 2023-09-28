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

# ╔═╡ 2f088bd3-184d-41a3-9254-8fa458d8ccaf
const fluid3 = notedata.c03.fluid3

# ╔═╡ cc1a6701-8907-440a-a77b-b89ec6abac65
const operations1 = notedata.c03.operations1

# ╔═╡ f1cc566b-87bb-42be-a0a5-c160f326817f
const operations2 = notedata.c03.operations2

# ╔═╡ 04cf5b92-d10b-43f5-8fc5-1e549105ef9d
md"""
## Casos exemplo

O par escolhido para exemplificar o comportamento de contra-corrente dos reatores
pistão tem por característica de que cada reator ocupa a metade de um cilindro de diâmetro `D` = $(reactor.D) m de forma que o perímetro de troca é igual o diâmetro e a área transversal a metade daquela do cilindro. A temperatura inicial do fluido no reator (1) que escoa da esquerda para a direita é de $(operations1.Tₚ) K e naquele em contra-corrente (2) é de $(operations2.Tₚ) K.

O fluido do reator (2) tem um calor específico que é o triplo daquele do reator (1).
"""

# ╔═╡ eecf85b0-180c-49c5-83ab-619ba6683960
const operations3 = notedata.c03.operations3

# ╔═╡ 9a529019-9cfc-4018-a7ce-051e6dbdd85e
"Cria um par padronizado de reatores para simulação exemplo."
function createprfpair1(; N = 10)
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

# ╔═╡ 7afff466-5463-431f-b817-083fe6102a8c
"Cria um par padronizado de reatores para simulação exemplo."
function createprfpair2(; N = 10)

    # "Mass específica do fluido [kg/m³]"
    # const ρˡ::Float64 = 1000.0
    # "Mass específica do sólido [kg/m³]"
    # const ρˢ::Float64 = 3000.0
    # "Calor específico do fluido [J/(kg.K)]"
    # const cₚˡ::Float64 = 4182.0
    # "Variação de entalpia do sólido [J/(kg.K)]"
    # const hˢ = (T) -> 900.0T

    p₃ = 101325.0
    T₃ = operations3.Tₚ
    h₃ = integrate(fluid3.cₚpoly(T₃))
    M̄₃ = 0.02897530345830224
    ρ₃ = (p₃ * M̄₃) / (GAS_CONSTANT * T₃)

    fluid₃ = (
            ρ = ρ₃,
            μ = fluid3.μpoly(T₃),
            cₚ = fluid3.cₚpoly(T₃),
            Pr = fluid3.Pr
    )

    # ratio = 1.5
    # ṁ3 = ρ3 * operations3.u * A
    # ṁ1 = ratio * ṁᵍ
    # u1 = ṁ1 / (ρ1 * A)

    shared = (
        N = N,
        L = reactor.L,
        P = reactor.D,
        A = 0.5π * (reactor.D/2)^2,
        ρ = fluid1.ρ
    )


    ĥ₁ = computehtc(; reactor..., fluid1..., u = operations1.u, verbose = false)
    ĥ₃ = computehtc(; reactor..., fluid₃..., u = operations3.u, verbose = false)

    r₁ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations1.Tₚ,
        u = operations1.u,
        ĥ = ĥ₁,
        h = (T) -> 1.0fluid1.cₚ * T + 1000.0
    )

    r₃ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations3.Tₚ,
        u = operations3.u,
        ĥ = ĥ₃,
        h = (T) -> h₃(T),
    )

    return r₁ , r₃
end

# ╔═╡ 7a278913-bf0f-4532-9c9b-f42aded9b6e9
md"""
## Estudo de caso I
"""

# ╔═╡ f3b7d46f-0fcc-4f68-9822-f83e977b87ee
md"""
## Estudo de caso II
"""

# ╔═╡ 975744de-7ab0-4bfa-abe5-3741ec7ec1cf
md"""
## Anexos
"""

# ╔═╡ 8b677cdd-bd4e-447a-aa78-99b5cab810a6
begin
    @info "to go to module"

    struct CounterFlowPFRModel
        this::IncompressibleEnthalpyPFRModel
        that::IncompressibleEnthalpyPFRModel
    end

    function swap(cf::CounterFlowPFRModel)
        return CounterFlowPFRModel(cf.that, cf.this)
    end

    function coordinates(cf::CounterFlowPFRModel)
        return cf.this.mesh.z
    end

    function thistemperature(cf::CounterFlowPFRModel)
        return cf.this.fvdata.x |> identity
    end

    function thattemperature(cf::CounterFlowPFRModel)
        return cf.that.fvdata.x |> reverse
    end

    function surfacetemperature(cf::CounterFlowPFRModel)
        # Energy conservation constraint!
        T1 = thistemperature(cf)
        T2 = thattemperature(cf)

        ĥ1 = cf.this.ĥ
        ĥ2 = cf.that.ĥ

        Tw1 = 0.5 * (T1[1:end-1] + T1[2:end])
        Tw2 = 0.5 * (T2[1:end-1] + T2[2:end])

        return (ĥ1 * Tw1 + ĥ2 * Tw2) / (ĥ1 + ĥ2)
    end

    function enthalpyresidual(cf::CounterFlowPFRModel)
        function enthalpyrate(r)
            T₁, T₀ = r.fvdata.x[[1, end]]
            return r.ṁ * (r.enthalpy(T₁) - r.enthalpy(T₀))
        end

        Δha = enthalpyrate(cf.this)
        Δhb = enthalpyrate(cf.that)
        return abs(Δhb + Δha) / abs(Δha)
    end

    function getrootfinder(h::Function)::Function
        return (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ)
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

    function innerloop(;
        cf::CounterFlowPFRModel,
        M::Int64 = 1,
        α::Float64 = 0.95,
        ε::Float64 = 1.0e-08
    )::Nothing
        S = surfacetemperature(cf)

        r = cf.this
        T = r.fvdata.x
        A = r.fvdata.A
        b = r.fvdata.b
        a = r.fvdata.c[1]
        h = r.enthalpy

        f = getrootfinder(r.enthalpy)

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
        rb = swap(ra)

        maxsteps = outer * inner
        residualsa = -ones(maxsteps)
        residualsb = -ones(maxsteps)

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
"Ilustração padronizada para a simulação exemplo."
function plotpfrpair(cf::CounterFlowPFRModel; ylims = (300, 400), loc = :rb)
    z1 = coordinates(cf)
    T1 = thistemperature(cf)
    T2 = thattemperature(cf)

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
    return fig
end

# ╔═╡ b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
let
    r₁, r₂ = createprfpair1(; N = 500)
    cf = CounterFlowPFRModel(r₁, r₂)

    outerloop(cf;
        inner = 25,
        outer = 500,
        relax = 0.99,
        Δhmax = 1.0e-06,
        ΔTmax = 1.0e-08
    )

    plotpfrpair(cf)
end

# ╔═╡ 9f1357f1-1e7b-4f55-9f4b-cc6a1fd3e2aa
let
    r₁, r₂ = createprfpair2(; N = 500)
    cf = CounterFlowPFRModel(r₁, r₂)

    outerloop(cf;
        inner = 25,
        outer = 500,
        relax = 0.99,
        Δhmax = 1.0e-06,
        ΔTmax = 1.0e-08
    )

    plotpfrpair(cf)
end

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
# ╟─2f088bd3-184d-41a3-9254-8fa458d8ccaf
# ╟─cc1a6701-8907-440a-a77b-b89ec6abac65
# ╟─f1cc566b-87bb-42be-a0a5-c160f326817f
# ╟─eecf85b0-180c-49c5-83ab-619ba6683960
# ╟─9a529019-9cfc-4018-a7ce-051e6dbdd85e
# ╠═7afff466-5463-431f-b817-083fe6102a8c
# ╟─7a278913-bf0f-4532-9c9b-f42aded9b6e9
# ╟─b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
# ╟─f3b7d46f-0fcc-4f68-9822-f83e977b87ee
# ╟─9f1357f1-1e7b-4f55-9f4b-cc6a1fd3e2aa
# ╟─975744de-7ab0-4bfa-abe5-3741ec7ec1cf
# ╟─8b677cdd-bd4e-447a-aa78-99b5cab810a6
# ╟─2d296ee3-ed4b-422a-9573-d10bbbdce344
# ╟─54aa6060-a605-4a05-83f1-2b672f1d148f
# ╟─fe2c3680-5b91-11ee-282c-c74d3b01ef9b
