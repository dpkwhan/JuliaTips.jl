### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 357be8bf-2702-4be3-ae73-d1c9edd9c673
md"""
# Functional One-Liners in Julia
"""

# ╔═╡ 2f0a86e2-be0d-400e-a1ac-a0b353433b76
html"""
	<span style="display: block; text-align: right;"><b>Erik Engheim</b>: Nov 15, 2020</span>
"""

# ╔═╡ 0b7404d2-af1c-4999-9758-b573c8ef374d
md"""
!!! note "Disclaimer"
	This Pluto notebook is a conversion of Erik Engheim's original article found [here](https://levelup.gitconnected.com/functional-one-liners-in-julia-e0ed35d4ff7b) with some minor changes to work with Pluto. All credits are Erik's.
"""

# ╔═╡ 3ecd7c3d-c334-42a4-acf2-9895d5f3cbea
html"""
<span style="display:block;text-align:center">
<img src="https://miro.medium.com/max/1400/1*VtUqyqctMRvEIvScSYIQfw.png">
</span>
"""

# ╔═╡ 8420cc24-51e6-4fbd-bcd9-47f819debc23
html"""
<article class="firstparagraph">
	<p>
		Being such an expressive language, it is easy when programming Julia to start thinking:
	</p>
	<blockquote>
		Isn’t there an even more conscience and elegant way of solving this problem?
	</blockquote>
</article>
"""

# ╔═╡ cd044311-97e9-49e4-ab70-ebca1ae8427e
md"""
A lot of problems can be solved straightforward with approaches you are used to from other languages. However in Julia there is often an even shorter and clearer way to do things.
"""

# ╔═╡ ffafed63-a861-40e8-8010-0f4733c15ed6
html"""<h2 style="color:red">Partial Application</h2>"""

# ╔═╡ 05296e57-2b92-4c6b-9273-10c4855864b3
md"""
Partial application of a function or currying is something that was popularized by Haskell. It means by not providing all the arguments you can return a new function taking the rest of the arguments.
This may sound confusing, so let me give some examples. Normally you would do a comparison like this:
"""

# ╔═╡ b2bf8b26-d140-4db0-8f1d-ce51832e7be6
3 < 4

# ╔═╡ 4e25f9c8-ed0b-4db2-882d-10f4eaf80c3d
md"Which is identical to this, because almost everything in Julia is a function:"

# ╔═╡ cd09ea22-739b-462c-9a90-03818e68a2fd
<(3, 4)

# ╔═╡ 34528ac4-11e1-4f6d-af63-4d6811ffac58
md"What happens if you don’t provide all the arguments?"

# ╔═╡ a1a03ff0-4e08-411b-baea-40616bfc5e4a
<(4)

# ╔═╡ a1f9e23a-ecd9-4854-b288-c2868f6438b4
md"What you get instead is a callable object. We can store this, and use it later:"

# ╔═╡ 38f525a5-44f6-465b-974e-d9f0e0056467
let
	f = <(4)
	f(3)
end

# ╔═╡ 17f7927b-34bb-4041-849a-c22517bab40b
md"""
How is this useful? It makes is really elegant to work with functions such as map, filter and reduce.
"""

# ╔═╡ 17b31772-0aee-4314-acab-fff5510cc968
html"""<h3 style="color:green">Find all elements which are less than value</h3>"""

# ╔═╡ e36cfcd7-cbb0-4fce-9650-d413145a6ede
md"Find elements in a list or range which are less than a given value."

# ╔═╡ 1d03d479-2ae3-4b77-820c-26d9ee32ec85
filter(<(5), 1:10)

# ╔═╡ d1905e19-b6f0-4ec3-8c14-8c8fa02941c7
md"You could also use it to find larger values instead:"

# ╔═╡ 015b66a2-53f1-4b4e-badf-dfc5258bf834
filter(>(5), 1:10)

# ╔═╡ 629428f3-ea8c-455c-9a5f-ea7d43780857
html"""<h3 style="color:green">Find index of an element</h3>"""

# ╔═╡ 9dde50c3-ee9e-4274-8d6f-877f62f8f492
md"""
We can find the index of every occurrence of the number 4, *e.g.*
"""

# ╔═╡ 8570b6ce-fc62-4962-847d-07f2c0f3a4c9
findall(==(4), [4, 8, 4, 2, 1, 5])

