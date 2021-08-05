### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 5f9d1f8b-2822-4591-833e-f33ad36c0992
using Random, BenchmarkTools, PlutoUI

# ╔═╡ 611ad9ed-ea8c-4630-a2b9-c16dddfedb4e
md"# Multiple Dispatch"

# ╔═╡ d556045a-1283-4aff-9047-dd9b2af54797
html"""
	<span style="display: block; text-align: right;"><b>David Han</b>: Aug 5, 2021</span>
"""

# ╔═╡ aa682430-d04e-4377-bde4-6d08b47636da
html"""
<article class="firstparagraph">
	<p>
		One of the best features of the Julia language is <i>multiple dispatch</i>, which allows Julia to choose which of a function's method to revoke based on the number of arguments and their types.
	</p>
</article>
"""

# ╔═╡ 6f605500-927f-450d-ad56-b2cdef79bd4c
html"""<h2 style="color:red">Task</h2>"""

# ╔═╡ 26a210d3-68e9-4fbc-b96e-08633aff2b84
md"""
We want to write a function which takes one argument and process the input differently based on the type of the input value. If the input is of
* type `String`, convert it to a `Float64`,
* type `Float64`, convert it to a `Int64`,
* any other type, return its square.
This is a typical conditional execution based on type of input value.
"""

# ╔═╡ 6cc17a40-f4a5-44a7-8a90-45b65117830c
html"""<h2 style="color:red">Initial Attempt</h2>"""

# ╔═╡ 798d7ed6-d4ab-4e48-a647-45332cf77148
md"""
Our initial implementation uses [`isa`](https://docs.julialang.org/en/v1/base/base/#Core.isa) to determine the type of the input value and `if-elseif-else` for the conditional evaluation. 
"""

# ╔═╡ 82bae368-936f-4278-9611-d480932bdfa6
function fv1(x)
    if isa(x, String)
        x = parse(Float64, x)
	end
	
	if isa(x, Float64)
        x = ceil(Int64, x)
	end
	
    return x*x
end;

# ╔═╡ 8cdf29f5-6ebb-4314-b209-ababd11dadf8
md"A few simple examples of using this function:"

# ╔═╡ 06982bb4-ee34-42af-979c-590f6251f394
md"Or using broadcasting,"

# ╔═╡ 29dd6d4e-c0ed-4f89-a621-65489f41fa4d
fv1.(["1.23", 2.23, 6])

# ╔═╡ 59c63680-9308-4ce8-bf03-8ff4eeffbb22
html"""<h2 style="color:red">Using Multiple Dispatch</h2>"""

# ╔═╡ de1dab2a-112e-4ed7-9818-6d37ab70041c
md"""
Three methods are implemented:
* The first one takes an input value of type `String`
* The second one takes an input value of type `Float64`
* The third one is a catch-all method, which will be called if input type is neither `String` nor `Float64`.
"""

# ╔═╡ 25d9c77f-ae89-4fc2-a637-fd5787e88f28
begin
	fv2(x::Int64) = x*x
	fv2(x::Float64) = fv2(ceil(Int64, x))
	fv2(x::String) = fv2(parse(Float64, x))
end

# ╔═╡ b0bbc23b-2759-4fa4-b8b6-df45c983ba02
fv2.(["1.23", 2.23, 6])

# ╔═╡ 2abcc108-962d-4b32-b4cb-2711973707e6
html"""<h2 style="color:red">Performance Comparison</h2>"""

# ╔═╡ 4ecf14a0-2ea5-4dc8-910a-7e4f9cecd5cc
md"""
Let's first generate some randome data and apply the two functions to the data to see the difference in terms of performance.
"""

# ╔═╡ 66509ada-dee0-4c55-9b6f-1eb1200df2d1
begin
	Random.seed!(0)
	numVals = 100_000
	floatVals = 1000 .* rand(Float64, numVals)
	stringVals = ["$i" for i in floatVals]
	intVals = vec(rand(1:100, 1, numVals))
	data = shuffle(vcat(floatVals, stringVals, intVals))
end;

# ╔═╡ ec720f95-0a28-43f6-b3a8-a6ec346312bd
with_terminal() do
	@btime fv1.(data)
end

# ╔═╡ e90c80fd-68d1-48c3-9cdf-03b025bab3d0
with_terminal() do
	@btime fv2.(data)
end

# ╔═╡ c3bd8534-8e7a-4144-8d53-0a273e4ae239
html"""<h2 style="color:red">Summary</h2>"""

# ╔═╡ 992b57ad-fec6-4209-81e9-51f0e81e7872
md"""
* Speed
* Memory
* Easier to maintain and extend functionalities
"""

# ╔═╡ 06edce3e-f5a1-11eb-1589-939dc6057a58
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
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
BenchmarkTools = "~1.1.1"
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
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

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
# ╟─611ad9ed-ea8c-4630-a2b9-c16dddfedb4e
# ╟─d556045a-1283-4aff-9047-dd9b2af54797
# ╠═5f9d1f8b-2822-4591-833e-f33ad36c0992
# ╟─aa682430-d04e-4377-bde4-6d08b47636da
# ╟─6f605500-927f-450d-ad56-b2cdef79bd4c
# ╟─26a210d3-68e9-4fbc-b96e-08633aff2b84
# ╟─6cc17a40-f4a5-44a7-8a90-45b65117830c
# ╟─798d7ed6-d4ab-4e48-a647-45332cf77148
# ╠═82bae368-936f-4278-9611-d480932bdfa6
# ╟─8cdf29f5-6ebb-4314-b209-ababd11dadf8
# ╟─06982bb4-ee34-42af-979c-590f6251f394
# ╠═29dd6d4e-c0ed-4f89-a621-65489f41fa4d
# ╟─59c63680-9308-4ce8-bf03-8ff4eeffbb22
# ╟─de1dab2a-112e-4ed7-9818-6d37ab70041c
# ╠═25d9c77f-ae89-4fc2-a637-fd5787e88f28
# ╠═b0bbc23b-2759-4fa4-b8b6-df45c983ba02
# ╟─2abcc108-962d-4b32-b4cb-2711973707e6
# ╟─4ecf14a0-2ea5-4dc8-910a-7e4f9cecd5cc
# ╠═66509ada-dee0-4c55-9b6f-1eb1200df2d1
# ╠═ec720f95-0a28-43f6-b3a8-a6ec346312bd
# ╠═e90c80fd-68d1-48c3-9cdf-03b025bab3d0
# ╟─c3bd8534-8e7a-4144-8d53-0a273e4ae239
# ╟─992b57ad-fec6-4209-81e9-51f0e81e7872
# ╟─06edce3e-f5a1-11eb-1589-939dc6057a58
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
