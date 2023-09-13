### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 54b47b10-94a7-4745-b8e2-ce033d9b4aa1
begin
    using Printf
    using PlutoUI: TableOfContents
    TableOfContents(title = "Tópicos")
end

# ╔═╡ 82fadcf2-0710-413e-9be1-3054d8a55fca
md"""
# Parte 2 - Manipulação textual
"""

# ╔═╡ ec8d6dd0-525a-11ee-3551-07f2ed0e3cd9
md"""
Uma habilidade frequentemente negligenciada pelo grande público de computação científica nos seus primeiros passos é a capacidade de manipulação textual. Não podemos esquecer que programas necessitam interfaces pelas quais alimentamos as condições do problema a ser solucionado e resultados são esperados ao fim da computação. Para problemas que tomam um tempo computacional importante, é extremamente útil ter mensagens de estado de progresso. Nessa seção introduzimos os primeiros elementos necessários para a manipulação textual em Julia.

Uma variável do tipo `String` declara-se com aspas duplas, como vimos inicialmente no programa `Hello, World!`. Deve-se tomar cuidado em Julia pois caracteres individuais (tipo `Char`) tem um significado distinto de uma coleção de caracteres `String`.

Por exemplo, avaliando o tipo de `'a'` obtemos:
"""

# ╔═╡ 794e2cd4-ee49-4f8c-91fa-7f5f8e225988
typeof('a')

# ╔═╡ ecbabb44-906a-4912-a808-20c6d0c92db6
md"""
## Declaração de Strings

Estudaremos caracteres mais tarde. Por enquanto nos interessamos por expressões como:
"""

# ╔═╡ 4b026ca7-d945-40f3-ac01-426b233e6ae6
text1 = "Olá, eu sou uma String"

# ╔═╡ 548cb583-eff4-44d0-afc9-4d317c9199b5
typeof(text1)

# ╔═╡ 6c074e35-ac22-4b39-a156-26030a680cf0
md"""
Eventualmente necessitamos utilizar aspas duplas no interior do texto. Neste caso, a primeira solução provida por Julia é utilizar três aspas duplas para a abertura e fechamento do texto. Observamos abaixo que o texto é transformado para adicionar uma barra invertida antes das aspas que estão no corpo do texto.
"""

# ╔═╡ 4d6afa66-bd15-4125-b012-0647983ffb6a
text2 = """Eu sou uma String que pode incluir "aspas duplas"."""

# ╔═╡ 5432a596-842a-4529-9c94-e940279c4099
md"""
Neste caso, Julia aplicou automaticamente um *caractere de escape* no símbolo a ser interpretado de maneira especial. Existem diversos casos aonde a aplicação manual pode ser útil, por exemplo quando entrando texto em UNICODE por códigos. No exemplo abaixo utilizamos a técnica manual com o texto precedente.
"""

# ╔═╡ be426c2e-39dd-4d3d-b5cb-dc668ff98d2e
text3 = "Eu sou uma String que pode incluir \"aspas duplas\"."

# ╔═╡ e6fb3d10-dca8-45c9-8476-ed5281535bf9
md"""
Para averiguar o funcionamento correto, testamos de imprimir `text3` no terminal.
"""

# ╔═╡ 163135ca-1218-4ae2-b3cc-e0e02d83ead7
println(text3)

# ╔═╡ d62e951b-0fab-49ab-b9ee-3173ebfa117a
md"""
O exemplo a seguir ilustra o uso do caracter de escape para representar UNICODE.
"""

# ╔═╡ 3b26710e-2782-40f2-b414-76903a909460
pounds = "\U000A3"

# ╔═╡ 109337f5-758b-4578-870c-15134be44262
md"""
## Interpolação de Strings

Para gerar mensagens automáticas frequentemente dispomos de um texto que deve ter partes substituidas. Ilustramos abaixo o uso de um símbolo de dólar $ seguido de parêntesis com a variável de substituição para realizar o que chamamos de *interpolação textual*.

!!! tip "Múltiplas variáveis em uma linha"

    Observe aqui a introdução da declaração de múltiplas variáveis em uma linha.
"""

