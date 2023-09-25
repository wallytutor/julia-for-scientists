### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 6bab4f07-a54a-41c8-b8b2-dc9459197be1
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using PlutoUI
    TableOfContents(title = "Conteúdos")
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

# ╔═╡ d4ac2a63-bc3e-421d-88ea-da106a617a30
html"""
<h3>Engenharia de reatores</h3>
<ol>
  <li style="height: 25px;">
    <a href="c01-reator-pistao.html" target="_blank">
      Reator pistão - Parte 1
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Reator pistão - Parte 2
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

# ╔═╡ Cell order:
# ╟─1b482d99-8528-4290-8f2b-1a93773c1471
# ╟─1a128fd6-a4e8-4ab9-a351-35bd930f876e
# ╟─bacb2362-eebb-43b7-a301-8c28c1e01e6a
# ╟─d4ac2a63-bc3e-421d-88ea-da106a617a30
# ╟─3bf84edf-3c2e-4dcf-bbac-e9c16f4a14a5
# ╟─916f2ca2-988f-4cc8-a2ec-b9991d7abafe
# ╟─230a17ec-ae6e-4bad-a895-5cfa1284576c
# ╟─6bab4f07-a54a-41c8-b8b2-dc9459197be1
