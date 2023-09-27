# -*- coding: utf-8 -*-

"Tipo abstrato para domínios em FVM."
abstract type AbstractDomainFVM end

"Método dos volumes finitos com condição limite imersa."
struct ImmersedConditionsFVM <: AbstractDomainFVM
    "Coordenadas dos centros das células [m]."
    z::Vector{Float64}

    "Coordenadas dos limites das células [m]."
    w::Vector{Float64}

    "Comprimento de uma célula [m]."
    δ::Float64

    function ImmersedConditionsFVM(; L::Float64, N::Int64)
        δ = L / N
        z = collect(0.0:δ:L)
        w = collect(0.5δ:δ:L-0.5δ)
        return new(z, w, δ)
    end
end

"Macro para capturar erro dada uma condição invalida."
macro warnonly(ex)
    quote
        try
            $(esc(ex))
        catch e
            @warn e
        end
    end
end

"Estima coeficiente de troca convectiva do escoamento."
function computehtc(; L, D, u, ρ, μ, cₚ, Pr,
                      method = :g, verbose = false)
    Re = ρ * u * D / μ

    Nug = gnielinski_Nu(Re, Pr)
    Nud = dittusboelter_Nu(Re, Pr, L, D)

    if Re > 3000
        Nu = (method == :g) ? Nug : Nub
    else
        Nu = 3.66
    end

    k = cₚ * μ / Pr
    h = Nu * k / D

	if verbose
	    println("""\
	        Reynolds ................... $(Re)
	        Nusselt (Gnielinsk) ........ $(Nug)
	        Nusselt (Dittus-Boelter) ... $(Nud)
	        Nusselt (usado aqui) ....... $(Nu)
	        k .......................... $(k) W/(m.K)
	        h .......................... $(h) W/(m².K)\
	        """)
	end
	
    return h
end

"Equação de Gnielinski para número de Nusselt."
function gnielinski_Nu(Re, Pr)
    function validate(Re, Pr)
        @assert 3000.0 <= Re <= 5.0e+06
        @assert 0.5 <= Pr <= 2000.0
    end

    @warnonly validate(Re, Pr)

    f = (0.79 * log(Re) - 1.64)^(-2)
    g = f / 8

    num = g * (Re - 1000) * Pr
    den = 1.0 + 12.7 * (Pr^(2 / 3) - 1) * g^(1 / 2)
    return num / den
end

"Equação de Dittus-Boelter para número de Nusselt."
function dittusboelter_Nu(Re, Pr, L, D; what = :heating)
    function validate(Re, Pr, L, D)
        @assert 10000.0 <= Re
        @assert 0.6 <= Pr <= 160.0
        @assert 10.0 <= L / D
    end

    @warnonly validate(Re, Pr, L, D)

    n = (what == :heating) ? 0.4 : 0.4
    return 0.023 * Re^(4 / 5) * Pr^n
end

"Dados usados nos notebooks da série."
const notedata = (
    c01 = (
        reactor = (
            L = 10.0,    # Comprimento do reator [m]
            D = 0.01     # Diâmetro do reator [m]
        ),
        fluid = (
            ρ = 1000.0,  # Mass específica do fluido [kg/m³]
            μ = 0.001,   # Viscosidade do fluido [Pa.s]
            cₚ = 4182.0, # Calor específico do fluido [J/(kg.K)]
            Pr = 6.9     # Número de Prandtl do fluido
        ),
        operations = (
            u = 1.0,     # Velocidade do fluido [m/s]
            Tₚ = 300.0,  # Temperatura de entrada do fluido [K]
            Tₛ = 400.0   # Temperatura da parede do reator [K]
        )
    ),
)

@info("Verifique `util-reator-pistao.jl` para mais detalhes...")
