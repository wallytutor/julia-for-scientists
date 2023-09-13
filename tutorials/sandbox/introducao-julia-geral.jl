### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ d9a638f7-2b1b-42b2-b4a8-9639d8083ba5
using Colors

# ╔═╡ b01ed707-d25c-4552-8a3a-2b8992d4cca4
using BenchmarkTools

# ╔═╡ 8152de0c-9c1d-400b-9d0a-5af8c4290d13
using PythonCall

# ╔═╡ 8427738c-7d0e-49a9-897c-8eaba766fede
# https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#LinearAlgebra.cross
using LinearAlgebra

# ╔═╡ ee43291c-fdd6-482e-b981-3478989679ed


# ╔═╡ f57557b9-15f6-4fdf-8186-9de5a136f810
md"""
### *Tuples*

Uma *tuple* é constituída de uma sequência de elementos, que podem ser de tipos diferentes, declarada entre parêntesis. A característica de base de uma *tuple* é sua imutabilidade: uma vez declarada, seus elementos não podem ser alterados.

!!! note "Já vimos isso antes"

	Voltando a seção aonde realizamos a conversão explícita de tipos acima, você pode verificar que na realidade já utilizamos uma tuple de números indicando as intensidades RGB de uma cor.

Declaremos uma sequência fixa de linguagens de programação dadas por seus nomes como `Strings`:
"""

# ╔═╡ 836147d1-3e4b-4277-b58a-cdb6266002d2
languages = ("Julia", "Python", "Octave")

# ╔═╡ 95980d0d-3c7d-4dbd-bb4e-536636dc7c11
md"""
Inspecionando o tipo desta variável aprendemos mais uma característica importante inerente a definição de `Tuple` feita acima quanto ao seu caráter imutável: o tipo de uma `Tuple` inclui individualmente o tipo de cada um de seus elementos. Dito de outra maneira, uma sequência composta de um número definido de objetos de dados tipos caracteriza por ela mesmo um novo tipo de dados.
"""

# ╔═╡ 538ee6c8-f730-4d5d-9014-3b4ab094c836
typeof(languages)

# ╔═╡ 5fcb53a1-ec70-4314-b994-9a763c42cd73
md"""
Os elementos de uma `Tuple` podem ser acessados por seus índices.

!!! warning "Indices em Julia"

	É o momento de mencionar que em Julia a indexação inicia com `1`.
"""

# ╔═╡ 028f2560-9f2a-47af-a705-94c451a59059
languages[1]

# ╔═╡ 4703820d-90c8-4c57-8437-d480b7bf2081
md"""
Vamos tentar modificar o segundo elemento da `Tuple`.

!!! tip "Sintaxe de controle de erros"

	Ainda é cedo para entrar nos detalhes, mas aproveite o bloco abaixo para ter um primeiro contato com a gestão de erros em Julia.
"""

# ╔═╡ e3641a9c-9e39-4dda-ba01-c9a25286f522
try 
	languages[2] = "C++"
catch err
	println("Erro: $(err)")
end

# ╔═╡ eeaa729a-18f7-4cab-a1b8-bb1d80429032
md"""
Existem certas subtilidades que você precisa saber sobre a imutabilidade. Observe o exemplo abaixo, aonde declaramos duas variáveis que são utilizadas para construir uma `Tuple` e então modificamos uma das variáveis: a `Tuple` continua com os valores originais do momento da sua construção.
"""

# ╔═╡ eb3e0a32-84cc-48f4-92a9-c644895ba0e3
begin
	var1 = 1;
	var2 = 2;
	
	test_tuple1 = (var1, var2);
	
	var1 = 5;
	test_tuple1
end

# ╔═╡ fdf4ef9c-04fd-4390-9a5d-3cb1b73dd399
md"""
!!! danger "Isso nem sempre é verdade!"

	Se o elemento compondo a `Tuple` for de um tipo mutável, como é o caso de `Array`'s, como veremos no que se segue, os elementos desta variável podem ser modificados e impactam a `Tuple` diretamente. Isso se dá porque neste caso a `Tuple` conserva a referência ao objeto em questão, e não uma cópia dos valores, como é o caso para tipos de base.
"""

# ╔═╡ ca4a685a-2ad9-4539-ac4c-5cbb1d339e38
begin
	var3 = [1, 2];
	
	test_tuple2 = (var1, var3);
	
	var3[1] = 999;
	test_tuple2
end

# ╔═╡ 72bf5bc0-00ae-4dd5-a903-578ca45992ea
md"""
### *Named tuples*

Esta extensão à `Tuples` adiciona a possibilidade de acesso aos componentes por um *nome* no lugar de um simples índice -- que continua funcional como veremos abaixo. Esse tipo de estrutura é bastante útil quando necessitamos criar abstrações de coisas bastante simples para as quais a criação de um novo tipo não se justifica. Discutiremos mais tarde quando vamos estudar a criação de *novos tipos*.
"""

# ╔═╡ df9616b6-ede4-4d91-a1d4-32dd0a77db12
named_languages = (julia = "Julia", python = "Python")

# ╔═╡ cd53e126-89e2-4692-9c3e-f0c15fc29de9
md"""
Observe o fato de que agora os nomes utilizados no índex fazem parte do tipo.
"""

# ╔═╡ c1d8e0e9-e583-4bd2-9284-fcc2b05f2e3a
typeof(named_languages)

# ╔═╡ 60dcce80-de1c-416b-bfd2-87b347bddb6c
md"""
Abaixo verificamos que além do acesso por nomes, `NamedTuples` também respeitam a ordem de declaração dos elementos: `:julia` é o primeiro índice. A sintaxe de acesso aos elementos neste caso é com a notação típica utilizando um ponto, comum a diversas linguages de programação.
"""

# ╔═╡ 5cb80948-e298-483f-8aae-beba7cf0c586
named_languages[1] == named_languages.julia

# ╔═╡ d81716d8-3146-48b7-a095-432d2c960ebd
md"""
### Dicionários

Objetos do tipo `Dict` possuem a similaridade com `NamedTuples` em que seus elementos podem ser acessados por nome. No entanto a sintaxe é diferente e os valores desta estrutura são mutáveis.
"""

# ╔═╡ ad9b36c0-e5d4-442a-9758-3ff497dfac1f
organs = Dict("brain" => "🧠", "heart" => "❤")

# ╔═╡ 25dab418-b1ec-494b-802e-f9b874acce0f
md"""
O acesso a elementos se faz com colchetes contendo o índex como se segue:
"""

