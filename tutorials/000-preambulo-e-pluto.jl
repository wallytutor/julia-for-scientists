### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 6f694879-9008-407c-b3cb-ab0340a0713a
begin
    using PlutoUI
    TableOfContents(title = "Tópicos")
end

# ╔═╡ 06957190-5207-11ee-34ad-638d21453389
md"""
# Parte 0 - Prêambulo e Pluto
"""

# ╔═╡ 60552cbc-902d-44d1-993c-6133786a810f
md"""
## Sobre Julia e a série

Neste tutorial apresentamos os elementos básicos para se seguir a série em relação a linguagem de programação [Julia](https://julialang.org/) e algumas particularidade do uso de [Pluto](https://plutojl.org/). Os conteúdos aqui apresentados são uma extensão daqueles providos pela [JuliaAcademy](https://juliaacademy.com/) em seu [curso introdutório](https://github.com/JuliaAcademy/Introduction-to-Julia). O objetivo desta extensão é apresentar alguns elementos suplementares para a prática de computação científica. A temática de gráficos em Julia, será abordada em um tutorial distinto do curso no qual nos baseamos dada a necessidade de ir um pouco além na qualidade gráfica para publicações em *journals*.

Julia é sintaticamente uma linguagem similar à [Python](https://www.python.org/) mas o estilo de programação tipicamente adotado tende a ser procedural com uso de estruturas e métodos para processar dados contidos nestas. Esta nova linguagem publicada pela primeira vez em 2012 vem ganhando grante *momentum* e uma comunidade bastante interessante na sua diversidade científica. Após alguns anos hesitando em me engajar no seu uso para aplicações em pesquisa em desenvolvimento, em 2023 fui convencido que é chegada hora de transferir parte dos estudos em Julia e então adaptar todos os conteúdos que produzo nesta linguagem.

Recomenda-se o estudo do presente tutorial de forma interativa em uma longa seção de aproximadamente 4 horas de estudo. Após este primeiro contato, a leitura do livro e seus tutoriais se tornará acessível mesmo para aqueles que estão tendo seu primeiro contato com computação. Este tutorial pode ao longo do estudo ser consultado para clarificar elementos da linguagem. Uma vez que se encontre confortável com o conteúdo aqui apresentado, recomenda-se estudar o [manual](https://docs.julialang.org/en/v1/manual/getting-started/) da linguagem, o qual apresenta detalhes omitidos nesta introdução almejada para um primeiro contato.

!!! tip "Dica"

    Julia possui um largo ecossistema de pacotes implementado uma vasta gama de funcionalidades. Para conhecer mais não deixe de visitar [Julia Packages](https://juliapackages.com/).
"""

# ╔═╡ 17abe3b3-ed55-4bb5-a289-992cd4cebfc0
md"""
## Introdução à Pluto

Pluto é uma ferramenta reativa de programação em Julia permiting a concepção de *notebooks*, *i.e* documentos de programação literada aonde o código e o texto/teoria encontram-se juntos. Por reativa entende-se que há interatividade dos elementos e as atualizações de valores propagam-se diretamente. Por exemplo, com *Pluto*, para facilitar a navegação, na próxima célula usamos `TableOfContents` que produz a lista de tópicos interativa que vemos a direita.

Para quem vem de Python, Pluto é o equivalente à Jupyter e suas variantes, com a vantagem de que os documentos produzidos são código puro em Julia, permitindo o controle de versão com *git* - o que é um problema com Jupyter, que encapsula programas dentro de uma estrutura HTML, podendo mesmo salvar figuras e dados em formato binário, o que produz arquivos de tamanhos eventualmente absurdos, além das vulnerabilidades associadas.
"""

# ╔═╡ b188844b-b73b-4187-bd83-e2c388be5fc3
md"""
Este *notebook* e os diversos que se seguem nesta série são concebidos com a tecnologia [Pluto](https://plutojl.org/). Pluto foi concebido principalmente para o ensino e reproductibilidade de *notebooks*. Duas particularidades são advindas as escolhas de design de Pluto que você precisa saber antes de prosseguir:

1. Uma variável pode ser atribuída em uma única célula no contexto global, o que é na verdade uma boa prática de programação e dá segurança a correta execução do programa. Pluto desativa automaticamente células tentando redefinir variáveis.

1. Dado o caráter educacional e para a apresentação de resultados, somente uma expressão é permitida por célula. Para realizar várias declarações em conjunto, devemos encapsulá-las em um bloco como se segue [^1]:

```julia
begin
...
end
```

ou então

```julia
let
...
end
```

[^1]: Existem outras aplicações deste bloco de [expressões compostas](https://docs.julialang.org/en/v1/manual/control-flow/#man-compound-expressions) na linguagem num contexto de concepção de programas e pacotes, os quais veremos no seu devido tempo.
"""

