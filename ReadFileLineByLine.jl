### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ d291ef1b-17a4-411b-821d-c93ae84c2c7d
using PlutoUI, BenchmarkTools, Downloads

# ╔═╡ 418ed47c-e538-4b04-be21-8452332c1bc1
md"""
# Read File Line by Line
"""

# ╔═╡ 0cb06ba6-3214-4bf9-aef9-336ca73afc41
html"""
	<span style="display: block; text-align: right;"><b>David Han</b>: August 6, 2021</span>
"""

# ╔═╡ 0fe60f2d-4e83-49d1-8243-7c67efda1064
html"""
<article class="firstparagraph">
	<p>
		Reading a file line by line is frequently encountered. Julia provides multiple functions to do this.
	</p>
</article>
"""

# ╔═╡ b06ca865-dbe9-4843-b2e7-b645525afd90
md"""
First we download the full text of *Pride and Prejudice* and save it to a temporary file. The task is to count the total number of words in each chapter.
"""

# ╔═╡ fd0356a3-3485-4bd8-878f-38787f565986
pnp = Downloads.download("https://www.gutenberg.org/files/1342/1342-0.txt");

# ╔═╡ fdcf7cde-e816-4bdd-874f-110029ceab2f
md"""
Below are two helper functions to process each line in the file.
* `process_line`: It returns a tuple. The first element is the chapter number if that line is a chapter title, otherwise, it is missing. The second element is the number of words in the current line. It is zero if the line is chapter title.
* `update_counts`: It updates the total word count of each chapter.
"""

# ╔═╡ 1b727893-c9ae-4a90-8af7-dfb26b7472c5
function process_line(line)
	words = split(line)
	wordCount = length(words)
	
	if !startswith(line, "Chapter ")
		return (missing, wordCount)
	else
		if wordCount != 2
			return (missing, wordCount)
		else
			return (parse(Int64, words[2]), 0)
		end
	end
end;

# ╔═╡ ceb669fa-18c6-40eb-a91a-3435c8be1e4e
function update_counts!(counts, chapter, chapterNumber, wordCount)
	if chapterNumber !== missing
		chapter = chapterNumber
		if length(counts) < chapterNumber
			push!(counts, wordCount)
		end
	elseif chapter !== missing
		counts[chapter] += wordCount
	end
end;

# ╔═╡ e94d5aac-5cdd-4142-a07d-b386f8e55fe1
html"""<h2 style="color:red">Using <code>readline</code></h2>"""

# ╔═╡ 7c39832b-a8d4-472c-ab00-fa8305b65eb9
function using_readline(file)
	wordsByChapter = Vector{Int64}()
	currentChapter = missing
	open(file) do io
		while !eof(io)
			line = strip(readline(io))
			(chapNum, wordCount) = process_line(line)
			update_counts!(wordsByChapter, currentChapter, chapNum, wordCount)
		end
	end
	wordsByChapter
end;

# ╔═╡ ee69823b-2a50-4026-891d-a711d39566f7
with_terminal() do
	@btime using_readline(pnp)
end

# ╔═╡ 71070037-5757-4886-a6d2-d50962362451
html"""<h2 style="color:red">Using <code>readlines</code></h2>"""

# ╔═╡ e1b71e41-e059-458a-8b5c-c2fa5924be98
function using_readlines(file)
	wordsByChapter = Vector{Int64}()
	currentChapter = missing
	for line in readlines(file)
		line = strip(line)
		(chapNum, wordCount) = process_line(line)
		update_counts!(wordsByChapter, currentChapter, chapNum, wordCount)
	end
	wordsByChapter
end;

# ╔═╡ 3d2a6f1f-82c1-4926-af25-4e0bd4c6672d
with_terminal() do
	@btime using_readlines(pnp)
end

# ╔═╡ e37a6a42-3538-4b13-b031-acec06de3d38
html"""<h2 style="color:red">Using <code>eachline</code></h2>"""

# ╔═╡ e66375ff-2f22-415a-b176-1f25cfe0c15a
function using_eachline(file)
	wordsByChapter = Vector{Int64}()
	currentChapter = missing
	open(file) do io
		for line in eachline(io)
			line = strip(line)
			(chapNum, wordCount) = process_line(line)
			update_counts!(wordsByChapter, currentChapter, chapNum, wordCount)
		end
	end
	wordsByChapter
