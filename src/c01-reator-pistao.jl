### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()
    
    using CairoMakie
    using DelimitedFiles
    using DifferentialEquations: solve
    using DocStringExtensions
    using ModelingToolkit
    using Printf
    using Roots
    using SparseArrays: spdiagm
    import PlutoUI
    
    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Reator pistão - Parte 1

Este é o primeiro notebook de uma série abordando reatores do tipo *pistão* (*plug-flow*) no qual os efeitos advectivos são preponderantes sobre o comportamento difusivo, seja de calor, massa, ou espécies. O estudo e modelagem desse tipo de reator apresentar diversos interesses para a pesquisa fundamental e na indústria. Muitos reatores tubulares de síntese laboratorial de materiais apresentam aproximadamente um comportamento como tal e processos nas mais diversas indústrias podem ser aproximados por um ou uma rede de reatores pistão e reatores agitados interconectados.

Começaremos por um caso simples considerando um fluido incompressível e ao longo da série aumentaremos progressivamente a complexidade dos modelos. Os notebooks nessa série vão utilizar uma estratégia focada nos resultados, o que indica que o código será na maior parte do tempo ocultado e o estudante interessado deverá executar o notebook por si mesmo para estudar as implementações.

Nesta *Parte 1* vamos estuda a formulação na temperatura da equação de conservação de energia.

$(toc)
"""

# ╔═╡ 31618e47-f85e-4045-9335-9a5bbe323375
md"""
## Modelo da temperatura

