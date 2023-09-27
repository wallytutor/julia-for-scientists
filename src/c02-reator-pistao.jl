### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ ea183591-cc73-44cc-b1d0-572cf24d5b6b
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using DifferentialEquations: solve
    using DocStringExtensions
    using ModelingToolkit
    using Printf
    using Roots
    using SparseArrays: spdiagm
    using SparseArrays: SparseMatrixCSC
    import PlutoUI
    
    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ 0c42a060-5cf5-11ee-273c-b16c31ed2b48
md"""
# Reator pistão - Parte 2

Neste notebook damos continuidade ao precedente através da extensão do modelo para a resolução da conservação de energia empregando a entalpia do fluido como variável independente. O caso tratado será o mesmo da *Parte 1* para que possamos ter uma base de comparação da solução.

$(toc)
"""

# ╔═╡ eaed30cf-e984-4ae6-8eb8-43ba533c23ee
md"""
## Modelo na entalpia

Em diversos casos a forma expressa na temperatura não é conveniente. Esse geralmente é o caso quando se inclui transformações de fase no sistema. Nessas situações a solução não suporta integração direta e devemos recorrer a um método iterativo baseado na entalpia. Isso se dá pela adição de uma etapa suplementar da solução de equações não lineares para se encontrar a temperatura à qual a entalpia corresponde para se poder avaliar as trocas térmicas.

Para se efetuar a integração partimos do modelo derivado anteriormente numa etapa antes da simplificação final para solução na temperatura e já agrupamos os parâmetros livres em ``a``

```math
\frac{dh}{dz}=\frac{\hat{h}P}{\rho{}u{}A_{c}}(T_{s}-T^{\star})=a(T_{s}-T^{\star})
```

É interessante observar que toda a discussão precedente acerca de porque não integrar sobre ``T^{\star}`` perde seu sentido aqui: a temperatura é claramente um parâmetro.

```math
\int_{h_P}^{h_N}dh=a^{\prime}\int_{0}^{\delta}(T_{s}-T^{\star})dz
```

Seguindo um procedimento de integração similar ao aplicado na formulação usando a temperatura chegamos a equação do fluxo fazendo ``a=a^{\prime}\delta``

```math
h_{E}-h_{P}=aT_{s}-aT^{\star}
```

Seguindo a mesma lógica discutida na formulação na temperatura, introduzimos a relação de interpolação ``T^{\star}=(1/2)(T_{E}+T_{P})`` e aplicando-se esta expressão na forma numérica final, após manipulação chega-se à

```math
-2h_{P}+2h_{E}=2aT_{s}-aT_{E}-aT_{P}
```

Essa expressão permite a solução da entalpia e a atualização do campo de temperaturas se faz através da solução de uma equação não linear do tipo ``h(T_{P})-h_{P}=0`` por célula.

Substituindo a temperatura inicial ``T_{0}`` e sua entalpia associada ``h_{0}`` na forma algébrica do problema encontramos a primeira linha da matriz que explicita as modificações para se implementar a condição inicial do problema

```math
2h_{1}=2aT_{s}-aT_{1}-aT_{0}-2h_{0}
```

Completamos assim as derivações para se escrever a forma matricial

```math
\begin{bmatrix}
 2      &  0     &  0     & \dots  &  0      &  0      \\
-2      &  2     &  0     & \dots  &  0      &  0      \\
 0      & -2     &  2     & \ddots &  0      &  0      \\
\vdots  & \ddots & \ddots & \ddots & \ddots  & \vdots  \\
 0      &  0     &  0     & -2     &  2      &  0     \\
 0      &  0     &  0     &  0     & -2      &  2 \\
\end{bmatrix}
\begin{bmatrix}
h_{1}    \\
h_{2}    \\
h_{3}    \\
\vdots   \\
h_{N-1}  \\
h_{N}    \\
\end{bmatrix}
=
\begin{bmatrix}
f_{0,1} + 2h(T_{0}) \\
f_{1,2}     \\
f_{2,3}      \\
\vdots                       \\
f_{N-2,N-1}  \\
f_{N-1,N}    \\
\end{bmatrix}
```

No vetor do lado direito introduzimos uma função de ``f`` dada por

```math
f_{i,j} = 2aT_{s} - a(T_{i}+T_{j})
```
"""