end;

# ╔═╡ 90df2887-2af5-40f2-ae08-3c850a1a98ca
with_terminal() do
	@btime using_eachline(pnp)
end

# ╔═╡ b0dfd849-24b2-4230-9a4a-8d8459e04b23
html"""<h2 style="color:red">Remarks</h2>"""

# ╔═╡ 494bdcc1-8055-45ce-bf0a-2720a7580356
html"""<h3 style="color:green">Variants</h3>"""

# ╔═╡ a9812e6f-a208-455f-a2b4-4355c511a5a4
md"""
For `readlines` and `eachline`, we can also read from a file directly:

```julia
for line in eachline(filename)
	# process the line
end
```
or

```julia
for line in readlines(filename)
	# process the line
end
```

If you need to use the line number, you can use `enumerate`. For example,
```julia
for (i, line) in enumerate(eachline(filename))
	# process the line
end
```
"""

# ╔═╡ 8aac55f7-c65d-4d79-8699-c0e9e62e86e0
html"""<h3 style="color:green">Performance</h3>"""

# ╔═╡ 4cdb1a95-a739-42fe-b642-b12df0bd471f
md"""
When reading a large file (*e.g.* millions of lines), `eachline` typically has better performance than `readline` and `readlines` in terms of speed and memory usage.
"""

# ╔═╡ e9463960-3189-44d1-8467-f2de1397275a
md"""
Finally, we delete the downloaded file.
"""

# ╔═╡ d7ab84ae-4cc7-419d-aa81-3b98f0b4ab2c
rm(pnp);

# ╔═╡ 05b16fce-f724-11eb-1058-37333da89628
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
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.1.1"
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

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "c31ebabde28d102b602bada60ce8922c266d205b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.1"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

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

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "477bf42b4d1496b454c10cce46645bb5b8a0cf2c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.2"

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

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
"""

# ╔═╡ Cell order:
# ╟─418ed47c-e538-4b04-be21-8452332c1bc1
# ╟─0cb06ba6-3214-4bf9-aef9-336ca73afc41
# ╟─0fe60f2d-4e83-49d1-8243-7c67efda1064
# ╠═d291ef1b-17a4-411b-821d-c93ae84c2c7d
# ╟─b06ca865-dbe9-4843-b2e7-b645525afd90
# ╠═fd0356a3-3485-4bd8-878f-38787f565986
# ╟─fdcf7cde-e816-4bdd-874f-110029ceab2f
# ╠═1b727893-c9ae-4a90-8af7-dfb26b7472c5
# ╠═ceb669fa-18c6-40eb-a91a-3435c8be1e4e
# ╟─e94d5aac-5cdd-4142-a07d-b386f8e55fe1
# ╠═7c39832b-a8d4-472c-ab00-fa8305b65eb9
# ╟─ee69823b-2a50-4026-891d-a711d39566f7
# ╟─71070037-5757-4886-a6d2-d50962362451
# ╠═e1b71e41-e059-458a-8b5c-c2fa5924be98
# ╠═3d2a6f1f-82c1-4926-af25-4e0bd4c6672d
# ╟─e37a6a42-3538-4b13-b031-acec06de3d38
# ╠═e66375ff-2f22-415a-b176-1f25cfe0c15a
# ╠═90df2887-2af5-40f2-ae08-3c850a1a98ca
# ╟─b0dfd849-24b2-4230-9a4a-8d8459e04b23
# ╟─494bdcc1-8055-45ce-bf0a-2720a7580356
# ╟─a9812e6f-a208-455f-a2b4-4355c511a5a4
# ╟─8aac55f7-c65d-4d79-8699-c0e9e62e86e0
# ╟─4cdb1a95-a739-42fe-b642-b12df0bd471f
# ╟─e9463960-3189-44d1-8467-f2de1397275a
# ╠═d7ab84ae-4cc7-419d-aa81-3b98f0b4ab2c
# ╟─05b16fce-f724-11eb-1058-37333da89628
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