# ╔═╡ 586d6ca6-d160-4c3c-9eb5-054712ab323c
organs["brain"]

# ╔═╡ 43589dee-139d-41ba-a9f1-b53f6eafb677
md"""
E como dissemos, os elementos são mutáveis: vamos atribuir um burrito ao cérebro.
"""

# ╔═╡ 96da8c59-190b-451a-b4c5-4b4a13d8c284
organs["brain"] = "🌯"

# ╔═╡ eabfcb68-f311-4c67-b82e-8b0adaca013c
md"""
Não só os elementos, mas o dicionário como um todo, pode ser alterado. Para adicionar novos elementos simplesmente *acessamos* a palavra-chave e atribuímos um valor:
"""

# ╔═╡ 89c87cbf-07f2-461f-89cc-09404272708c
organs["eyes"] = "👀"

# ╔═╡ 292824db-d029-49a8-a1db-9b930359e8bb
md"""
Internamente para evitar nova alocação de memória a cada tentativa de se adicionar um novo elemento, um dicionário realiza a alocação de `slots` que são renovados cada vez que sua capacidade é ultrapassada. Observe que a lista retornada abaixo é composta majoritariamente de `0x00`, que é o endereço de memória nulo, enquanto 3 elementos indicam um valor não-nulo, correspondendo aos elementos já adicionados ao dicionário. Disto vemos que adicionalmente um dicionário não preserva necessariamente uma sequência ordenada. Esses detalhes ultrapassam o presente escopo mas vão abrindo as portas para assuntos mais complexos. 
"""

# ╔═╡ ae336d80-b84d-4da6-89bc-81c9f1cf8591
organs.slots

# ╔═╡ 945285a3-5ee3-4885-9012-de9e3dc71df6
organs

# ╔═╡ 150a84c3-0858-4889-953c-d8ddbb69e384
md"""
Para remover elementos utilizamos a função `pop!`. Por convenção em Julia, funções que terminam por um ponto de exclamação modificam os argumentos que são passados. No caso de `pop!` o dicionário é modificado e o valor de retorno é aquele do elemento removido.
"""

# ╔═╡ 1900d8a9-d54d-4b26-b250-96170052c605
pop!(organs, "brain")

# ╔═╡ 88e7a7b3-fa34-487b-ab5c-3cf4e3355bda
md"""
A tentativa de remover um elemento inexistente obviamente conduz à um erro:
"""

# ╔═╡ 5c582489-ba64-47be-8f46-1e1bdd6112ed
try
	pop!(organs, "leg")
catch err
	println("Erro: $(err)")
end

# ╔═╡ c553dc66-2352-4037-9b84-84e9b8323c8e
organs

# ╔═╡ e306855c-d2e6-4b8a-907e-007322382d07
md"""
Para evitar essa possibilidade podemos usar a função `haskey()`.
"""

# ╔═╡ 2bcdb75c-26b8-4fb7-9314-596a721186df
haskey(organs, "liver")

# ╔═╡ 8caaf9aa-134a-4466-8635-4dde3a181082
md"""
Uma última coisa a notar é que *praticamente* qualquer tipo básico pode ser empregado como a chave de um dicionário em Julia. Veja o exemplo à seguir:
"""

# ╔═╡ d4d83311-7402-41b7-8c1e-b35806ea6492
music = Dict(:violin => "🎻", 1 => 2)

# ╔═╡ edce5c44-56cb-4ab2-aea3-cb1098e2239a
md"""
Como as chaves são de tipos diferentes (um `Symbol` e um `Int64`), assim como os valores (uma `String` e um `Int64`), a função `typeof()` nos retorna tipos `Any`.
"""

# ╔═╡ 1ed6c78d-bbb1-420d-8306-f825a08a284a
typeof(music)

# ╔═╡ 5840dc33-6db4-4aca-b496-2f23bf4035be
md"""
### *Arrays*

A estrutura `Array` se diferencia de `Tuple` pelo fato de ser mutável e de `Dict` pela noção de ordem. Dadas essas características não é surpreendente que seja esse o tipo de base sobre o qual Julia constrói vetores e matrizes, embora um `Array` seja mais genérico que esses conceitos matemáticos. Podemos, por exemplo, construir um `Array` contendo sub-`Array`'s de tamanho variável, o que não constituiria uma matriz. Ou então misturar tipos de dados nos elementos de um `Array`, como mostramos ser possível com `Tuple`.

Em termos de sintaxe, usamos nesse caso colchetes `[]` para limitar a sequência.

Considere por exemplo a seguinte lista de países...
"""

# ╔═╡ 1742e850-a40d-4121-8419-4e57b20a9662
countries = ["France", "Brazil", "Germany"]

# ╔═╡ 84aa69fb-5be5-4dd4-90ff-31bbed5bd3d1
md"""
...ou então de números,...
"""

# ╔═╡ 75f552be-4102-4c5d-abf2-08e2d4e6d4c0
numbers = [1, 2, 3.1]

# ╔═╡ 9569d1f1-20ab-42e0-97e1-b5e131e158b8
md"""
..., ou simplesmente informações pessoais.
"""

# ╔═╡ d8c00413-82ec-4a03-b840-925160835d4e
personal_info = ["Walter", 34, "Lyon"]

# ╔═╡ 3af42ca4-1e78-4f44-9702-f0aeb97123c5
md"""
O acesso a elementos se faz através de índices, como em `Tuple`.
"""

# ╔═╡ 22133960-c154-4293-83ba-f15b26ada104
personal_info[2]

# ╔═╡ 42140a89-2731-4e41-b92d-467cbd99e21e
md"""
Como essa estrutura é mutável ela suporta -- [entre muitos outros](https://docs.julialang.org/en/v1/base/arrays/) -- o método `push!()` para se adicionar um elemento após o último.
"""

# ╔═╡ a910ddd8-8c2f-43d8-bb16-e649d4262081
push!(personal_info, "Engineer")

# ╔═╡ 5a1a313a-1f23-44ce-bfcf-66b7ab2c0465
md"""
De maneira similar ao que vimos para `Dict`, uma implementação de `pop!()` é disponível para o tipo `Array`, realizando a operação inversa de `push!()`.
"""

# ╔═╡ 3655f0da-39d3-4137-886b-54b33b0e49e2
pop!(personal_info)

# ╔═╡ a86488ee-ff0c-4eea-9225-fa9c03309eb3
md"""
O exemplo de uma *não-matriz* citado na introdução é apresentado a seguir.
"""

