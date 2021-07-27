### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ b51fcf4e-0440-4abd-96b0-4a24b92b1d3b
using HypertextLiteral

# ╔═╡ 8358cbf1-5666-485e-81cc-0870ee981d0e
md"# ECharts in Pluto"

# ╔═╡ 8af14ba2-2ec2-4561-bf63-b1213654ef26
html"""<h2 style="color:red">Preparing Data</h2>"""

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

# ╔═╡ fee6e1fa-e60e-4fda-8511-2244cbb5662d
html"""<h3 style="color:green">Chart width</h3>"""

# ╔═╡ 4e9348be-ca26-4da7-9dd2-646d724c8f89
md"""
ECharts needs an explicit chart width provided when the chart is rendered. The JavaScript code below computes the chart width by aligning it to the Pluto cell width. It first finds the first Pluto cell and retrieves its width. The chart with is offset by a small margin from the cell width.

```js
const plutoCell = document.querySelector('pluto-cell');
const cellWidth = plutoCell.clientWidth || plutoCell.offsetWidth;
const chartWidth = cellWidth - Math.max(20, 0.05*cellWidth);
```

The chart is then put in the center of the cell by
```js
div.style.margin = '0 auto';
```
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
# ╠═b51fcf4e-0440-4abd-96b0-4a24b92b1d3b
# ╟─8af14ba2-2ec2-4561-bf63-b1213654ef26
# ╠═cb176b72-5cbc-40c1-ba1d-a6473c7da839
# ╟─21caa0f0-0354-44d0-a8eb-c6966c0317dc
# ╟─fee6e1fa-e60e-4fda-8511-2244cbb5662d
# ╟─4e9348be-ca26-4da7-9dd2-646d724c8f89
# ╠═ac498c76-bb3b-49a0-9ffa-b6039d7ae87d
# ╟─4a4e6920-ef10-11eb-23a9-a95dc76d9289
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