# ╔═╡ a65867b5-364b-4aee-b3d9-f1693479d263
md"This of course works equally well with strings:"

# ╔═╡ de85335e-0687-46db-8ada-80ddf89477dd
findlast(==("foo"), ["bar", "foo", "qux", "foo"])

# ╔═╡ 7a764858-a163-4112-ba99-86e4a87e9487
html"""<h3 style="color:green">Filter out particular file types</h3>"""

# ╔═╡ bc0e6a11-da23-4f48-9513-f159c2e97db2
md"""
Say you want to get a list of all the `.png` files in the current directory. How do you do that?

We can use the [`endswith`](https://docs.julialang.org/en/v1/base/strings/#Base.endswith) function.
"""

# ╔═╡ 188de107-84cd-4e79-91de-c5d0ff9f65fc
endswith("somefile.png", ".png")

# ╔═╡ cc26d6ed-e424-4c3e-b057-be69355cfa55
md"""
Like many other functions it can be used in partial application which makes it handy to use in filters:
"""

# ╔═╡ dd1e8d10-4310-4b7a-aaf9-58e304cc59be
pngs = filter(endswith(".png"), readdir())

# ╔═╡ b5798e99-dcdf-4cfb-b0e2-37f577cdfff1
html"""<h2 style="color:red">Predicate Function Negation</h2>"""

# ╔═╡ 261b54d1-6703-4941-824c-dfa5eb5f633d
md"""
This is a trick I sadly discovered quite late. But it turns out that you can place `!` in front of a function to produce a new function which inverts its output. This is actually not built into the Julia language but just a function itself defined as:

```julia
!(f::Function) = (x...)->!f(x...)
```

Again it may not be entirely clear what I am getting at, so let us look at some examples.
"""

# ╔═╡ 0bb0b73d-5e19-4ae3-b859-8fa567a19aa4
html"""<h3 style="color:green">Removing empty lines</h3>"""

# ╔═╡ 708487f0-8745-4162-97a8-4ee1a1ab6115
md"""
Say you read all the lines in a file given by filename and you want to strip out the empty lines, you could do that like this:

```julia
filter(line -> !isempty(line), readlines(filename))
```

But these is a more elegant approach using partial application of `!`:

```julia
filter(!isempty, readlines(filename))
```
"""

# ╔═╡ 52719697-6818-40fa-a86d-90418ab4279c
md"Here is an example of using it on the REPL with some dummy data:"

# ╔═╡ e4480c83-2359-4d1c-8d4d-cc40d827d34e
filter(!isempty, ["foo", "", "bar", ""])

# ╔═╡ d8aed918-a91e-47de-a66a-1e879dd0f8d9
html"""<h2 style="color:red">Broadcast and Map</h2>"""

# ╔═╡ d98d4389-ff25-4091-8c23-fcd41e637ee3
md"""
Julia has the broadcast function which you can think of as a fancy version of [`map`](https://docs.julialang.org/en/v1/base/collections/#Base.map). You can even use it in similar fashion:
"""

# ╔═╡ ad4138e4-b32a-453e-a809-5d6dff9704d5
map(sqrt, [9, 16, 25])

# ╔═╡ fc8d8037-ee1a-4ac7-bef0-a06111c9e065
broadcast(sqrt, [9, 16, 25])

# ╔═╡ 8d4269b6-d4b4-4fb7-aa1a-fdbde17687e3
md"""
The real power comes when dealing with functions taking multiple arguments and you want one of the arguments to be reused and the others to be changed.
"""

# ╔═╡ cf334a52-25f5-4ed3-b111-d2477185d863
html"""<h3 style="color:green">Converting a list of strings to numbers</h3>"""

# ╔═╡ 85a6f3b7-c814-4907-986b-716d6a71a113
md"""
To convert say a string to a number you use the [`parse`](https://docs.julialang.org/en/v1/base/numbers/#Base.parse) function like this:
"""

# ╔═╡ 15cabf67-e9fd-42f6-8b3f-f2eaccb63694
parse(Int, "42")

# ╔═╡ 909ee33e-3526-47f7-916a-dfa01cc766e3
md"The naive way to apply this to multiple text strings would be to write:"

# ╔═╡ cf4bc097-2047-4c61-ab91-987d4ae977c1
map(s -> parse(Int, s), ["7", "42", "1331"])

