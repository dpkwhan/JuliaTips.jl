### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 65983459-2f74-41be-83bd-acfab15462d2
using HypertextLiteral

# ╔═╡ 8358cbf1-5666-485e-81cc-0870ee981d0e
md"# ECharts in Pluto"

# ╔═╡ aa821412-060d-49a1-85e3-2c3ffa2abafc
md"""
[Apache ECharts](https://echarts.apache.org/en/index.html) is an open source JavaScript visualization library, originally from [Baidu](https://www.baidu.com/) and later incubated by Apache. A gallery of examples can be found [here](https://echarts.apache.org/examples/en/index.html).
"""

# ╔═╡ e630e9cc-efa9-497d-881a-709733f5f1b3
html"""
<blockquote>Apache ECharts is a free, powerful charting and visualization library offering an easy way of adding intuitive, interactive, and highly customizable charts to your commercial products. It is written in pure JavaScript and based on <a href="https://github.com/ecomfe/zrender" target="_blank">zrender</a>, which is a whole new lightweight canvas library.
</blockquote>
"""

# ╔═╡ 8af14ba2-2ec2-4561-bf63-b1213654ef26
html"""<h2 style="color:red">Preparing Data</h2>"""

# ╔═╡ 765cda25-fa90-48c5-9a58-126213d2f871
md"""
The data is stored as a vector of dictionaries, which is later interpolated into JavaScript code via package [`HypertextLiteral`](https://github.com/MechanicalRabbit/HypertextLiteral.jl).
"""

# ╔═╡ cb176b72-5cbc-40c1-ba1d-a6473c7da839
data = [
	Dict("time" => "2021-06-23T09:30:01.123", "qty"=>200, "price"=>12.34),
	Dict("time" => "2021-06-23T09:31:22.234", "qty"=>400, "price"=>12.37),
	Dict("time" => "2021-06-23T09:33:05.678", "qty"=>900, "price"=>12.43),
	Dict("time" => "2021-06-23T09:34:05.678", "qty"=>1900, "price"=>12.48),
	Dict("time" => "2021-06-23T09:35:45.348", "qty"=>3200, "price"=>12.54),
];

# ╔═╡ 21caa0f0-0354-44d0-a8eb-c6966c0317dc
html"""<h2 style="color:red">Rendering Chart</h2>"""

# ╔═╡ 2c6287ac-0c58-4216-951e-104b1fadc59a
html"""<h3 style="color:green">Import echarts</h3>"""

# ╔═╡ 3a392308-cdff-4569-a033-ca324a931b98
md"""
*Line 2* in the code below imports `echarts` object into the global space so that we can call its `init` function to create an `EChart` instance. This is just a regular `<script>` element in any HTML file.
"""

# ╔═╡ fee6e1fa-e60e-4fda-8511-2244cbb5662d
html"""<h3 style="color:green">Chart width</h3>"""

# ╔═╡ 4e9348be-ca26-4da7-9dd2-646d724c8f89
md"""
ECharts needs an explicit chart width provided when the chart is rendered. The JavaScript code below computes the chart width by aligning it to the Pluto cell width. It first finds the first Pluto cell and retrieves its width. The chart width is offset by a small margin from the cell width.

```js
const plutoCell = document.querySelector('pluto-cell');
const cellWidth = plutoCell.clientWidth || plutoCell.offsetWidth;
const chartWidth = cellWidth - Math.max(20, 0.05*cellWidth);
```

*Line 8* creates a `div` element as a container for the chart we are going to render. The chart is then placed at the center of the cell by

```js
div.style.margin = '0 auto';
```
"""

# ╔═╡ 2317ce33-708b-4168-a3fa-5c807af260d5
html"""<h3 style="color:green">Chart rendering</h3>"""

# ╔═╡ 6f51cd28-a45a-42c8-bf0b-1cff8f4acc29
md"""
*Lines 13-19* prepares the data in the format expected by `ECharts`, which is basically an array of two-element array. Note that line 13 has data from Julia interpolated directly into JavaScript code.

*Lines 21-70* creates the options for the chart. `ECharts` provides rich customization options to fine tune the appearance of the plots. You can copy and paste the `option` varaible defined in most examples provided by `ECharts` here and it should work without any changes.

*Lines 72-74* create the charts inside the container and return it.
"""

# ╔═╡ ac498c76-bb3b-49a0-9ffa-b6039d7ae87d
@htl("""
<script src="https://cdn.jsdelivr.net/npm/echarts@5.1.2/dist/echarts.min.js"></script>
<script>
	const plutoCell = document.querySelector('pluto-cell');
	const cellWidth = plutoCell.clientWidth || plutoCell.offsetWidth;
	const chartWidth = cellWidth - Math.max(20, 0.05*cellWidth);
	
	const div = document.createElement('div');
	div.style.width = chartWidth + 'px';
	div.style.height = '500px';
	div.style.margin = '0 auto';

	const data = $(data);
	const prices = [];
	const qtys = [];
	data.forEach(d => {
		prices.push([d.time, d.price]);
		qtys.push([d.time, d.qty])
	});

	const option = {
		title : {
			text: 'Price and Quantity',
			textStyle: {
				fontFamily: 'lato'
			}
		},
		tooltip : {
			trigger: 'axis'
		},
		calculable : true,
		xAxis : {
			type: 'time',
			boundaryGap: false,
		},
		yAxis : [
			{
				type: 'value',
				name: 'Price',
				min : 'dataMin',
				max : 'dataMax',
			}, {
				type: 'value',
				name: 'Shares',
				min : 'dataMin',
				max : 'dataMax',
			}
		],
		legend: {
			bottom: 0,
			left: 'center',
			itemWidth: 20,
			padding: [0, 0, 15, 0],
			data: ['Price', 'Quantity'],
		},
		series : [
			{
				name: 'Price',
				type: 'line',
				smooth: true,
				data: prices,
			}, {
				name: 'Quantity',
				type: 'line',
				smooth: true,
				yAxisIndex: 1,
				data: qtys,
			}
		],
	};

	const chart = echarts.init(div);
	chart.setOption(option);
	return div;
</script>
""")

# ╔═╡ 4a4e6920-ef10-11eb-23a9-a95dc76d9289
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}

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
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"
"""

# ╔═╡ Cell order:
# ╟─8358cbf1-5666-485e-81cc-0870ee981d0e
# ╟─aa821412-060d-49a1-85e3-2c3ffa2abafc
# ╟─e630e9cc-efa9-497d-881a-709733f5f1b3
# ╟─8af14ba2-2ec2-4561-bf63-b1213654ef26
# ╟─765cda25-fa90-48c5-9a58-126213d2f871
# ╠═cb176b72-5cbc-40c1-ba1d-a6473c7da839
# ╟─21caa0f0-0354-44d0-a8eb-c6966c0317dc
# ╟─2c6287ac-0c58-4216-951e-104b1fadc59a
# ╟─3a392308-cdff-4569-a033-ca324a931b98
# ╟─fee6e1fa-e60e-4fda-8511-2244cbb5662d
# ╟─4e9348be-ca26-4da7-9dd2-646d724c8f89
# ╟─2317ce33-708b-4168-a3fa-5c807af260d5
# ╟─6f51cd28-a45a-42c8-bf0b-1cff8f4acc29
# ╠═ac498c76-bb3b-49a0-9ffa-b6039d7ae87d
# ╟─65983459-2f74-41be-83bd-acfab15462d2
# ╟─4a4e6920-ef10-11eb-23a9-a95dc76d9289
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
