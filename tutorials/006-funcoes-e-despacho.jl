### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 6 - Funções e despacho
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Capturando de excessões
"""

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
try
    unsignedx::UInt8 = 13;
    unsignedx = 256;
catch err
    println("Error: $(err)")
end

# ╔═╡ 3ea63386-f519-45f3-ad0c-e132ece600d8
try
    var = "bolo";
    throw(DomainError(var, "Não quero $(var)!"))
catch err
    println("Error: $(err)")
end

# ╔═╡ a7b98a28-a889-4c12-a3a7-2e1c932b2d0d
try
    error("Pare já!")
catch err
    println("Error: $(err)")
end

# ╔═╡ f4ff938a-e686-4d3f-a26f-b691f06308dc
md"""
## O básico de funções
"""

# ╔═╡ 5162ae71-422b-43c9-8992-c1e0858c866a
function sayhi(name)
    println("Hi $name, it's great to see you!")
end

# ╔═╡ bfe58e91-80c6-48c9-9659-17a63f8740e1
function f(x)
    x^2
end

# ╔═╡ 375f28c2-f7b5-4a7d-8390-d4db4a536f65
sayhi("C-3PO")

# ╔═╡ 00534b84-fa0a-497d-a1a4-4799e374d3c7
f(42)

# ╔═╡ 02e12b7e-b094-4dec-8014-fa6e3943a4da
md"""
## Funções *inline*
"""

# ╔═╡ 3129caeb-1429-4490-a161-31f2ae4c4b18
sayhi2(name) = println("Hi $name, it's great to see you!")

# ╔═╡ 21d2de46-56db-4937-b3fe-ee182f94e89f
f2(x) = x^2

# ╔═╡ 9645676d-7896-4ed9-9733-6e03a7869815
sayhi2("R2D2")

# ╔═╡ 072942b2-3811-40bd-94c2-646cf84b3bd7
f2(42)

# ╔═╡ b9b1f6b5-910f-41fa-963d-137a692b1b3f
md"""
## Funções anônimas
"""

# ╔═╡ b4827084-5ee9-4e1a-843d-1d40ee5a9831
sayhi3 = name -> println("Hi $name, it's great to see you!")

# ╔═╡ bc8988db-b6c1-42c4-ac67-621aeec7fb41
f3 = x -> x^2

# ╔═╡ 8f409f59-0441-47d8-8fd3-fed9a0e0ef90
sayhi3("Chewbacca")

# ╔═╡ 88a042f8-0ea2-43d1-b0bc-b02c17a10e7d
f3(42)

# ╔═╡ 5f8c7947-ebbc-4088-ae2f-6c6ed2887c88
md"""
## *Duck-typing*
"""

# ╔═╡ 1cc9e102-7f3a-467b-a411-f53ba6182737
sayhi(55595472)

# ╔═╡ 6b0c7d4e-169d-4fa0-a035-e069a8df4e3a
f(rand(3, 3))

# ╔═╡ 1410bb0e-ca29-49e5-ba94-c535a853dbef
f("hi")

# ╔═╡ ad57b708-e9f1-4b84-8017-e21ff7e4f46c
try
    f(rand(3))
catch err
    println("Erro: $(err)")
end

# ╔═╡ f354f7e6-96fa-4f89-a80e-eabb3371e085
md"""
## Funções mutantes
"""

# ╔═╡ cd3ca7a3-7507-4b79-9b66-efc23b226339
v = [3, 5, 2]

# ╔═╡ 789045e0-f17a-43f4-80a7-c72a66aebd65
sort(v), v

# ╔═╡ c5ac8f6b-1727-4d24-aee6-79c5e80b916c
sort!(v), v

# ╔═╡ 85fc3e1e-94f2-4c5e-b83f-d1b8bdc4e8f5
md"""
## Funções de ordem superior
"""

# ╔═╡ 40aa7913-5221-42ff-b2c4-bccef842278e
map(f, [1, 2, 3])

# ╔═╡ e5da732b-aac4-4dc5-b4d0-b39033758a56
map(x -> x^3, [1, 2, 3])

# ╔═╡ aa15e96d-311d-4b3c-98a1-64f9ae7d889e
broadcast(f, [1, 2, 3])

# ╔═╡ b82b4049-ce04-4083-a9b9-87c97cd0eaff
md"""
Some syntactic sugar for calling broadcast is to place a . between the name of the function you want to broadcast and its input arguments. For example,

```julia
broadcast(f, [1, 2, 3])
```
is the same as

