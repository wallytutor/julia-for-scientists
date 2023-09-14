### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 5b226140-525d-11ee-2e60-55f9f82f899e
md"""
# Parte 3 - Estruturas de dados I
"""

# ╔═╡ 47fbe810-d30b-4f6a-93d1-2856fed594ca
md"""
Nesta seção vamos estudar alguns tipos de estruturas de dados. Essas formas *compostas* são construídas sobre elementos que já vimos mas podem também ir além destes. Abordaremos apenas as características básicas de cada uma das estruturas apresentadas e os casos de aplicação se tornarão evidentes. Os diversos métodos comuns à essas coleções é descrito [nesta página](https://docs.julialang.org/en/v1/base/collections/).
"""

# ╔═╡ 91d42cd2-1a69-4fbc-9edb-d4d607371c60
md"""
## *Tuples*

Uma *tuple* é constituída de uma sequência de elementos, que podem ser de tipos diferentes, declarada entre parêntesis. A característica de base de uma *tuple* é sua imutabilidade: uma vez declarada, seus elementos não podem ser alterados.

!!! note "Já vimos isso antes"

    Voltando a seção aonde realizamos a conversão explícita de tipos acima, você pode verificar que na realidade já utilizamos uma tuple de números indicando as intensidades RGB de uma cor.

Declaremos uma sequência fixa de linguagens de programação dadas por seus nomes como `Strings`:
"""

# ╔═╡ 692e4a6b-ee30-4ee7-a5ab-1f4ed5271e5a
languages = ("Julia", "Python", "Octave")

# ╔═╡ c750be52-e855-4190-a766-b1c518577965
md"""
Inspecionando o tipo desta variável aprendemos mais uma característica importante inerente a definição de `Tuple` feita acima quanto ao seu caráter imutável: o tipo de uma `Tuple` inclui individualmente o tipo de cada um de seus elementos. Dito de outra maneira, uma sequência composta de um número definido de objetos de dados tipos caracteriza por ela mesmo um novo tipo de dados.
"""

# ╔═╡ 6f88eee0-a1a1-471f-8b28-9e197ae04499
typeof(languages)

# ╔═╡ 6a42cbf3-3e1f-40f9-aefe-c4688ec7c0ec
md"""
Os elementos de uma `Tuple` podem ser acessados por seus índices.

!!! warning "Indices em Julia"

    É o momento de mencionar que em Julia a indexação inicia com `1`.
"""

# ╔═╡ 29698a56-3627-46a2-9c5c-029b2f92b606
@show languages[1]

# ╔═╡ 31b10f62-4e4a-4ab9-a81d-de7d0d9b756f
md"""
Vamos tentar modificar o segundo elemento da `Tuple`.

!!! tip "Sintaxe de controle de erros"

    Ainda é cedo para entrar nos detalhes, mas aproveite o bloco abaixo para ter um primeiro contato com a gestão de erros em Julia.
"""

# ╔═╡ e22b0b9e-813c-4528-aa09-d394c7d37da5
try
    languages[2] = "C++"
catch err
    println("Erro: $(err)")
end

# ╔═╡ c3658afa-1a9b-4cd2-951c-234a6b37c8fe
md"""
Existem certas subtilidades que você precisa saber sobre a imutabilidade. Observe o exemplo abaixo, aonde declaramos duas variáveis que são utilizadas para construir uma `Tuple` e então modificamos uma das variáveis: a `Tuple` continua com os valores originais do momento da sua construção.
"""

# ╔═╡ 0c29046a-2f4a-43b0-a670-2a2cfca22398
begin
    var1 = 1
    var2 = 2

    test_tuple1 = (var1, var2)

    var1 = 5
    test_tuple1
end

# ╔═╡ 245b49a4-c880-4b6e-bc08-99d8494264d6
md"""
!!! danger "Isso nem sempre é verdade!"

    Se o elemento compondo a `Tuple` for de um tipo mutável, como é o caso de `Array`'s, como veremos no que se segue, os elementos desta variável podem ser modificados e impactam a `Tuple` diretamente. Isso se dá porque neste caso a `Tuple` conserva a referência ao objeto em questão, e não uma cópia dos valores, como é o caso para tipos de base.
"""

# ╔═╡ bfc36ed8-9b17-4fbd-bea2-97141c2e83b8
begin
    var3 = [1, 2]

    test_tuple2 = (var1, var3)

    var3[1] = 999
    test_tuple2
end

# ╔═╡ ce0750fd-ff28-4c77-9cd5-e99a6217d1ae
md"""
## *Named tuples*

Esta extensão à `Tuples` adiciona a possibilidade de acesso aos componentes por um *nome* no lugar de um simples índice -- que continua funcional como veremos abaixo. Esse tipo de estrutura é bastante útil quando necessitamos criar abstrações de coisas bastante simples para as quais a criação de um novo tipo não se justifica. Discutiremos mais tarde quando vamos estudar a criação de *novos tipos*.
"""