# ╔═╡ c57cff4e-c144-42ff-a2bf-dd9a0ff44305
begin
    name, age = "Walter", 34
    println("Olá, $(name), você tem $(age) anos!")
end

# ╔═╡ ad75f4d4-4c39-49c3-892c-3977b52f77ba
md"""
!!! warning "Prática não recomendada"

    Para nomes simples de variáveis e sem formatação explícita, o código a seguir também é valido, mas é pode ser considerado uma má prática de programação.
"""

# ╔═╡ d3ba5e50-3a8a-4fb2-a59b-0cf5e30739b2
println("Olá, $name, você tem $age anos!")

# ╔═╡ 31429329-bd9b-4422-8afc-1b7e84d4d889
md"""
Em alguns casos, como na contagem de operações em um laço, podemos também realizar operações e avaliação de funções diretamente na `String` sendo interpolada.
"""

# ╔═╡ 864e53f2-6d21-4934-aad5-a880cdff920d
println("Também é possível realizar operações, e.g 2³ = $(2^3).")

# ╔═╡ 16f92129-7642-4e9b-bd28-715567eb5f14
md"""
## Formatação de números
"""

# ╔═╡ 2c84fb97-67fa-478f-8261-603faf317795
@sprintf("%g", 12.0)

# ╔═╡ 37fce998-102c-4dcd-9e7e-270875cb3206
@sprintf("%.6f", 12.0)

# ╔═╡ e789b407-e99c-460c-8a3d-02233dddf13c
@sprintf("%.6e", 12.0)

# ╔═╡ 09fc99c8-f083-4446-a76b-e777e6d5344b
@sprintf("%15.8e %15.8E", 12.0, 13)

# ╔═╡ a42f4ca7-2f05-43e1-8dbb-f7c2a1910635
@sprintf("%6d", 12.0)

# ╔═╡ 16c4da7b-7662-48fb-a5ed-924ea38946e2
@sprintf("%06d", 12)

# ╔═╡ 10b5affc-a1d0-4fef-a384-7e34926768fa
md"""
## Concatenação de Strings

Na maioria das linguagens de programação a concatenação textual se faz com o símbolo de adição `+`. Data suas origens já voltadas para a computação numérica, Julia adota para esta finalidade o asterísco `*` utilizado para multiplicação, o que se deve à sua utilização em álgebra abstrata para indicar operações não-comutativas, como clarificado no [manual](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation).
"""

# ╔═╡ df66434b-24d9-4ed8-bac9-36c27256c464
bark = "Au!"

# ╔═╡ 896325c1-2e20-4fd1-bc12-61e4a1529c03
bark * bark * bark

# ╔═╡ 10fe8692-3213-4c54-b7cd-7948a0ada44c
md"""
O circunflexo `^` utilizado para a exponenciação também pode ser utilizado para uma repetição múltipla de uma data `String`.
"""

# ╔═╡ af6a5902-c4fb-42b4-a3fd-35e6f0f849e3
bark^10

# ╔═╡ a7cde7b1-4025-43a9-b506-72ed164e3213
md"""
Finalmente o construtor `string()` permite de contactenar não somente `Strings`, mas simultanêamente `Strings` e objetos que suportam conversão textual.
"""

# ╔═╡ 24a3311b-7196-44c2-bad8-520d6536d1a8
string("Unido um número ", 10, " ou ", 12.0, " a outro ", "texto!")

# ╔═╡ 65937ef7-de46-4449-a077-024a680e049f
md"""
## Funções básicas

Diversos outros [métodos](https://docs.julialang.org/en/v1/base/strings/) são disponíveis para Strings. Dado o suporte UNICODE de Julia, devemos enfatizar com o uso de `length()` e `sizeof()` que o comprimento textual de uma `String` pode não corresponder ao seu tamanho em *bytes*, o que pode levar ao usuário desavisado a erros numa tentativa de acesso à caracteres por índices.
"""

