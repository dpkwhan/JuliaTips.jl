### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 82a391a3-f50a-4b03-b19d-beef0d25ad15
using BenchmarkTools, PlutoUI, HypertextLiteral

# ╔═╡ 1bd9f079-ed17-4d5a-a8b0-dd4069c8acac
md"# Pluto Tutorial"

# ╔═╡ f897e51a-a9d1-4535-bbe7-2fa650aca172
html"""<h2 style="color:red">Development setup</h2>"""

# ╔═╡ 5573c41a-08d2-4e5d-a33b-bd0e8136eb69
html"""<h3 style="color:green">Margin and page width</h3>"""

# ╔═╡ 38c31c2e-40e6-4122-996e-23931df7a745
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""

# ╔═╡ 68d21800-22c4-44c9-80b2-4c9e52d1929e
html"""<h3 style="color:green">Package manager</h3>"""

# ╔═╡ af5bff7f-58d4-449f-8cde-d24ae9a83082
md"""
The built-in package manager in Pluto allows us to use package directly, *i.e.*

```julia
using BenchmarkTools, PlutoUI
```
"""

# ╔═╡ 25aee722-3f05-48f5-ae89-fd8e0c3644df
md"""
The above will automatically install packages `BenchmarkTools` and `PlutoUI` for us. See documentation on [Pluto package management](https://github.com/fonsp/Pluto.jl/wiki/%F0%9F%8E%81-Package-management).
"""

# ╔═╡ fb101abf-436e-4b38-838f-7b7c458e5018
html"""<h2 style="color:red">HTML Styling</h2>"""

# ╔═╡ 4793c655-4dd2-4475-8e56-84b3f5cf8092
html"""<h3 style="color:green">Styling block quote</h3>"""

# ╔═╡ a91f0f22-df29-4d24-8890-729fe4582325
html"""
<style>
	blockquote {
		background: #f8f8f8;
		border-left: 7px solid #ccc;
		margin: 1.5em 7px;
		padding: .2em 7px;
		quotes: "\201C""\201D";
	}
	blockquote {
		display: block;
		margin-block-start: 1em;
		margin-block-end: 1em;
		margin-inline-start: 40px;
		margin-inline-end: 40px;
	}
	blockquote:before {
		color: #ccc;
		content: open-quote;
		font-size: 3.5em;
		line-height: .1em;
		vertical-align: -0.4em;
	}
	blockquote p {
		font-family: Georgia;
		font-style: italic;
	}
</style>
"""

# ╔═╡ 417585e4-f7f4-4363-b1e8-9ae5028f0736
html"""
<blockquote>
<p>
Julia is a general-purpose, high-level, dynamic language, designed from the start to take advantage of techniques for executing dynamic languages at statically-compiled language speeds.
</p>
<p>
We have also experimented with cloud API integration, and begun to develop a web-based, language-neutral platform for visualization and collaboration. The ultimate goal is to make cloud-based supercomputing as easy and accessible as Google Docs.
</p>
</blockquote>
"""

# ╔═╡ c9f916d1-96c8-40d1-9130-d027053fb94e
html"""<h3 style="color:green">First letter of a paragraph</h3>"""

# ╔═╡ 3c51588b-4f64-46fc-87b3-11a410fe3a41
html"""
<style>
	article.firstparagraph p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}
</style>
"""

# ╔═╡ 13b6b1fc-4f95-400c-af62-f0b19392d93e
html"""
<article class="firstparagraph"><p>
Julia is a general-purpose, high-level, dynamic language, designed from the start to take advantage of techniques for executing dynamic languages at statically-compiled language speeds.
</p></article>
"""

# ╔═╡ 44539e27-87a0-493d-af6d-ed2df07d73d5
html"""<h2 style="color:red">Output Display</h2>"""

# ╔═╡ b6e36974-b210-4a7d-ab39-f153bd581cac
md"""
Package [`PlutoUI`](https://github.com/fonsp/PlutoUI.jl) provides function `with_terminal` to capture all messages sent to `stdout`.
"""

# ╔═╡ 9170c6d5-d3c5-46d3-9cd8-fbabd77bfcf8
with_terminal() do
	@btime sum(1:100000)
end

# ╔═╡ bf91edef-afac-4dfe-bc26-9f3e1ec75501
with_terminal() do
	dump(Meta.parse("1 + 1"))
end

# ╔═╡ ea7215c9-98d8-445d-bf56-2f4ed9470f56
html"""<h2 style="color:red">Tips</h2>"""

# ╔═╡ dacb53a7-877c-4aa7-8de0-e86c35d9df6f
html"""<h3 style="color:green">Send value from JavaScript to Julia</h3>"""

# ╔═╡ e1420477-cdb4-4c4e-9385-803257d46a35
md"""
Sometimes we need to use JavaScript to compute some values related to the browswer and then send it back to Julia for some other computations. In the example below, we retrieve the cell width and then assign it to a variable in Julia.
"""