```julia
f.([1, 2, 3])
```
"""

# ╔═╡ a01353ca-c442-4ab2-9f05-686bf28315d7
f.([1, 2, 3])

# ╔═╡ ec9b12db-e336-418e-8cd7-ddf0cd317c04
M = [i + 3*j for j in 0:2, i in 1:3]

# ╔═╡ f760e4f1-e69e-43c4-a9f2-9a781b55c0f0
f(M)

# ╔═╡ 42f39581-ee66-4b91-aba7-e7ce531371f1
f.(M)

# ╔═╡ fd58bd8d-5117-4602-a2f9-440635c1ee1c
M .+ 2 .* f.(M) ./ M

# ╔═╡ 6b9e0dc2-b245-44de-af4d-bf814add67be
broadcast(x -> x + 2 * f(x) / x, M)

# ╔═╡ 084164e4-f2c9-4baf-94c9-37b09caa11e2
@. M + 2 * f(M) / M

# ╔═╡ 0f9e30f1-ef56-40c7-9db2-5539b3af74c5
md"""
## Despacho múltiplo
"""

# ╔═╡ b77e16a4-3006-4723-8695-3c5c48abab86
foo(x::String, y::String) = println("My inputs x and y are both strings!")

# ╔═╡ 10d33b9a-9a1d-4d9b-bec6-56bcb9e520d4
foo(x::Int, y::Int) = println("My inputs x and y are both integers!")

# ╔═╡ 7a9fb78c-9fee-4c9f-86ed-39f00fea4715
methods(cd)

# ╔═╡ fa1c30f7-75dc-49f3-9f60-bb1bc1d2e5a8
@which 3.0 + 3.0

# ╔═╡ b6378ba8-f0f2-4df2-9aad-1e9a209e1c2b
foo(x::Number, y::Number) = println("My inputs x and y are both numbers!")

# ╔═╡ bddddbab-501d-4882-a589-cbb704044f52
foo(x, y) = println("I accept inputs of any type!")

# ╔═╡ 509acca3-4221-4d61-995a-183b1c326957
foo("hello", "hi!")

# ╔═╡ 816e018d-d815-489f-91f4-e82672d3bb1a
foo(3, 4)

# ╔═╡ a896fde1-03ce-4748-905b-09c46412748b
methods(foo)

# ╔═╡ ce6e237c-77d0-4892-a297-7a61874df3a7
@which foo(3, 4)

# ╔═╡ 73d561f0-4eaa-4ac7-909e-fb0f20f420f5
@which foo(3, 4)

# ╔═╡ a046fc0a-55e4-4831-9139-6cefe39649c6
@which foo(3.0, 4)

# ╔═╡ e3371c65-7719-427d-9574-974c751dd66d
foo(rand(3), "who are you")

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!
"""

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

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
# ╠═3ea63386-f519-45f3-ad0c-e132ece600d8
# ╠═a7b98a28-a889-4c12-a3a7-2e1c932b2d0d
# ╟─f4ff938a-e686-4d3f-a26f-b691f06308dc
# ╠═5162ae71-422b-43c9-8992-c1e0858c866a
# ╠═bfe58e91-80c6-48c9-9659-17a63f8740e1
# ╠═375f28c2-f7b5-4a7d-8390-d4db4a536f65
# ╠═00534b84-fa0a-497d-a1a4-4799e374d3c7
# ╟─02e12b7e-b094-4dec-8014-fa6e3943a4da
# ╠═3129caeb-1429-4490-a161-31f2ae4c4b18
# ╠═21d2de46-56db-4937-b3fe-ee182f94e89f
# ╠═9645676d-7896-4ed9-9733-6e03a7869815
# ╠═072942b2-3811-40bd-94c2-646cf84b3bd7
# ╟─b9b1f6b5-910f-41fa-963d-137a692b1b3f
# ╠═b4827084-5ee9-4e1a-843d-1d40ee5a9831
# ╠═bc8988db-b6c1-42c4-ac67-621aeec7fb41
# ╠═8f409f59-0441-47d8-8fd3-fed9a0e0ef90
# ╠═88a042f8-0ea2-43d1-b0bc-b02c17a10e7d
# ╟─5f8c7947-ebbc-4088-ae2f-6c6ed2887c88
# ╠═1cc9e102-7f3a-467b-a411-f53ba6182737
# ╠═6b0c7d4e-169d-4fa0-a035-e069a8df4e3a
# ╠═1410bb0e-ca29-49e5-ba94-c535a853dbef
# ╠═ad57b708-e9f1-4b84-8017-e21ff7e4f46c
# ╟─f354f7e6-96fa-4f89-a80e-eabb3371e085
# ╠═cd3ca7a3-7507-4b79-9b66-efc23b226339
# ╠═789045e0-f17a-43f4-80a7-c72a66aebd65
# ╠═c5ac8f6b-1727-4d24-aee6-79c5e80b916c
# ╟─85fc3e1e-94f2-4c5e-b83f-d1b8bdc4e8f5
# ╠═40aa7913-5221-42ff-b2c4-bccef842278e
# ╠═e5da732b-aac4-4dc5-b4d0-b39033758a56
# ╠═aa15e96d-311d-4b3c-98a1-64f9ae7d889e
# ╟─b82b4049-ce04-4083-a9b9-87c97cd0eaff
# ╠═a01353ca-c442-4ab2-9f05-686bf28315d7
# ╠═ec9b12db-e336-418e-8cd7-ddf0cd317c04
# ╠═f760e4f1-e69e-43c4-a9f2-9a781b55c0f0
# ╠═42f39581-ee66-4b91-aba7-e7ce531371f1
# ╠═fd58bd8d-5117-4602-a2f9-440635c1ee1c
# ╠═6b9e0dc2-b245-44de-af4d-bf814add67be
# ╠═084164e4-f2c9-4baf-94c9-37b09caa11e2
# ╟─0f9e30f1-ef56-40c7-9db2-5539b3af74c5
# ╠═b77e16a4-3006-4723-8695-3c5c48abab86
# ╠═10d33b9a-9a1d-4d9b-bec6-56bcb9e520d4
# ╠═509acca3-4221-4d61-995a-183b1c326957
# ╠═816e018d-d815-489f-91f4-e82672d3bb1a
# ╠═a896fde1-03ce-4748-905b-09c46412748b
# ╠═7a9fb78c-9fee-4c9f-86ed-39f00fea4715
# ╠═ce6e237c-77d0-4892-a297-7a61874df3a7
# ╠═fa1c30f7-75dc-49f3-9f60-bb1bc1d2e5a8
# ╠═b6378ba8-f0f2-4df2-9aad-1e9a209e1c2b
# ╠═73d561f0-4eaa-4ac7-909e-fb0f20f420f5
# ╠═a046fc0a-55e4-4831-9139-6cefe39649c6
# ╠═bddddbab-501d-4882-a589-cbb704044f52
# ╠═e3371c65-7719-427d-9574-974c751dd66d
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