# ╔═╡ 7904de54-7459-4a8a-b3f3-c54ebe820c5c
length("∀"), sizeof("∀")

# ╔═╡ 8ad7e9bc-572b-4ccd-b283-88e3477c1e6c
md"""
Uma função que é bastante útil é `startswith()` que permite verificar se uma `String` inicia por um outro bloco de caracteres visado. Testes mais complexos podem ser feitos com [expressões regulares](https://docs.julialang.org/en/v1/base/strings/#Base.Regex), como veremos mais tarde.
"""

# ╔═╡ 2963aaae-bd1d-4ab0-beb2-277a59b05757
startswith("align", "al")

# ╔═╡ cdf074bb-38af-4522-b32c-2247572cd451
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[compat]
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "dd9679cc9a727597e16ac12dd74411e4fa6b952a"

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
# ╟─82fadcf2-0710-413e-9be1-3054d8a55fca
# ╠═54b47b10-94a7-4745-b8e2-ce033d9b4aa1
# ╟─ec8d6dd0-525a-11ee-3551-07f2ed0e3cd9
# ╠═794e2cd4-ee49-4f8c-91fa-7f5f8e225988
# ╟─ecbabb44-906a-4912-a808-20c6d0c92db6
# ╠═4b026ca7-d945-40f3-ac01-426b233e6ae6
# ╠═548cb583-eff4-44d0-afc9-4d317c9199b5
# ╟─6c074e35-ac22-4b39-a156-26030a680cf0
# ╠═4d6afa66-bd15-4125-b012-0647983ffb6a
# ╟─5432a596-842a-4529-9c94-e940279c4099
# ╠═be426c2e-39dd-4d3d-b5cb-dc668ff98d2e
# ╟─e6fb3d10-dca8-45c9-8476-ed5281535bf9
# ╠═163135ca-1218-4ae2-b3cc-e0e02d83ead7
# ╟─d62e951b-0fab-49ab-b9ee-3173ebfa117a
# ╠═3b26710e-2782-40f2-b414-76903a909460
# ╟─109337f5-758b-4578-870c-15134be44262
# ╠═c57cff4e-c144-42ff-a2bf-dd9a0ff44305
# ╟─ad75f4d4-4c39-49c3-892c-3977b52f77ba
# ╠═d3ba5e50-3a8a-4fb2-a59b-0cf5e30739b2
# ╟─31429329-bd9b-4422-8afc-1b7e84d4d889
# ╠═864e53f2-6d21-4934-aad5-a880cdff920d
# ╟─16f92129-7642-4e9b-bd28-715567eb5f14
# ╠═2c84fb97-67fa-478f-8261-603faf317795
# ╠═37fce998-102c-4dcd-9e7e-270875cb3206
# ╠═e789b407-e99c-460c-8a3d-02233dddf13c
# ╠═09fc99c8-f083-4446-a76b-e777e6d5344b
# ╠═a42f4ca7-2f05-43e1-8dbb-f7c2a1910635
# ╠═16c4da7b-7662-48fb-a5ed-924ea38946e2
# ╟─10b5affc-a1d0-4fef-a384-7e34926768fa
# ╠═df66434b-24d9-4ed8-bac9-36c27256c464
# ╠═896325c1-2e20-4fd1-bc12-61e4a1529c03
# ╟─10fe8692-3213-4c54-b7cd-7948a0ada44c
# ╠═af6a5902-c4fb-42b4-a3fd-35e6f0f849e3
# ╟─a7cde7b1-4025-43a9-b506-72ed164e3213
# ╠═24a3311b-7196-44c2-bad8-520d6536d1a8
# ╟─65937ef7-de46-4449-a077-024a680e049f
# ╠═7904de54-7459-4a8a-b3f3-c54ebe820c5c
# ╟─8ad7e9bc-572b-4ccd-b283-88e3477c1e6c
# ╠═2963aaae-bd1d-4ab0-beb2-277a59b05757
# ╟─cdf074bb-38af-4522-b32c-2247572cd451
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
