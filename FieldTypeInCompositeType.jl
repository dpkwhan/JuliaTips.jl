### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 608a431e-e51c-4899-bffe-7261c625fb64
using Random, PlutoUI, BenchmarkTools, Formatting

# ╔═╡ 50aa9471-503a-499f-990b-f1c7acb784bc
md"# Composite Types with Fields of Concrete Types"

# ╔═╡ 9d8f3586-ce99-405c-8329-3a58ee176ef7
html"""
<article class="firstparagraph">
	<p>
		Composite types are the most commonly used user-defined type in Julia. A composite type is a collection of named fields and an instance of it is treated as a single value.
	</p>
</article>
"""

# ╔═╡ 1a9931d6-1312-419b-8888-cac2fb8b7497
md"""
!!! tip "Tip"
	Use concrete types for fields of a composite type.
"""

# ╔═╡ 6e2bec05-8fad-4398-b28d-f72fba3664d0
struct StructWithAnyType
	x
end

# ╔═╡ a88c0498-205f-4da0-a448-4402a292bf96
md"""
Without specifying the type for `x` in the above composite type `StructWithAnyType`, it has a type of `Any` by default. You can use [`dump`](https://docs.julialang.org/en/v1/base/io-network/#Base.dump) to see the types of all fields of a composite type.
"""

# ╔═╡ 49c8e290-ad2d-4759-b33f-4267c6f43083
with_terminal() do
	dump(StructWithAnyType)
end

# ╔═╡ 591a952b-16dd-4b8c-b3ba-ef7a6328d039
md"""
Now, let's create another composite type `StructWithConcreteType` with a concrete type of `Float64` for the field `x`.
"""

# ╔═╡ c55b9ef5-f432-46f5-928d-f305cdc7fce5
struct StructWithConcreteType
	x::Float64
end

# ╔═╡ 5572c1f6-db1f-4571-9be5-258b94379f9d
md"""
We first define a varaible `num_elements` to store the total number of instances of the composite types shown above.
"""

# ╔═╡ 06a22264-4b2c-4b68-bd4c-2c7ce45cd5be
num_elements = 100_000;

# ╔═╡ c701389a-2411-4c53-8436-9a3be7f7aa46
md"""
Let's compare the performance of the two composite types. We first generate $(format(num_elements, commas=true)) random numbers between 0 and 1, instantiates the composite type with these random numbers, and count how many numbers are greater than 0.5.
"""

# ╔═╡ 1253f9dc-4cd8-481e-a5a8-81eea124a572
function count_objects_any_type(n)
	Random.seed!(1)
	objects = [StructWithAnyType(x) for x in rand(n)]
	count = 0
	for obj in objects
		if obj.x > 0.5
			count += 1
		end
	end
	return count
end;

# ╔═╡ 9abbaae0-2315-4653-b920-5c512fb45801
function count_objects_concrete_type(n)
	Random.seed!(1)
	objects = [StructWithConcreteType(x) for x in rand(n)]
	count = 0
	for obj in objects
		if obj.x > 0.5
			count += 1
		end
	end
	return count
end;

# ╔═╡ a63b531a-615e-449d-9c4e-e2e0d63fd560
with_terminal() do
	@btime count_objects_any_type(num_elements)
end

# ╔═╡ b031cceb-e4e9-49cd-ace3-367d9e1a3c27
with_terminal() do
	@btime count_objects_concrete_type(num_elements)
end

# ╔═╡ de9bc66e-e8e2-434c-8489-b4442d2fdb35
md"""
In this simple example, the composite type with a field of concrete type outperforms the version with the default abstract type by almost 10 times.
"""

# ╔═╡ ef7d8380-f25e-11eb-1779-ef4a5d863cc1
html"""
<style>
	article.firstparagraph p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}
	
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}

	/* For bullet point inside admonition */
	pluto-output div.admonition .admonition-title ~ ul {
		padding-left: 2.5em;
	}

	/* For block quote */
	blockquote {
		font-family: Georgia, serif;
		position: relative;
		margin: 0.0em;
		padding: 0.5em 2em 0.5em 3em;
	}
	
	blockquote:before {
		font-family: Georgia, serif;
		position: absolute;
		font-size: 3em;
		line-height: 1;
		top: 0;
		left: 0;
		content: "\201C";
	}
	blockquote:after {
		font-family: Georgia, serif;
		position: absolute;
		float:right;
		font-size:3em;
		line-height: 1;
		right:0;
		bottom:-0.5em;
		content: "\201D";
	}
	blockquote footer {
		padding: 0 2em 0 0;
		text-align:right;
	}
	blockquote cite:before {
		content: "\2013";
	}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Formatting = "59287772-0a20-5a39-b81b-1366585eb4c0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
BenchmarkTools = "~1.1.1"
Formatting = "~0.4.2"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "c31ebabde28d102b602bada60ce8922c266d205b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.1"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "94bf17e83a0e4b20c8d77f6af8ffe8cc3b386c0a"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╟─50aa9471-503a-499f-990b-f1c7acb784bc
# ╠═608a431e-e51c-4899-bffe-7261c625fb64
# ╟─9d8f3586-ce99-405c-8329-3a58ee176ef7
# ╟─1a9931d6-1312-419b-8888-cac2fb8b7497
# ╠═6e2bec05-8fad-4398-b28d-f72fba3664d0
# ╟─a88c0498-205f-4da0-a448-4402a292bf96
# ╠═49c8e290-ad2d-4759-b33f-4267c6f43083
# ╟─591a952b-16dd-4b8c-b3ba-ef7a6328d039
# ╠═c55b9ef5-f432-46f5-928d-f305cdc7fce5
# ╟─5572c1f6-db1f-4571-9be5-258b94379f9d
# ╠═06a22264-4b2c-4b68-bd4c-2c7ce45cd5be
# ╟─c701389a-2411-4c53-8436-9a3be7f7aa46
# ╠═1253f9dc-4cd8-481e-a5a8-81eea124a572
# ╠═9abbaae0-2315-4653-b920-5c512fb45801
# ╠═a63b531a-615e-449d-9c4e-e2e0d63fd560
# ╠═b031cceb-e4e9-49cd-ace3-367d9e1a3c27
# ╟─de9bc66e-e8e2-434c-8489-b4442d2fdb35
# ╟─ef7d8380-f25e-11eb-1779-ef4a5d863cc1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