# ╔═╡ 2cc6b2d8-31c1-49b1-9c6d-042971f4b583
md"""
We can simplify this with the broadcast function:
"""

# ╔═╡ 47c6419e-b138-489e-9d60-68e180c2c08d
broadcast(parse, Int, ["7", "42", "1331"])

# ╔═╡ 1b276979-ae85-4f9f-8030-f36f65be47ae
md"""
In fact this is so useful and common to do in Julia, that there is an even shorter version using the dot `.` suffix:
"""

# ╔═╡ bc45a23c-aadb-4093-83ff-52a558a37178
parse.(Int, ["7", "42", "1331"])

# ╔═╡ d6667306-f852-4f21-95bc-93e53cc8d050
md"You can even chain this:"

# ╔═╡ 54b6c5d4-8d31-4129-83b0-343865147950
sqrt.(parse.(Int, ["9", "16", "25"]))

# ╔═╡ 4103062d-d4d2-4dab-82f2-bbdfcfcf9d93
html"""<h3 style="color:green">Convert snake case to camel case</h3>"""

# ╔═╡ 710e9e0b-57ce-4678-a1a2-bdae72cd3561
md"""
In programming we often have identifiers written like `hello_how_are_you` which we may want to covert to camel case written like `HelloHowAreYou`. Turns out you can do this easily with just one line of code in Julia.
"""

# ╔═╡ 96a85f97-82e0-4b80-bd2d-ce60ce180f61
greeting = "hello_how_are_you"

# ╔═╡ af40c72a-ef23-449e-a339-20dedc773ea6
join(uppercasefirst.(split(greeting, '_')))

# ╔═╡ d4f49923-a027-4f00-a56d-b257141b9209
html"""<h3 style="color:green">Avoid deep nesting with pipe operator</h3>"""

# ╔═╡ be5b62eb-66db-4fcc-b6c0-c83b54eec6b8
md"""
A common complaint against more functional oriented language like Julia from OOP fans is that it is hard to read deeply nested function calls. However we can avoid deep nesting by using the pipe opeator `|>`. Just to give a simple flavor of what it does. Here is an example of equivalent expressions:
"""

# ╔═╡ 9ce4d002-0fbf-4aa9-b4ea-4537b0dea7d9
string(sqrt(16))

# ╔═╡ 34b5c16d-1bef-4d22-a05c-b9ee28747dd3
16 |> sqrt |> string

# ╔═╡ e96f9ef7-ef85-4f2b-994b-28f223f8900d
md"""
This also works with broadcast so you can use it is pipe multiple values between stages in a sort of pipeline.
"""

# ╔═╡ bd000e6c-8a91-4d5f-9ca6-ccbdff231f76
[16, 4, 9] .|> sqrt .|> string

# ╔═╡ 076dcda3-dff3-4c5a-930f-56e398378598
md"With this we can simplify our snake-case to camel-case example."

# ╔═╡ 6bcda6d6-657e-4ce7-b484-ad5121d6a2f8
split(greeting, '_') .|> uppercasefirst |> join

# ╔═╡ 71ebda85-dedf-4491-9388-fe24d9e72c38
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

	pluto-output div.admonition .admonition-title ~ ul {
		padding-left: 2.5em;
	}
