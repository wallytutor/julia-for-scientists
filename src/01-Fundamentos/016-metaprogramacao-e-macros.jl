### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using CairoMakie
    import PlutoUI
    toc = PlutoUI.TableOfContents(title="Tópicos")

    include("util-metaprogramacao.jl")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte X - Title

$(toc)
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Seção

[Workshop - JuliaCon 2021](https://www.youtube.com/watch?v=2QLhw6LVaq0&t=3275s)
[This video?](https://www.youtube.com/watch?v=sL8O4Hb9zD0)
"""

# ╔═╡ 2eb3228b-609c-40ce-97a3-b2ba4a79a85d
@makeplot1 quote
    lines!(ax, [0, 1], [0, 1], label = "1")
    lines!(ax, [0, 1], [0, 3], label = "2")
end

# ╔═╡ 1ee2a5e9-8a13-43b4-a4de-f00dc97e9fd3
let
    # ex = quote
    #     lines!(ax, [0, 1], [0, 1], label = "1")
    #     lines!(ax, [0, 1], [0, 3], label = "2")
    # end

    @makeplot1 quote
        lines!(ax, [0, 1], [0, 1], label = "1")
        lines!(ax, [0, 1], [0, 3], label = "2")
    end
end

# ╔═╡ de9ce81f-4199-4247-95e7-668be3acf7dd
let
    ex = quote
        lines!(ax, [0, 1], [0, 1], label = "1")
        lines!(ax, [0, 1], [0, 3], label = "2")
    end

    @makeplot1 ex
end

# ╔═╡ 2d115c34-b17f-406f-9cd8-fc62da5f4c00
fig

# ╔═╡ 131a3ce1-2a2e-44d6-86b1-e9cb3902768f
# @makeplot2  quote (0, 2) end

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╠═2eb3228b-609c-40ce-97a3-b2ba4a79a85d
# ╠═1ee2a5e9-8a13-43b4-a4de-f00dc97e9fd3
# ╠═de9ce81f-4199-4247-95e7-668be3acf7dd
# ╠═2d115c34-b17f-406f-9cd8-fc62da5f4c00
# ╠═131a3ce1-2a2e-44d6-86b1-e9cb3902768f
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