# ╔═╡ 3a028952-519a-4508-bf40-18ba68f05780
not_a_matrix = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]

# ╔═╡ 3886c204-ac60-4258-97ae-af89c80d63ba
md"""
Usando `typeof()` descobrimos que se trata de um `Vector` de `Vector` e que na verdade Julia usa `Vector` com um *alias* para um `Array{T, 1}`, aonde `T` denota o tipo de dado.
"""

# ╔═╡ 0bb35344-2e5c-4f69-b167-b35404613691
typeof(not_a_matrix)

# ╔═╡ 2acac8b8-4646-4069-bec0-bc9d11708e79
md"""
A função [`rand()`](https://docs.julialang.org/en/v1/stdlib/Random/#Base.rand) pode ser usada para criar uma matriz de números aleatórios -- e outras estruturas de ordem superior -- como se segue. Observe o tipo `Matrix{Float64}` indicado.
"""

# ╔═╡ 34296fa9-585f-4984-b8ad-0ff79f5cda93
a_matrix = rand(3, 3)

# ╔═╡ bd4b503d-4929-43d1-8a06-30c004d6cddd
md"""
Repetindo a verificação de tipo como fizemos para of *vetor de vetores* anteriormente, descobrimos que uma `Matrix` em Julia não é interpretada da mesma maneira, mas como um `Array` com duas dimensões. Isso é a forma que a linguagem emprega para assegurar as dimensões constantes segundo cada direção da matriz.
"""

# ╔═╡ d9327f86-9670-4549-ba8b-18272abe2aa0
typeof(a_matrix)

# ╔═╡ 3c56c5b3-e306-4594-ac5f-d9b144ee4d19
md"""
Vamos agora atribuir nossa `a_matrix` à uma outra variável e então modificar a matrix original.
"""

# ╔═╡ d952ec3f-8ffa-4e15-bce9-5dbdf1ab6175
begin
	maybe_another_matrix = a_matrix
	a_matrix[1, 1] = 999
	a_matrix
end

# ╔═╡ 46262c79-cf75-46cf-b090-3e6614ee3ad1
md"""
Tal como para a `Tuple` com objetos mutáveis, atribuir um novo nome à uma matriz não cria uma nova matriz, apenas referencia o seu endereço de memória: observamos abaixo que a tentativa de cópia `maybe_another_matriz` também é modificada em razão da operação sobre `a_matrix`.
"""

# ╔═╡ cb6c142b-6694-4e92-bf09-65b947746742
maybe_another_matrix

# ╔═╡ d3e39397-f1d1-4773-82c0-f082134260b2
md"""
Quando uma cópia da matriz é necessária devemos utilizar `copy()`. Nas próximas células criamos uma matriz e então uma cópia, a qual é modificada, e verificamos não haver impacto na matriz original, validando a cópia em um novo endereço de memória.
"""

# ╔═╡ d7e05bf7-ffdf-4551-b4e8-d987dbd6fa6a
begin
	another_matrix = rand(2, 2)
	another_matrix
end

# ╔═╡ cbe50047-720a-40fe-a39e-b81438896045
begin
	again_a_matrix = copy(another_matrix)
	again_a_matrix[1, 2] = 0;
	again_a_matrix
end

# ╔═╡ a858b440-38b3-44af-b8a9-456b5738db87
another_matrix

# ╔═╡ 3a26ea95-a3a0-44c6-b38e-29040bbbaf18
md"""
### *Ranges*
"""

# ╔═╡ 1197e4a7-3c95-43ec-9bd9-e3253a8234d6
range_of_numbers = 1:10

# ╔═╡ c92d1f01-76bb-4f4c-a00b-f6f00e1b9fe8
md"""
"""

# ╔═╡ 5b04a964-3d43-49c2-b8bd-4e3aeab05356
typeof(range_of_numbers)

# ╔═╡ a7c070bc-1778-4285-a84e-518547dc9b99
md"""
"""

# ╔═╡ 55b1ed1e-3e13-4762-bdb8-7bfc2982d46c
collect(range_of_numbers)

# ╔═╡ f1470ec3-fe8f-449e-9405-bd50b9e8f853
md"""
"""

# ╔═╡ 178aa45a-f908-415f-835d-37b3311ce3a9
float_range = 1:0.6:10

# ╔═╡ 208539f4-8ea8-4564-aad7-a21df37f0929
md"""
"""

# ╔═╡ c5ddbaed-7ff8-4090-8020-1ec06bc59ca7
collect(float_range)

# ╔═╡ 0824c647-9b20-4ac7-896b-dbc419f35f08
md"""
"""

# ╔═╡ 6504a38d-621c-4140-8ea5-876942ec25c9
typeof(float_range)

# ╔═╡ 49bf987f-3c8a-4652-aa03-8eca45fa173a
md"""
## Atribuição de tipos
"""

# ╔═╡ 8eafed32-f8cf-481c-99f7-5285499ec3be


# ╔═╡ cd06fe4e-0a00-4332-9d6c-8ccda8be6fcc
md"""
## Laços e condicionais
"""

# ╔═╡ 6a706e32-caba-4c23-9a7f-9b649324de32
md"""
### Laços predeterminados
"""

# ╔═╡ 5c9faf63-9de4-4349-bf22-f4509f729945
for k in 1:5
    println("k = $(k)")
end

# ╔═╡ 651ad85b-7d96-4eaf-b98c-87ad5f5dcdb3
md"""
### Laços condicionais
"""

# ╔═╡ aaf67d41-126d-42da-bcac-9f962ea02d59
begin
	count = 0
	
	while count < 100
	    count += 1
	    
	    if count > 7
	        break
	    elseif count > 5
	        continue
	    else
	        println("count = $(count)")
	    end
	end
	
	count
end

# ╔═╡ 71ff7cbd-a928-4b23-bf6f-aacbff15c774
md"""
### Exemplos com matrizes
"""

# ╔═╡ 3ff3624d-f4d9-44dc-9336-f43336190e01
begin
	nrows = 3
	ncols = 4
	
	A = fill(0, (nrows, ncols))
end

# ╔═╡ 7e5b8031-e130-4374-80df-3893be560bc5
begin
	for j in 1:ncols
	    for i in 1:nrows
	        A[i, j] = i + j
	    end
	end
	
	A
end

# ╔═╡ 6213683a-9502-449e-9609-435098231c1c
begin
	B = fill(0, (nrows, ncols))
	
	for j in 1:ncols, i in 1:nrows
	    B[i, j] = i + j
	end
	
	B
end