</style>
"""

# ╔═╡ Cell order:
# ╟─357be8bf-2702-4be3-ae73-d1c9edd9c673
# ╟─2f0a86e2-be0d-400e-a1ac-a0b353433b76
# ╟─0b7404d2-af1c-4999-9758-b573c8ef374d
# ╟─3ecd7c3d-c334-42a4-acf2-9895d5f3cbea
# ╟─8420cc24-51e6-4fbd-bcd9-47f819debc23
# ╟─cd044311-97e9-49e4-ab70-ebca1ae8427e
# ╟─ffafed63-a861-40e8-8010-0f4733c15ed6
# ╟─05296e57-2b92-4c6b-9273-10c4855864b3
# ╠═b2bf8b26-d140-4db0-8f1d-ce51832e7be6
# ╟─4e25f9c8-ed0b-4db2-882d-10f4eaf80c3d
# ╠═cd09ea22-739b-462c-9a90-03818e68a2fd
# ╟─34528ac4-11e1-4f6d-af63-4d6811ffac58
# ╠═a1a03ff0-4e08-411b-baea-40616bfc5e4a
# ╠═a1f9e23a-ecd9-4854-b288-c2868f6438b4
# ╠═38f525a5-44f6-465b-974e-d9f0e0056467
# ╟─17f7927b-34bb-4041-849a-c22517bab40b
# ╟─17b31772-0aee-4314-acab-fff5510cc968
# ╟─e36cfcd7-cbb0-4fce-9650-d413145a6ede
# ╠═1d03d479-2ae3-4b77-820c-26d9ee32ec85
# ╟─d1905e19-b6f0-4ec3-8c14-8c8fa02941c7
# ╠═015b66a2-53f1-4b4e-badf-dfc5258bf834
# ╟─629428f3-ea8c-455c-9a5f-ea7d43780857
# ╟─9dde50c3-ee9e-4274-8d6f-877f62f8f492
# ╠═8570b6ce-fc62-4962-847d-07f2c0f3a4c9
# ╟─a65867b5-364b-4aee-b3d9-f1693479d263
# ╠═de85335e-0687-46db-8ada-80ddf89477dd
# ╟─7a764858-a163-4112-ba99-86e4a87e9487
# ╟─bc0e6a11-da23-4f48-9513-f159c2e97db2
# ╠═188de107-84cd-4e79-91de-c5d0ff9f65fc
# ╟─cc26d6ed-e424-4c3e-b057-be69355cfa55
# ╠═dd1e8d10-4310-4b7a-aaf9-58e304cc59be
# ╟─b5798e99-dcdf-4cfb-b0e2-37f577cdfff1
# ╟─261b54d1-6703-4941-824c-dfa5eb5f633d
# ╟─0bb0b73d-5e19-4ae3-b859-8fa567a19aa4
# ╟─708487f0-8745-4162-97a8-4ee1a1ab6115
# ╟─52719697-6818-40fa-a86d-90418ab4279c
# ╠═e4480c83-2359-4d1c-8d4d-cc40d827d34e
# ╟─d8aed918-a91e-47de-a66a-1e879dd0f8d9
# ╟─d98d4389-ff25-4091-8c23-fcd41e637ee3
# ╠═ad4138e4-b32a-453e-a809-5d6dff9704d5
# ╠═fc8d8037-ee1a-4ac7-bef0-a06111c9e065
# ╟─8d4269b6-d4b4-4fb7-aa1a-fdbde17687e3
# ╟─cf334a52-25f5-4ed3-b111-d2477185d863
# ╟─85a6f3b7-c814-4907-986b-716d6a71a113
# ╠═15cabf67-e9fd-42f6-8b3f-f2eaccb63694
# ╟─909ee33e-3526-47f7-916a-dfa01cc766e3
# ╠═cf4bc097-2047-4c61-ab91-987d4ae977c1
# ╟─2cc6b2d8-31c1-49b1-9c6d-042971f4b583
# ╠═47c6419e-b138-489e-9d60-68e180c2c08d
# ╟─1b276979-ae85-4f9f-8030-f36f65be47ae
# ╠═bc45a23c-aadb-4093-83ff-52a558a37178
# ╟─d6667306-f852-4f21-95bc-93e53cc8d050
# ╠═54b6c5d4-8d31-4129-83b0-343865147950
# ╟─4103062d-d4d2-4dab-82f2-bbdfcfcf9d93
# ╟─710e9e0b-57ce-4678-a1a2-bdae72cd3561
# ╠═96a85f97-82e0-4b80-bd2d-ce60ce180f61
# ╠═af40c72a-ef23-449e-a339-20dedc773ea6
# ╟─d4f49923-a027-4f00-a56d-b257141b9209
# ╟─be5b62eb-66db-4fcc-b6c0-c83b54eec6b8
# ╠═9ce4d002-0fbf-4aa9-b4ea-4537b0dea7d9
# ╠═34b5c16d-1bef-4d22-a05c-b9ee28747dd3
# ╟─e96f9ef7-ef85-4f2b-994b-28f223f8900d
# ╠═bd000e6c-8a91-4d5f-9ca6-ccbdff231f76
# ╟─076dcda3-dff3-4c5a-930f-56e398378598
# ╠═6bcda6d6-657e-4ce7-b484-ad5121d6a2f8
# ╟─71ebda85-dedf-4491-9388-fe24d9e72c38
