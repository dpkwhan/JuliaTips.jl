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

# ╔═╡ da7b7a29-36c0-4ade-ae66-af42161b680c
using DataFrames, PlutoUI

# ╔═╡ d554f41c-534a-4620-a27c-680e715d760f
md"""
# Partial Aplication
"""

# ╔═╡ f87fa4b2-11b8-4535-918b-8b54db14dc60
html"""
	<span style="display: block; text-align: right;"><b>David Han</b>: July 20, 2021</span>
"""

# ╔═╡ ca5d7300-e8a2-11eb-2288-d773f589cb3d
html"""
<article class="firstparagraph">
	<p>
		Even though Julia is not a pure functional programming language, but its support of functional programming provides some useful tools make some code amazingly elegant and concise.
	</p>
</article>
"""

# ╔═╡ 0f932493-1aff-44a5-8c57-c650df1ab5d2
html"""<h2 style="color:red">Overview</h2>"""

# ╔═╡ 306a72cf-2c07-4e06-89d3-66e36284c2de
md"""
Quoted from [wiki](https://en.wikipedia.org/wiki/Partial_application):
> In computer science, **partial application** (or **partial function application**) refers to 
> the process of fixing a number of arguments to a function, producing another function 
> of smaller arity.

For a function taking multiple arguments, some arguments can be provided to create a new function object, which can later be called with the remaining arguments. The new function object is called partial function and this approach is called partial applicaiton of a function. A few examples should help understand this concept.

Let's first look at this extremely simple example:
"""

# ╔═╡ 23b6dbd4-656d-4407-b249-f1b4358fdb54
3 < 4

# ╔═╡ 94b74d59-25ec-4169-9190-4d5bb1d67b7e
md"""
The mathematical symbol `<` is actually a function. In additional to the above familiar infix form, a prefix notation can also be used as follows:
"""

# ╔═╡ 1d362ece-2e0e-4dde-8eb0-84aa32515b44
<(3, 4)

# ╔═╡ 95c9e7d4-b58a-49e9-b86b-39fe42bd5936
md"""
Let's create a new function `lt4` by fixing the second argument to 4:
"""

# ╔═╡ 8c058a29-3864-42df-a26d-1184f6afffc8
lt4 = <(4)

# ╔═╡ efcfbbbe-0be5-4500-93ed-bee09f67058c
md"""
So now `lt4` is a single argument function. For example,
"""

# ╔═╡ c478aebe-8bd2-4259-9167-5bcfe9c0cc95
lt4(3), lt4(5)

# ╔═╡ 1332a41f-2d56-4bf5-a376-07879408f25d
md"""
!!! info "Advanced Topic"
	Check the box below to unveil some advanced topic:
"""

# ╔═╡ 41432409-9110-4b69-bf5d-b44878b89020
md"""
An astute reader might notice that the type for partial function `lt4` is `Base.Fix2{typeof(<), Int64})`. We can use `Base.Fix1` to fix the value for the first argument, *i.e.*
	
```julia
julia> 3lt = Base.Fix1(<, 3)
```
Then we can use it like:
```julia
julia> 3lt(4)
true
```
"""

# ╔═╡ 46790754-e01a-4a2c-be2f-9c79ffd7c139
html"""<h2 style="color:red">Usage Examples</h2>"""

# ╔═╡ 0c6a064c-8460-401a-acab-b50a3591c5db
md"""
After the warmup with our toy function `lt4`, let's see how partial function application can be used in practice to help us write concise and elegant code.
"""

# ╔═╡ 5028f189-1e10-4442-91fd-e4d83dbf0f97
html"""<h3 style="color:green;">Example 1: Find all files of a particular type</h3>"""

# ╔═╡ a010ebb9-cad6-48b6-938f-ab2cab2d5284
md"""
Say you want to get a list of all the Julia scripts in the current directory. How do you do that?

We can use the [`endswith`](https://docs.julialang.org/en/v1/base/strings/#Base.endswith) function to match all files that ends with `.jl`.
"""

# ╔═╡ 1b2d0bd8-8a2d-4a05-bfc1-0c595cc0face
filter(filename -> endswith(filename, ".jl"), readdir())

# ╔═╡ 6498bd50-a6b9-4769-8b7f-caa61d6d12f6
md"""
Instead, we can define a function `is_julia_script` by partially applying `endswith` to `".jl"`:
"""

# ╔═╡ 056953c7-f296-4469-b574-22312688f51a
is_julia_script = endswith(".jl");

# ╔═╡ 8d37bfbe-0c5b-4045-a4ed-e4e1e6994569
filter(is_julia_script, readdir())

# ╔═╡ 414209fb-e04b-4269-a532-eb81b5f51bb8
md"""
Or put everything in one line:
"""

# ╔═╡ a630bd48-3854-42d5-be42-1ea002aaab52
filter(endswith(".jl"), readdir());

# ╔═╡ 76570b0e-7468-4b83-b46c-e15c62e46833


