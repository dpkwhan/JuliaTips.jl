### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ dc17b960-e9ca-11eb-20e2-5ba0054538e8
begin
	using Pkg, Random
	Pkg.activate(mktempdir())
	Pkg.add("BenchmarkTools")
	using BenchmarkTools
end

# ╔═╡ 1743f917-f85e-44ab-951a-138f21de23e4
md"""
# Map, Loop and Broadcasting
"""

# ╔═╡ f0da4670-5130-42dc-ba13-5c19cff89214
html"""
	<span style="display: block; text-align: right;"><b>David Han</b>: July 22, 2021</span>
"""

# ╔═╡ 2751245e-7a93-493f-a72e-e36929096a9b
html"""
<article class="firstparagraph">
	<p>
		Performance
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

# ╔═╡ 517c7d02-e991-4c77-bb4a-3f63ff65d0db
md"""
## Notes
* Generate random numbers between 0 and 1. Head if greater than 0.5 and tail otherwise.
* Count number of heads
* Compare the performance of:
  * map
  * for loop
  * broadcast
"""

# ╔═╡ Cell order:
# ╟─1743f917-f85e-44ab-951a-138f21de23e4
# ╟─f0da4670-5130-42dc-ba13-5c19cff89214
# ╠═dc17b960-e9ca-11eb-20e2-5ba0054538e8
# ╟─2751245e-7a93-493f-a72e-e36929096a9b
# ╠═517c7d02-e991-4c77-bb4a-3f63ff65d0db
