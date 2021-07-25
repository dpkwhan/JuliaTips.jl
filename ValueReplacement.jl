### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ dece5f90-d6df-11eb-3b7f-f3dce8a7c686
md"# Value Replacement"

# ╔═╡ 62134f84-d7b1-455d-a3c3-4412ec4e7e06
md"""
!!! note "Example 1"
	Replace `missing` values with `NaN`
"""

# ╔═╡ eed959ba-9c6d-4067-abbd-4ec01438e22a
replace([1.0, missing, 2.0, missing], missing=>NaN)

# ╔═╡ cb5285f6-427a-4c9a-b3b1-cd034d07c1d2
md"""
To replace the first missing value by `NaN`, but keep the second one as it is:
"""

# ╔═╡ 3b842704-f5f0-4ebe-bab4-c2255377f0e4
replace([1.0, missing, 2.0, missing], missing=>NaN; count=1)

# ╔═╡ 351460e0-11aa-4994-88be-d3372883d642
md"""
!!! note "Example 2" 
	Replace `.` with `-` in a string
"""

# ╔═╡ cc3b095b-a622-4f96-8a83-4eb57e0fc4dc
replace("2021.06.26", "." => "-")

# ╔═╡ 584596ca-b465-4ba1-9b88-797321cb80d9
md"""
!!! note "Example 3"
	Replace with multiple pairs of old and new values
"""

# ╔═╡ ad657ffc-e9cd-4585-9398-05b46d832da0
begin
	dt1 = "2021-06-29T23:14:20"
	subs1 = ["-" => "", ":" => ""]
	for sub in subs1
		dt1 = replace(dt1, sub)
	end
	dt1
end

# ╔═╡ 671d8022-d1cc-47b2-a440-9d99471e1c57
begin
	dt2 = "2021-06-29T23:14:20"
	subs2 = Dict("-" => "", ":" => "")
	replace(dt2, r"-|:" => s -> subs2[s])
end

# ╔═╡ da307dad-ac6f-4818-a4ef-133508a46d79
replace([1, 2, 1, 3], 1=>0, 2=>4)

# ╔═╡ 5adb8ad7-166d-4645-b640-6f06f3834098
replace(Dict(1=>2, 3=>4)) do kv
	kv.first < 3 ? kv.first=>3 : kv
end

# ╔═╡ 6cb727ac-05b5-4f5f-955e-c727605b39a9
replace.("123", [r"1" => s"a", r"2" => s"b"])

# ╔═╡ 1046d8f4-7709-4de6-9617-f1c23fc4bd2b
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

# ╔═╡ Cell order:
# ╟─dece5f90-d6df-11eb-3b7f-f3dce8a7c686
# ╟─62134f84-d7b1-455d-a3c3-4412ec4e7e06
# ╠═eed959ba-9c6d-4067-abbd-4ec01438e22a
# ╟─cb5285f6-427a-4c9a-b3b1-cd034d07c1d2
# ╠═3b842704-f5f0-4ebe-bab4-c2255377f0e4
# ╟─351460e0-11aa-4994-88be-d3372883d642
# ╠═cc3b095b-a622-4f96-8a83-4eb57e0fc4dc
# ╟─584596ca-b465-4ba1-9b88-797321cb80d9
# ╠═ad657ffc-e9cd-4585-9398-05b46d832da0
# ╠═671d8022-d1cc-47b2-a440-9d99471e1c57
# ╠═da307dad-ac6f-4818-a4ef-133508a46d79
# ╠═5adb8ad7-166d-4645-b640-6f06f3834098
# ╠═6cb727ac-05b5-4f5f-955e-c727605b39a9
# ╟─1046d8f4-7709-4de6-9617-f1c23fc4bd2b