# ╔═╡ 2ddf06a7-8378-4f99-96bd-246c16e4c8da
b = [α^β for α in 1:5, β in 2:5]

# ╔═╡ ae05c863-f1fe-41e8-9afb-8b4140cb5fbe
length(b)

# ╔═╡ 5a7238d8-7a5b-4bef-adb9-a654e506f3ec
sum(1:10)

# ╔═╡ 198a058d-da0b-4ff9-8c72-e57f878eacca
md"""
### Operador ternário
"""

# ╔═╡ d2146125-a558-4084-9fe9-073603cfa0a1
answer1 = (1 < 2) ? true : false

# ╔═╡ d41b8a94-502b-477e-80c9-c526deb01d12
answer2 = if (1 < 2) true else false end

# ╔═╡ 3bbad29a-e045-4442-9cd9-a2b4f5acdc09
md"""
### Avaliações em curto-circuito
"""

# ╔═╡ 5ac1f338-1b06-4405-b41e-e59d64e01ce8
(2 > 0) && println("2 é maior que 0")

# ╔═╡ ce078faa-0f95-47b8-86a4-6aa9c2ddf578
(2 < 0) && println("esse código não executa")

# ╔═╡ 7c8c5602-5477-46b2-acff-983275cd9120
true || print("não será avaliado")

# ╔═╡ c566aada-4eae-48d0-a59d-a691c060f163
false || print("será avaliado")

# ╔═╡ 0ed128d3-9a20-477d-8593-e79ebdfe78f2
md"""
### Controle de excessões
"""

# ╔═╡ d3a72eb2-4fb1-4d57-8212-905d1f5ffc03
try
	unsignedx::UInt8 = 13;
	unsignedx = 256;
catch err
	println("Error: $(err)")
end

# ╔═╡ b71637f1-4fa3-4d76-90cc-4b046eefae6f
try
	var = "bolo";
	throw(DomainError(var, "Não quero $(var)!"))
catch err
	println("Error: $(err)")
end

# ╔═╡ 6fa6185b-dd36-4ee9-8e00-46332c88dc8c
try
	error("Pare já!")
catch err
	println("Error: $(err)")
end

# ╔═╡ cfa4add3-4099-48f4-bdfc-f0d47116dcd6
md"""
## Funções e despacho múltiplo
"""

# ╔═╡ 26cb00c5-d7d8-4823-bbf5-acaf3bb305c8
md"""
### Funções fundamentais
"""

# ╔═╡ ce9c9473-6588-48a0-8ebe-f67f0cf8132f
function sayhi(name)
    println("Hi $name, it's great to see you!")
end

# ╔═╡ 0ea91607-b465-4956-97ec-2401f802b8d0
function f(x)
    x^2
end

# ╔═╡ 1b73a75c-d4af-44bb-8a45-20328c236c32
sayhi("C-3PO")

# ╔═╡ 04f634ca-4fb7-479c-b7e6-932bc86f7317
f(42)

# ╔═╡ ea6769cf-8a5a-4ce5-9a60-1dce936a22aa
md"""
### Funções *inline*
"""

# ╔═╡ c87b813d-2e9f-424b-9851-eb96ea6bbc2c
sayhi2(name) = println("Hi $name, it's great to see you!")

# ╔═╡ 716f9c3b-19cf-48cd-8891-40d3f39e8df1
f2(x) = x^2

# ╔═╡ 9c219e9b-471c-4ac4-bcdb-87b5d8d00946
sayhi2("R2D2")

# ╔═╡ cd1278f0-4141-49ef-b816-70be1b31cab5
f2(42)

# ╔═╡ 99f38df2-1b7a-4270-9afc-df90165134ee
md"""
### Funções anônimas
"""

# ╔═╡ c194e060-e256-4429-84da-0f33aef00239
sayhi3 = name -> println("Hi $name, it's great to see you!")

# ╔═╡ ce5ad935-61c4-4c20-840b-1333d4f10e1c
f3 = x -> x^2

# ╔═╡ e4568614-1750-4176-a004-0b60d01f76f8
sayhi3("Chewbacca")

# ╔═╡ d95fdbd0-6452-4b44-9fec-11662e155641
f3(42)

# ╔═╡ 842c2683-9beb-478f-977e-1ee2c647e0ac
md"""
### *Duck-typing*
"""

# ╔═╡ 161a8e84-4585-4835-99d8-b7a25a83df6b
sayhi(55595472)

# ╔═╡ a8510fcd-e0b6-4353-bf7d-b3904463545c
f(rand(3, 3))

# ╔═╡ 464e1ca1-44b0-4924-b2df-5ef6692da5b9
f("hi")

# ╔═╡ 2b8b7796-b8da-4880-ae84-28c59cd7e9fb
try
	f(rand(3))
catch err
	println("Erro: $(err)")
end

# ╔═╡ 710db65f-47b8-4a27-bc01-733953c27701
md"""
### Funções mutantes
"""

# ╔═╡ 0c3a1741-6719-4289-be5d-4699d24aec49
v = [3, 5, 2]

# ╔═╡ 77ab637b-c376-4795-9a09-243a78762a13
sort(v), v

# ╔═╡ 1bcef17d-da25-4bc5-b407-899b3dc62494
sort!(v), v

# ╔═╡ d4e508c4-06db-4a25-8901-46bd27433f0f
md"""
### Funções de ordem superior
"""

# ╔═╡ 343152fe-6008-4acd-9626-c53f935de11e
map(f, [1, 2, 3])

# ╔═╡ ad12396c-5180-4bb5-8783-5570cd7308d2
map(x -> x^3, [1, 2, 3])

# ╔═╡ 5f1e0231-d402-47b1-8aa6-79dd0d193326
broadcast(f, [1, 2, 3])

# ╔═╡ 7bb9b556-64b0-40b5-8ecc-ee70a58b20ea
md"""
Some syntactic sugar for calling broadcast is to place a . between the name of the function you want to broadcast and its input arguments. For example,

broadcast(f, [1, 2, 3])
is the same as

f.([1, 2, 3])
"""

# ╔═╡ bac4d9b1-e9fe-4226-ba4a-26df6e0dd61b
f.([1, 2, 3])

# ╔═╡ 0f1db661-37f4-4acd-b72a-2339439e0b89
M = [i + 3*j for j in 0:2, i in 1:3]

# ╔═╡ df9e5a3e-b4df-4457-bf8e-59ceeed5f777
f(M)

# ╔═╡ 9b53f1fa-fe23-45ec-aee7-37f2c57e0b8c
f.(M)

