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

# ╔═╡ a8ddd630-e978-11eb-1b2d-b5a0af7bcef8
begin
	using Pkg, Random
	Pkg.activate(mktempdir())
	Pkg.add("PlutoUI")
	Pkg.add("BenchmarkTools")
	using PlutoUI, BenchmarkTools
end

# ╔═╡ 58895063-cb7a-4631-9f73-8ceebb9c7528
md"""
# Conditional Execution with Binary Selection
"""

# ╔═╡ c1195b3f-0441-478a-845f-55a569996c70
html"""
	<span style="display: block; text-align: right;"><b>David Han</b>: July 21, 2021</span>
"""

# ╔═╡ 5c894d8b-9aaf-496f-a84b-37c35d8175da
html"""
<article class="firstparagraph">
	<p>
		Conditional execution is supported by every programming language and the simplest form is <i>if statement</i>. This section focuses on the binary selection, which basically has two possible paths of execution.
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

# ╔═╡ 901290fd-d665-4573-89be-2693a42cbaa4
html"""<h2 style="color:red">Overview</h2>"""

# ╔═╡ b1ee75b8-0430-4f56-9c2b-d7110cef74f5
md"""
We are asked to determine whether a day is weekend day and the day of the week is represented by three characters: "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" and "Sun". It returns "weekend" if the input is a weekend day and "weekday" otherwise. We have three approaches to do this:
* `if...else...`
* `... ? ... : ...`
* `ifelse()`
Let's look at each approach in order.
"""

# ╔═╡ 13877003-e5a0-4ad9-8082-ef7983745edb
weekenddays = ["Sat", "Sun"];

# ╔═╡ 8a5222a2-990c-47da-826a-0efa18ee9279
html"""<h3 style="color:green;">Single day</h3>"""

# ╔═╡ d148c7ac-54e5-48c3-9c83-cb6aee128a02
SelectDay = @bind dow Select(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])

# ╔═╡ 9c681c2b-09fb-4673-8a39-2ac981cd9e8e
html"""<h4 style="color:blue">if-else</h4>"""

# ╔═╡ 05faac70-1f91-4a21-973a-d765704545c9
if dow in weekenddays
	"weekend"
else
	"weekday"
end

# ╔═╡ 984b5158-0513-4555-bb5d-2f22826d2004
html"""<h4 style="color:blue">ternary operator (<code>?:</code>)</h4>"""

# ╔═╡ c266fbbe-6988-4666-851d-8628add173c2
dow in weekenddays ? "weekend" : "weekday"

# ╔═╡ 2e83cac7-cac2-4d65-949f-61ee9ce7fb6f
html"""<h4 style="color:blue">function <code>ifelse</code></h4>"""

# ╔═╡ 38539208-116c-43f4-a12b-4dc3bf1fa1ca
ifelse(dow in weekenddays, "weekend", "weekday")

# ╔═╡ 73425695-d61d-466a-a37d-9a12f4ee3c9d
html"""<h3 style="color:green;">Multiple days</h3>"""

# ╔═╡ cc74025b-624d-4bac-8d20-8ec2a482a118
md"""
Let's go one step further from a scalar variable to an array of days.
"""

# ╔═╡ f4414ae5-244f-42ba-9f1a-cb52bf4d5d47
days = ["Sun", "Mon", "Wed", "Tue", "Fri", "Sat", "Thu"]

# ╔═╡ 3ca7721e-b15f-4ed4-8400-6ea1bbec7c88
html"""<h4 style="color:blue">if-else</h4>"""

# ╔═╡ ce625916-9b0c-4a99-8ffc-0acc83daf8e6
begin
	function daytype_if_else(xs, ys)
		res = []
		for x in xs
			r = if x in ys
				 "weekend"
			else
				"weekday"
			end
			push!(res, r)
		end
		res
	end
	daytype_if_else(days, weekenddays)
end

# ╔═╡ 537aeebd-8630-453b-a9db-a924826ad7fd
html"""<h4 style="color:blue">ternary operator (<code>?:</code>)</h4>"""

# ╔═╡ 0e9f50d7-1ea4-4c9c-9d79-e5e78e001be7
begin
	function daytype_ternary(xs, ys)
		res = []
		for x in xs
			r = x in ys ? "weekend" : "weekday"
			push!(res, r)
		end
		res
	end
	daytype_ternary(days, weekenddays)
end

# ╔═╡ c464a077-71e2-4d1b-ac42-32cccdf12e25
html"""<h4 style="color:blue">function <code>ifelse</code></h4>"""

# ╔═╡ 9e6a8044-a630-48f1-bfc2-54c01c2ec8b5
begin
	function daytype_ifelse(xs, ys)
		res = []
		for x in xs
			r = ifelse(x in ys, "weekend", "weekday")
			push!(res, r)
		end
		res
	end
	daytype_ifelse(days, weekenddays)
end

# ╔═╡ 4bf8a9dc-fd86-424c-b636-08b24969d5d5
html"""<h3 style="color:green;">Performance</h3>"""

# ╔═╡ 2bd5eecd-38cb-47f3-bbbc-cf77370591d4
html"""<h4 style="color:blue">Prepare data</h4>"""

# ╔═╡ 96253069-6a5b-436f-9a81-c87c6fa04ae6
begin
	rng = MersenneTwister(0)
	many_days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][rand(rng, 1:7, 1_000)]
end;

# ╔═╡ bd0c5981-f0d2-4e2b-abb2-c90641a1ff97
html"""<h4 style="color:blue">if-else</h4>"""

# ╔═╡ eb481f69-70ac-4fd9-9582-e4e865894b4e
@benchmark daytype_if_else(many_days, weekenddays)

# ╔═╡ 2168caf2-ff72-43dd-81b9-bfbe4dc9bd32
html"""<h4 style="color:blue">ternary operator (<code>?:</code>)</h4>"""

# ╔═╡ 63f58c5d-4059-46ee-b9a8-3179ab195d7c
@benchmark daytype_ternary(many_days, weekenddays)

# ╔═╡ 94e4333f-a3ab-4089-9043-dad7b99fb0ed
html"""<h4 style="color:blue">function <code>ifelse</code></h4>"""

# ╔═╡ 360a8c5d-f552-43a7-b868-d4f28233990a
@benchmark daytype_ifelse(many_days, weekenddays)

# ╔═╡ d070db0e-7494-474b-991a-25bcbd706bd4
html"""<h2 style="color:red">Summary</h2>"""

# ╔═╡ e9fb7b45-f07e-47b6-890b-0ba91c6e4582
md"""
The testing above indicates there is no significant difference in performance among the three approaches. The Julia Base documentation on [`ifelse`](https://docs.julialang.org/en/v1/base/base/#Core.ifelse) states that in some cases, using `ifelse` instead of an `if` statement can eliminate the branch in generated code and provide higher performance in tight loops.
"""

# ╔═╡ Cell order:
# ╟─58895063-cb7a-4631-9f73-8ceebb9c7528
# ╟─c1195b3f-0441-478a-845f-55a569996c70
# ╠═a8ddd630-e978-11eb-1b2d-b5a0af7bcef8
# ╟─5c894d8b-9aaf-496f-a84b-37c35d8175da
# ╟─901290fd-d665-4573-89be-2693a42cbaa4
# ╟─b1ee75b8-0430-4f56-9c2b-d7110cef74f5
# ╠═13877003-e5a0-4ad9-8082-ef7983745edb
# ╟─8a5222a2-990c-47da-826a-0efa18ee9279
# ╠═d148c7ac-54e5-48c3-9c83-cb6aee128a02
# ╟─9c681c2b-09fb-4673-8a39-2ac981cd9e8e
# ╠═05faac70-1f91-4a21-973a-d765704545c9
# ╟─984b5158-0513-4555-bb5d-2f22826d2004
# ╠═c266fbbe-6988-4666-851d-8628add173c2
# ╟─2e83cac7-cac2-4d65-949f-61ee9ce7fb6f
# ╠═38539208-116c-43f4-a12b-4dc3bf1fa1ca
# ╟─73425695-d61d-466a-a37d-9a12f4ee3c9d
# ╟─cc74025b-624d-4bac-8d20-8ec2a482a118
# ╠═f4414ae5-244f-42ba-9f1a-cb52bf4d5d47
# ╟─3ca7721e-b15f-4ed4-8400-6ea1bbec7c88
# ╠═ce625916-9b0c-4a99-8ffc-0acc83daf8e6
# ╟─537aeebd-8630-453b-a9db-a924826ad7fd
# ╠═0e9f50d7-1ea4-4c9c-9d79-e5e78e001be7
# ╟─c464a077-71e2-4d1b-ac42-32cccdf12e25
# ╠═9e6a8044-a630-48f1-bfc2-54c01c2ec8b5
# ╟─4bf8a9dc-fd86-424c-b636-08b24969d5d5
# ╟─2bd5eecd-38cb-47f3-bbbc-cf77370591d4
# ╠═96253069-6a5b-436f-9a81-c87c6fa04ae6
# ╟─bd0c5981-f0d2-4e2b-abb2-c90641a1ff97
# ╠═eb481f69-70ac-4fd9-9582-e4e865894b4e
# ╟─2168caf2-ff72-43dd-81b9-bfbe4dc9bd32
# ╠═63f58c5d-4059-46ee-b9a8-3179ab195d7c
# ╟─94e4333f-a3ab-4089-9043-dad7b99fb0ed
# ╠═360a8c5d-f552-43a7-b868-d4f28233990a
# ╟─d070db0e-7494-474b-991a-25bcbd706bd4
# ╟─e9fb7b45-f07e-47b6-890b-0ba91c6e4582
