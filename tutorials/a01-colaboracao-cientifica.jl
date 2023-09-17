### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 61b0c450-53b3-11ee-1e8b-c709c9aa1e5e
md"""
# Ciência colaborativa

Uma dificuldade recorrente encontrada em projetos científicos contendo uma componente numérica é o despreparo dos colaboradores para a gestão de dados e documentos. Essa dificuldade não é somente técnica, mas frequentemente a origem de discórdias nos projetos. O estudo de Julia ou qualquer outra ferramenta para suporte computacional em ciência não tem sentido sem o caráter aplicativo no contexto de um projeto, seja ele acadêmico ou industrial. Neste anexo vamos abordar algumas ferramentas complementares ao uso de Julia úteis para o cientista e apontar os caminhos para encontrá-las e aprender mais sobre elas sem entrar nos detalhes de seus usos. A lista provida não é exaustiva mas contém um esqueleto mínimo que toda pesquisa séria deveria adotar para prover materiais com controle de qualidade e versionagem adequada.
"""

# ╔═╡ d542189a-352e-42ef-a444-e508ae48e6a8
md"""
## Ferramentas recomendadas

Para estudar aspectos computacionais em ciência você precisa de alguns componentes de suporte à linguagem de programação usada, em nosso caso Julia. No que se segue vamos apresentar:

- O editor de texto recomendado VS Code e a extensão requerida.
- A linguagem ``\LaTeX`` usada para a entrada de equações nos notebooks e artigos.
- As ferramentas necessárias para editar ``\LaTeX`` fora do contexto de Julia.
- E finalmente o sistema de versionagem Git.
"""

# ╔═╡ 507d8f92-63dc-42a6-b746-ee642fe51add
md"""
### VS Code

Nos últimos anos [VSCode](https://code.visualstudio.com/) se tornou o editor mais popular da comunidade *open source* e com toda razão. A qualidade da ferramenta provida pela Microsoft chegou a um nível que é difícil justificar o uso de um editor de código comercial. Aliado a isso, com a extensão [Julia VSCode](https://www.julia-vscode.org/) um suporte avançado a edição de código e documentação da linguagem é disponível. Além disso, a ferramenta provê [integração com o sistema de controle de versões Git](https://code.visualstudio.com/docs/sourcecontrol/overview) que vamos discutir no que se segue.
"""

# ╔═╡ b0ee7807-239c-4e29-bbfc-c492225ff726
md"""
### ``\LaTeX``

Para a entrada de equações nos notebooks, [Julia markdown](https://docs.julialang.org/en/v1/stdlib/Markdown/) provê suporte à renderização de ``\LaTeX``. É fundamental ter algum domínio desta linguagem para a elaborção de documentos científicos. As distribuições mais populares são [MiKTeX](https://miktex.org/) para Windows e [TeX Live](https://tug.org/texlive/) para os demais sistemas operacionais. Ademais, artigos escritos usando a linguagem são aceitos pelas publicações mais relevantes em várias áreas do conhecimento. Outra razão para o uso de ``\LaTeX`` é a estocagem de documentos em formato de texto bruto, o que permite um controle de versões com Git.
"""

# ╔═╡ 6abb1126-5154-4f96-8c1f-a9f23e8f2e71
md"""
### TeXStudio

Em complemento à distribuição de ``\LaTeX`` é necessário um editor de texto adaptado. Embora existam extensões excelentes para realizar a compilação dos documentos [^1] para VS Code, elas não são muito fáceis de se compreender para um iniciante. Por isso recomendamos [TeXStudio](https://www.texstudio.org/) para editar e compilar documentos escritos em ``\LaTeX``.

[^1]: Por compilação entende-se em nossos dias transformar o documento em PDF.
"""

# ╔═╡ 29d9dcf5-e584-4a94-b4de-3aecb1efe5b6
md"""
### JabRef

Embora as referências bibliográficas possam ser inseridas diretamente em documentos ``\LaTeX``, o ideal é utilizar uma base de dados comum que possa ser reutilizada ao longo da carreira de pesquisa. [JabRef](https://www.jabref.org/) é um gestor de bibliografia para o formato ``BibTeX`` suportado por ``\LaTeX`` que estoca dados diretamente em formato textual. A interface gráfica é fácil de interagir e dado o formato de documento, as bases *.bib* são compatíveis com Git. 
"""

# ╔═╡ 31afad0d-a16e-475e-9568-c8f964bfbba0
md"""
### Git

Falamos bastante em [Git](https://git-scm.com/downloads) até o momento sem entrar em mais detalhes de que é uma ferramenta de controle de versões. Git elimina a prática insana de se salvar manualmente várias cópias de um mesmo documento para gerir versões. O sistema basea-se na comparação de conteúdos e propõe de se salvar unicamente os documentos modificados em um projeto. Embora seu uso básico seja bastante simples e plausível de se aprender em uma tarde de estudo, a ferramenta é bastante complexa e complexa, permitindo de voltar em pontos históricos de um projeto, publicar *releases*, etc. Para uma pesquisa sã e durável, o uso de documentos em formatos aceitando texto bruto em conjunto com Git é ideal.
"""

# ╔═╡ 872efb8d-b5a9-46c7-b790-b8f4932b26b7
md"""
## Outras ferramentas
"""

# ╔═╡ 8a90084c-db27-45ad-b07c-6f8495c91cab
md"""
### Python

Embora esse seja um curso de Julia, é importante que o cientista também tenha conhecimento de [Python](https://www.python.org/). Python é uma linguagem generalista que também é bastante rica em termos de pacotes para aplicações científicas. Em termos de aprendizado é relativamente mais simples que Julia, com o porém que código nativo em Python é extremamente lento, requerindo sempre o uso de bibliotecas que na verdade são implementadas em C, Fortran, Rust, etc. Para a concepção de aplicações web especialmente a linguagem encontra-se num estado de maturidade bastante superior à Julia e não deve ser negligenciada. Ademais, encontra-se entre as linguagens mais utilizadas no mundo, enquanto Julia é uma linguagem de nicho.
"""

# ╔═╡ 2c60e69c-63ed-463f-b2d1-5ffd91942e80
md"""
### GNUPlot

Embora tratemos da temática de gráficos para publicações no curso, uma alternativa sempre é interessante. [GNUPlot](http://www.gnuplot.info/) é uma ferramenta *open source* contando com sua própria linguagem para geração de gráficos. É uma ferramenta interessante principalmente quando se deseja padronizar todas as figuras em um projeto através de arquivos de configuração.

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ 66e395aa-900e-48bd-9f95-f535612ae513
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title="Tópicos")
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
# ╟─61b0c450-53b3-11ee-1e8b-c709c9aa1e5e
# ╟─d542189a-352e-42ef-a444-e508ae48e6a8
# ╟─507d8f92-63dc-42a6-b746-ee642fe51add
# ╟─b0ee7807-239c-4e29-bbfc-c492225ff726
# ╟─6abb1126-5154-4f96-8c1f-a9f23e8f2e71
# ╟─29d9dcf5-e584-4a94-b4de-3aecb1efe5b6
# ╟─31afad0d-a16e-475e-9568-c8f964bfbba0
# ╟─872efb8d-b5a9-46c7-b790-b8f4932b26b7
# ╟─8a90084c-db27-45ad-b07c-6f8495c91cab
# ╟─2c60e69c-63ed-463f-b2d1-5ffd91942e80
# ╟─66e395aa-900e-48bd-9f95-f535612ae513
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