# ╔═╡ 94eec946-853a-46e7-b89d-a490975d7f2b
M .+ 2 .* f.(M) ./ M

# ╔═╡ 8fc5f22f-3a52-4e5d-9d56-db5eaa6323c3
broadcast(x -> x + 2 * f(x) / x, M)

# ╔═╡ b64ad44c-9f53-4db8-863c-71d38d4dc18a
md"""
### Despacho múltiplo
"""

# ╔═╡ f8053bc7-1a87-47de-893f-9aeba087b0a0
foo(x::String, y::String) = println("My inputs x and y are both strings!")

# ╔═╡ 958f584d-5419-4bc1-b624-375b7b5caae2
foo(x::Int, y::Int) = println("My inputs x and y are both integers!")

# ╔═╡ 4ecdf29e-59d4-49a2-bfa4-6f27530ce6ae
methods(cd)

# ╔═╡ d7ca878f-9f7d-4a73-8a07-dd1cf03d7eff
@which 3.0 + 3.0

# ╔═╡ 9ccc30fd-7bb1-4408-881a-7e178309e3f0
foo(x::Number, y::Number) = println("My inputs x and y are both numbers!")

# ╔═╡ bad8d7d5-721c-42cf-9c5f-4a735a7a6865
foo(x, y) = println("I accept inputs of any type!")

# ╔═╡ 14ccfb9e-ff0f-41e9-8596-8bede1aa317f
foo("hello", "hi!")

# ╔═╡ aed9af2a-c89f-496c-a9ac-8736e0d7f340
foo(3, 4)

# ╔═╡ 6640fb3e-a639-429f-beda-9de0ef3e5eca
methods(foo)

# ╔═╡ 87ca1620-537f-483c-81e7-d597f7fb4d1f
@which foo(3, 4)

# ╔═╡ ad445cd3-2e18-4b0e-a954-b7f08bd09e17
@which foo(3, 4)

# ╔═╡ 2e9a16ab-589d-4f56-886e-ef321b3fe74f
@which foo(3.0, 4)

# ╔═╡ d43495a2-db23-4275-b15d-46fce6c64efa
foo(rand(3), "who are you")

# ╔═╡ afd1fe1c-927f-41ac-9680-7171ec073fb7
md"""
## Pacotes e ecossistema

https://julialang.org/packages/

```julia
using Pkg

Pkg.add("Colors")
```
"""

# ╔═╡ 6713b0b3-c99f-40af-a4d7-d3362a205dfb
palette = distinguishable_colors(50)

# ╔═╡ f8b2fcfb-3802-47f9-bca7-b392ebc09964
rand(palette, 3, 3)

# ╔═╡ 97bc1bb2-95cd-478a-836a-cea9caeca568
md"""
## Avaliando performance
"""

# ╔═╡ 825c967e-47a8-4457-a937-c9a162ae4671
md"""

```julia
using CondaPkg

CondaPkg.add("numpy")
```
"""

# ╔═╡ b0716047-d1e9-421a-a8ab-cab2b4b8e610
npsum = pyimport("numpy").sum

# ╔═╡ 37579c02-2c79-4d1d-8039-7a3500e784e3
function jlsum(a)
	val = 0.0;
	for v in a
		val += v;
	end
	return val
end

# ╔═╡ 75aae357-2af9-4752-ba1e-e885fb43ec4b
function jlsumsimd(A)   
    s = 0.0 # s = zero(eltype(A))
    @simd for a in A
        s += a
    end
    s
end

# ╔═╡ 23274c5b-6081-405b-9bda-93b45156b952
arands = rand(10^7);

# ╔═╡ c1249bb5-4327-4c2a-b82c-c05f566888e2
@benchmark $pybuiltins.sum($arands)

# ╔═╡ 59b3d5bb-93c3-4e2c-beeb-a93620ab125e
@benchmark $npsum($arands)

# ╔═╡ 7d137542-5a38-4ae3-b6ec-8b6fd6840c94
@benchmark jlsum($arands)

# ╔═╡ a02dd5f4-c9f4-408e-9e98-282593d41106
@benchmark jlsumsimd($arands)

# ╔═╡ 079d7d61-e790-4144-9eb6-d451c6194a50
@benchmark sum($arands)

# ╔═╡ a0eafb7a-6788-4c08-ab7c-55a3dd6b79d5
@which sum(arands)

# ╔═╡ a22ae871-38a4-4280-b1a2-e6fdc7732a34
sum(arands) ≈ jlsum(arands)

# ╔═╡ 91412e9b-f0e6-4b61-9bb7-600b974239a8
sum(arands) ≈ pyconvert(Float64, npsum(arands))

# ╔═╡ 2d2e595b-0ffb-4e21-8bda-08419221ba7e
md"""
## Elementos de álgebra linear
"""

# ╔═╡ de8f9f3a-88a5-45da-a2e3-593bf04022a0
A₁ = rand(1:4, 3, 3)

# ╔═╡ 0e2d2b84-4801-48d5-beff-6e4e1e4fa8ce
x = fill(1.0, 3)

# ╔═╡ fe95a603-3489-4536-b622-1afccf6a2ce3
A₁ * x

# ╔═╡ 6613f0f4-c8eb-4b01-a19e-792b51585197
A₁'

# ╔═╡ e249e68b-7b47-45f4-8251-c3df3f8dcb8f
transpose(A₁)

# ╔═╡ b8cbf8d7-01c9-4f2a-93b4-cf3d2a117856
A₁'A₁

# ╔═╡ 5f3f0cf3-ec7a-4069-8020-d684b9ea265c
A₁' * A₁

# ╔═╡ 9ab5273e-2dfd-488c-a950-15571fa7ec84
A₁ \ x

# ╔═╡ 31736d0a-0958-4e9f-a82a-b6ffdd7f3ebf
Atall = rand(3, 2)

# ╔═╡ 56489f6f-60da-4a8f-a842-2fcd51873958
md"""
A\b gives us the least squares solution if we have an overdetermined linear system (a "tall" matrix) and the minimum norm least squares solution if we have a rank-deficient least squares problem
"""

# ╔═╡ 5651b87d-80a7-4d66-a471-601d959951a7
Atall \ x

# ╔═╡ b445f276-b352-498b-b6cb-e22036e5dc35
begin
	v₁ = rand(3)
	rankdef = hcat(v₁, v₁)
end

# ╔═╡ 76f9da13-55a2-418b-a68a-9aae4950ef65
rankdef \ x