# ╔═╡ 55737e3e-d1df-4dc5-99bb-4ddc7c33145a
named_languages = (julia = "Julia", python = "Python")

# ╔═╡ 4b1aa7ab-dcdd-4f31-9acb-874293628981
md"""
Observe o fato de que agora os nomes utilizados no índex fazem parte do tipo.
"""

# ╔═╡ 23b805d5-8380-42ec-8750-89175477ac19
typeof(named_languages)

# ╔═╡ 0ff040a3-86cc-4ec7-bcc3-204efdc3bc55
md"""
Abaixo verificamos que além do acesso por nomes, `NamedTuples` também respeitam a ordem de declaração dos elementos: `:julia` é o primeiro índice. A sintaxe de acesso aos elementos neste caso é com a notação típica utilizando um ponto, comum a diversas linguages de programação.
"""

# ╔═╡ f1e6c01f-3b0b-4786-aad1-e2a0315bc989
named_languages[1] == named_languages.julia

# ╔═╡ 8df29d98-4128-4b30-af1b-6a8e4bd1a876
md"""
## Dicionários

Objetos do tipo `Dict` possuem a similaridade com `NamedTuples` em que seus elementos podem ser acessados por nome. No entanto a sintaxe é diferente e os valores desta estrutura são mutáveis.
"""

# ╔═╡ d5cf68d2-9d47-4458-b44c-29629840abba
organs = Dict("brain" => "🧠", "heart" => "❤")

# ╔═╡ d8e2af34-2840-4aae-921f-bc2535ff416c
md"""
O acesso a elementos se faz com colchetes contendo o índex como se segue:
"""

# ╔═╡ c253e7a0-878f-48ce-87e2-9c7d3267b960
organs["brain"]

# ╔═╡ ab4506c1-745d-408c-947a-c688935249fc
md"""
E como dissemos, os elementos são mutáveis: vamos atribuir um burrito ao cérebro.
"""

# ╔═╡ 6ed3740d-ca3b-4714-9dc7-9e08948a88b7
organs["brain"] = "🌯"

# ╔═╡ 8b799f5c-9ce7-4db8-b991-f49d885335d2
md"""
Não só os elementos, mas o dicionário como um todo, pode ser alterado. Para adicionar novos elementos simplesmente *acessamos* a palavra-chave e atribuímos um valor:
"""

# ╔═╡ f6e40b5b-a4e9-4a29-bf5d-81dbee87b18b
organs["eyes"] = "👀"

# ╔═╡ 039ea029-bcc5-4b99-83f8-de9d205c8a76
md"""
Internamente para evitar nova alocação de memória a cada tentativa de se adicionar um novo elemento, um dicionário realiza a alocação de `slots` que são renovados cada vez que sua capacidade é ultrapassada. Observe que a lista retornada abaixo é composta majoritariamente de `0x00`, que é o endereço de memória nulo, enquanto 3 elementos indicam um valor não-nulo, correspondendo aos elementos já adicionados ao dicionário. Disto vemos que adicionalmente um dicionário não preserva necessariamente uma sequência ordenada. Esses detalhes ultrapassam o presente escopo mas vão abrindo as portas para assuntos mais complexos. 
"""

# ╔═╡ 0ef39afb-9727-4d0e-a803-aaa7be1c0478
organs.slots

# ╔═╡ 4e4c5a86-4081-439f-bbb2-ff2d7ea677ee
organs

# ╔═╡ 6affc4cc-0bbf-47cf-8b11-53d8b9f589ba
md"""
Para remover elementos utilizamos a função `pop!`. Por convenção em Julia, funções que terminam por um ponto de exclamação modificam os argumentos que são passados. No caso de `pop!` o dicionário é modificado e o valor de retorno é aquele do elemento removido.
"""

# ╔═╡ c82d7896-1b33-48b7-802e-3e257adc4410
pop!(organs, "brain")

# ╔═╡ be1b0abb-124b-40a0-9568-97d67a4593fd
md"""
A tentativa de remover um elemento inexistente obviamente conduz à um erro:
"""

# ╔═╡ 883c21f5-7e99-4807-bd9d-108e3073e025
try
    pop!(organs, "leg")
catch err
    println("Erro: $(err)")
end

# ╔═╡ 930089df-128e-4993-902a-5611b5a6884b
organs

# ╔═╡ e5fefe37-d51d-4dc4-94b2-00a1ade5d7db
md"""
Para evitar essa possibilidade podemos usar a função `haskey()`.
"""

# ╔═╡ c3108d00-657d-4711-8474-e8b22e4c9eeb
haskey(organs, "liver")

