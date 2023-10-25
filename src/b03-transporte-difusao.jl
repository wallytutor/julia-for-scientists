### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 73b13fb0-62b6-11ee-27bf-69788069829a
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using LinearAlgebra
    using Printf
    using Trapz
    import PlutoUI

    toc = PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ f6cdb233-9b99-48ff-bce4-4f359a35f591
begin
    include("util-residuos.jl")
    include("util-geral.jl")
end

# ╔═╡ 30c163e1-4af6-4776-887b-2835cf488407
md"""
# Aplicação ao tratamento de materiais

$(toc)
"""

# ╔═╡ f3f32e4b-5ebd-4ce1-bc42-907eb54789e7


# ╔═╡ c20a6318-26a3-4971-be92-bfc1c79d8c3f
md"""
## Materiais
"""

# ╔═╡ 01fde065-7081-4255-9a52-a69c2c9f4afb
"Espessura das placas tratadas [m]"
const L = 0.004

# ╔═╡ 1a1aaeb6-060a-4352-bf93-aa2b3c665119
@bind go PlutoUI.Button("Go!")

# ╔═╡ 6b169165-92ab-4386-802e-ce7d11c0a471
function outerloop()

end

# ╔═╡ 7fc69ea4-015f-4913-94ff-e3e0820af12b
md"""
## Carbonitretação austenítica
"""

# ╔═╡ 0e077ba1-e451-4982-a6bd-a3fc7f2c6a89
md"""
## Anexos
"""

# ╔═╡ 1eecfc46-2403-4378-95bc-7cd0807b50df
md"""
### Modelos
"""

# ╔═╡ a28e78ec-fcef-4ab5-8b65-9260c3cfd8a4
struct CarburizingModel

end

# ╔═╡ f3c9aea8-653d-49c2-a806-0d1b3a263012
md"""
### Gráficos
"""

# ╔═╡ fe489f21-c657-465a-b8a9-948dfc93051b
"Ilustra perfis de difusão calculados."
function plotprofile(;
        z::Vector{Float64},
        yc,
        yc₀,
        yn,
        yn₀,
        ρ::Float64 = 7890.0,
        showstairs::Bool = false
    )
	σ₀ = yc₀ * last(z) / (1 - yc₀)
	σ₁ = trapz(z, @. yc / (1 - yc))
	m = 1000ρ  * (σ₁ - σ₀)

    xticks = 0.0:0.3:1000z[end]
    yticks = 0.0:0.2:1.2

    fig = Figure(resolution = (720, 500))

    ax = Axis(fig[1, 1])
    ax.xlabel = "Posição [mm]"
    ax.ylabel = "Porcentagem mássica [%]"
    ax.title = "Ganho de massa $(@sprintf("%.1f", m)) g/m²"
    ax.xticks = xticks
    ax.yticks = yticks

    xlims!(ax, extrema(xticks))
    ylims!(ax, extrema(yticks))

    lines!(ax,  1000z, 100yc)

    if showstairs
        stairs!(ax, 1000z, 100yc, color = :black, step = :center)
    end

    return fig
end

# ╔═╡ 8b9cf875-78b6-466a-9e43-f3eceb8d027a
"Ilustra residuais do problema ao longo das iterações."
function plotresiduals(r, ε; yticks = -13:2:-1)
    xg = 1:r.counter
    yg = log10.(r.residuals)

    xs = r.finalsteps
    ys = log10.(r.finalresiduals)

    δi = closestpowerofx(xg[end]/10; x = 10)
    imax = closestpowerofx(xg[end]; x = 10)
    xticks = 0:δi:imax

    fig = Figure(resolution = (720, 500))

    ax = Axis(fig[1, 1], yscale = identity)
    ax.xlabel = "Iteração global"
    ax.ylabel = "log10(Resíduo)"
    ax.title = "Máximo de iterações $(maximum(r.innersteps)) por passo de tempo"
    ax.xticks = xticks
    ax.yticks = yticks

    xlims!(ax, extrema(xticks))
    ylims!(ax, extrema(yticks))

    lines!(ax, xg, yg, color = :black, linewidth = 0.5)
    scatter!(ax, xs, ys, color = :red)

    hlines!(ax, log10(ε), color = :blue, linewidth = 2)

    fig
end

# ╔═╡ f9a24b0f-d820-48d1-a048-853dd994a249
md"""
### Outras
"""

# ╔═╡ 63a9fa87-92f1-444a-8bcf-dde5d682e099
begin
    @info "Opções compartilhadas pelos *sliders*"
    rngN = [10, 100, 200, 500, 1000, 2000, 10000]
    rngM = [10, 20, 50, (100:100:10000)...]
    rngt = 1800:600:10800
    rngI = 1:1:100
    rngh = -8:1:0
    rngT = 1123.15:25.0:1273.15
    rngα = 0.0:0.05:1.0
    rngε = -15:1:-2