# ╔═╡ dae96e7b-d193-48aa-9fcf-11ae4bde5561
md"""
Blocos `begin ... end` expõe todas as variáveis de seu contexto ao global e retornam a última expressão avaliada, enquanto `let ... end` retorna unicamente a última expressão avaliada. As definições de *escopo de variáveis*, ou seja, a região do código podendo acessar uma variável, normalmente são introduzidas mais tarde em cursos de programação. Vamos avançar um pouco o conteúdo deste tópico dada sua necessidade para se utilizar Pluto corretamente.

Vejamos os exemplos que se seguem.
"""

# ╔═╡ 40ef4210-35c5-456f-8d67-1733977a2eaf
md"""
## Bloco `begin`

No exemplo abaixo declaramos `a` e `b` dentro de um contexto `begin ... end`. Observe o valor `2` que aparece acima da célula, indicando que a última variável é *retornada* pelo contexto.
"""

# ╔═╡ eda9e357-c68f-4a5c-bdc6-b3c6a3583c64
begin
    a = 1
    b = 2
end

# ╔═╡ 9ba0443e-8cf0-49a1-954c-eb506d266823
md"""
Abaixo podemos averiguar que ambas são visíveis no contexto global, quer dizer, fora do bloco `begin ... end` no qual foram declaradas.
"""

# ╔═╡ 265d2df7-b7a6-4c4a-9f74-e751d7ba6845
a, b

# ╔═╡ 04b6a02a-a1d3-4d7a-a58c-d388a257a98d
md"""
Experimente apagar o indicativo de comentário `#` da célula que segue e executá-la:
"""

# ╔═╡ 206d9224-fb25-4995-b449-cb67fcf87b2d
# a = 3

# ╔═╡ 0f166c7d-be43-4e69-a961-d2e58b873e34
md"""
## Bloco `let`

Vamos fazer um experimento similar com `let ... end` mas usando outros nomes de variáveis para evitar confusão. Novamente encontramos o valor `3` da última variável sobre a célula, indicando seu retorno.
"""

# ╔═╡ 589f2573-1e14-4db8-be63-7cf635f84754
let
    c = 2
    d = 3
end

# ╔═╡ 67440ef5-2731-4acb-ba0b-cf282615ed79
md"""
Tentemos agora acessar `c` e `d` fora do contexto: encontramos um `UndefVarError` indicando que a variável `c` não é definida. O erro encerra a execução da célula por aí, não indicando nada a respeito de `d`, que também é indefinida neste escopo.
"""

# ╔═╡ ba9450ae-628b-46a9-9bae-9276442bc8ef
c, d

# ╔═╡ e52c0aaa-8e37-4f33-9ba0-b4fef4dc5631
md"""
Repetimos o bloco acima com a adição de uma declaração em sua última linha. Observe que *capturamos* os valores empregando outros *nomes* `e` e `f`:
"""

# ╔═╡ 228cb901-f577-4698-88cd-9027e10fb556
e, f = let
    c = 1
    d = 2
    c, d
end

# ╔═╡ 5d89fbc8-3ca1-4328-9dfd-1f2d12e7b1bf
md"""
Verificamos abaixo que ambas as variáveis são visíveis globalmente.
"""

# ╔═╡ 2576f7e6-a890-4e54-babe-895502a1e94f
e, f

# ╔═╡ 0ddb1e39-0c06-4437-aa03-1571bec2cf4e
md"""
## Contexto `local`

Em algumas aplicações bem específicas - por exemplo, quando estamos estudando variantes de um mesmo problema em um notebook - gostaríamos de reusar os nomes de variáveis. Isso é possível graças à palavra-chave `local` que indica que uma variável não deve ser visível fora do bloco de declaração.

Na célula abaixo declaramos `x` como local e atribuímos o resultado à `y1`.
"""

# ╔═╡ cb5e5f4a-528c-4c0f-84f9-ac6aa19fde86
y1 = begin
    local x = 1
    x + 1
end

# ╔═╡ 883ee654-74fa-44ff-b3d6-9d5918122aae
md"""
Não encontramos problemas para declarar um novo `x`. Ao invés de atribuirmos o retorno do bloco, neste caso decidimos de ilustrar a atribuição de `y2` dentro do contexto.
"""

# ╔═╡ 5f7589d6-ce9e-4836-918b-00382d3abf2d
begin
    local x = 2 | y2 = x + 2
end

# ╔═╡ 7b63d877-25de-44a4-88ab-e9ac97fbec82
md"""
Confirmamos abaixo a inexistência de `x` no contexto global.
"""

