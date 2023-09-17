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
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 5 - Laços e condicionais
"""

# ╔═╡ 265edda4-ea89-45c9-a0aa-11bf40091e73
md"""
## Laços predeterminados
"""

# ╔═╡ fb0e0a6a-b5ff-4218-8f83-a0a0f5733e41
for k in 1:5
    println("k = $(k)")
end

# ╔═╡ 0171741a-3e4b-4dc0-aea5-32cc0370290f
md"""
## Laços condicionais
"""

# ╔═╡ 16c26354-f42f-4f64-85f0-c0ef63934b9a
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

# ╔═╡ 417adb28-3380-44e1-a393-285256b4d6d9
md"""
## Exemplos com matrizes
"""

# ╔═╡ 6d100024-12fd-472a-a054-ca839bd746f6
begin
    nrows = 3
    ncols = 4

    A = fill(0, (nrows, ncols))
end

# ╔═╡ 270c3239-209c-4b57-83d7-275896d977b5
begin
    for j in 1:ncols
        for i in 1:nrows
            A[i, j] = i + j
        end
    end

    A
end

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
begin
    B = fill(0, (nrows, ncols))

    for j in 1:ncols, i in 1:nrows
        B[i, j] = i + j
    end

    B
end

# ╔═╡ 95114075-a01d-431a-8a28-1201768abb95
b = [α^β for α in 1:5, β in 2:5]

# ╔═╡ 34934ccd-4579-4294-ab25-352912b97529
length(b)

# ╔═╡ 5bc0ea13-d51d-4219-bfe4-a9cbf255c79e
sum(1:10)

# ╔═╡ 8efe6053-a499-4967-a807-79a40fad994e
md"""
## Operador ternário
"""

# ╔═╡ 6ee8f21c-80c2-4807-adf8-adb0cba2c6ad
begin
    iamtrue = (1 < 2)
    iamfalse = (2 > 1)
end

# ╔═╡ e096e80a-c111-498a-b956-e69539d5c84a
answer1 = (1 < 2) ? iamtrue : iamfalse

# ╔═╡ 814a05d0-43cf-47a6-989b-c745805ce356
answer2 = if (1 < 2) iamtrue else iamfalse end

# ╔═╡ 9a2095f1-dff3-4aa7-b06d-d14e4f16213d
md"""
## Avaliação em curto-circuito
"""

# ╔═╡ d2be3957-13b2-4bf0-9b23-6b0406bdc070
(2 > 0) && println("2 é maior que 0")

# ╔═╡ 0cd7abb2-f06a-4ac7-bcde-dea4e5915c3e
(2 < 0) && println("esse código não executa")

# ╔═╡ a5324ed8-f1dd-4846-9340-cb09cebf9640
iamtrue || print("não será avaliado")

# ╔═╡ 50e2a402-af30-408d-9714-ee444fd072d5
iamfalse || print("será avaliado")

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─265edda4-ea89-45c9-a0aa-11bf40091e73
# ╠═fb0e0a6a-b5ff-4218-8f83-a0a0f5733e41
# ╟─0171741a-3e4b-4dc0-aea5-32cc0370290f
# ╠═16c26354-f42f-4f64-85f0-c0ef63934b9a
# ╟─417adb28-3380-44e1-a393-285256b4d6d9
# ╠═6d100024-12fd-472a-a054-ca839bd746f6
# ╠═270c3239-209c-4b57-83d7-275896d977b5
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╠═95114075-a01d-431a-8a28-1201768abb95
# ╠═34934ccd-4579-4294-ab25-352912b97529
# ╠═5bc0ea13-d51d-4219-bfe4-a9cbf255c79e
# ╟─8efe6053-a499-4967-a807-79a40fad994e
# ╠═6ee8f21c-80c2-4807-adf8-adb0cba2c6ad
# ╠═e096e80a-c111-498a-b956-e69539d5c84a
# ╠═814a05d0-43cf-47a6-989b-c745805ce356
# ╟─9a2095f1-dff3-4aa7-b06d-d14e4f16213d
# ╠═d2be3957-13b2-4bf0-9b23-6b0406bdc070
# ╠═0cd7abb2-f06a-4ac7-bcde-dea4e5915c3e
# ╠═a5324ed8-f1dd-4846-9340-cb09cebf9640
# ╠═50e2a402-af30-408d-9714-ee444fd072d5
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