# ╔═╡ da2429b7-5dd5-44f4-a5ec-d60b69100fb6
md"""
## Solução em volumes finitos

A solução neste caso foi implementada numa estrutura `EnthalpyPFR`. Como as temperaturas usadas no lado direito da equação não são conhecidas inicialmente, o problema tem um carater iterativo intrínsico. Initializamos o lado direito da equação para em seguida resolver o problema na entalpia, que deve ser invertida (equações não lineares) para se atualizar as temperaturas. Isso se repete até que a solução entre duas iterações consecutivas atinja um *critério de convergência*.
"""

# ╔═╡ 548a5654-47bf-42d4-bfb6-38e1c2860c32
"Representa um reator pistão formulado na entalpia.

$(TYPEDFIELDS)
"
struct EnthalpyPFR
    "Vetor das coordenadas das células do reator."
    z::Vector{Float64}

    "Temperatura do fluido das células do reator."
    T::Vector{Float64}

    "Vetor para estocagem dos residuos nas iterações."
    residual::Vector{Float64}

    "A chamada do objeto retorna a solução."
    function (model::EnthalpyPFR)()
        return model.z, model.T, model.residual
    end

    """
    Construtor interno do modelo de reator.

        h  : Função entalpia [J/kg].
        P  : Perímetro da seção [m].
        A  : Área da seção [m²].
        Tₛ : Temperatura da superfície do reator [K].
        Tₚ : Temperatura inicial do fluido [K].
        ĥ  : Coeficiente de troca convectiva [W/(m².K)].
        u  : Velocidade do fluido [m/s].
        ρ  : Densidade do fluido [kg/m³].
        L  : Comprimento do reator [m].
        N  : Número de células no sistema, incluindo limites.
        M  : Máximo número de iterações para a solução.
        α  : Fator de relaxação da solução entre iterações.
        ε  : Tolerância absoluta da solução.
    """
    function EnthalpyPFR(;
        h::Function,
        P::Float64,
        A::Float64,
        Tₛ::Float64,
        Tₚ::Float64,
        ĥ::Float64,
        u::Float64,
        ρ::Float64,
        L::Float64,
        N::Int64,
        M::Int64 = 100,
        α::Float64 = 0.4,
        ε::Float64 = 1.0e-10,
    )
        # Comprimento de uma célula.
        δ = L / N

        # Alocação das coordenadas do sistema.
        z = cellcenters(L, δ)

        # Alocação da solução com a condição inicial.
        T = Tₚ * ones(N + 1)

        # Alocação a matrix de diferenças.
        K = 2spdiagm(-1 => -ones(N - 1), 0 => ones(N))

        # Constante do modelo.
        a = (ĥ * P * δ) / (ρ * u * A)

        # Alocação do vetor do lado direito da equação.
        b = (2a * Tₛ) * ones(N)
        b[1] += 2h(Tₚ)

        # Aloca e inicia em negativo o vetor de residuos. Isso
        # é interessante para o gráfico aonde podemos eliminar
        # os elementos negativos que não tem sentido físico.
        residual = -ones(M)

        # Resolve o problema iterativamente.
        niter = 0

        @time while (niter < M)
            niter += 1

            # Calcula o vetor `b` do lado direito e resolve o sistema. O bloco
            # comentado abaixo implementa uma versão com `RollingFunctions` que
            # acaba sendo muito mais lenta dada uma alocação maior de memória.
            # h̄ = K \ (b - a * rolling(sum, T, 2))
            h̄ = K \ (b - a * (T[1:end-1] + T[2:end]))

            # Encontra as novas temperaturas resolvendo uma equação não-linear
            # para cada nova entalpia calculada resolvendo `A*h=b`.
            U = map((Tₖ, hₖ) -> find_zero(T -> h(T) - hₖ, Tₖ), T[2:end], h̄)

            # Relaxa a solução para evitar atualizações bruscas. Como o cálculo
            # se faz por `T=(1-α)*U+α*T`, podemos simplificar as operações com:
            # Tn = (1-α)*U + α*Tm ⟹ ΔT = Tn - Tm = (1-α)*(U-Tm), logo
            # Tn = Tm + ΔT, e o resíduo fica ε = max(|ΔT|).

            # Incremento da solução.
            Δ = (1-α) * (U - T[2:end])

            # Relaxa solução para evitar divergência.
            T[2:end] += Δ

            # Verica progresso da solução.
            residual[niter] = maximum(abs.(Δ))

            # Verifica status da convergência.
            if (residual[niter] <= ε)
                println("Converged after $(niter) iterations")
                break
            end
        end

        return new(z, T, residual)
    end