# ╔═╡ 10690fa3-6aa8-4791-bf24-f177e956c3cf
x

# ╔═╡ 64e4652b-da49-42ee-abce-d5c3f804c0a8
md"""
Em contrapartida, ambas `y1` e `y2` são acessíveis.
"""

# ╔═╡ 892a900f-a41b-4e72-91d4-252e3f7d01c6
y1, y2

# ╔═╡ 290f062c-02e6-48fb-8d01-3d7acf14682a
md"""
Uma outra aplicação de `local` é para criar localmente uma variável que *talvez* já exista no contexto `global`. Vemos abaixo o valor de `e` criada num exemplo anterior.
"""

# ╔═╡ d2da6172-cca8-443e-8026-c4f712dab624
e

# ╔═╡ 75c28e55-0cc6-40d3-a45b-3421b5c5c5ba
md"""
Usando `local` podemos declarar um novo `e` e mesmo realizar uma operação sobre esta variável. Isso não impacta o valor de `e` global, caso contrário a célula acima seria atualizada pelo caráter reativo de Pluto.
"""

# ╔═╡ 11a5d756-840e-455a-be0a-ae47f15f59db
begin
    local e = 1
    e = e + 2
end

# ╔═╡ a945640d-4097-4ede-bed6-cb39b2aa1864
md"""
## Atalhos importantes

| Ação                          | Atalho                 |
| ----------------------------: | :--------------------- |
| Executar uma célula           | `<Shift> + <Enter>`    |
| Adicionar/remover comentários | `<Ctrl> + /`           |
| Listar todos os atalhos       | `<Ctrl> + <Shift> + ?` |

Para mais operações consulte esta [wiki](https://github.com/fonsp/Pluto.jl/wiki/%F0%9F%94%8E-Basic-Commands-in-Pluto).
"""

# ╔═╡ 07a43302-09d5-444c-b215-ad3c6e587762
md"""
Encerramos aqui este preâmbulo, nos vemos nos tutoriais!
"""

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
# ╟─06957190-5207-11ee-34ad-638d21453389
# ╟─60552cbc-902d-44d1-993c-6133786a810f
# ╟─17abe3b3-ed55-4bb5-a289-992cd4cebfc0
# ╠═6f694879-9008-407c-b3cb-ab0340a0713a
# ╟─b188844b-b73b-4187-bd83-e2c388be5fc3
# ╟─dae96e7b-d193-48aa-9fcf-11ae4bde5561
# ╟─40ef4210-35c5-456f-8d67-1733977a2eaf
# ╠═eda9e357-c68f-4a5c-bdc6-b3c6a3583c64
# ╟─9ba0443e-8cf0-49a1-954c-eb506d266823
# ╠═265d2df7-b7a6-4c4a-9f74-e751d7ba6845
# ╟─04b6a02a-a1d3-4d7a-a58c-d388a257a98d
# ╠═206d9224-fb25-4995-b449-cb67fcf87b2d
# ╟─0f166c7d-be43-4e69-a961-d2e58b873e34
# ╠═589f2573-1e14-4db8-be63-7cf635f84754
# ╟─67440ef5-2731-4acb-ba0b-cf282615ed79
# ╠═ba9450ae-628b-46a9-9bae-9276442bc8ef
# ╟─e52c0aaa-8e37-4f33-9ba0-b4fef4dc5631
# ╠═228cb901-f577-4698-88cd-9027e10fb556
# ╟─5d89fbc8-3ca1-4328-9dfd-1f2d12e7b1bf
# ╠═2576f7e6-a890-4e54-babe-895502a1e94f
# ╟─0ddb1e39-0c06-4437-aa03-1571bec2cf4e
# ╠═cb5e5f4a-528c-4c0f-84f9-ac6aa19fde86
# ╟─883ee654-74fa-44ff-b3d6-9d5918122aae
# ╠═5f7589d6-ce9e-4836-918b-00382d3abf2d
# ╟─7b63d877-25de-44a4-88ab-e9ac97fbec82
# ╠═10690fa3-6aa8-4791-bf24-f177e956c3cf
# ╟─64e4652b-da49-42ee-abce-d5c3f804c0a8
# ╠═892a900f-a41b-4e72-91d4-252e3f7d01c6
# ╟─290f062c-02e6-48fb-8d01-3d7acf14682a
# ╠═d2da6172-cca8-443e-8026-c4f712dab624
# ╟─75c28e55-0cc6-40d3-a45b-3421b5c5c5ba
# ╠═11a5d756-840e-455a-be0a-ae47f15f59db
# ╟─a945640d-4097-4ede-bed6-cb39b2aa1864
# ╟─07a43302-09d5-444c-b215-ad3c6e587762
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