# ╔═╡ 614f0b35-20cb-4e53-bb88-f0039ba3ad11
html"""<h3 style="color:green;">Example 2: Broadcasting a vector over another vector</h3>"""

# ╔═╡ b8a2be7b-d854-40db-9321-03ac03d09e93
md"""
Below is quoted from Julia Base documentation on function [`in`](https://docs.julialang.org/en/v1/base/collections/#Base.in).

>
> When broadcasting with `in.(items, collection)` or `items .∈ collection`, 
> both `items` and collection are broadcasted over, which is often not what 
> is intended. For example, if both arguments are vectors (and the dimensions match), 
> the result is a vector indicating whether each value in collection `items` is in the 
> value at the corresponding position in `collection`. To get a vector indicating 
> whether each value in `items` is in `collection`, wrap `collection` in a tuple or 
> a `Ref` like this: `in.(items, Ref(collection))` or `items .∈ Ref(collection)`.

Now, let's look at some examples. To check whether each element of a vector is in another vector, we can do the following suggested by the documentation:
"""

# ╔═╡ 144db80c-82a4-4e02-be88-521f5611221f
in.([1, 2, 3], Ref([2, 3]))

# ╔═╡ 742053a8-9d54-4ece-a272-28a592e46cae
md"""
With function partial application, we can do
"""

# ╔═╡ f6b1b445-455b-4626-98c6-46882956e2af
in([2, 3]).([1, 2, 3])

# ╔═╡ 17576d88-6fc4-4d3e-a859-c210ef96affe
md"""
This technique is quite useful in selecting a subset of rows from a `DataFrame` from package [`DataFrame.jl`](https://github.com/JuliaData/DataFrames.jl). Below is the population for a few selected states, which is stored as a `DataFrame`.
"""

# ╔═╡ a93c3fa9-5381-4cf3-805d-a10465e318b6
begin
	statePopulation = [
		(state=:FL, population=21312211),
		(state=:NY, population=19862512),
		(state=:PA, population=12823989),
		(state=:GA, population=10545138),
		(state=:MI, population=9991177),
		(state=:NJ, population=9032872),
		(state=:VA, population=8525660),
		(state=:WA, population=7530552),
		(state=:CT, population=3588683),
		(state=:IA, population=3160553),
	]
	df = DataFrame(statePopulation)
end

# ╔═╡ cdb2e4bd-36ec-4072-b618-895ccac115bf
md"""
Due to some reason, we are particularly interested in the population of the tri-state area, *i.e.* NY, NJ and CT. How to single out the data for these three states? The `in` function discussed above can be used here.
"""

# ╔═╡ 5a08dda3-0b06-4ae2-ab87-cb6c4092fab9
html"""<h4 style="color:blue">Using (<code>Ref</code>)</h4>"""

# ╔═╡ 5c73d81a-91d2-48e2-9e57-8f109eedba0a
df[in.(df.state, Ref([:NY, :NJ, :CT])), :]

# ╔═╡ 2895c8bc-1563-4622-bb86-56214d029438
html"""<h4 style="color:blue">Using fuction application</h4>"""

# ╔═╡ ef09c83e-a60f-49a0-8388-9f39453b9f14
df[in([:NY, :NJ, :CT]).(df.state), :]

# ╔═╡ 4ba09790-aa58-4d8f-8ad7-3b19ca2f5315
begin
	struct Section
		id::Integer
	end

	function Base.show(io::IO, mime::MIME, s::Section)
	  	iobuff = IOBuffer()
	  	cb = HTML("""
	  		<style>
		  		pluto-cell.hide_below_$(s.id) {
					display: none;
		  		}
	  		</style>
	  		<script>
				if (!window.hasOwnProperty("plutoSections")) {
					window.plutoSections = {};
				}
				const container = currentScript.parentElement;
				const cell = currentScript.closest("pluto-cell");
				const checkbox = container.querySelector("#checkbox-$(s.id)");
				
				const cells = Array.from(cell.parentElement.children);
				const currentIdx = cells.indexOf(cell);
				for (let i = currentIdx; i < cells.length-1; i++) {
					if (!window.plutoSections.hasOwnProperty("pluto_section_$(s.id)")) {
						window.plutoSections["pluto_section_$(s.id)"] = [];
					}
					const cellId = cells[i].id;
					window.plutoSections["pluto_section_$(s.id)"].push(cellId);
				}
				window.plutoSections["pluto_section_$(s.id)"] = [...new Set(window.plutoSections["pluto_section_$(s.id)"])];
				console.log(window.plutoSections["pluto_section_$(s.id)"]);
			
				const setclass = () => {
					const cells = Array.from(cell.parentElement.children)
					for (let i = 0; i < cells.length-1; i++) {
						const cellId = cells[i].id;
						if (window.plutoSections["pluto_section_$(s.id)"].includes(cellId) && cellId !== cell.id) {
							cells[i].classList.toggle("hide_below_$(s.id)", !checkbox.checked);
						}
					}
					container.value = $(s.id)
					container.dispatchEvent(new CustomEvent("input"));
				};
				checkbox.addEventListener("input", setclass);
				setclass();
			</script>
			Show Advanced Topic? <input type="checkbox" id="checkbox-$(s.id)">
		""" * String(take!(iobuff)))
		show(iobuff, mime, cb)
		write(io, take!(iobuff))
	end
	
	PlutoUI.get(s::Section) = s.id
	
	endsection(sid::Int) = HTML("""
		<script>
			let cell = currentScript.closest("pluto-cell");
			let cells = Array.from(cell.parentElement.children);
			let currentIdx = cells.indexOf(cell);
			console.log("End: ", currentIdx, cells.length-1);
			for (let i = currentIdx+1; i <= cells.length-1; i++) {
				const cellId = cells[i].id;
				const idx = window.plutoSections["pluto_section_$(sid)"].indexOf(cellId);
				if (idx !== -1) {
				  window.plutoSections["pluto_section_$(sid)"].splice(idx, 1);
				}
			}

			for (let i = currentIdx; i <= cells.length-1; i++) {
				const cellId = cells[i].id;
				cells[i].classList.toggle("hide_below_$(sid)", false);
			}


		</script>
	""")
