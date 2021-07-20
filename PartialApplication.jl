### A Pluto.jl notebook ###
# v0.14.8

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
begin
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add("DataFrames")
	Pkg.add("PlutoUI")
	using DataFrames, PlutoUI
end

# ╔═╡ d554f41c-534a-4620-a27c-680e715d760f
md"""
# Partial Aplication
"""

# ╔═╡ ca5d7300-e8a2-11eb-2288-d773f589cb3d
html"""
<article class="firstparagraph">
	<p>
		Even though Julia is not a pure functional programming language, but its support of functional programming provides some useful tools make some code amazingly elegant and concise.
	</p>
</article>

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

# ╔═╡ 306a72cf-2c07-4e06-89d3-66e36284c2de
md"""
## Overview

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
md"""
## Usage Examples
"""

# ╔═╡ 0c6a064c-8460-401a-acab-b50a3591c5db
md"""
After the warmup with our toy function `lt4`, let's see how partial function application can be used in practice to help us write concise and elegant code.
"""

# ╔═╡ a010ebb9-cad6-48b6-938f-ab2cab2d5284
md"""
### Example 1: Find all files of a particular type
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


# ╔═╡ b8a2be7b-d854-40db-9321-03ac03d09e93
md"""
### Example 2: Broadcasting a vector over another vector

Below is quoted from Base documentation on function [`in`](https://docs.julialang.org/en/v1/base/collections/#Base.in).

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
This technique is quite useful in selecting a subset of rows from a `DataFrame` from package [`DataFrame.jl`](https://github.com/JuliaData/DataFrames.jl).
"""

# ╔═╡ a93c3fa9-5381-4cf3-805d-a10465e318b6
begin
	statePopulation = [
		(state=:CA, population=39776830),
		(state=:TX, population=28704330),
		(state=:FL, population=21312211),
		(state=:NY, population=19862512),
		(state=:PA, population=12823989),
		(state=:IL, population=12768320),
		(state=:OH, population=11694664),
		(state=:GA, population=10545138),
		(state=:NC, population=10390149),
		(state=:MI, population=9991177),
		(state=:NJ, population=9032872),
		(state=:VA, population=8525660),
		(state=:WA, population=7530552),
		(state=:AZ, population=7123898),
		(state=:MA, population=6895917),
		(state=:TN, population=6782564),
		(state=:IN, population=6699629),
		(state=:MO, population=6135888),
		(state=:MD, population=6079602),
		(state=:WI, population=5818049),
		(state=:CO, population=5684203),
		(state=:MN, population=5628162),
		(state=:SC, population=5088916),
		(state=:AL, population=4888949),
		(state=:LA, population=4682509),
		(state=:KY, population=4472265),
		(state=:OR, population=4199563),
		(state=:OK, population=3940521),
		(state=:CT, population=3588683),
		(state=:IA, population=3160553),
		(state=:UT, population=3159345),
		(state=:NV, population=3056824),
		(state=:AR, population=3020327),
		(state=:MS, population=2982785),
		(state=:KS, population=2918515),
		(state=:NM, population=2090708),
		(state=:NE, population=1932549),
		(state=:WV, population=1803077),
		(state=:ID, population=1753860),
		(state=:HI, population=1426393),
		(state=:NH, population=1350575),
		(state=:ME, population=1341582),
		(state=:MT, population=1062330),
		(state=:RI, population=1061712),
		(state=:DE, population=971180),
		(state=:SD, population=877790),
		(state=:ND, population=755238),
		(state=:AK, population=738068),
		(state=:DC, population=703608),
		(state=:VT, population=623960),
		(state=:WY, population=573720),
	]
	df = DataFrame(statePopulation)
end

# ╔═╡ cdb2e4bd-36ec-4072-b618-895ccac115bf
md"""
Due to some reason, we are particularly interested in the population of the tri-state area, *i.e.* NY, NJ and CT. How to single out the data for these three states? We can use the `in` function discussed above.
"""

# ╔═╡ 5a08dda3-0b06-4ae2-ab87-cb6c4092fab9
md"""
#### Using `Ref`
"""

# ╔═╡ 5c73d81a-91d2-48e2-9e57-8f109eedba0a
df[in.(df.state, Ref([:NY, :NJ, :CT])), :]

# ╔═╡ 2895c8bc-1563-4622-bb86-56214d029438
md"""
#### Using fuction application
"""

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

# ╔═╡ Cell order:
# ╠═da7b7a29-36c0-4ade-ae66-af42161b680c
# ╟─d554f41c-534a-4620-a27c-680e715d760f
# ╟─ca5d7300-e8a2-11eb-2288-d773f589cb3d
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
# ╟─a010ebb9-cad6-48b6-938f-ab2cab2d5284
# ╠═1b2d0bd8-8a2d-4a05-bfc1-0c595cc0face
# ╟─6498bd50-a6b9-4769-8b7f-caa61d6d12f6
# ╠═056953c7-f296-4469-b574-22312688f51a
# ╠═8d37bfbe-0c5b-4045-a4ed-e4e1e6994569
# ╟─414209fb-e04b-4269-a532-eb81b5f51bb8
# ╠═a630bd48-3854-42d5-be42-1ea002aaab52
# ╟─76570b0e-7468-4b83-b46c-e15c62e46833
# ╟─b8a2be7b-d854-40db-9321-03ac03d09e93
# ╠═144db80c-82a4-4e02-be88-521f5611221f
# ╟─742053a8-9d54-4ece-a272-28a592e46cae
# ╠═f6b1b445-455b-4626-98c6-46882956e2af
# ╟─17576d88-6fc4-4d3e-a859-c210ef96affe
# ╟─a93c3fa9-5381-4cf3-805d-a10465e318b6
# ╟─cdb2e4bd-36ec-4072-b618-895ccac115bf
# ╟─5a08dda3-0b06-4ae2-ab87-cb6c4092fab9
# ╠═5c73d81a-91d2-48e2-9e57-8f109eedba0a
# ╟─2895c8bc-1563-4622-bb86-56214d029438
# ╠═ef09c83e-a60f-49a0-8388-9f39453b9f14
# ╟─4ba09790-aa58-4d8f-8ad7-3b19ca2f5315