end

# ╔═╡ bd79aef3-2634-48b2-b06c-2f0185ebc3ac
md"""
Usamos agora essa estrutura para uma última simulação do mesmo problema. Para que os resultados sejam comparáveis as soluções precedentes, fizemos ``h(T) = c_{p}T + h_{ref}``. O valor de ``h_{ref}`` é arbitrário e não deve afetar a solução por razões que deveriam ser evidentes neste ponto do estudo.
"""

# ╔═╡ 4fd5e5e0-8cd7-4d9b-88b8-ce2dbbbfef66
# fig

# ╔═╡ 07ce85f9-b2f2-4008-b8ae-0e417e22347c
# residual, fig = let
#     c = Conditions()
#     N = 10000

#     z = cellcenters(c.L, c.L / N)
#     ĥ = computehtc(c)

#     P = 2π * c.R
#     A = π * c.R^2

#     pars1 = (P = P, A = A, Tₛ = c.Tₛ, Tₚ = c.Tₚ, ĥ = ĥ, u = c.u, ρ = c.ρ)
#     pars2 = (cₚ = c.cₚ, z = z)

#     model = DifferentialEquationPFR()
#     Tₐ = analyticalthermalpfr(; pars1..., pars2...)

#     pfr = EnthalpyPFR(; h = (T) -> c.cₚ * T + 1000, pars1..., L = c.L, N = N)
#     x, Tₙ, residual = pfr()

#     fig, ax = reactorplot(; L = c.L)
#     lines!(ax, z, Tₐ, color = :red, linewidth = 4, label = "Analítica")
#     stairs!(ax, x, Tₙ, color = :black, linewidth = 1, label = "Numérica", step = :center)
#     reactoraxes(@sprintf("%.2f", Tₙ[end]), ax)
#     residual, fig
# end;

# ╔═╡ 2ff750d6-8680-44cd-a873-bc6f9ac9a383
md"""
Verificamos acima que a solução levou um certo número de iterações para convergir. Para concluir vamos averiguar a qualidade da convergência ao longo das iterações.
"""

# ╔═╡ c4b7cfe3-37a8-4619-b8c9-3d506f74468b
# let
#     r = residual[residual.>0]
#     n = length(r)

#     fig = Figure(resolution = (720, 500))
#     ax = Axis(fig[1, 1], ylabel = "log10(r)", xlabel = "Iteração")
#     xlims!(ax, (1, n))
#     lines!(ax, log10.(r))

#     ax.xticks = 0:5:n
#     ax.yticks = range(-15, 5, 5)
#     xlims!(ax, (0, n))
#     ylims!(ax, (-15, 5))
#     fig
# end

# ╔═╡ 5c97795c-fc24-409b-ac15-7fafebf6153b
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/).
"""

# ╔═╡ b272c7d6-1697-4805-bcb4-73ca02de4b1c
md"""
## Anexos
"""

# ╔═╡ 97f56fc2-bbb0-4cde-8d55-751160dea9a1


# ╔═╡ 7158a6ea-48ec-4b19-81db-1317198cc980
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─0c42a060-5cf5-11ee-273c-b16c31ed2b48
# ╟─eaed30cf-e984-4ae6-8eb8-43ba533c23ee
# ╟─da2429b7-5dd5-44f4-a5ec-d60b69100fb6
# ╟─548a5654-47bf-42d4-bfb6-38e1c2860c32
# ╟─bd79aef3-2634-48b2-b06c-2f0185ebc3ac
# ╠═4fd5e5e0-8cd7-4d9b-88b8-ce2dbbbfef66
# ╠═07ce85f9-b2f2-4008-b8ae-0e417e22347c
# ╟─2ff750d6-8680-44cd-a873-bc6f9ac9a383
# ╠═c4b7cfe3-37a8-4619-b8c9-3d506f74468b
# ╟─5c97795c-fc24-409b-ac15-7fafebf6153b
# ╟─b272c7d6-1697-4805-bcb4-73ca02de4b1c
# ╠═97f56fc2-bbb0-4cde-8d55-751160dea9a1
# ╟─7158a6ea-48ec-4b19-81db-1317198cc980
# ╠═ea183591-cc73-44cc-b1d0-572cf24d5b6b