No que se segue vamos implementar a forma mais simples de um reator pistão. Para este primeiro estudo o foco será dado apenas na solução da equação da energia. As etapas globais implementadas aqui seguem o livro de [Kee *et al.* (2017)](https://www.wiley.com/en-ie/Chemically+Reacting+Flow%3A+Theory%2C+Modeling%2C+and+Simulation%2C+2nd+Edition-p-9781119184874), seção 9.2.

Da forma simplificada como tratado, o problema oferece uma solução analítica análoga à [lei do resfriamento de Newton](https://pt.wikipedia.org/wiki/Lei_do_resfriamento_de_Newton), o que é útil para a verificação do problema. Os cálculos do número de Nusselt para avaliação do coeficiente de transferência de calor são providos nos anexos com expressões discutidas [aqui](https://en.wikipedia.org/wiki/Nusselt_number).

A primeira etapa no estabelecimento do modelo concerne as equações de conservação necessárias. No presente caso, com a ausência de reações químicas e trocas de matéria com o ambiente - o reator é um tubo fechado - precisamos estabelecer a conservação de massa e energia apenas. Como dito, o reator em questão conserva a massa transportada, o que é matematicamente expresso pela ausência de variação axial do fluxo de matéria, ou seja

```math
\frac{d(\rho{}u)}{dz}=0
```

Mesmo que trivial, esse resultado é frequentemente útil na simplificação das outras equações de conservação para um reator pistão, como veremos (com frequência) mais tarde.

Embora não trocando matéria com o ambiente a través das paredes, vamos considerar aqui trocas térmicas. Afinal não parece muito útil um modelo de reator sem trocas de nenhum tipo nem reações. Da primeira lei da Termodinâmica temos que a taxa de variação da energia interna ``E`` é igual a soma das taxas de trocas de energia ``Q`` e do trabalho realizado ``W``.

```math
\frac{dE}{dt}=
\frac{dQ}{dt}+
\frac{dW}{dt}
```

Podemos reescrever essa equação para uma seção transversal do reator de área ``A_{c}`` em termos das grandezas específicas e densidade ``\rho`` com as integrais

```math
\int_{\Omega}\rho{}e\mathbf{V}\cdotp\mathbf{n}dA_{c}=
\dot{Q}-
\int_{\Omega}p\mathbf{V}\cdotp\mathbf{n}dA_{c}
```

Com a definição de entalpia ``h`` podemos simplificar essa equação e obter

```math
\int_{\Omega}\rho{}h\mathbf{V}\cdotp\mathbf{n}dA_{c}=
\dot{Q}\qquad{}\text{aonde}\qquad{}h = e+\frac{p}{\rho}
```

Usando o teorema de Gauss transformamos essa integral sobre a superfície num integral de divergência sobre o volume diferencial ``dV``, o que é útil na manipulação de equações de conservação

```math
\int_{\Omega}\rho{}h\mathbf{V}\cdotp\mathbf{n}dA_{c}=
\int_{V}\nabla\cdotp(\rho{}h\mathbf{V})dV
```

Nos resta ainda determinar ``\dot{Q}``. O tipo de interação com ambiente, numa escala macroscópica, não pode ser representado por leis físicas fundamentais. Para essa representação necessitamos de uma *lei constitutiva* que modela o fenômeno em questão. Para fluxos térmicos convectivos à partir de uma parede com temperatura fixa ``T_{s}`` a forma análoga a uma condição limite de Robin expressa o ``\dot{Q}`` como

```math
\dot{Q}=\hat{h}A_{s}(T_{s}-T)=\hat{h}(Pdz)(T_{s}-T)
```

O coeficiente de troca térmica convectiva ``\hat{h}`` é frequentemente determinado à partir do tipo de escoamento usando fórmulas empíricas sobre o número de Nusselt. A abordagem desse tópico vai além do nosso escopo e assume-se que seu valor seja conhecido. Nessa expressão já transformamos a área superficial do reator ``A_{s}=Pdz`` o que nos permite agrupar os resultados em

```math
\int_{V}\nabla\cdotp(\rho{}h\mathbf{V})dV=
\hat{h}(Pdz)(T_{w}-T)
```

Em uma dimensão ``z`` o divergente é simplemente a derivada nessa coordenada. Usando a relação diverencial ``\delta{}V=A_{c}dz`` podemos simplificar a equação para a forma diferencial como se segue

```math
\frac{d(\rho{}u{}h)}{dz}=
\frac{\hat{h}Pdz}{\delta{}V}(T_{w}-T)
\implies
\frac{d(\rho{}u{}h)}{dz}=
\frac{\hat{h}P}{A_{c}}(T_{w}-T)
```

A expressão acima já consitui um modelo para o reator pistão, mas sua forma não é facilmente tratável analiticamente. Empregando a propriedade multiplicativa da diferenciaÇão podemos expandir o lado esquedo da equação como

```math
\rho{}u{}\frac{dh}{dz}+h\frac{d(\rho{}u)}{dz}=
\frac{\hat{h}P}{A_{c}}(T_{w}-T)
```

O segundo termo acima é nulo em razão da conservação da matéria, como discutimos anteriormente. Da definição diferencial de entalpia ``dh=c_{p}dT`` chegamos a formulação do modelo na temperatura como dado no título dessa seção.

```math
\rho{}u{}c_{p}A_{c}\frac{dT}{dz}=
\hat{h}P(T_{w}-T)
```

Vamos agora empregar esse modelo para o cálculo da distribuição axial de temperatura ao longo do reator. No que se segue assume-se um reator tubular de seção circular de raio ``R`` e todos os parâmetros do modelo são constantes.
"""

# ╔═╡ 2ff345b1-aa07-439b-92c4-a25c228550f5
md"""
### Solução analítica da EDO

O problema tratado aqui permite uma solução analítica simples que desenvolvemos de maneira um pouco abrupta no que se segue. Separando os termos em ``T`` (variável dependente) e ``z`` (variável independente) e integrando sobre os limites adequados obtemos

```math
\int_{T_{0}}^{T}\frac{dT}{T_{w}-T}=
\frac{\hat{h}P}{\rho{}u{}c_{p}A_{c}}\int_{0}^{z}dz=
\mathcal{C}_{0}z
```

Na expressão acima ``\mathcal{C}_{0}`` não é uma constante de integração mas apenas regrupa os parâmetros do modelo. O termo em ``T`` pode ser integrado por uma substituição trivial

```math
u=T_{w}-T \implies -\int\frac{du}{u}=\log(u)\biggr\vert_{u_0}^{u}+\mathcal{C}_{1}
```

Realizando a integração definida e resolvendo para ``T`` chegamos a

```math
T=T_{w}-(T_{w}-T_{0})\exp\left(-\mathcal{C}_{0}z+\mathcal{C}_{1}\right)
```

É trivial verificar com ``T(z=0)=T_{0}`` que ``\mathcal{C}_{1}=0`` o que conduz à solução analítica que é implementada no que se segue em `analyticalthermalpfr`.

```math
T=T_{w}-(T_{w}-T_{0})\exp\left(-\frac{\hat{h}P}{\rho{}u{}c_{p}A_{c}}z\right)
```
"""

# ╔═╡ af4440bb-7ca3-4229-9145-9f4c8d2d6af2
"Solução analítica do reator pistão circular no espaço das temperaturas."
function analyticalthermalpfr(; P::T, A::T, Tₛ::T, Tₚ::T, ĥ::T, u::T, ρ::T,
                                cₚ::T, z::Vector{T})::Vector{T} where T
    return @. Tₛ - (Tₛ - Tₚ) * exp(-z * (ĥ * P) / (ρ * u * cₚ * A))
end

# ╔═╡ 2475c3e0-8819-4b4d-94e2-67a65f1e9c5f
md"""
O bloco abaixo resolve o problema para um conjunto de condições que você pode consultar nos anexos e expandindo o seu código. Observe abaixo da célula um *log* do cálculo dos números adimensionais relevantes ao problema e do coeficiente de transferência de calor convectivo associado. Esses elementos são tratados por funções externas que se encontram em um arquivo de suporte a esta série e são tidos como conhecimentos *a priori* para as discussões.
"""

# ╔═╡ 509cffd8-76e8-489a-aa9c-4b32a08a2c04
md"""
### Integração numérica da EDO

Neste exemplo tivemos *sorte* de dispor de uma solução analítica. Esse problema pode facilmente tornar-se intratável se considerarmos uma dependência arbitrária do calor específico com a temperatura ou se a parede do reator tem uma dependência na coordenada axial. É importante dispor de meios numéricos para o tratamento deste tipo de problema.

No caso de uma equação diferencial ordinária (EDO) como no presente caso, a abordagem mais simples é a de se empregar um integrador numérico. Para tanto é prática comum estabelecer uma função que representa o *lado direito* do problema isolando a(s) derivada(s) no lado esquerdo. Em Julia dispomos do *framework* de `ModelingToolkit` que provê uma forma simbólica de representação de problemas e interfaces com diversos integradores. A estrutura `DifferentialEquationPFR` abaixo implementa o problema diferencial desta forma.
"""

# ╔═╡ cc4c1239-5397-46b6-88a2-a1efa041bf09
"""
Representação em forma EDO do reator pistão.

$(TYPEDFIELDS)
"""
struct DifferentialEquationPFR
    "Perímetro transversal do reator [m]"
    P::Num

    "Área transversal do reator [m²]"
    A::Num

    "Temperatura de superfície do reator [K]"
    Tₛ::Num

    "Coeficient convectivo de troca de calor [W/(m².K)]"
    ĥ::Num

    "Velocidade do fluido [m/s]"
    u::Num

    "Densidade do fluido [kg/m³]"
    ρ::Num

    "Calor específico do fluido [J/(kg.K)]"
    cₚ::Num

    "Coordenada axial do reator [m]"
    z::Num

    "Temperatura axial do reator [K]"
    T::Num

    "Sistema diferencial ordinário à simular"
    sys::ODESystem

    function DifferentialEquationPFR()
        # Variável independente.
        @variables z

        # Variável dependente.
        @variables T(z)

        # Parâmetros.
        pars = @parameters P A Tₛ ĥ u ρ cₚ

        # Operador diferencial em z.
        D = Differential(z)

        # Sistema de equações.
        eqs = [D(T) ~ ĥ * P * (Tₛ - T) / (ρ * u * A * cₚ)]

        # Criação do sistema.
        @named sys = ODESystem(eqs, z, [T], pars)

        return new(P, A, Tₛ, ĥ, u, ρ, cₚ, z, T, sys)
    end
end

# ╔═╡ c10705b4-870c-45b4-9db2-3c67e622167c
md"""
Para integração do modelo simbólico necessitamos substituir os parâmetros por valores numéricos e fornecer a condição inicial e intervalo de integração ao integrador que vai gerir o problema. A interface `solveodepfr` realiza essas etapas. É importante mencionar aqui que a maioria dos integradores numéricos vai *amostrar* pontos na coordenada de integração segundo a *rigidez numérica* do problema, de maneira que a solução retornada normalmente não está sobre pontos equi-espaçados. Podemos fornecer um parâmetro opcional para recuperar a solução sobre os pontos desejados, o que pode facilitar, por exemplo, comparação com dados experimentais.
"""

# ╔═╡ a683ff7b-44ef-4872-bb4a-c39da1e1650d
"Integra o modelo diferencial de reator pistão"
function solveodepfr(; model::DifferentialEquationPFR, P::T, A::T, Tₛ::T, Tₚ::T,
                       ĥ::T, u::T, ρ::T, cₚ::T, z::Vector{T}) where T
    T₀ = [model.T => Tₚ]

    p = [
        model.P => P,
        model.A => A,
        model.Tₛ => Tₛ,
        model.ĥ => ĥ,
        model.u => u,
        model.ρ => ρ,
        model.cₚ => cₚ,
    ]

    zspan = (0, z[end])
    prob = ODEProblem(model.sys, T₀, zspan, p)
    return solve(prob; saveat = z)
end

# ╔═╡ 33a5cf9d-4f6c-4edf-898b-53a376fbafd6
md"""
Uma funcionalidade bastante interessante de `ModelingToolkit` é sua capacidade de representar diretamente em com ``\LaTeX`` as equações implementadas. Antes de proceder a solução verificamos na célula abaixo que a equação estabelecida no modelo está de acordo com a formulação que derivamos para o problema diferencial. Verifica-se que a ordem dos parâmetros pode não ser a mesma, mas o modelo é equivalente.
"""

# ╔═╡ 8af47db5-1e57-4e53-b701-23d257edb3e0
let
    DifferentialEquationPFR().sys
end

# ╔═╡ f359e8b3-35da-4c38-9dc8-35a95c13bd8b
md"""
Com isso podemos proceder à integração com ajuda de `solveodepfr` concebida acima e aproveitamos para traçar o resultado em conjunto com a solução analítica.
"""

# ╔═╡ b902a85e-6c49-41f7-9355-26fa05b68105
md"""
### Método dos volumes finitos

Quando integrando apenas um reator, o método de integração numérica da equação é geralmente a escolha mais simples. No entanto, em situações nas quais desejamos integrar trocas entre diferentes reatores aquela abordagem pode se tornar proibitiva. Uma dificuldade que aparece é a necessidade de solução iterativa até convergência dados os fluxos pelas paredes do reator, o que demandaria um código extremamente complexo para se gerir em integração direta. Outro caso são trocadores de calor que podem ser representados por conjutos de reatores em contra-corrente, um exemplo que vamos tratar mais tarde nesta série. Nestes casos podemos ganhar em simplicidade e tempo de cálculo empregando métodos que *linearizam* o problema para então resolvê-lo por uma simples *álgebra linear*.

Na temática de fênomenos de transporte, o método provavelmente mais frequentemente utilizado é o dos volumes finitos (em inglês abreviado FVM). Note que em uma dimensão com coeficientes constantes pode-se mostrar que o método é equivalente à diferenças finitas (FDM), o que é nosso caso neste problema. No entanto vamos insistir na tipologia empregada com FVM para manter a consistência textual nos casos em que o problema não pode ser reduzido à um simples FDM.

No que se segue vamos usar uma malha igualmente espaçada de maneira que nossas coordenadas de solução estão em ``z\in\{0,\delta,2\delta,\dots,N\delta\}`` e as interfaces das células encontram-se nos pontos intermediários. Isso dito, a primeira e última célula do sistema são *meias células*, o que chamaremos de *condição limite imersa*, contrariamente à uma condição ao limite com uma célula fantasma na qual o primeiro ponto da solução estaria em ``z=\delta/2``. Trataremos esse caso em outra ocasião.

O problema de transporte advectivo em um reator pistão é essencialmente *upwind*, o que indica que a solução em uma célula ``E`` *a leste* de uma célula ``P`` depende exclusivamente da solução em ``P``. Veremos o impacto disto na forma matricial trivial que obteremos na sequência. Para a sua construção, começamos pela integração do problema entre ``P`` e ``E``, da qual se segue a separação de variáveis

```math
\int_{T_P}^{T_E}\rho{}u{}c_{p}A_{c}dT=
\int_{0}^{\delta}\hat{h}{P}(T_{s}-T^{\star})dz
```

Observe que introduzimos a variável ``T^{\star}`` no lado direito da equação e não sob a integral em ``dT``. Essa escolha se fez porque ainda não precisamos definir qual a temperatura mais representativa deve-se usar para o cálculo do fluxo térmico. Logo vamos interpretá-la como uma constante que pode ser movida para fora da integral

```math
\rho{}u{}c_{p}A_{c}\int_{T_P}^{T_E}dT=
\hat{h}{P}(T_{s}-T^{\star})\int_{0}^{\delta}dz
```

Realizando-se a integração definida obtemos a forma paramétrica

```math
\rho{}u{}c_{p}A_{c}(T_{E}-T_{P})=
\hat{h}{P}\delta(T_{s}-T^{\star})
```

Para o tratamento com FVM agrupamos parâmetros para a construção matricial, o que conduz à

```math
aT_{E}-aT_{P}=
T_{s}-T^{\star}
```

No método dos volumes finitos consideramos que a solução é constante através de uma célula. Essa hipótese é a base para construção de um modelo para o parâmetro ``T^{\star}`` na presente EDO. Isso não deve ser confundido com os esquemas de interpolaçãO que encontramos em equações diferenciais parciais.

A ideia é simples: tomemos um par de células ``P`` e ``E`` com suas respectivas temperaturas ``T_{P}`` e ``T_{E}``. O limite dessas duas células encontra-se no ponto médio entre seus centros, que estão distantes de um comprimento ``\delta``. Como a solução é constante em cada célula, entre ``P`` e a parede o fluxo de calor total entre seu centro e a fronteira ``e`` com a célula ``E`` é

```math
\dot{Q}_{P-e} = \hat{h}{P}(T_{s}-T_{P})\delta_{P-e}=\frac{\hat{h}{P}\delta}{2}(T_{s} - T_{P})
```

De maneira análoga, o fluxo entre a fronteira ``e`` e o centro de ``E`` temos

```math
\dot{Q}_{e-E} = \hat{h}{P}(T_{s}-T_{E})\delta_{e-E}=\frac{\hat{h}{P}\delta}{2}(T_{s}-T_{E})
```

Nas expressões acima usamos a notação em letras minúsculas para indicar fronteiras entre células. A célula de *referência* é normalmente designada ``P``, e logo chamamos a fronteira pela letra correspondendo a célula vizinha em questão, aqui ``E``. O fluxo convectivo total entre ``P`` e ``E`` é portanto

```math
\dot{Q}_{P-E}=\dot{Q}_{P-e}+\dot{Q}_{e-E}=\hat{h}{P}\left[T_{s}-\frac{(T_{E}+T_{P})}{2}\right]
```

de onde adotamos o modelo

```math
T^{\star}=\frac{T_{E}+T_{P}}{2}
```

A troca convectiva com a parede não seria corretamente representada se escolhessemos ``T_{P}`` como referência para o cálculo do fluxo (o que seria o caso em FDM). Obviamente aproximações de ordem superior são possíveíveis empregando-se mais de duas células mas isso ultrapassa o nível de complexidade que almejamos entrar no momento.

Aplicando-se esta expressão na forma numérica precedente, após manipulação chega-se à

```math
(2a + 1)T_{E}=
(2a - 1)T_{P} + 2T_{w}
```

Com algumas manipulações adicionais obtemos a forma que será usada na sequência

```math
-A^{-}T_{P} + A^{+}T_{E}=1\quad\text{aonde}\quad{}A^{\pm} = \frac{2a \pm 1}{2T_{w}}
```

A expressão acima é válida entre todos os pares de células ``P\rightarrow{}E`` no sistema, exceto pela primeira. Como se trata de uma EDO, a primeira célula do sistema contém a condição inicial ``T_{0}`` e não é precedida por nenhuma outra célula e evidentemente não precisamos resolver uma equação adicional para esta. Considerando o par de vizinhos ``P\rightarrow{}E\equiv{}0\rightarrow{}1``, substituindo o valor da condição inicial obtemos a modificação da equação para a condição inicial imersa

```math
A^{+}T_{1}=1 + A^{-}T_{0}
```

Como não se trata de um problema de condições de contorno, nada é necessário para a última célula do sistema. Podemos agora escrever a forma matricial do problema que se dá por

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

A dependência de ``E`` somente em ``P`` faz com que tenhamos uma matriz diagonal inferior, aonde os ``-A^{-}`` são os coeficientes de ``T_{P}`` na formulação algébrica anterior. A condição inicial modifica o primeiro elemento do vetor constante à direita da igualdade. A construção e solução deste problema é provida em `solvethermalpfr` abaixo.
"""

# ╔═╡ e08d8341-f3a5-4ff1-b18e-19e9a0757b24
"Integra reator pistão circular no espaço das temperaturas."
function solvethermalpfr(; mesh::AbstractDomainFVM, P::T, A::T, Tₛ::T, Tₚ::T,
                         ĥ::T, u::T, ρ::T, cₚ::T, z::Vector{T}) where T
    N = length(mesh.z) - 1
    a = (ρ * u * cₚ * A) / (ĥ * P * mesh.δ)

    A⁺ = (2a + 1) / (2Tₛ)
    A⁻ = (2a - 1) / (2Tₛ)

    b = ones(N)
    b[1] = 1 + A⁻ * Tₚ

    M = spdiagm(-1 => -A⁻*ones(N-1), 0 => +A⁺*ones(N+0))
    U = similar(mesh.z)

    U[1] = Tₚ
    U[2:end] = M \ b

    return U
end

# ╔═╡ 6f2ead8f-9626-4418-8453-f8964016b5d3
md"""
Abaixo adicionamos a solução do problema sobre malhas grosseiras sobre as soluções desenvolvidas anteriormente. A ideia de se representar sobre malhas grosseiras é simplesmente ilustrar o caráter discreto da solução, que é representada como constante no interior de uma célula. Adicionalmente representamos no gráfico um resultado interpolado de uma simulação CFD 3-D de um reator tubular em condições *supostamente identicas* as representadas aqui, o que mostra o bom acordo de simulações 1-D no limite de validade do modelo.
"""

# ╔═╡ 195576d4-6f34-4ad7-87c9-780ade2d402c
md"""
Com isso encerramos essa primeira introdução a modelagem de reatores do tipo pistão. Estamos ainda longe de um modelo generalizado para estudo de casos de produção, mas os principais blocos de construção foram apresentados. Os pontos principais a reter deste estudo são:

- A equação de conservação de massa é o ponto chave para a expansão e simplificação das demais equações de conservação. Note que isso é uma consequência de qua a massa corresponde à aplicação do [Teorema de Transporte de Reynolds](https://pt.wikipedia.org/wiki/Teorema_de_transporte_de_Reynolds) sobre a *unidade 1*. 

- Sempre que a implementação permita, é mais fácil de se tratar o problema como uma EDO e pacotes como ModelingToolkit proveem o ferramental básico para a construção deste tipo de modelos facilmente.

- Uma implementação em volumes finitos será desejável quando um acoplamento com outros modelos seja envisajada. Neste caso a gestão da solução com uma EDO a parâmetros variáveis pode se tornar computacionalmente proibitiva, seja em complexidade de código ou tempo de cálculo.
"""

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/).
"""

# ╔═╡ 1cf0a5eb-6f80-4105-8f21-a731583a7665
md"""
## Anexos
"""

# ╔═╡ f5ae8785-de5b-43cf-b289-bec4a2f92085
"Paramêtros do reator."
const reactor = notedata.c01.reactor

# ╔═╡ dd774c04-7829-4b8e-8e2b-254d85c29eed
"Parâmetros do fluido"
const fluid = notedata.c01.fluid

# ╔═╡ f8fde200-41ce-46c0-a784-3f77e38e8ac8
"Parâmetros de operação."
const operations = notedata.c01.operations

# ╔═╡ 2060c323-2565-4456-b5d1-0705a3e48e93
"Perímetro da seção circular do reator [m]."
const P = π * reactor.D

# ╔═╡ a23296bb-dfa6-439d-94e9-c7e072af1d6c
"Área da seção circula do reator [m²]."
const A = π * (reactor.D/2)^2

# ╔═╡ 88aa55d3-519d-4d74-a553-890e9bb56bb5
"Gráficos padronizados para este notebook."
function standardplot(toplot, yrng = (300, 400))
    ex = quote
        let
            fig = Figure(resolution = (720, 500))
            ax = Axis(fig[1, 1])
            $toplot
            xlims!(ax, (0, $reactor.L))
            ax.title = "Temperatura final = $(Tend) K"
            ax.xlabel = "Posição [m]"
            ax.ylabel = "Temperatura [K]"
            ax.xticks = range(0.0, $reactor.L, 6)
            ax.yticks = range($yrng..., 6)
            ylims!(ax, $yrng)
            axislegend(position = :rb)
            fig
        end
    end

    return eval(ex)
end

# ╔═╡ c3eb75c6-92dd-4d7f-9c29-e1249bc0e485
let
    z = ImmersedConditionsFVM(; L = reactor.L, N = 10000).z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u, verbose = true)

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)
    Tₐ = analyticalthermalpfr(; pars...)

    standardplot(quote
        lines!(ax, $z, $Tₐ, color = :red,   linewidth = 5, label = "Analítica")
        Tend = @sprintf("%.2f", $Tₐ[end])
    end)
end

# ╔═╡ 54b4ea1d-2fb3-4d8e-a41f-b887aebb4071
let
    z = ImmersedConditionsFVM(; L = reactor.L, N = 10000).z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)

    model = DifferentialEquationPFR()
    Tₐ = analyticalthermalpfr(; pars...)
    Tₒ = solveodepfr(; model = model, pars...)[:T]

    standardplot(quote
        lines!(ax, $z, $Tₐ, color = :red,   linewidth = 5, label = "Analítica")
        lines!(ax, $z, $Tₒ, color = :black, linewidth = 2, label = "EDO")
        Tend = @sprintf("%.2f", $Tₒ[end])
    end)
