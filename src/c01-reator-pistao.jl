### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
    Pkg.add("DifferentialEquations")
    Pkg.add("ModelingToolkit")

    using CairoMakie
    using DelimitedFiles
    using DifferentialEquations: solve
    using DocStringExtensions
    using ModelingToolkit
    using Printf
    using RollingFunctions
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

Este é o primeiro notebook de uma série abordando reatores do tipo *pistão* (*plug-flow*) no qual os efeitos advectivos são preponderantes sobre o comportamento difusivo, seja de calor, massa, ou espécies. O estudo e modelagem desse tipo de reator apresentar diversos interesses para a pesquisa fundamental e na indústria. Muitos reatores tubulares de síntese laboratorial de materiais apresentam aproximadamente um comportamento como tal e processos nas mais diversas indústrias podem ser aproximados por um ou uma rede de reatores pistão e reatores agitados interconectados.

Começaremos por um caso simples considerando um fluido incompressível e ao longo da série aumentaremos progressivamente a complexidade dos modelos. Os notebooks nessa série vão utilizar uma estratégia focada nos resultados, o que indica que o código será na maior parte do tempo ocultado e o estudante interessado deverá executar o notebook por si mesmo para estudar as implementações.
"""

# ╔═╡ bdbaf01f-6600-49e3-a459-76448bdd61c0
md"""
## Formulação na temperatura