# ╔═╡ 4c34f7c4-76bf-47a7-88e3-852b96b82517
md"""
Julia also gives us the minimum norm solution when we have an underdetermined solution (a "short" matrix)
"""

# ╔═╡ 91794db9-e4de-4142-aeb8-c343b1ed0ebe
begin
	bshort = rand(2)
	Ashort = rand(2, 3)
	Ashort, bshort
end

# ╔═╡ b44552fe-bee4-4de7-be2b-51b1038f43bf
Ashort\bshort

# ╔═╡ 2945fef4-a556-4804-9365-f1a06fcb9571
LinearAlgebra.dot([1 1], [1 1])

# ╔═╡ e96b2bce-d095-42da-9b79-11552bd26ab0
LinearAlgebra.kron(v₁', v₁)

# ╔═╡ fb44687c-4e14-4b4d-84a9-2a2f13708d26
u = [1, 2, 3]

# ╔═╡ b33bea47-01bc-4ac0-b8b2-cc2a10681bb8
kron(u', u)

# ╔═╡ 3c4320db-fb39-4e39-8f7b-4b36b059e0c5
cross(u, u)

# ╔═╡ 1f62aeb7-a379-420c-9f35-1a91f0d34be7
md"""
## Expressões regulares
"""

# ╔═╡ 4108e7bd-519a-4614-86f4-3b32ba4933b6
md"""
## Execução concorrente

## Leitura e escritura de arquivos

## Metaprogramação
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"

[compat]
BenchmarkTools = "~1.3.2"
Colors = "~0.12.10"
PythonCall = "~0.9.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "3a8b8a600e9b79c8012cc19d155b84c32dafd2c0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.CondaPkg]]
deps = ["JSON3", "Markdown", "MicroMamba", "Pidfile", "Pkg", "TOML"]
git-tree-sha1 = "741146cf2ced5859faae76a84b541aa9af1a78bb"
uuid = "992eb4ea-22a4-4c89-a5bb-47a3300528ab"
version = "0.2.18"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "5b62d93f2582b09e469b3099d839c2d2ebf5066d"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicroMamba]]
deps = ["Pkg", "Scratch", "micromamba_jll"]
git-tree-sha1 = "011cab361eae7bcd7d278f0a7a00ff9c69000c51"
uuid = "0b3b1443-0f03-428d-bdfb-f27f9c1191ea"
version = "0.1.14"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pidfile]]
deps = ["FileWatching", "Test"]
git-tree-sha1 = "2d8aaf8ee10df53d0dfb9b8ee44ae7c04ced2b03"
uuid = "fa939f87-e72e-5be4-a000-7fc836dbe307"
version = "1.3.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.PythonCall]]
deps = ["CondaPkg", "Dates", "Libdl", "MacroTools", "Markdown", "Pkg", "REPL", "Requires", "Serialization", "Tables", "UnsafePointers"]
git-tree-sha1 = "70af6bdbde63d7d0a4ea99f3e890ebdb55e9d464"
uuid = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
version = "0.9.14"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafePointers]]
git-tree-sha1 = "c81331b3b2e60a982be57c046ec91f599ede674a"
uuid = "e17b2a0c-0bdf-430a-bd0c-3a23cae4ff39"
version = "1.0.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.7.0+0"

[[deps.micromamba_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "ed38e87f1a2f42427603a2a188b4ec5d9d28fb44"
uuid = "f8abcde7-e9b7-5caa-b8af-a437887ae8e4"
version = "1.4.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═ee43291c-fdd6-482e-b981-3478989679ed
# ╟─f57557b9-15f6-4fdf-8186-9de5a136f810
# ╠═836147d1-3e4b-4277-b58a-cdb6266002d2
# ╟─95980d0d-3c7d-4dbd-bb4e-536636dc7c11
# ╠═538ee6c8-f730-4d5d-9014-3b4ab094c836
# ╟─5fcb53a1-ec70-4314-b994-9a763c42cd73
# ╠═028f2560-9f2a-47af-a705-94c451a59059
# ╟─4703820d-90c8-4c57-8437-d480b7bf2081
# ╠═e3641a9c-9e39-4dda-ba01-c9a25286f522
# ╟─eeaa729a-18f7-4cab-a1b8-bb1d80429032
# ╠═eb3e0a32-84cc-48f4-92a9-c644895ba0e3
# ╟─fdf4ef9c-04fd-4390-9a5d-3cb1b73dd399
# ╠═ca4a685a-2ad9-4539-ac4c-5cbb1d339e38
# ╟─72bf5bc0-00ae-4dd5-a903-578ca45992ea
# ╠═df9616b6-ede4-4d91-a1d4-32dd0a77db12
# ╟─cd53e126-89e2-4692-9c3e-f0c15fc29de9
# ╠═c1d8e0e9-e583-4bd2-9284-fcc2b05f2e3a
# ╟─60dcce80-de1c-416b-bfd2-87b347bddb6c
# ╠═5cb80948-e298-483f-8aae-beba7cf0c586
# ╟─d81716d8-3146-48b7-a095-432d2c960ebd
# ╠═ad9b36c0-e5d4-442a-9758-3ff497dfac1f
# ╟─25dab418-b1ec-494b-802e-f9b874acce0f
# ╠═586d6ca6-d160-4c3c-9eb5-054712ab323c
# ╟─43589dee-139d-41ba-a9f1-b53f6eafb677
# ╠═96da8c59-190b-451a-b4c5-4b4a13d8c284
# ╟─eabfcb68-f311-4c67-b82e-8b0adaca013c
# ╠═89c87cbf-07f2-461f-89cc-09404272708c
# ╟─292824db-d029-49a8-a1db-9b930359e8bb
# ╠═ae336d80-b84d-4da6-89bc-81c9f1cf8591
# ╠═945285a3-5ee3-4885-9012-de9e3dc71df6
# ╟─150a84c3-0858-4889-953c-d8ddbb69e384
# ╠═1900d8a9-d54d-4b26-b250-96170052c605
# ╟─88e7a7b3-fa34-487b-ab5c-3cf4e3355bda
# ╠═5c582489-ba64-47be-8f46-1e1bdd6112ed
# ╠═c553dc66-2352-4037-9b84-84e9b8323c8e
# ╟─e306855c-d2e6-4b8a-907e-007322382d07
# ╠═2bcdb75c-26b8-4fb7-9314-596a721186df
# ╟─8caaf9aa-134a-4466-8635-4dde3a181082
# ╠═d4d83311-7402-41b7-8c1e-b35806ea6492
# ╟─edce5c44-56cb-4ab2-aea3-cb1098e2239a
# ╠═1ed6c78d-bbb1-420d-8306-f825a08a284a
# ╟─5840dc33-6db4-4aca-b496-2f23bf4035be
# ╠═1742e850-a40d-4121-8419-4e57b20a9662
# ╟─84aa69fb-5be5-4dd4-90ff-31bbed5bd3d1
# ╠═75f552be-4102-4c5d-abf2-08e2d4e6d4c0
# ╟─9569d1f1-20ab-42e0-97e1-b5e131e158b8
# ╠═d8c00413-82ec-4a03-b840-925160835d4e
# ╟─3af42ca4-1e78-4f44-9702-f0aeb97123c5
# ╠═22133960-c154-4293-83ba-f15b26ada104
# ╟─42140a89-2731-4e41-b92d-467cbd99e21e
# ╠═a910ddd8-8c2f-43d8-bb16-e649d4262081
# ╟─5a1a313a-1f23-44ce-bfcf-66b7ab2c0465
# ╠═3655f0da-39d3-4137-886b-54b33b0e49e2
# ╟─a86488ee-ff0c-4eea-9225-fa9c03309eb3
# ╠═3a028952-519a-4508-bf40-18ba68f05780
# ╟─3886c204-ac60-4258-97ae-af89c80d63ba
# ╠═0bb35344-2e5c-4f69-b167-b35404613691
# ╟─2acac8b8-4646-4069-bec0-bc9d11708e79
# ╠═34296fa9-585f-4984-b8ad-0ff79f5cda93
# ╟─bd4b503d-4929-43d1-8a06-30c004d6cddd
# ╠═d9327f86-9670-4549-ba8b-18272abe2aa0
# ╟─3c56c5b3-e306-4594-ac5f-d9b144ee4d19
# ╠═d952ec3f-8ffa-4e15-bce9-5dbdf1ab6175
# ╟─46262c79-cf75-46cf-b090-3e6614ee3ad1
# ╠═cb6c142b-6694-4e92-bf09-65b947746742
# ╟─d3e39397-f1d1-4773-82c0-f082134260b2
# ╠═d7e05bf7-ffdf-4551-b4e8-d987dbd6fa6a
# ╠═cbe50047-720a-40fe-a39e-b81438896045
# ╠═a858b440-38b3-44af-b8a9-456b5738db87
# ╟─3a26ea95-a3a0-44c6-b38e-29040bbbaf18
# ╠═1197e4a7-3c95-43ec-9bd9-e3253a8234d6
# ╠═c92d1f01-76bb-4f4c-a00b-f6f00e1b9fe8
# ╠═5b04a964-3d43-49c2-b8bd-4e3aeab05356
# ╠═a7c070bc-1778-4285-a84e-518547dc9b99
# ╠═55b1ed1e-3e13-4762-bdb8-7bfc2982d46c
# ╠═f1470ec3-fe8f-449e-9405-bd50b9e8f853
# ╠═178aa45a-f908-415f-835d-37b3311ce3a9
# ╠═208539f4-8ea8-4564-aad7-a21df37f0929
# ╠═c5ddbaed-7ff8-4090-8020-1ec06bc59ca7
# ╠═0824c647-9b20-4ac7-896b-dbc419f35f08
# ╠═6504a38d-621c-4140-8ea5-876942ec25c9
# ╟─49bf987f-3c8a-4652-aa03-8eca45fa173a
# ╠═8eafed32-f8cf-481c-99f7-5285499ec3be
# ╟─cd06fe4e-0a00-4332-9d6c-8ccda8be6fcc
# ╟─6a706e32-caba-4c23-9a7f-9b649324de32
# ╠═5c9faf63-9de4-4349-bf22-f4509f729945
# ╟─651ad85b-7d96-4eaf-b98c-87ad5f5dcdb3
# ╠═aaf67d41-126d-42da-bcac-9f962ea02d59
# ╟─71ff7cbd-a928-4b23-bf6f-aacbff15c774
# ╠═3ff3624d-f4d9-44dc-9336-f43336190e01
# ╠═7e5b8031-e130-4374-80df-3893be560bc5
# ╠═6213683a-9502-449e-9609-435098231c1c
# ╠═2ddf06a7-8378-4f99-96bd-246c16e4c8da
# ╠═ae05c863-f1fe-41e8-9afb-8b4140cb5fbe
# ╠═5a7238d8-7a5b-4bef-adb9-a654e506f3ec
# ╟─198a058d-da0b-4ff9-8c72-e57f878eacca
# ╠═d2146125-a558-4084-9fe9-073603cfa0a1
# ╠═d41b8a94-502b-477e-80c9-c526deb01d12
# ╟─3bbad29a-e045-4442-9cd9-a2b4f5acdc09
# ╠═5ac1f338-1b06-4405-b41e-e59d64e01ce8
# ╠═ce078faa-0f95-47b8-86a4-6aa9c2ddf578
# ╠═7c8c5602-5477-46b2-acff-983275cd9120
# ╠═c566aada-4eae-48d0-a59d-a691c060f163
# ╟─0ed128d3-9a20-477d-8593-e79ebdfe78f2
# ╠═d3a72eb2-4fb1-4d57-8212-905d1f5ffc03
# ╠═b71637f1-4fa3-4d76-90cc-4b046eefae6f
# ╠═6fa6185b-dd36-4ee9-8e00-46332c88dc8c
# ╟─cfa4add3-4099-48f4-bdfc-f0d47116dcd6
# ╟─26cb00c5-d7d8-4823-bbf5-acaf3bb305c8
# ╠═ce9c9473-6588-48a0-8ebe-f67f0cf8132f
# ╠═0ea91607-b465-4956-97ec-2401f802b8d0
# ╠═1b73a75c-d4af-44bb-8a45-20328c236c32
# ╠═04f634ca-4fb7-479c-b7e6-932bc86f7317
# ╟─ea6769cf-8a5a-4ce5-9a60-1dce936a22aa
# ╠═c87b813d-2e9f-424b-9851-eb96ea6bbc2c
# ╠═716f9c3b-19cf-48cd-8891-40d3f39e8df1
# ╠═9c219e9b-471c-4ac4-bcdb-87b5d8d00946
# ╠═cd1278f0-4141-49ef-b816-70be1b31cab5
# ╟─99f38df2-1b7a-4270-9afc-df90165134ee
# ╠═c194e060-e256-4429-84da-0f33aef00239
# ╠═ce5ad935-61c4-4c20-840b-1333d4f10e1c
# ╠═e4568614-1750-4176-a004-0b60d01f76f8
# ╠═d95fdbd0-6452-4b44-9fec-11662e155641
# ╠═842c2683-9beb-478f-977e-1ee2c647e0ac
# ╠═161a8e84-4585-4835-99d8-b7a25a83df6b
# ╠═a8510fcd-e0b6-4353-bf7d-b3904463545c
# ╠═464e1ca1-44b0-4924-b2df-5ef6692da5b9
# ╠═2b8b7796-b8da-4880-ae84-28c59cd7e9fb
# ╟─710db65f-47b8-4a27-bc01-733953c27701
# ╠═0c3a1741-6719-4289-be5d-4699d24aec49
# ╠═77ab637b-c376-4795-9a09-243a78762a13
# ╠═1bcef17d-da25-4bc5-b407-899b3dc62494
# ╟─d4e508c4-06db-4a25-8901-46bd27433f0f
# ╠═343152fe-6008-4acd-9626-c53f935de11e
# ╠═ad12396c-5180-4bb5-8783-5570cd7308d2
# ╠═5f1e0231-d402-47b1-8aa6-79dd0d193326
# ╟─7bb9b556-64b0-40b5-8ecc-ee70a58b20ea
# ╠═bac4d9b1-e9fe-4226-ba4a-26df6e0dd61b
# ╠═0f1db661-37f4-4acd-b72a-2339439e0b89
# ╠═df9e5a3e-b4df-4457-bf8e-59ceeed5f777
# ╠═9b53f1fa-fe23-45ec-aee7-37f2c57e0b8c
# ╠═94eec946-853a-46e7-b89d-a490975d7f2b
# ╠═8fc5f22f-3a52-4e5d-9d56-db5eaa6323c3
# ╟─b64ad44c-9f53-4db8-863c-71d38d4dc18a
# ╠═f8053bc7-1a87-47de-893f-9aeba087b0a0
# ╠═958f584d-5419-4bc1-b624-375b7b5caae2
# ╠═14ccfb9e-ff0f-41e9-8596-8bede1aa317f
# ╠═aed9af2a-c89f-496c-a9ac-8736e0d7f340
# ╠═6640fb3e-a639-429f-beda-9de0ef3e5eca
# ╠═4ecdf29e-59d4-49a2-bfa4-6f27530ce6ae
# ╠═87ca1620-537f-483c-81e7-d597f7fb4d1f
# ╠═d7ca878f-9f7d-4a73-8a07-dd1cf03d7eff
# ╠═9ccc30fd-7bb1-4408-881a-7e178309e3f0
# ╠═ad445cd3-2e18-4b0e-a954-b7f08bd09e17
# ╠═2e9a16ab-589d-4f56-886e-ef321b3fe74f
# ╠═bad8d7d5-721c-42cf-9c5f-4a735a7a6865
# ╠═d43495a2-db23-4275-b15d-46fce6c64efa
# ╟─afd1fe1c-927f-41ac-9680-7171ec073fb7
# ╠═d9a638f7-2b1b-42b2-b4a8-9639d8083ba5
# ╠═6713b0b3-c99f-40af-a4d7-d3362a205dfb
# ╠═f8b2fcfb-3802-47f9-bca7-b392ebc09964
# ╟─97bc1bb2-95cd-478a-836a-cea9caeca568
# ╠═b01ed707-d25c-4552-8a3a-2b8992d4cca4
# ╠═8152de0c-9c1d-400b-9d0a-5af8c4290d13
# ╟─825c967e-47a8-4457-a937-c9a162ae4671
# ╠═b0716047-d1e9-421a-a8ab-cab2b4b8e610
# ╠═37579c02-2c79-4d1d-8039-7a3500e784e3
# ╠═75aae357-2af9-4752-ba1e-e885fb43ec4b
# ╠═23274c5b-6081-405b-9bda-93b45156b952
# ╠═c1249bb5-4327-4c2a-b82c-c05f566888e2
# ╠═59b3d5bb-93c3-4e2c-beeb-a93620ab125e
# ╠═7d137542-5a38-4ae3-b6ec-8b6fd6840c94
# ╠═a02dd5f4-c9f4-408e-9e98-282593d41106
# ╠═079d7d61-e790-4144-9eb6-d451c6194a50
# ╠═a0eafb7a-6788-4c08-ab7c-55a3dd6b79d5
# ╠═a22ae871-38a4-4280-b1a2-e6fdc7732a34
# ╠═91412e9b-f0e6-4b61-9bb7-600b974239a8
# ╟─2d2e595b-0ffb-4e21-8bda-08419221ba7e
# ╠═de8f9f3a-88a5-45da-a2e3-593bf04022a0
# ╠═0e2d2b84-4801-48d5-beff-6e4e1e4fa8ce
# ╠═fe95a603-3489-4536-b622-1afccf6a2ce3
# ╠═6613f0f4-c8eb-4b01-a19e-792b51585197
# ╠═e249e68b-7b47-45f4-8251-c3df3f8dcb8f
# ╠═b8cbf8d7-01c9-4f2a-93b4-cf3d2a117856
# ╠═5f3f0cf3-ec7a-4069-8020-d684b9ea265c
# ╠═9ab5273e-2dfd-488c-a950-15571fa7ec84
# ╠═31736d0a-0958-4e9f-a82a-b6ffdd7f3ebf
# ╟─56489f6f-60da-4a8f-a842-2fcd51873958
# ╠═5651b87d-80a7-4d66-a471-601d959951a7
# ╠═b445f276-b352-498b-b6cb-e22036e5dc35
# ╠═76f9da13-55a2-418b-a68a-9aae4950ef65
# ╠═4c34f7c4-76bf-47a7-88e3-852b96b82517
# ╠═91794db9-e4de-4142-aeb8-c343b1ed0ebe
# ╠═b44552fe-bee4-4de7-be2b-51b1038f43bf
# ╠═8427738c-7d0e-49a9-897c-8eaba766fede
# ╠═2945fef4-a556-4804-9365-f1a06fcb9571
# ╠═e96b2bce-d095-42da-9b79-11552bd26ab0
# ╠═fb44687c-4e14-4b4d-84a9-2a2f13708d26
# ╠═b33bea47-01bc-4ac0-b8b2-cc2a10681bb8
# ╠═3c4320db-fb39-4e39-8f7b-4b36b059e0c5
# ╟─1f62aeb7-a379-420c-9f35-1a91f0d34be7
# ╟─4108e7bd-519a-4614-86f4-3b32ba4933b6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