end

# ╔═╡ c8623e44-348b-4db0-8440-fc7053f3e780
let
    case = "fluent-reference"
    data = readdlm("c01-reator-pistao/$(case)/postprocess.dat", Float64)
    x, Tₑ = data[:, 1], data[:, 2]

    mesh = ImmersedConditionsFVM(; L = reactor.L, N = 10000)
    
    z = mesh.z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)

    model = DifferentialEquationPFR()
    Tₐ = analyticalthermalpfr(; pars...)
    Tₒ = solveodepfr(; model = model, pars...)[:T]
    
    standardplot(quote
        lines!(ax, $z, $Tₐ, color = :red,   linewidth = 5, label = "Analítica")
        lines!(ax, $z, $Tₒ, color = :black, linewidth = 2, label = "EDO")
        lines!(ax, $x, $Tₑ, color = :blue,  linewidth = 2, label = "CFD")

        for N in [20, 100]
            meshN = ImmersedConditionsFVM(; L = $reactor.L, N = N)
            T = solvethermalpfr(; mesh = meshN, $pars...)
            stairs!(ax, meshN.z, T; label = "N = $(N)", step = :center)
            # Experimente substituir a linha acima pelo código abaixo:
            # lines!(ax, meshN.z, T; label = "N = $(N)")
        end
        
        Tend = @sprintf("%.2f", $Tₐ[end])
    end)
