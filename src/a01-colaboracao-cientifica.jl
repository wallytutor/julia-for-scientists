### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 66e395aa-900e-48bd-9f95-f535612ae513
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title = "Tópicos")
end

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