# ╔═╡ 5259ed97-19fc-4ee4-b568-ca9ed355eed8
md"""
Uma última coisa a notar é que *praticamente* qualquer tipo básico pode ser empregado como a chave de um dicionário em Julia. Veja o exemplo à seguir:
"""

# ╔═╡ 94a1caa0-153b-4208-a4f4-32bc2eaee2c9
music = Dict(:violin => "🎻", 1 => 2)

# ╔═╡ 2fc1eea1-661f-4b01-8890-d9a9a3157f6f
md"""
Como as chaves são de tipos diferentes (um `Symbol` e um `Int64`), assim como os valores (uma `String` e um `Int64`), a função `typeof()` nos retorna tipos `Any`.
"""

# ╔═╡ 10fb89d7-1401-4962-b740-a7ae858f4604
typeof(music)

# ╔═╡ 058aee92-02b3-4626-b4af-88d80b99f4f1
md"""
Ainda nos restam alguns detalhes e tipos de dados, mas o tutorial começa a ficar longo... e não queremos te perder por aqui!

Isso é tudo para esta sessão de estudo! Até a próxima!
"""

# ╔═╡ b9af06b7-88c7-40fe-8c0d-f2510c5ec36d
begin
    import PlutoUI
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "f5c06f335ceddc089c816627725c7f55bb23b077"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

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

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

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

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.7.0+0"

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
# ╟─5b226140-525d-11ee-2e60-55f9f82f899e
# ╟─47fbe810-d30b-4f6a-93d1-2856fed594ca
# ╟─91d42cd2-1a69-4fbc-9edb-d4d607371c60
# ╠═692e4a6b-ee30-4ee7-a5ab-1f4ed5271e5a
# ╟─c750be52-e855-4190-a766-b1c518577965
# ╠═6f88eee0-a1a1-471f-8b28-9e197ae04499
# ╟─6a42cbf3-3e1f-40f9-aefe-c4688ec7c0ec
# ╠═29698a56-3627-46a2-9c5c-029b2f92b606
# ╟─31b10f62-4e4a-4ab9-a81d-de7d0d9b756f
# ╠═e22b0b9e-813c-4528-aa09-d394c7d37da5
# ╟─c3658afa-1a9b-4cd2-951c-234a6b37c8fe
# ╠═0c29046a-2f4a-43b0-a670-2a2cfca22398
# ╟─245b49a4-c880-4b6e-bc08-99d8494264d6
# ╠═bfc36ed8-9b17-4fbd-bea2-97141c2e83b8
# ╟─ce0750fd-ff28-4c77-9cd5-e99a6217d1ae
# ╠═55737e3e-d1df-4dc5-99bb-4ddc7c33145a
# ╟─4b1aa7ab-dcdd-4f31-9acb-874293628981
# ╠═23b805d5-8380-42ec-8750-89175477ac19
# ╟─0ff040a3-86cc-4ec7-bcc3-204efdc3bc55
# ╠═f1e6c01f-3b0b-4786-aad1-e2a0315bc989
# ╟─8df29d98-4128-4b30-af1b-6a8e4bd1a876
# ╠═d5cf68d2-9d47-4458-b44c-29629840abba
# ╟─d8e2af34-2840-4aae-921f-bc2535ff416c
# ╠═c253e7a0-878f-48ce-87e2-9c7d3267b960
# ╟─ab4506c1-745d-408c-947a-c688935249fc
# ╠═6ed3740d-ca3b-4714-9dc7-9e08948a88b7
# ╟─8b799f5c-9ce7-4db8-b991-f49d885335d2
# ╠═f6e40b5b-a4e9-4a29-bf5d-81dbee87b18b
# ╟─039ea029-bcc5-4b99-83f8-de9d205c8a76
# ╠═0ef39afb-9727-4d0e-a803-aaa7be1c0478
# ╠═4e4c5a86-4081-439f-bbb2-ff2d7ea677ee
# ╟─6affc4cc-0bbf-47cf-8b11-53d8b9f589ba
# ╠═c82d7896-1b33-48b7-802e-3e257adc4410
# ╟─be1b0abb-124b-40a0-9568-97d67a4593fd
# ╠═883c21f5-7e99-4807-bd9d-108e3073e025
# ╠═930089df-128e-4993-902a-5611b5a6884b
# ╟─e5fefe37-d51d-4dc4-94b2-00a1ade5d7db
# ╠═c3108d00-657d-4711-8474-e8b22e4c9eeb
# ╟─5259ed97-19fc-4ee4-b568-ca9ed355eed8
# ╠═94a1caa0-153b-4208-a4f4-32bc2eaee2c9
# ╟─2fc1eea1-661f-4b01-8890-d9a9a3157f6f
# ╠═10fb89d7-1401-4962-b740-a7ae858f4604
# ╟─058aee92-02b3-4626-b4af-88d80b99f4f1
# ╟─b9af06b7-88c7-40fe-8c0d-f2510c5ec36d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
