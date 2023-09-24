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
    using DelimitedFiles
    using DocStringExtensions
    using Printf
    using Roots
    using SparseArrays: spdiagm
    using SparseArrays: SparseMatrixCSC

    import PlutoUI
    toc = PlutoUI.TableOfContents(title="Tópicos")

    macro warnonly(ex)
        quote
            try
                $(esc(ex))
            catch e
                @warn e
            end
        end
    end

    toc
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Reator pistão - Parte 1
"""

# ╔═╡ 53f1cba1-130f-4bb2-bf64-5e948b38b2c7
md"""
## Formulação na temperatura

No que se segue vamos implementar a forma mais simples de um reator pistão. Para este primeiro estudo o foco será dado apenas na solução da equação da energia. As etapas globais implementadas aqui seguem o livro de [Kee *et al.* (2017)](https://www.wiley.com/en-ie/Chemically+Reacting+Flow%3A+Theory%2C+Modeling%2C+and+Simulation%2C+2nd+Edition-p-9781119184874), seção 9.2.

Da forma simplificada como tratado, o problema oferece uma solução analítica na forma da [lei do resfriamento de Newton](https://pt.wikipedia.org/wiki/Lei_do_resfriamento_de_Newton), o que é útil para a verificação do problema. Os cálculos do número de Nusselt para avaliação do coeficiente de transferência de calor são providos nos anexos com expressões discutidas [aqui](https://en.wikipedia.org/wiki/Nusselt_number).

### Conservação da matéria

O reator em questão conserva a massa transportada, o que é matematicamente expresso pela ausência de variação axial do fluxo de matéria, ou seja

```math
\frac{d(\rho{}u)}{dz}=0
```

### Conservação da energia

```math
\frac{dE}{dt}=
\frac{dQ}{dt}+
\frac{dW}{dt}
\implies
\int_{\Omega}\rho{}e\mathbf{V}\cdotp\mathbf{n}dA_{c}=
\dot{Q}-
\int_{\Omega}p\mathbf{V}\cdotp\mathbf{n}dA_{c}
```

```math
\int_{\Omega}\rho{}h\mathbf{V}\cdotp\mathbf{n}dA_{c}=
\dot{Q}\qquad{}\text{aonde}\qquad{}h = e+\frac{p}{\rho}
```

```math
\int_{\Omega}\rho{}h\mathbf{V}\cdotp\mathbf{n}dA_{c}=
\int_{V}\nabla\cdotp(\rho{}h\mathbf{V})dV
```

### Lei constitutiva

```math
\dot{Q}=\hat{h}A_{s}(T_{w}-T)=\hat{h}(Pdz)(T_{w}-T)
```

```math
\int_{V}\nabla\cdotp(\rho{}h\mathbf{V})dV=
\hat{h}(Pdz)(T_{w}-T)
```

```math
\frac{d(\rho{}u{}h)}{dz}=
\hat{h}\frac{Pdz}{\delta{}V}(T_{w}-T)
\implies
\frac{d(\rho{}u{}h)}{dz}=
\hat{h}\frac{P}{A_{c}}(T_{w}-T)
```

``\delta{}V=A_{c}dz``

### Modelo do reator

```math
\rho{}u{}\frac{dh}{dz}+h\frac{d(\rho{}u)}{dz}=
\hat{h}\frac{P}{A_{c}}(T_{w}-T)
```

```math
\rho{}u{}c_{p}A_{c}\frac{dT}{dz}=
\hat{h}P(T_{w}-T)
```

### Formulação numérica

```math
\int_{T_P}^{T_N}\rho{}u{}c_{p}A_{c}dT=
\int_{0}^{\delta}\hat{h}{P}(T_{w}-T)dz
```

```math
\rho{}u{}c_{p}A_{c}\int_{T_P}^{T_E}dT=
\hat{h}{P}(T_{w}-T^{\prime})\int_{0}^{\delta}dz
```

```math
\rho{}u{}c_{p}A_{c}(T_{E} - T_{P})=
\hat{h}{P}\delta(T_{w}-T^{\star})
```

```math
a(T_{E} - T_{P})=
T_{w}-T^{\star}
```

### Relação de interpolação

```math
T^{\star}=\frac{T_{E}+T_{P}}{2}
```

Aplicando-se esta expressão na forma numérica final, após manipulação chega-se à

```math
(2a + 1)T_{E}=
(2a - 1)T_{P} + 2T_{w}
```

```math
A^{+}T_{E}=A^{-}T_{P} + 1
```

```math
A^{\pm} = \frac{2a \pm 1}{2T_{w}}
```

### Condição inicial

Sistema com condição imersa

```math
A^{+}T_{1}=1 + A^{-}T_{0}
```

### Forma matricial

```math
\begin{bmatrix} 
 A^{+}  &  0     &  0     & \dots  &  0      &  0      \\
-A^{-}  &  A^{+} &  0     & \dots  &  0      &  0      \\
 0      & -A^{-} &  A^{+} & \ddots &  0      &  0      \\
\vdots  & \ddots & \ddots & \ddots & \ddots  & \vdots  \\
 0      &  0     &  0     & -A^{-} &  A^{+}  &   0     \\
 0      &  0     &  0     &  0     & -A^{-}  &   A^{+} \\
\end{bmatrix}
\begin{bmatrix} 
T_{1}    \\
T_{2}    \\
T_{3}    \\
\vdots   \\
T_{N-1}  \\
T_{N}    \\
\end{bmatrix}
=
\begin{bmatrix} 
1 + A^{-}T_{0}  \\
1               \\
1               \\
\vdots          \\
1               \\
1               \\
\end{bmatrix}
```
"""

# ╔═╡ 86d9caa3-5b77-4f4a-888f-48d8423269ae
md"""
### Solução analítica


"""

# ╔═╡ 7c43c2e5-98da-4e35-8f06-1a301f02cfec
md"""
## Formulação na entalpia

### Modelo do reator

```math
\rho{}u{}\frac{dh}{dz}=
\hat{h}\frac{P}{A_{c}}(T_{w}-T)
```

### Formulação numérica

```math
\int_{h_P}^{h_N}\rho{}u{}A_{c}dh=
\int_{0}^{\delta}\hat{h}{P}(T_{w}-T)dz
```

Seguindo um procedimento de integração similar ao aplicado na formulação usando a temperatura chegamos a equação do fluxo

```math
h_{E} - h_{P}=
bT_{w}-bT^{\star}
```

### Relação de interpolação

```math
T^{\star}=\frac{T_{E}+T_{P}}{2}
```

Aplicando-se esta expressão na forma numérica final, após manipulação chega-se à

```math
2h_{E} - 2h_{P}=
2bT_{w}-bT_{E}-bT_{P}
```

Essa expressão permite a solução da entalpia e a atualização do campo de temperaturas se faz através da solução de uma equação não linear do tipo ``h(T_{P})-h_{P}=0`` por célula.
"""

# ╔═╡ 4ff853d4-6747-46ac-b569-55febe550a27
md"""
### Condição inicial

A condição inicial é conhecida na interface e coincide com a temperatura que é usada para o cálculo do fluxo de calor ``T^{\star}`` localmente

```math
T^{\star}=\frac{T_{1}+T_{0}}{2}
```

Substituindo essa expressão na forma linear do problema para a célula na fronteira produz

```math
2h_{1} = 2bT_{w}-bT_{1}-bT_{0} - 2h_{0}
```
"""

# ╔═╡ 8cf8d53e-aa26-4376-8973-be73791b90f4
md"""

### Forma matricial

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

```math
f_{i,j} = 2bT_{w} - b(T_{i}+T_{j})
```
"""

# ╔═╡ 7f826838-e7a7-4853-ac2e-d7ae6ca33da1
md"""
### Solução analítica

aa [^1]

[^1]: Neste caso a solução se aplica unicamente ao exemplo utilizado neste tópico. Isso se dá pela forma particular integrável da entalpia utilizada.
"""

# ╔═╡ eecddd3e-81b6-452b-876d-fd8e76f96684
struct EnthalpyPFR
    h::Function
    
    N::Int64
    M::Int64
    α::Float64
    ε::Float64
    
    T_old::Vector{Float64}
    T_new::Vector{Float64}
    
    A::SparseMatrixCSC{Float64, Int64}
    b::Vector{Float64}

    a::Float64
    Φ::Float64
    h₀::Float64
    
    function EnthalpyPFR(;
        h::Function,
        ρ::Float64,
        u::Float64,
        r::Float64,
        ĥ::Float64,
    
        Tₚ::Float64,
        Tₛ::Float64,
    
        N::Int64 = 20000,
        M::Int64 = 100,
        α::Float64 = 0.6,
        ε = 1.0e-08
    )
        T_old = Tₛ * ones(N+1)
        T_new = similar(T_old)
        
        T_old[1] = Tₚ
        T_new[1] = Tₚ

        b = zeros(N)
        A = spdiagm(-1 => -2 * ones(N - 1),
                     0 =>  2 * ones(N + 0))

        a = ĥ / (ρ * u * r)
        Φ = 2a * Tₛ
        h₀ = 2h(Tₚ)
        
        new(h, N, M, α, ε, T_new, T_old, A, b, a, Φ, h₀)
    end
end

# ╔═╡ fb8a77ab-5072-44a7-a94f-5dbb5d0b34ce
function underrelax(aold, anew, α)
    return (1-α) * anew + α * aold
end

# ╔═╡ b4ce7c35-b705-43e6-aee0-8bb4bea3aa7e
function temperature(s::EnthalpyPFR)
    f(Tₖ, hₖ) = find_zero(T->s.h(T)-hₖ, Tₖ)
    return f.(s.T_old[2:end], s.A \ s.b)
end

# ╔═╡ aef93e07-e205-441c-b930-0ed6a193dabe
function iterate(s::EnthalpyPFR)
    s.b[1:end] = s.Φ .- s.a * (s.T_old[1:end-1] + s.T_old[2:end])
    s.b[1] += s.h₀
    
    s.T_new[2:end] = temperature(s)
    s.T_old[2:end] = underrelax(s.T_old[2:end], s.T_new[2:end], s.α)

    return maximum(abs2.(s.T_old-s.T_new))
end

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
    end

    @doc """
    Condições compartilhadas pelos modelos.

    $(TYPEDFIELDS)
    """ Conditions
end

# ╔═╡ 96e44c91-06c3-4b9f-bdaa-55919d2e13f0
"Coordenadas dos limites das células [m]"
function cellwalls(L, δ)
    return collect(0.5δ:δ:L-0.5δ)
end

# ╔═╡ 530a7c51-e3ad-429a-890f-136fa63ff404
"Coordenadas dos centros das células [m]"
function cellcenters(L, δ)
    return collect(0.0:δ:L)
end

# ╔═╡ e08d8341-f3a5-4ff1-b18e-19e9a0757b24
"Integra reator pistão no espaço das temperaturas."
function solvethermalpfr(c, N, ĥ)
    δ = c.L / N
    r = c.R / 2δ
    a = (c.ρ * c.u * c.cₚ * r) / ĥ
    
    A⁺ = (2a + 1) / (2c.Tₛ)
    A⁻ = (2a - 1) / (2c.Tₛ)

    b = ones(N)
    b[1] = 1 + A⁻ * c.Tₚ

    M = spdiagm(-1 => -A⁻ * ones(N - 1),
                 0 => +A⁺ * ones(N + 0))
    
    z = cellcenters(c.L, δ)
    T = similar(z)

    T[1] = c.Tₚ
    T[2:end] = M \ b

    return z, T
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

# ╔═╡ 8b69fbf0-73f8-4297-b810-7cc17486712e
"Equação de Gnielinski para número de Nusselt"
function gnielinski_Nu(Re, Pr)
    function validate(Re, Pr)
        @assert 3000.0 <= Re <= 5.0e+06
        @assert 0.5 <= Pr <= 2000.0
    end

    @warnonly validate(Re, Pr)

    f = (0.79 * log(Re) - 1.64)^(-2)
    g = f / 8

    num = g * (Re - 1000) * Pr
    den = 1.0 + 12.7 * (Pr^(2/3)-1) * g^(1/2)
    return num / den
end

# ╔═╡ cba4b197-9cbf-4c6d-9a5c-79dd212953dc
"Equação de Dittus-Boelter para número de Nusselt"
function dittusboelter_Nu(Re, Pr, L, D; what = :heating)
    function validate(Re, Pr, L, D)
        @assert 10000.0 <= Re
        @assert 0.6 <= Pr <= 160.0
        @assert 10.0 <= L/D
    end

    @warnonly validate(Re, Pr, L, D)
    
    n = (what == :heating) ? 0.4 : 0.4
    return 0.023 * Re^(4/5) * Pr^n
end

# ╔═╡ f9687d19-1fc9-40b1-97b1-365b80061a1b
"Estima coeficient de troca convectiva do escoamento"
function computehtc(c; method = :g)
    D = 2c.R
    
    Pr = c.Pr
    Re = c.ρ * c.u * D / c.μ

    Nug = gnielinski_Nu(Re, Pr)
    Nud = dittusboelter_Nu(Re, Pr, c.L, D)
    
    if Re > 3000
        Nu = (method == :g) ? Nug : Nub
    else
        Nu = 3.66
    end

    k = c.cₚ * c.μ / Pr
    h = Nu * k / D

    println("""\
        Reynolds ................... $(Re)
        Nusselt (Gnielinsk) ........ $(Nug)
        Nusselt (Dittus-Boelter) ... $(Nud)
        Nusselt (usado aqui) ....... $(Nu)
        k .......................... $(k) W/(m.K)
        h .......................... $(h) W/(m².K)\
        """
    )

    return h
end

# ╔═╡ 74233232-e490-4d6e-b424-5228f0e680f6
let
    case = "fluent-reference"
    # case = "constant-properties"
    data = readdlm("c01-reator-pistao/$(case)/postprocess.dat", Float64)
    
    c = Conditions()
    ĥ = computehtc(c)

    fig, ax = reactorplot(; L = c.L)
    lines!(ax, data[:, 1], data[:, 2], color=:black, label = "CFD")
    Tend = -1
    
    for N in [10, 100, 500]
        z, T = solvethermalpfr(c, N, ĥ)
        stairs!(ax, z, T; label = "N = $(N)", step = :center)
        Tend = @sprintf("%.1f", T[end])
    end

    ax.title = "Temperatura final = $(Tend) K"
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
    fig
end

# ╔═╡ e8b9773c-be88-4d68-8874-060945ed08bf
figh, residuals = let
    case = "fluent-reference"
    # case = "constant-properties"
    data = readdlm("c01-reator-pistao/$(case)/postprocess.dat", Float64)
    
    c = Conditions()

    N = 20000
    δ = c.L / N
    
    s = EnthalpyPFR(;
        h = (T) -> c.cₚ * T,
        ρ = c.ρ,
        u = c.u,
        r = c.R / 2δ,
        ĥ = computehtc(c),
    
        Tₚ = c.Tₚ,
        Tₛ = c.Tₛ,
    
        N = 20000,
        M = 100,
        α = 0.6,
        ε = 1.0e-08
    )
    
    z = cellcenters(c.L, δ)
    
    niter = 1
    residuals = -1ones(s.M)

    @time while niter < s.M+1
        ε = residuals[niter] = iterate(s)
    
        if ε <= s.ε
            println("Converged after $(niter) iterations")
            break
        end
    
        niter += 1
    end

    T = s.T_old

    fig, ax = reactorplot(; L = c.L)
    lines!(ax, data[:, 1], data[:, 2], color=:black, label = "CFD")
    stairs!(ax, z, T; label = "N = $(N)", step = :center)
    ax.title = "Temperatura final = $(@sprintf("%.1f", T[end])) K"
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
    fig, residuals
end;

# ╔═╡ 11aadef3-2ab9-45f9-8e8b-f33c8f7d39e3
figh

# ╔═╡ 6e981934-8a73-4302-b810-f2ffb058eaf1
let
    # Improve axes limits/ticks!
    r  = residuals[residuals .> 0]
    n = length(r)
    fig = Figure(resolution = (720, 500))
    ax = Axis(fig[1, 1],
              ylabel = "log10(r)",
              xlabel = "Iteração")
    xlims!(ax, (1, n))
    lines!(ax, log10.(r))

    ax.xticks = 0:5:n
    ax.yticks = range(-8, 4, 13)
    xlims!(ax, (0, n))
    ylims!(ax, (-8, 4))
    fig
end

# ╔═╡ f9b1527e-0d91-490b-95f6-13b649fe61db
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─53f1cba1-130f-4bb2-bf64-5e948b38b2c7
# ╟─86d9caa3-5b77-4f4a-888f-48d8423269ae
# ╠═e08d8341-f3a5-4ff1-b18e-19e9a0757b24
# ╠═74233232-e490-4d6e-b424-5228f0e680f6
# ╟─7c43c2e5-98da-4e35-8f06-1a301f02cfec
# ╟─4ff853d4-6747-46ac-b569-55febe550a27
# ╟─8cf8d53e-aa26-4376-8973-be73791b90f4
# ╟─7f826838-e7a7-4853-ac2e-d7ae6ca33da1
# ╠═eecddd3e-81b6-452b-876d-fd8e76f96684
# ╠═fb8a77ab-5072-44a7-a94f-5dbb5d0b34ce
# ╠═b4ce7c35-b705-43e6-aee0-8bb4bea3aa7e
# ╠═aef93e07-e205-441c-b930-0ed6a193dabe
# ╠═e8b9773c-be88-4d68-8874-060945ed08bf
# ╟─11aadef3-2ab9-45f9-8e8b-f33c8f7d39e3
# ╟─6e981934-8a73-4302-b810-f2ffb058eaf1
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─1cf0a5eb-6f80-4105-8f21-a731583a7665
# ╟─30f97d5b-e1de-4593-b451-1bd42156a4fc
# ╟─96e44c91-06c3-4b9f-bdaa-55919d2e13f0
# ╟─530a7c51-e3ad-429a-890f-136fa63ff404
# ╟─4ac709ca-586c-41f8-a239-90b4c885ad7e
# ╟─8b69fbf0-73f8-4297-b810-7cc17486712e
# ╟─cba4b197-9cbf-4c6d-9a5c-79dd212953dc
# ╟─f9687d19-1fc9-40b1-97b1-365b80061a1b
# ╟─f9b1527e-0d91-490b-95f6-13b649fe61db
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