end;

# ╔═╡ cf70c457-202d-4065-ba2f-83deeff0829d
@bind s1 Section(1)

# ╔═╡ a002bc9d-2dc4-41d4-bc2e-dd3dbc30939a
endsection(1)

# ╔═╡ 942bc4a3-4644-4369-8d98-810e41505153
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataFrames = "~1.2.1"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "a19645616f37a2c2c3077a44bc0d3e73e13441d7"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.1"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

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

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

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

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

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

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "8ed4a3ea724dac32670b062be3ef1c1de6773ae8"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.4.4"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─d554f41c-534a-4620-a27c-680e715d760f
# ╟─f87fa4b2-11b8-4535-918b-8b54db14dc60
# ╠═da7b7a29-36c0-4ade-ae66-af42161b680c
# ╟─ca5d7300-e8a2-11eb-2288-d773f589cb3d
# ╟─0f932493-1aff-44a5-8c57-c650df1ab5d2
# ╟─306a72cf-2c07-4e06-89d3-66e36284c2de
# ╠═23b6dbd4-656d-4407-b249-f1b4358fdb54
# ╟─94b74d59-25ec-4169-9190-4d5bb1d67b7e
# ╠═1d362ece-2e0e-4dde-8eb0-84aa32515b44
# ╟─95c9e7d4-b58a-49e9-b86b-39fe42bd5936
# ╠═8c058a29-3864-42df-a26d-1184f6afffc8
# ╟─efcfbbbe-0be5-4500-93ed-bee09f67058c
# ╠═c478aebe-8bd2-4259-9167-5bcfe9c0cc95
# ╟─1332a41f-2d56-4bf5-a376-07879408f25d
# ╟─cf70c457-202d-4065-ba2f-83deeff0829d
# ╟─41432409-9110-4b69-bf5d-b44878b89020
# ╟─a002bc9d-2dc4-41d4-bc2e-dd3dbc30939a
# ╟─46790754-e01a-4a2c-be2f-9c79ffd7c139
# ╟─0c6a064c-8460-401a-acab-b50a3591c5db
# ╟─5028f189-1e10-4442-91fd-e4d83dbf0f97
# ╟─a010ebb9-cad6-48b6-938f-ab2cab2d5284
# ╠═1b2d0bd8-8a2d-4a05-bfc1-0c595cc0face
# ╟─6498bd50-a6b9-4769-8b7f-caa61d6d12f6
# ╠═056953c7-f296-4469-b574-22312688f51a
# ╠═8d37bfbe-0c5b-4045-a4ed-e4e1e6994569
# ╟─414209fb-e04b-4269-a532-eb81b5f51bb8
# ╠═a630bd48-3854-42d5-be42-1ea002aaab52
# ╟─76570b0e-7468-4b83-b46c-e15c62e46833
# ╟─614f0b35-20cb-4e53-bb88-f0039ba3ad11
# ╟─b8a2be7b-d854-40db-9321-03ac03d09e93
# ╠═144db80c-82a4-4e02-be88-521f5611221f
# ╟─742053a8-9d54-4ece-a272-28a592e46cae
# ╠═f6b1b445-455b-4626-98c6-46882956e2af
# ╟─17576d88-6fc4-4d3e-a859-c210ef96affe
# ╠═a93c3fa9-5381-4cf3-805d-a10465e318b6
# ╟─cdb2e4bd-36ec-4072-b618-895ccac115bf
# ╟─5a08dda3-0b06-4ae2-ab87-cb6c4092fab9
# ╠═5c73d81a-91d2-48e2-9e57-8f109eedba0a
# ╟─2895c8bc-1563-4622-bb86-56214d029438
# ╠═ef09c83e-a60f-49a0-8388-9f39453b9f14
# ╟─4ba09790-aa58-4d8f-8ad7-3b19ca2f5315
# ╟─942bc4a3-4644-4369-8d98-810e41505153
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