end;

# ╔═╡ 8fe591cd-f3f7-4cf8-8d91-92c6dff1dd01
begin
    @info "Funções secundárias específicas ao notebook"

    function masstomolefraction(w)
        return w * (w / 0.012 + (1 - w) / 0.055)^(-1) / 0.012
    end

    function moletomassfraction(x)
        return 0.012 * x / (0.012*x + (1 - x) * 0.055)
    end
end;

# ╔═╡ 75d6913c-bf90-4b1c-9fdd-0e9e9c9e26f6
"Fração molar em carbono na liga."
const aeroc = masstomolefraction(0.0016)

# ╔═╡ 50545d72-c312-437f-94c2-8c907327f17b
"Fração molar em carbono na liga."
const autoc = masstomolefraction(0.0023)

# ╔═╡ 518e9825-dea1-4c8f-9395-d21b33e386e3
md"""
## Cementação austenítica

Parâmetros de solução:

|______________________________|_______________________|
|:-----------------------------|:----------------------|
| $(@bind N PlutoUI.Slider(rngN, default=2000, show_value=true)) | Volumes de controle
| $(@bind M PlutoUI.Slider(rngM, default=20,   show_value=true)) | Passos de tempo
| $(@bind I PlutoUI.Slider(rngI, default=50,   show_value=true)) | Iterações por passo
| $(@bind α PlutoUI.Slider(rngα, default=0.5,  show_value=true)) | Relaxação
| $(@bind ε PlutoUI.Slider(rngε, default=-8,   show_value=true)) | Expoente da tolerância

Parâmetros físicos

|______________________________|_______________________|
|:-----------------------------|:----------------------|
$(@bind C PlutoUI.Select([aeroc=>"16NiCrMo13", autoc=>"23MnCrMo5"])) | Liga
$(@bind t PlutoUI.Slider(rngt, default=7200,   show_value=true)) | Duração física [s]
$(@bind h PlutoUI.Slider(rngh, default=0,      show_value=true)) | Expoente de hₘ
$(@bind T PlutoUI.Slider(rngT, default=1173.0, show_value=true)) | Temperatura [K]

"""

# ╔═╡ 89dfc30a-f103-496a-b794-f341b53f09dc
"Fração molar em carbono equivalente ao potencial da atmosfera."
const aero∞ = masstomolefraction(0.0100)

# ╔═╡ 995acd5a-7dc1-42fd-ad12-e7fbef516f12
"Fração molar em carbono equivalente ao potencial da atmosfera."
const auto∞ = masstomolefraction(0.0095)

# ╔═╡ efed88fb-9b89-4896-acc3-cec5f3462978
begin
    const R = 8.314_462_618_153_24

    struct HalfCellBoundaryFVM
        "Coordenadas dos centros das células [m]."
        z::Vector{Float64}

        "Coordenadas dos limites das células [m]."
        w::Vector{Float64}

        "Comprimento de uma célula [m]."
        δ::Float64

        function HalfCellBoundaryFVM(; L::Float64, N::Int64)
            δ = L / N
            z = collect(0.0:δ:L)
            w = collect(0.5δ:δ:L-0.5δ)
            return new(z, w, δ)
        end
    end

    function diffcoef₁(T::Float64, x₁::Float64)::Float64
        A = 4.84e-05exp(-38.0x₁) / (1.0 - 5.0x₁)
        E = 155_000.0 - 570_000.0x₁
        return A * exp(- E / (R * T))
    end

    function harmonic(k::Vector{Float64})::Vector{Float64}
        ke, kw = k[1:end-1], k[2:end-0]
        return @. 2 * ke * kw / (ke + kw)
    end

    function createproblem(N)
        A = Tridiagonal(zeros(N-1), zeros(N), zeros(N-1))
        b = zeros(N)
        return A, b
    end

    function updatematrix!(
            M::Tridiagonal{Float64, Vector{Float64}},
            x::Vector{Float64},
            T::Float64,
            τ::Float64,
            δ::Float64,
            h::Float64
        )::Nothing
        D = map((x)->diffcoef₁(T, x), x)
        d = harmonic(D)

        β = τ / δ
        γ = d[1] / δ

        M.dl[:] = -(β / δ) * d
        M.du[:] = -(β / δ) * d

        M.d[:] .= 1.0
        M.d[1:end-1] -= M.du
        M.d[2:end-0] -= M.dl

        M.d[1]  = 1 + β * (h + γ)
        M.du[1] = β * γ

        return nothing
    end

    @warn "Organizar"
