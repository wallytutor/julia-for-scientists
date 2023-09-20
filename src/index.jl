### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 6bab4f07-a54a-41c8-b8b2-dc9459197be1
begin
    using PlutoUI
    TableOfContents()
end

# ╔═╡ 1b482d99-8528-4290-8f2b-1a93773c1471
html"""
<h1>Julia para Cientistas</h1>
<p>Materiais de estudo do curso <a href="https://github.com/wallytutor/julia-for-scientists" target="_blank">Julia para Cientistas (GitHub)</a>.</p>
"""

# ╔═╡ 1a128fd6-a4e8-4ab9-a351-35bd930f876e
html"""
<h2>Conteúdos</h2>

<ol>
  <li style="height: 25px;">
    <a href="000-preambulo-e-pluto.html" target="_blank">
      Preâmbulo e Pluto
    </a>
  </li>
  <li style="height: 25px;">
    <a href="001-primeiros-passos.html" target="_blank">
      Primeiros passos
    </a>
  </li>
  <li style="height: 25px;">
    <a href="002-manipulacao-textual.html" target="_blank">
      Manipulação textual
    </a>
  </li>
  <li style="height: 25px;">
    <a href="003-estruturas-de-dados.html" target="_blank">
      Estruturas de dados I
    </a>
  </li>
  <li style="height: 25px;">
    <a href="004-estruturas-de-dados.html" target="_blank">
      Estruturas de dados II
    </a>
  </li>
  <li style="height: 25px;">
    <a href="005-lacos-e-condicionais.html" target="_blank">
      Laços e condicionais
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Funções e despacho múltiplo
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Pacotes e ecossistema
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Avaliando performance
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Álgebra linear
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Expressões regulares
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Execução concorrente
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Trabalhando com arquivos
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Bibliotecas gráficas
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Gráficos para publicações
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Tipos de dados e estruturas
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Metaprogramação e macros
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Interoperação com C
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Equações diferenciais ordinárias
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Equações diferenciais parciais
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Redes neuronais clássicas
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Aprendizado com suporte físico
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Análise quantitativa de imagens
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Criando seus próprios pacotes
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      ...
    </a>
  </li>
</ol>
"""

# ╔═╡ bacb2362-eebb-43b7-a301-8c28c1e01e6a
html"""
<h3>Fenômenos de transporte</h3>
<ol>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Equação da advecção
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank">
      ...
    </a>
  </li>
</ol>
"""

# ╔═╡ 3bf84edf-3c2e-4dcf-bbac-e9c16f4a14a5
html"""
<h3>Materiais suplementares</h3>
<ol>
  <li style="height: 25px;">
    <a href="a01-colaboracao-cientifica.html" target="_blank">
      Ciência colaborativa
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank">
      ...
    </a>
  </li>
</ol>
"""

# ╔═╡ 916f2ca2-988f-4cc8-a2ec-b9991d7abafe
md"""
## Seguindo os materiais

Os conteúdos são majoritariamente sequenciais: exceto para os tópicos mais avançados (para aqueles que já programam em Julia), é necessário seguir os notebooks na ordem provida.

Um canal YouTube do curso está em fase de concepção para abordar os detalhes entre-linhas, involvendo aspectos que não necessariamente estão escritos.

Etapas à seguir para começar os estudos:

1. Ler [este anexo](https://wallytutor.github.io/julia-for-scientists/a01-colaboracao-cientifica.html) para se familiarizar com alguns elementos que vamos abordar no que se segue.

1. [Instalar Julia](https://julialang.org/downloads/) na versão estável para seu sistema operacional.

1. [Instalar Pluto](https://github.com/fonsp/Pluto.jl) para visualizar e editar os notebooks do curso.

1. Clonar este repositório com todos os materiais usando a seguinte ordem de prioridade:

    - Usando Git à través da linha de comando, forma recomendada [^1]

    - Com a interface gráfica de [GitHub Desktop](https://desktop.github.com/)

    - Usando o botão de [Download](https://github.com/wallytutor/julia-for-scientists/archive/refs/heads/main.zip) [^2]

[^1]: `git clone https://github.com/wallytutor/julia-for-scientists.git`

[^2]: Caso a última opção de download tenha sido a sua escolha, observe que o arquivo `.zip` não contem os elementos de *repositório git* para controle de versão, implicando que as suas modificações e notas tomadas deverão ser geridas localmente, o que não é recomendável. Para estudantes ainda não familiarizados com *git*, a opção de utilizar GitHub Desktop é a mais apropriada.
"""

# ╔═╡ 230a17ec-ae6e-4bad-a895-5cfa1284576c
md"""
## Para aonde ir depois?

[Julia Academy](https://juliaacademy.com/): nesta página encontram-se cursos abertos em várias temáticas comumente abordadas com a linguagem Julia. Você encontrará cursos parcialmente equivalentes aos materiais tratados aqui, mas também vários conteúdos que não são abordados nesta introdução, especialmente em tópicos ligados a Ciência de Dados.

[Introduction to Computational Thinking](https://computationalthinking.mit.edu/Fall23/): esse é provavelmente o melhor curso generalista para aplicações científicas da linguagem. O curso é ministrado inclusive pelo [Pr. Dr. Alan Edelman](https://en.wikipedia.org/wiki/Alan_Edelman) um dos criadores de Julia. Os tópicos abordados vão de tratamento de imagens, séries temporais, a resolução de equações diferenciais parciais.

[*SciML Book*](https://book.sciml.ai/): este livro é o resultado dos materiais de suporte do curso *Parallel Computing and Scientific Machine Learning (SciML): Methods and Applications* no MIT. Os tópicos são suportados por vídeo aulas e entram em mais profundidade nos assuntos avançados que tratamos aqui.

[Exercism Julia Track](https://exercism.org/tracks/julia): a plataforma  *Exercism* propõe no percurso de Julia vários exercícios de algoritmos de nível fácil à intermediário-avançado. Minha recomendação é que essa prática venha a complementar os materiais propostos acima como forma de sedimentar o aprendizado da linguagem.

[Julia Data Science](https://juliadatascience.io/): este livro complementa tópicos mais operacionais de análise de dados, especialemente técnicas básicas de Ciência de Dados, que omitimos neste curso. Um bom material complementar aos estudos.

[Julia Community Zulipchat](https://julialang.zulipchat.com/): precisando de ajuda ou buscando um projeto para contribuir? Este chat aberto da comunidade Julia é o ponto de encontro para discutir acerca dos diferenter projetos e avanços na linguagem.

[Julia Packages](https://juliapackages.com/): o repositório mestre do índice de pacotes escritos na linguagem Julia ou provendo interfaces à outras ferramentas. A página contém um sistema de busca e um índice por temas.

[JuliaHub](https://juliahub.com/): esta plataforma comercial provê tudo que é necessário para se passar da prototipagem à escala industrial de soluções concebidas em Julia. Atualmente é a norma em termos de escalabilidade para a linguagem.
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
# ╟─1b482d99-8528-4290-8f2b-1a93773c1471
# ╟─1a128fd6-a4e8-4ab9-a351-35bd930f876e
# ╟─bacb2362-eebb-43b7-a301-8c28c1e01e6a
# ╟─3bf84edf-3c2e-4dcf-bbac-e9c16f4a14a5
# ╟─916f2ca2-988f-4cc8-a2ec-b9991d7abafe
# ╟─230a17ec-ae6e-4bad-a895-5cfa1284576c
# ╟─6bab4f07-a54a-41c8-b8b2-dc9459197be1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