# ╔═╡ 71d508d8-b03b-4b17-8f76-e6057837c19f
CellWidth() = html"""
<div>
<script>
	// Find the first Pluto cell
	const plutoCell = document.querySelector('pluto-cell');
	
	// Retrieve the inner width if available otherwise use outer width
	const cellWidth = plutoCell.clientWidth || plutoCell.offsetWidth;
	
	const div = currentScript.parentElement;
	div.value = cellWidth;  // Set the initial value
	div.dispatchEvent(new CustomEvent("input"));
</script>
</div>
""";

# ╔═╡ 7d6b0f49-8c31-49f5-a2ee-9fbb514e5c7c
@bind cellWidth CellWidth()

# ╔═╡ 728cb7b6-349d-4b00-a359-6fdb3e388888
cellWidth

# ╔═╡ ade2f7ae-016b-4794-8155-a93baa800397
html"""<h3 style="color:green">Send value from Julia to JavaScript</h3>"""

# ╔═╡ 04b5ef98-a9a5-4eb2-834c-b743c5ede6ba
html"""<h4 style="color:blue">Use HypertextLiteral</h4>"""

# ╔═╡ 1f544981-b580-4e5e-9803-3a4d0a2593dd
md"""
Package [`HypertextLiteral.jl`](https://github.com/MechanicalRabbit/HypertextLiteral.jl) allows us to interpolate Julia values into JavaScript. The cell width is printed out on the console of your [browser's built-in developer tools](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_are_browser_developer_tools).
"""

# ╔═╡ de8272fb-053d-4afc-af0a-0ff1a76e21ae
@htl("""
	<script>
	const cellWidth = $(cellWidth);
	console.log("Pluto cell width is ", cellWidth);
	</script>
""")

# ╔═╡ f7c2c20a-fbf2-4208-854d-038231ea6d60
html"""<h4 style="color:blue">Use built-in data transfer</h4>"""

# ╔═╡ 5f9e8589-26c1-4bf8-856d-a95f5d115a26
let
	x = rand(UInt8, 10_000)
	
	d = Dict(
		"some_raw_data" => x,
		"wow" => 1000,
	)
	
	HTML("""
		<script>
		const d = $(PlutoRunner.publish_to_js(d));
		console.log(d);
		</script>
	""")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.1.1"
HypertextLiteral = "~0.9.0"
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

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

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
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

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
# ╟─1bd9f079-ed17-4d5a-a8b0-dd4069c8acac
# ╟─f897e51a-a9d1-4535-bbe7-2fa650aca172
# ╟─5573c41a-08d2-4e5d-a33b-bd0e8136eb69
# ╠═38c31c2e-40e6-4122-996e-23931df7a745
# ╟─68d21800-22c4-44c9-80b2-4c9e52d1929e
# ╟─af5bff7f-58d4-449f-8cde-d24ae9a83082
# ╟─25aee722-3f05-48f5-ae89-fd8e0c3644df
# ╟─fb101abf-436e-4b38-838f-7b7c458e5018
# ╟─4793c655-4dd2-4475-8e56-84b3f5cf8092
# ╠═a91f0f22-df29-4d24-8890-729fe4582325
# ╟─417585e4-f7f4-4363-b1e8-9ae5028f0736
# ╟─c9f916d1-96c8-40d1-9130-d027053fb94e
# ╠═3c51588b-4f64-46fc-87b3-11a410fe3a41
# ╟─13b6b1fc-4f95-400c-af62-f0b19392d93e
# ╟─44539e27-87a0-493d-af6d-ed2df07d73d5
# ╟─b6e36974-b210-4a7d-ab39-f153bd581cac
# ╠═9170c6d5-d3c5-46d3-9cd8-fbabd77bfcf8
# ╠═bf91edef-afac-4dfe-bc26-9f3e1ec75501
# ╟─ea7215c9-98d8-445d-bf56-2f4ed9470f56
# ╟─dacb53a7-877c-4aa7-8de0-e86c35d9df6f
# ╟─e1420477-cdb4-4c4e-9385-803257d46a35
# ╠═71d508d8-b03b-4b17-8f76-e6057837c19f
# ╠═7d6b0f49-8c31-49f5-a2ee-9fbb514e5c7c
# ╠═728cb7b6-349d-4b00-a359-6fdb3e388888
# ╟─ade2f7ae-016b-4794-8155-a93baa800397
# ╟─04b5ef98-a9a5-4eb2-834c-b743c5ede6ba
# ╟─1f544981-b580-4e5e-9803-3a4d0a2593dd
# ╠═de8272fb-053d-4afc-af0a-0ff1a76e21ae
# ╟─f7c2c20a-fbf2-4208-854d-038231ea6d60
# ╠═5f9e8589-26c1-4bf8-856d-a95f5d115a26
# ╟─82a391a3-f50a-4b03-b19d-beef0d25ad15
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
