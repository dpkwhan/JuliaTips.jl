### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 4e0e1d7e-3d7c-4c26-92d4-54afa8f2c025
begin
	using Pkg
	pkgs_required = ["BenchmarkTools", "PlutoUI", "DataFrames"]
end;

# ╔═╡ 83d36770-eb6b-11eb-01b6-bf15f63d0ab2
begin
	pkgs_installed = [dep.name for (uuid, dep) in Pkg.dependencies() if dep.is_direct_dep]
	pkgs_unstalled = setdiff(pkgs_required, pkgs_installed)
	
	for pkg in pkgs_unstalled
		Pkg.add(pkg)
	end
end

# ╔═╡ c8f9a175-0ca2-4b48-884a-32ae375cf832
for pkg in [Symbol(p) for p in pkgs_required]
	@eval using $pkg
end

# ╔═╡ 1bd9f079-ed17-4d5a-a8b0-dd4069c8acac
md"# Pluto Tutorial"

# ╔═╡ f897e51a-a9d1-4535-bbe7-2fa650aca172
html"""<h2 style="color:red">Customize Pluto Appearance</h2>"""

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

# ╔═╡ fb101abf-436e-4b38-838f-7b7c458e5018
html"""<h2 style="color:red">HTML Elements</h2>"""

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

# ╔═╡ 44539e27-87a0-493d-af6d-ed2df07d73d5
html"""<h2 style="color:red">Output Display</h2>"""

# ╔═╡ 9170c6d5-d3c5-46d3-9cd8-fbabd77bfcf8
with_terminal() do
	@btime sum(1:1000000)
end

# ╔═╡ Cell order:
# ╟─1bd9f079-ed17-4d5a-a8b0-dd4069c8acac
# ╟─f897e51a-a9d1-4535-bbe7-2fa650aca172
# ╠═38c31c2e-40e6-4122-996e-23931df7a745
# ╠═4e0e1d7e-3d7c-4c26-92d4-54afa8f2c025
# ╠═83d36770-eb6b-11eb-01b6-bf15f63d0ab2
# ╠═c8f9a175-0ca2-4b48-884a-32ae375cf832
# ╠═fb101abf-436e-4b38-838f-7b7c458e5018
# ╠═a91f0f22-df29-4d24-8890-729fe4582325
# ╟─417585e4-f7f4-4363-b1e8-9ae5028f0736
# ╟─44539e27-87a0-493d-af6d-ed2df07d73d5
# ╠═9170c6d5-d3c5-46d3-9cd8-fbabd77bfcf8
