### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 4 - Estruturas de dados II
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## *Arrays*

A estrutura `Array` se diferencia de `Tuple` pelo fato de ser mutável e de `Dict` pela noção de ordem. Dadas essas características não é surpreendente que seja esse o tipo de base sobre o qual Julia constrói vetores e matrizes, embora um `Array` seja mais genérico que esses conceitos matemáticos. Podemos, por exemplo, construir um `Array` contendo sub-`Array`'s de tamanho variável, o que não constituiria uma matriz. Ou então misturar tipos de dados nos elementos de um `Array`, como mostramos ser possível com `Tuple`.

Em termos de sintaxe, usamos nesse caso colchetes `[]` para limitar a sequência.

Considere por exemplo a seguinte lista de países...
"""

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
countries = ["France", "Brazil", "Germany"]

# ╔═╡ 715c4df3-20ae-485c-8ec8-6ceddc85e435
md"""
...ou então de números,...
"""

# ╔═╡ 81ee5eea-c845-45f3-839f-261438bb18da
numbers = [1, 2, 3.1]

# ╔═╡ 186e1ce9-10f8-4c78-8da2-d8c158922498
md"""
..., ou simplesmente informações pessoais.
"""

# ╔═╡ 30c53c06-bad5-4393-be43-6e45f08aafff
personal_info = ["Walter", 34, "Lyon"]

# ╔═╡ d28455d2-7087-49d9-b11a-76a2e287f423
md"""
O acesso a elementos se faz através de índices, como em `Tuple`.
"""

# ╔═╡ d15f2c5e-6983-497a-af35-050a1863e79c
personal_info[2]

# ╔═╡ fed7d7b0-9018-46a2-9eda-a360dc82688f
md"""
Como essa estrutura é mutável ela suporta -- [entre muitos outros](https://docs.julialang.org/en/v1/base/arrays/) -- o método `push!()` para se adicionar um elemento após o último.
"""

# ╔═╡ 43eaf40c-ec42-48f7-8494-9504884f301b
push!(personal_info, "Engineer")

# ╔═╡ c73e2b54-dca0-4635-ad2f-888d5924b282
md"""
De maneira similar ao que vimos para `Dict`, uma implementação de `pop!()` é disponível para o tipo `Array`, realizando a operação inversa de `push!()`.
"""

# ╔═╡ e7960796-2800-465d-9782-c3345cfef98b
pop!(personal_info)

# ╔═╡ 5a557511-de4b-4dcd-ad47-b204cd186db8
md"""
O exemplo de uma *não-matriz* citado na introdução é apresentado a seguir.
"""

# ╔═╡ 535f8185-995d-40b8-afa7-5cef162b2338
not_a_matrix = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]

# ╔═╡ d5d7d18d-a401-4fcd-a6f9-3f447e12a98c
md"""
Usando `typeof()` descobrimos que se trata de um `Vector` de `Vector` e que na verdade Julia usa `Vector` com um *alias* para um `Array{T, 1}`, aonde `T` denota o tipo de dado.
"""

# ╔═╡ 21d1c153-cb0b-49b5-9fbc-a8fa0f73f9dd
typeof(not_a_matrix)

# ╔═╡ b328ae4d-49cd-43f5-a8f7-abf775874c80
md"""
A função [`rand()`](https://docs.julialang.org/en/v1/stdlib/Random/#Base.rand) pode ser usada para criar uma matriz de números aleatórios -- e outras estruturas de ordem superior -- como se segue. Observe o tipo `Matrix{Float64}` indicado.
"""

# ╔═╡ 860f3e80-d717-4f42-a758-1abab49c2daa
a_matrix = rand(3, 3)

# ╔═╡ bcf85815-6dfb-4b32-8877-087072813665
md"""
Repetindo a verificação de tipo como fizemos para of *vetor de vetores* anteriormente, descobrimos que uma `Matrix` em Julia não é interpretada da mesma maneira, mas como um `Array` com duas dimensões. Isso é a forma que a linguagem emprega para assegurar as dimensões constantes segundo cada direção da matriz.
"""

# ╔═╡ f2e84314-d964-42f8-b725-7f307ca4ad21
typeof(a_matrix)

# ╔═╡ c8b40514-5aef-42f1-addf-2e8b2dab649f
md"""
Vamos agora atribuir nossa `a_matrix` à uma outra variável e então modificar a matrix original.
"""

# ╔═╡ a6f9d8f4-3631-4d85-91c2-8dff1f783faf
begin
    maybe_another_matrix = a_matrix
    a_matrix[1, 1] = 999
    a_matrix
end

# ╔═╡ ae795a89-678a-440f-b36e-8ca278c6af04
md"""
Tal como para a `Tuple` com objetos mutáveis, atribuir um novo nome à uma matriz não cria uma nova matriz, apenas referencia o seu endereço de memória: observamos abaixo que a tentativa de cópia `maybe_another_matriz` também é modificada em razão da operação sobre `a_matrix`.
"""

# ╔═╡ b0412585-f2fc-4c43-a563-776133c93d86
maybe_another_matrix

# ╔═╡ 2d9e4441-9fec-4610-8cd6-1ee567ebe837
md"""
Quando uma cópia da matriz é necessária devemos utilizar `copy()`. Nas próximas células criamos uma matriz e então uma cópia, a qual é modificada, e verificamos não haver impacto na matriz original, validando a cópia em um novo endereço de memória.
"""

# ╔═╡ 734562d1-8016-4fa1-b21c-db9fd6da5cb9
begin
    another_matrix = rand(2, 2)
    another_matrix
end

# ╔═╡ cfe59ba2-bc37-49ec-864a-b231f5ad8f07
begin
    again_a_matrix = copy(another_matrix)
    again_a_matrix[1, 2] = 0
    again_a_matrix
end

# ╔═╡ 7e8106ea-177f-4df8-8ccf-a589464a781b
another_matrix

# ╔═╡ 4d831b57-af10-4f79-b7d4-cd95e59f5b8e
md"""
## *Ranges*
"""

# ╔═╡ e6a2b219-d776-4e5a-bf23-41ab6cf2f5fa
range_of_numbers = 1:10

# ╔═╡ a76497eb-c1f4-420d-8aa7-a5b95d1c2142
typeof(range_of_numbers)

# ╔═╡ ee0b6b65-9e6e-4ba6-a29b-a996d97380de
collect(range_of_numbers)

# ╔═╡ a639a716-4a55-49b4-94cd-1e7285cb2678
float_range = 1:0.6:10

# ╔═╡ 78fd40d8-bd00-4b00-b6ec-1bf70a41e3ac
collect(float_range)

# ╔═╡ c7ed7434-0277-409a-a082-15518ed09ebd
typeof(float_range)

# ╔═╡ ac221166-290c-45d3-89ff-c5c61e6f73f8
md"""
## Atribuição de tipos
"""

# ╔═╡ 6628c659-435f-45ea-a899-f761e5a655d1
@time ai::Vector{Int64} = collect(1:10)

# ╔═╡ ab0e828e-6c01-462f-a410-7ac81a23050b
@time af::Vector{Float64} = collect(1:10)

# ╔═╡ ecacb086-7b70-4d8a-b5f9-26283530afcf
typeof(af)

# ╔═╡ a59c8e9e-bc5c-4ae8-b9b0-eaebde637f64
@time b::Vector{Float64} = collect(1.0:10.0)

# ╔═╡ 07cb0ba2-3328-4ec2-8263-9aea918c411b
# TODO

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!
"""

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
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
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╟─715c4df3-20ae-485c-8ec8-6ceddc85e435
# ╠═81ee5eea-c845-45f3-839f-261438bb18da
# ╟─186e1ce9-10f8-4c78-8da2-d8c158922498
# ╠═30c53c06-bad5-4393-be43-6e45f08aafff
# ╟─d28455d2-7087-49d9-b11a-76a2e287f423
# ╠═d15f2c5e-6983-497a-af35-050a1863e79c
# ╟─fed7d7b0-9018-46a2-9eda-a360dc82688f
# ╠═43eaf40c-ec42-48f7-8494-9504884f301b
# ╟─c73e2b54-dca0-4635-ad2f-888d5924b282
# ╠═e7960796-2800-465d-9782-c3345cfef98b
# ╟─5a557511-de4b-4dcd-ad47-b204cd186db8
# ╠═535f8185-995d-40b8-afa7-5cef162b2338
# ╟─d5d7d18d-a401-4fcd-a6f9-3f447e12a98c
# ╠═21d1c153-cb0b-49b5-9fbc-a8fa0f73f9dd
# ╟─b328ae4d-49cd-43f5-a8f7-abf775874c80
# ╠═860f3e80-d717-4f42-a758-1abab49c2daa
# ╟─bcf85815-6dfb-4b32-8877-087072813665
# ╠═f2e84314-d964-42f8-b725-7f307ca4ad21
# ╟─c8b40514-5aef-42f1-addf-2e8b2dab649f
# ╠═a6f9d8f4-3631-4d85-91c2-8dff1f783faf
# ╟─ae795a89-678a-440f-b36e-8ca278c6af04
# ╠═b0412585-f2fc-4c43-a563-776133c93d86
# ╟─2d9e4441-9fec-4610-8cd6-1ee567ebe837
# ╠═734562d1-8016-4fa1-b21c-db9fd6da5cb9
# ╠═cfe59ba2-bc37-49ec-864a-b231f5ad8f07
# ╠═7e8106ea-177f-4df8-8ccf-a589464a781b
# ╠═4d831b57-af10-4f79-b7d4-cd95e59f5b8e
# ╠═e6a2b219-d776-4e5a-bf23-41ab6cf2f5fa
# ╠═a76497eb-c1f4-420d-8aa7-a5b95d1c2142
# ╠═ee0b6b65-9e6e-4ba6-a29b-a996d97380de
# ╠═a639a716-4a55-49b4-94cd-1e7285cb2678
# ╠═78fd40d8-bd00-4b00-b6ec-1bf70a41e3ac
# ╠═c7ed7434-0277-409a-a082-15518ed09ebd
# ╟─ac221166-290c-45d3-89ff-c5c61e6f73f8
# ╠═6628c659-435f-45ea-a899-f761e5a655d1
# ╠═ab0e828e-6c01-462f-a410-7ac81a23050b
# ╠═ecacb086-7b70-4d8a-b5f9-26283530afcf
# ╠═a59c8e9e-bc5c-4ae8-b9b0-eaebde637f64
# ╠═07cb0ba2-3328-4ec2-8263-9aea918c411b
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