end

# ╔═╡ bb5c9e93-0ec4-4395-b646-c0ab1deb70c1
function innerloop(;
        residual::ResidualsRaw,
        A,
        x,
        b,
        T,
        τ,
        δ,
        h::Float64,
        M::Int64,
        α::Float64,
        ε::Float64
    )
    for niter in 1:M
        updatematrix!(A, x, T, τ, δ, h)

        Δx = (1-α) * (A\b - x)
        εm = maximum(abs.(Δx)) / maximum(x)

        feedinnerresidual(residual, εm)
        x[:] += Δx

        if εm <= ε
            return niter
        end
    end

    @warn "Não convergiu após $(M) passos"
    return M
end

# ╔═╡ 1e875527-cd12-4a24-93c2-04933b661c5c
begin
    go


    hₘ = 10.0^h

    x∞  = aero∞
    x₁₀ = C

    domain = HalfCellBoundaryFVM(; L = L/2, N = N)
    A, b = createproblem(N+1)

    x = x₁₀ * ones(N+1)
    u = copy(x)
    τ = t / M
    times = 0.0:τ:t

    inner = I
    outer = length(times)
    residual = ResidualsRaw(inner, outer)

    for (nouter, ts) in enumerate(times)
        b[:] = x[:]
        b[1] += (τ / domain.δ) * hₘ * x∞

        residual.innersteps[nouter] = innerloop(;
            residual = residual,
            A = A,
            x = x,
            b = b,
            T = T,
            τ = τ,
            δ = domain.δ,
            h = hₘ,
            M = inner,
            α = α,
            ε = 10.0^ε
        )
    end

    finalresidual = ResidualsProcessed(residual)

    fig1 = plotprofile(;
        z   = domain.z,
        yc  = moletomassfraction.(x),
        yc₀ = moletomassfraction.(aeroc),
        yn  = nothing,
        yn₀ = nothing
    )

    fig2 = plotresiduals(finalresidual, 10.0^ε; yticks = -10:2:0)
end;

# ╔═╡ 98f18741-d76c-46b4-91dc-a44eb8e4a67f
fig1

# ╔═╡ aca99c04-1987-4cb9-a923-5c8d55121001
fig2

# ╔═╡ 7b591c27-18d8-4022-9b6a-bb0c0ccce888
md"""
### Pacotes
"""

# ╔═╡ Cell order:
# ╠═30c163e1-4af6-4776-887b-2835cf488407
# ╠═f3f32e4b-5ebd-4ce1-bc42-907eb54789e7
# ╟─c20a6318-26a3-4971-be92-bfc1c79d8c3f
# ╟─75d6913c-bf90-4b1c-9fdd-0e9e9c9e26f6
# ╟─50545d72-c312-437f-94c2-8c907327f17b
# ╟─89dfc30a-f103-496a-b794-f341b53f09dc
# ╟─995acd5a-7dc1-42fd-ad12-e7fbef516f12
# ╟─01fde065-7081-4255-9a52-a69c2c9f4afb
# ╠═518e9825-dea1-4c8f-9395-d21b33e386e3
# ╠═1a1aaeb6-060a-4352-bf93-aa2b3c665119
# ╟─98f18741-d76c-46b4-91dc-a44eb8e4a67f
# ╟─aca99c04-1987-4cb9-a923-5c8d55121001
# ╠═1e875527-cd12-4a24-93c2-04933b661c5c
# ╠═6b169165-92ab-4386-802e-ce7d11c0a471
# ╠═bb5c9e93-0ec4-4395-b646-c0ab1deb70c1
# ╟─7fc69ea4-015f-4913-94ff-e3e0820af12b
# ╟─0e077ba1-e451-4982-a6bd-a3fc7f2c6a89
# ╟─1eecfc46-2403-4378-95bc-7cd0807b50df
# ╠═a28e78ec-fcef-4ab5-8b65-9260c3cfd8a4
# ╟─f3c9aea8-653d-49c2-a806-0d1b3a263012
# ╠═fe489f21-c657-465a-b8a9-948dfc93051b
# ╟─8b9cf875-78b6-466a-9e43-f3eceb8d027a
# ╟─f9a24b0f-d820-48d1-a048-853dd994a249
# ╟─63a9fa87-92f1-444a-8bcf-dde5d682e099
# ╠═8fe591cd-f3f7-4cf8-8d91-92c6dff1dd01
# ╠═efed88fb-9b89-4896-acc3-cec5f3462978
# ╟─7b591c27-18d8-4022-9b6a-bb0c0ccce888
# ╠═73b13fb0-62b6-11ee-27bf-69788069829a
# ╟─f6cdb233-9b99-48ff-bce4-4f359a35f591