No que se segue vamos implementar a forma mais simples de um reator pistão. Para este primeiro estudo o foco será dado apenas na solução da equação da energia. As etapas globais implementadas aqui seguem o livro de [Kee *et al.* (2017)](https://www.wiley.com/en-ie/Chemically+Reacting+Flow%3A+Theory%2C+Modeling%2C+and+Simulation%2C+2nd+Edition-p-9781119184874), seção 9.2.

Da forma simplificada como tratado, o problema oferece uma solução analítica análoga à [lei do resfriamento de Newton](https://pt.wikipedia.org/wiki/Lei_do_resfriamento_de_Newton), o que é útil para a verificação do problema. Os cálculos do número de Nusselt para avaliação do coeficiente de transferência de calor são providos nos anexos com expressões discutidas [aqui](https://en.wikipedia.org/wiki/Nusselt_number).
"""

# ╔═╡ 133ec2e4-34f9-4f2f-bd75-a601efc2d2d4
md"""
A primeira etapa no estabelecimento do modelo concerne as equações de conservação necessárias. No presente caso, com a ausência de reações químicas e trocas de matéria com o ambiente - o reator é um tubo fechado - precisamos estabelecer a conservação de massa e energia apenas. Como dito, o reator em questão conserva a massa transportada, o que é matematicamente expresso pela ausência de variação axial do fluxo de matéria, ou seja

```math
\frac{d(\rho{}u)}{dz}=0
```

Mesmo que trivial, esse resultado é frequentemente útil na simplificação das outras equações de conservação para um reator pistão, como veremos (com frequência) mais tarde.
"""

# ╔═╡ 53c7c127-9b25-4dd3-8e25-82f64c15b70e
md"""
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
"""

# ╔═╡ 008e881f-2d7b-42ca-b16d-6d9369583d7f
md"""
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
"""

# ╔═╡ 53f1cba1-130f-4bb2-bf64-5e948b38b2c7
md"""
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
function analyticalthermalpfr(;
        P::Float64, A::Float64, Tₛ::Float64, Tₚ::Float64,
        ĥ::Float64, u::Float64, ρ::Float64, cₚ::Float64,
        z::Vector{Float64}
    )
    return @. Tₛ-(Tₛ-Tₚ)*exp(-z*(ĥ*P)/(ρ*u*cₚ*A))
end

# ╔═╡ 2475c3e0-8819-4b4d-94e2-67a65f1e9c5f
md"""
O bloco abaixo resolve o problema para um conjunto de condições que você pode consultar nos anexos e expandindo o seu código.
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
function solveodepfr(;
        model::DifferentialEquationPFR,
        P::Float64, A::Float64, Tₛ::Float64, Tₚ::Float64,
        ĥ::Float64, u::Float64, ρ::Float64, cₚ::Float64,
        z::Vector{Float64}
    )
    T = [model.T => Tₚ]

    p = [
        model.P  => P,
        model.A  => A,
        model.Tₛ => Tₛ,
        model.ĥ  => ĥ,
        model.u  => u,
        model.ρ  => ρ,
        model.cₚ  => cₚ,
    ]

    zspan = (0, z[end])
    prob = ODEProblem(model.sys, T, zspan, p)
    return solve(prob; saveat=z)
end

# ╔═╡ 33a5cf9d-4f6c-4edf-898b-53a376fbafd6
md"""
Uma funcionalidade bastante interessante de `ModelingToolkit` é sua capacidade de representar diretamente em com ``\LaTeX`` as equações implementadas. Antes de proceder a solução verificamos na célula abaixo que a equação estabelecida no modelo está de acordo com a formulação que derivamos para o problema diferencial. Verifica-se que a ordem dos parâmetros pode não ser a mesma, mas o modelo é equivalente.
"""

# ╔═╡ 8af47db5-1e57-4e53-b701-23d257edb3e0
let
    model = DifferentialEquationPFR()
    model.sys
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
"""

# ╔═╡ 9eb2dbcb-cb78-479c-a2d4-2f45cdf37e19
md"""
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
\rho{}u{}c_{p}A_{c}(T_{E} - T_{P})=
\hat{h}{P}\delta(T_{s}-T^{\star})
```

Para o tratamento com FVM agrupamos parâmetros para a construção matricial, o que conduz à

```math
a(T_{E} - T_{P})=
T_{s}-T^{\star}
```
"""

# ╔═╡ 69a8f137-eea6-4088-b973-5b68fa706e19
md"""
O ponto principal de partida de FVM em relação à FDM é a introdução de relações de interpolação. Normalmente vamos tratar destas quando gerindo fluxos em equações diferenciais parciais. Para fins didáticos, vamos discutir o conceito para o parâmetro ``T^{\star}`` na presente EDO.

A troca convectiva com a parede não seria corretamente representada se escolhessemos ``T_{P}`` como referência para o cálculo do fluxo (o que seria o caso em FDM). Pode-se demonstrar, o que não faremos aqui, que sobre o comprimento ``\delta`` separando as células ``P`` e ``E`` a quantidade que levaria à um fluxo integral de calor idêntico à integração de um perfil linear de temperatura entre as células é dado pela média de suas temperaturas, o que é bastante intuitivo. Obviamente aproximações de ordem superior são possíveíveis empregando-se mais de duas células mas isso ultrapassa o nível de complexidade que almejamos entrar no momento.

```math
T^{\star}=\frac{T_{E}+T_{P}}{2}
```

Aplicando-se esta expressão na forma numérica precedente, após manipulação chega-se à

```math
(2a + 1)T_{E}=
(2a - 1)T_{P} + 2T_{w}
```

Com algumas manipulações adicionais obtemos a forma que será usada na sequência

```math
-A^{-}T_{P} + A^{+}T_{E}=1\quad\text{aonde}\quad{}A^{\pm} = \frac{2a \pm 1}{2T_{w}}
```
"""

# ╔═╡ a28774b0-0e2c-4a49-87f0-daf7ceb72766
md"""
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
"""

# ╔═╡ a82921d7-fb98-4f33-bc1e-df592fbaa7aa
md"""
A dependência de ``E`` somente em ``P`` faz com que tenhamos uma matriz diagonal inferior, aonde os ``-A^{-}`` são os coeficientes de ``T_{P}`` na formulação algébrica anterior. A condição inicial modifica o primeiro elemento do vetor constante à direita da igualdade. A construção e solução deste problema é provida em `solvethermalpfr` abaixo.
"""

# ╔═╡ 6f2ead8f-9626-4418-8453-f8964016b5d3
md"""
Abaixo adicionamos a solução do problema sobre malhas grosseiras sobre as soluções desenvolvidas anteriormente. A ideia de se representar sobre malhas grosseiras é simplesmente ilustrar o caráter discreto da solução, que é representada como constante no interior de uma célula. Adicionalmente representamos no gráfico um resultado interpolado de uma simulação CFD 3-D de um reator tubular em condições *supostamente identicas* as representadas aqui, o que mostra o bom acordo de simulações 1-D no limite de validade do modelo.
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
"Integra reator pistão circular no espaço das temperaturas."
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

# ╔═╡ eecddd3e-81b6-452b-876d-fd8e76f96684
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

    function (model::EnthalpyPFR)()
        return model.z, model.T, model.residual
    end
    
    """
    Construtor interno do modelo de reator.
    
        h::Function
        ρ  : Densidade do fluido [kg/m³].
        u  : Velocidade do fluido [m/s].
        r  : Relação de áreas [-].
        ĥ  : Coeficiente de troca convectiva [W/(m².K)].
        L  : Comprimento do reator [m].
        Tₚ : Temperatura inicial do fluido [K].
        Tₛ : Temperatura da superfície do reator [K].
        N  : Número de células no sistema, incluindo limites.
        M  : Máximo número de iterações para a solução.
        α  : Fator de relaxação da solução entre iterações.
        ε  : Tolerância absoluta da solução.
    """
    function EnthalpyPFR(;
        h::Function,
        ρ::Float64,
        u::Float64,
        r::Float64,
        ĥ::Float64,
        L::Float64,
        Tₚ::Float64,
        Tₛ::Float64,
        N::Int64,
        M::Int64 = 100,
        α::Float64 = 0.4,
        ε::Float64 = 1.0e-10
    )
        # Alocação das coordenadas do sistema.
        z = cellcenters(L, L/N)

        # Alocação da solução com a condição inicial.
        T = Tₚ * ones(N+1)

        # Alocação a matrix de diferenças.
        A = 2spdiagm(-1 => -ones(N-1), 0 =>  ones(N))

        # Constante do modelo.
        a = ĥ / (ρ * u * r)
        
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
            # h̄ = A \ (b - a * rolling(sum, T, 2))
            h̄ = A \ (b - a * (T[1:end-1] + T[2:end]))
        
            # Encontra as novas temperaturas resolvendo uma equação não-linear
            # para cada nova entalpia calculada resolvendo `A*h=b`.
            U = map((Tₖ, hₖ)->find_zero(T->h(T)-hₖ, Tₖ), T[2:end], h̄)
            
            # Relaxa a solução para evitar atualizações bruscas. Como o cálculo
            # se faz por `(1-α)*U + α*T`, podemos reescrever a expressão como
            # `U+α*(T-U) = anew+α*Δ`, aonde o incremento Δ pode ser reutilizado
            # para o cálculo do resíduo que avalia a máxima atualização.
            Δ = T[2:end] - U
            T[2:end] = U + α * Δ
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

# ╔═╡ 21322737-95e7-4ca3-840a-91351880755a
"Função para padronizar gráficos somente."
function reactoraxes(Tend, ax)
    ax.title = "Temperatura final = $(Tend) K"
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
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

# ╔═╡ c3eb75c6-92dd-4d7f-9c29-e1249bc0e485
let
    c = Conditions()
    N = 10000
    
    z = cellcenters(c.L, c.L / N)
    ĥ = computehtc(c)

    P  = 2π * c.R
    A  = π * c.R^2

    pars = (P = P, A = A, Tₛ = c.Tₛ, Tₚ = c.Tₚ,
            ĥ = ĥ, u = c.u, ρ = c.ρ, cₚ = c.cₚ,
            z = z)
    
    Tₐ = analyticalthermalpfr(; pars...)
    
    fig, ax = reactorplot(; L = c.L)
    lines!(ax, z, Tₐ, color = :red,   linewidth = 2, label = "Analítica")
    reactoraxes(@sprintf("%.2f", Tₐ[end]), ax)
    fig
end

# ╔═╡ 54b4ea1d-2fb3-4d8e-a41f-b887aebb4071
let
    c = Conditions()
    N = 10000
    
    z = cellcenters(c.L, c.L / N)
    ĥ = computehtc(c)

    P  = 2π * c.R
    A  = π * c.R^2

    pars = (P = P, A = A, Tₛ = c.Tₛ, Tₚ = c.Tₚ,
            ĥ = ĥ, u = c.u, ρ = c.ρ, cₚ = c.cₚ,
            z  = z)
    
    model = DifferentialEquationPFR()
    Tₒ = solveodepfr(; model = model, pars...)[:T]
    Tₐ = analyticalthermalpfr(; pars...)
    
    fig, ax = reactorplot(; L = c.L)
    lines!(ax, z, Tₒ, color = :black, linewidth = 5, label = "EDO")
    lines!(ax, z, Tₐ, color = :red,   linewidth = 2, label = "Analítica")
    reactoraxes(@sprintf("%.2f", Tₒ[end]), ax)
    fig
end

# ╔═╡ 8a502d49-a68a-494c-966c-fda03f51b6c0
let
    case = "fluent-reference"
    data = readdlm("c01-reator-pistao/$(case)/postprocess.dat", Float64)
    x, Tₑ = data[:, 1], data[:, 2]
    
    c = Conditions()
    N = 10000
    
    z = cellcenters(c.L, c.L / N)
    ĥ = computehtc(c)

    P  = 2π * c.R
    A  = π * c.R^2

    pars = (P = P, A = A, Tₛ = c.Tₛ, Tₚ = c.Tₚ,
            ĥ = ĥ, u = c.u, ρ = c.ρ, cₚ = c.cₚ,
            z  = z)
    
    model = DifferentialEquationPFR()
    Tₒ = solveodepfr(; model = model, pars...)[:T]
    Tₐ = analyticalthermalpfr(; pars...)
    
    fig, ax = reactorplot(; L = c.L)
    lines!(ax, z, Tₒ, color = :black, linewidth = 5, label = "EDO")
    lines!(ax, z, Tₐ, color = :red,   linewidth = 2, label = "Analítica")
    lines!(ax, x, Tₑ, color = :blue,  linewidth = 2, label = "CFD")

    for N in [20, 100]
        z, T = solvethermalpfr(c, N, ĥ)
        stairs!(ax, z, T; label = "N = $(N)", step = :center)
        Tend = @sprintf("%.1f", T[end])
    end
    
    reactoraxes(@sprintf("%.2f", Tₒ[end]), ax)
    fig
end

# ╔═╡ e8b9773c-be88-4d68-8874-060945ed08bf
figh, residuals = let
    case = "fluent-reference"
    # case = "constant-properties"
    data = readdlm("c01-reator-pistao/$(case)/postprocess.dat", Float64)
    
    c = Conditions()

    N = 1000

    # TODO mudar interface e fornecer raio e deixar δ como interno!
    model = EnthalpyPFR(;
        h = (T) -> c.cₚ * T,
        ρ = c.ρ,
        u = c.u,
        r = c.R / (2c.L/N),
        ĥ = computehtc(c),
        L = c.L,
        Tₚ = c.Tₚ,
        Tₛ = c.Tₛ,
        N = N
    )
    
    z, T, residual = model()

    fig, ax = reactorplot(; L = c.L)
    lines!(ax, data[:, 1], data[:, 2], color=:black, label = "CFD")
    stairs!(ax, z, T; label = "N = $(N)", step = :center)
    ax.title = "Temperatura final = $(@sprintf("%.1f", T[end])) K"
    ax.yticks = range(300, 400, 6)
    ylims!(ax, (300, 400))
    axislegend(position = :rb)
    fig, residual
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
    ax.yticks = range(-15, 5, 5)
    xlims!(ax, (0, n))
    ylims!(ax, (-15, 5))
    fig
end

# ╔═╡ f9b1527e-0d91-490b-95f6-13b649fe61db
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─bdbaf01f-6600-49e3-a459-76448bdd61c0
# ╟─133ec2e4-34f9-4f2f-bd75-a601efc2d2d4
# ╟─53c7c127-9b25-4dd3-8e25-82f64c15b70e
# ╟─008e881f-2d7b-42ca-b16d-6d9369583d7f
# ╟─53f1cba1-130f-4bb2-bf64-5e948b38b2c7
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
# ╟─9eb2dbcb-cb78-479c-a2d4-2f45cdf37e19
# ╟─69a8f137-eea6-4088-b973-5b68fa706e19
# ╟─a28774b0-0e2c-4a49-87f0-daf7ceb72766
# ╟─a82921d7-fb98-4f33-bc1e-df592fbaa7aa
# ╟─e08d8341-f3a5-4ff1-b18e-19e9a0757b24
# ╟─6f2ead8f-9626-4418-8453-f8964016b5d3
# ╟─8a502d49-a68a-494c-966c-fda03f51b6c0
# ╟─7c43c2e5-98da-4e35-8f06-1a301f02cfec
# ╟─4ff853d4-6747-46ac-b569-55febe550a27
# ╟─8cf8d53e-aa26-4376-8973-be73791b90f4
# ╟─7f826838-e7a7-4853-ac2e-d7ae6ca33da1
# ╟─eecddd3e-81b6-452b-876d-fd8e76f96684
# ╠═e8b9773c-be88-4d68-8874-060945ed08bf
# ╟─11aadef3-2ab9-45f9-8e8b-f33c8f7d39e3
# ╠═6e981934-8a73-4302-b810-f2ffb058eaf1
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─1cf0a5eb-6f80-4105-8f21-a731583a7665
# ╟─30f97d5b-e1de-4593-b451-1bd42156a4fc
# ╟─96e44c91-06c3-4b9f-bdaa-55919d2e13f0
# ╟─530a7c51-e3ad-429a-890f-136fa63ff404
# ╟─4ac709ca-586c-41f8-a239-90b4c885ad7e
# ╟─21322737-95e7-4ca3-840a-91351880755a
# ╟─8b69fbf0-73f8-4297-b810-7cc17486712e
# ╟─cba4b197-9cbf-4c6d-9a5c-79dd212953dc
# ╟─f9687d19-1fc9-40b1-97b1-365b80061a1b
# ╟─f9b1527e-0d91-490b-95f6-13b649fe61db
# ╠═92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