end

# ╔═╡ f9b1527e-0d91-490b-95f6-13b649fe61db
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─31618e47-f85e-4045-9335-9a5bbe323375
# ╟─2ff345b1-aa07-439b-92c4-a25c228550f5
# ╟─af4440bb-7ca3-4229-9145-9f4c8d2d6af2
# ╟─2475c3e0-8819-4b4d-94e2-67a65f1e9c5f
# ╟─c3eb75c6-92dd-4d7f-9c29-e1249bc0e485
# ╟─509cffd8-76e8-489a-aa9c-4b32a08a2c04
# ╟─cc4c1239-5397-46b6-88a2-a1efa041bf09
# ╟─c10705b4-870c-45b4-9db2-3c67e622167c
# ╟─a683ff7b-44ef-4872-bb4a-c39da1e1650d
# ╟─33a5cf9d-4f6c-4edf-898b-53a376fbafd6
# ╟─8af47db5-1e57-4e53-b701-23d257edb3e0
# ╟─f359e8b3-35da-4c38-9dc8-35a95c13bd8b
# ╟─54b4ea1d-2fb3-4d8e-a41f-b887aebb4071
# ╟─b902a85e-6c49-41f7-9355-26fa05b68105
# ╟─e08d8341-f3a5-4ff1-b18e-19e9a0757b24
# ╟─6f2ead8f-9626-4418-8453-f8964016b5d3
# ╟─c8623e44-348b-4db0-8440-fc7053f3e780
# ╟─195576d4-6f34-4ad7-87c9-780ade2d402c
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─1cf0a5eb-6f80-4105-8f21-a731583a7665
# ╟─f5ae8785-de5b-43cf-b289-bec4a2f92085
# ╟─dd774c04-7829-4b8e-8e2b-254d85c29eed
# ╟─f8fde200-41ce-46c0-a784-3f77e38e8ac8
# ╟─2060c323-2565-4456-b5d1-0705a3e48e93
# ╟─a23296bb-dfa6-439d-94e9-c7e072af1d6c
# ╟─88aa55d3-519d-4d74-a553-890e9bb56bb5
# ╟─f9b1527e-0d91-490b-95f6-13b649fe61db
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
