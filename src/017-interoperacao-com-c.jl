### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title="Tópicos")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 17 - Interoperação com C
"""

# ╔═╡ 9babf862-40fe-4a39-a259-3d9b30e2a9f2
md"""
Neste tutorial vamos ilustrar como usar uma biblioteca de link dinâmico (DLL) em Julia. Essa atividade é recorrente em computação científica quando desejamos realizar interface de código externo -- normalmente bibliotecas mais antigas ou aceitas como de alta performance -- com código desenvolvido para aplicações específicas.

Escolhemos como caso de estudo a avaliação de propriedades de transporte em produtos de combustão em termos de uma composição local. Isso é possível de ser realizado através do pacote Cantera, que pelo momento não é disponível em Julia [^1]. As interfaces em C da *DLL* [^2] de Cantera incluem o arquivo de cabeçalho [clib_defs.h](https://cantera.org/documentation/docs-2.6/doxygen/html/dd/d7b/clib__defs_8h.html).

[^1]: Funções de Cantera poderiam ser facilmente acessadas através da interface em Python, mas isso adicionaria a necessidade de se utilizar Conda e a interface de chamada de funções em Python. Por razões evidentes e para manter o sentido deste tutorial vamos negligenciar essa possibilidade.

[^2]: Nos sistemas operacionais Linux (e similares) e Mac OS a terminologia para uma biblioteca compartilhada utiliza a extensão `.so`. Para nosso deleito Julia leva em conta essas diferenças e veremos que o nome da biblioteca não necessita especificar a extensão do arquivo.
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Preparando Cantera
"""

# ╔═╡ 29715b01-6586-41e7-b33e-e838cc39156c
md"""
## Interface das funções necessárias
"""

# ╔═╡ 9c31760b-58be-4f13-bce6-c3218a852924
md"""
## Uso e validação da interface
"""

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─9babf862-40fe-4a39-a259-3d9b30e2a9f2
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╟─29715b01-6586-41e7-b33e-e838cc39156c
# ╟─9c31760b-58be-4f13-bce6-c3218a852924
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
