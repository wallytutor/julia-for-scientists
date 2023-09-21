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

    import PlutoUI
    PlutoUI.TableOfContents(title="Tópicos")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Reator pistão - Parte 1
"""

# ╔═╡ 53f1cba1-130f-4bb2-bf64-5e948b38b2c7
md"""
## Formulação na temperatura

[Lei do resfriamento de Newton](https://pt.wikipedia.org/wiki/Lei_do_resfriamento_de_Newton)

Os cálculos do [número de Nusselt](https://en.wikipedia.org/wiki/Nusselt_number)
"""

# ╔═╡ aa0f612f-377a-4a01-9db5-16e606cf8ef7
md"""
```math
\frac{d(\rho{}u)}{dz}=0
```

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

```math
\dot{Q}=\hat{h}A_{s}(T_{w}-T)=\hat{h}(Pdz)(T_{w}-T)
```
"""

# ╔═╡ d4daf57c-cbaf-4911-8688-d46c89b7d6cd
md"""
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
"""

# ╔═╡ bdd8cf33-6bce-4303-8d30-86719f9054de
md"""
```math
\rho{}u{}\frac{dh}{dz}+h\frac{d(\rho{}u)}{dz}=
\hat{h}\frac{P}{A_{c}}(T_{w}-T)
```

```math
\rho{}u{}c_{p}A_{c}\frac{dT}{dz}=
\hat{h}P(T_{w}-T)
```
"""

# ╔═╡ 80df79d6-c3ca-4afd-89df-d665c933731f
md"""
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
a_{1}(T_{E} - T_{P})=
a_{2}(T_{w}-T^{\star})
```

```math
a(T_{E} - T_{P})=
T_{w}-T^{\star}
```
"""

# ╔═╡ 04ce41bf-c0c4-4db5-8ced-df16a72eaf10
md"""
```math
T^{\star}=\frac{T_{E}+T_{P}}{2}
```

```math
2a(T_{E}-T_{P})=
2T_{w}-T_{E}-T_{P}
```

```math
2aT_{E} - 2aT_{P}=
2T_{w} - T_{E} - T_{P}
```

```math
2aT_{E} + T_{E}=
2aT_{P} - T_{P} + 2T_{w}
```

```math
(2a + 1)T_{E}=
(2a - 1)T_{P} + 2T_{w}
```
"""

# ╔═╡ 5ad7df94-f80c-4db5-acce-9d703c137ee2
md"""
```math
A^{+}T_{E}=A^{-}T_{P} + 1
```

```math
A^{\pm} = \frac{2a \pm 1}{2T_{w}}
```
"""

# ╔═╡ 4903552c-2daf-49f2-94af-f05f2bea2214
md"""
```math
A^{+}T_{P}=A^{-}T_{G} + 1
```

```math
A^{+}T_{P}=A^{-}(2T_{0}-T_{P}) + 1
```

```math
(A^{+}+A^{-})T_{P}=1 + 2A^{-}T_{0}
```

```math
C_{1}T_{P}=1 + 2A^{-}T_{0}
```
"""

# ╔═╡ 4cda6d02-a63e-4178-ab62-4b331eb8afb2
md"""
```math
\begin{bmatrix}
 C_{1}  &  0     &  0     & \dots  &  0      &  0      \\
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
1 + 2A^{-}T_{0} \\
1               \\
1               \\
\vdots          \\
1               \\
1               \\
\end{bmatrix}
```
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
        h .......................... $(h) W/(m².K)\
        """
    )

    return h
end

# ╔═╡ 74233232-e490-4d6e-b424-5228f0e680f6
fig = let
    data = readdlm("c01-reator-pistao/default-h2o/postprocess.dat", Float64)

    Γ = 2

    c = Conditions()

    ĥ = Γ * computehtc(c)

    fig, ax = reactorplot(; L = c.L)

    for N in [10, 100, 500]
        c.N = N
        δ = c.L / c.N

        r = c.R / 2δ
        a = (c.ρ * c.u * c.cₚ * r) / ĥ

        A⁺ = (2a + 1) / (2c.Tₛ)
        A⁻ = (2a - 1) / (2c.Tₛ)

        C₁ = A⁺ + A⁻
        C₂ = 2A⁻ * c.Tₚ

        d₀ = +A⁺ * ones(c.N)
        d₁ = -A⁻ * ones(c.N - 1)
        b = ones(c.N)

        d₀[1] = C₁
        b[1] = 1 + C₂

        M = spdiagm(0 => d₀, -1 => d₁)
        T = M \ b

        z = cellwalls(c.L, δ)[1:end-1]
        stairs!(ax, z, T, label = "N = $(c.N)", step = :post)

        global Tend = @sprintf("%.1f", T[end])
    end

    lines!(ax, data[:, 1], data[:, 2], color=:black, label = "CFD")

    ax.title = "Temperatura final = $(Tend) K"
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
    fig
end;

# ╔═╡ 2a5c963b-80c4-4f31-a997-542cef9a2f03
fig

# ╔═╡ a537a56b-9b46-4363-b462-e92d02f2aa35
macro warnonly(ex)
    quote
        try
            $(esc(ex))
        catch e
            @warn e
        end
    end
end

# ╔═╡ f9b1527e-0d91-490b-95f6-13b649fe61db
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─53f1cba1-130f-4bb2-bf64-5e948b38b2c7
# ╟─aa0f612f-377a-4a01-9db5-16e606cf8ef7
# ╟─d4daf57c-cbaf-4911-8688-d46c89b7d6cd
# ╟─bdd8cf33-6bce-4303-8d30-86719f9054de
# ╟─80df79d6-c3ca-4afd-89df-d665c933731f
# ╟─04ce41bf-c0c4-4db5-8ced-df16a72eaf10
# ╟─5ad7df94-f80c-4db5-acce-9d703c137ee2
# ╟─4903552c-2daf-49f2-94af-f05f2bea2214
# ╟─4cda6d02-a63e-4178-ab62-4b331eb8afb2
# ╠═74233232-e490-4d6e-b424-5228f0e680f6
# ╟─2a5c963b-80c4-4f31-a997-542cef9a2f03
# ╟─7c43c2e5-98da-4e35-8f06-1a301f02cfec
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─1cf0a5eb-6f80-4105-8f21-a731583a7665
# ╟─30f97d5b-e1de-4593-b451-1bd42156a4fc
# ╟─03dc6676-49f2-486d-a7f2-deac6ce83f29
# ╟─530a7c51-e3ad-429a-890f-136fa63ff404
# ╟─4ac709ca-586c-41f8-a239-90b4c885ad7e
# ╟─8b69fbf0-73f8-4297-b810-7cc17486712e
# ╟─cba4b197-9cbf-4c6d-9a5c-79dd212953dc
# ╟─f9687d19-1fc9-40b1-97b1-365b80061a1b
# ╟─a537a56b-9b46-4363-b462-e92d02f2aa35
# ╟─f9b1527e-0d91-490b-95f6-13b649fe61db
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
