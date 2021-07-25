### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 49d5613d-0d67-4253-b36b-8aa603490184
begin
	using Pkg, Random, LinearAlgebra
	Pkg.activate(mktempdir())
	Pkg.add("StatsModels")
	Pkg.add("Tables")
	Pkg.add("RDatasets")
	using StatsModels, Tables, RDatasets
end

# ╔═╡ fb7eb8d0-ecf9-11eb-0334-c3db5458d86a
md"# Linear algebra and statistical models"

# ╔═╡ 835955f9-f586-449a-8b0c-330d587dff21
md"""
Julia provides one of the best, if not _the best_, environments for numerical linear algebra.

The `Base` package provides basic array (vector, matrix, etc.) construction and manipulation: [`*`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#Base.:*-Tuple{AbstractMatrix{T}%20where%20T,%20AbstractMatrix{T}%20where%20T}), `/`, [`\`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#Base.:\\-Tuple{AbstractMatrix{T}%20where%20T,%20AbstractVecOrMat{T}%20where%20T}), `'`.  The `LinearAlgebra` package provides many definitions of matrix types (`Diagonal`, `UpperTriangular`, ...) and factorizations.  The `SparseArrays` packages provides types and methods for sparse matrices.
"""

# ╔═╡ fbe7d9cf-1b5c-478d-9e74-c76faea6ec21
# simulate a matrix with elements selected at random from (0,1)
A = rand(4, 3)

# ╔═╡ 52339415-3c5b-4403-a0f8-5c6be720edfd
B = rand(3, 4)

# ╔═╡ 822b2ad6-5958-45f2-af13-e975ce0e95d9
# "lazy" transpose
A'

# ╔═╡ 5148129c-449e-4dc6-b120-2f25f93db5d8
A*B

# ╔═╡ 8a21d817-5625-4796-98fa-d95117a9064c
md"""
## Solving least squares problems

A least squares solution is one of the building blocks for statistical models.

If `X` is an $n\times p$ model matrix and `y` is an $n$-dimensional vector of observed responses, a _linear model_ is of the form

$$\begin{equation}
\mathcal{Y}\sim\mathcal{N}(\mathbf{X}\beta, \sigma^2\mathbf{I})
\end{equation}$$

"""

# ╔═╡ 00a9d3cf-e461-4d75-b148-9295a51e0a22
md"""
That is, the _mean response_ is modeled as a _linear predictor_, $\mathbf{X}\beta$, depending on the _parameter vector_, $\beta$ (also called _coefficients_) with the covariance matrix, $\sigma^2\mathbf{I}$. In general the probability density for a [multivariate normal distribution](https://en.wikipedia.org/wiki/Multivariate_normal_distribution) with mean $\mu$ and covariance matrix $\Sigma$ is

$$\begin{equation}
  f(\mathbf{y}|\mu,\Sigma) = \frac{1}{(2\pi)^{n/2}|\Sigma|^{1/2}}
     \exp\left(-\frac{(\mathbf{y}-\mu)'\Sigma^{-1}(\mathbf{y}-\mu)}{2}\right)
\end{equation}$$

where $|\Sigma|$ denotes the determinant of $\Sigma$.

When the covariance matrix is of the form $\sigma^2\mathbf{I}$ the distribution is called a _spherical_ normal
distribution because the contours of constant density are $n$-dimensional spheres centered at $\mu$.
In these cases the probability density can be simplified to

$$\begin{equation}
  \begin{aligned}
   f(\mathbf{y}|\beta,\sigma)&= \frac{1}{(2\pi\sigma^2)^{n/2}} \exp\left(-\frac{(\mathbf{y}-\mathbf{X}\beta)'(\mathbf{y}-\mathbf{X}\beta)}{2\sigma^2}\right)\newline
   &= \frac{1}{(2\pi\sigma^2)^{n/2}} \exp\left(-\frac{\|\mathbf{y}-\mathbf{X}\beta)\|^2}{2\sigma^2}\right) .
  \end{aligned}
\end{equation}$$
"""

# ╔═╡ f434c9af-63be-4512-8639-5d6e9a23bdec
md"""
The _likelihood_ of the parameters, $\beta$ and $\sigma$, given the data, $\mathbf{y}$ (and, implicitly, $\mathbf{X}$), is the same expression as the density but with the roles of the parameters and the observations reversed

$$\begin{equation}
L(\beta,\sigma|\mathbf{y})=\frac{1}{(2\pi\sigma^2)^{n/2}} \exp\left(-\frac{\|\mathbf{y}-\mathbf{X}\beta)\|^2}{2\sigma^2}\right) .
\end{equation}$$

The _maximum likelihood estimates_ of the parameters are the values that maximize the likelihood given the data.  It is convenient to maximize the logarithm of the likelihood, called the _log-likelihood_, instead of the likelihood.

$$\begin{equation}
\ell(\beta,\sigma|\mathbf{y})=\log L(\beta,\sigma|\mathbf{y})=
-\frac{n}{2}\log(2\pi\sigma^2)-\frac{\|\mathbf{y}-\mathbf{X}\beta)\|^2}{2\sigma^2}
\end{equation}$$

(Because the logarithm function is monotone increasing, the values of $\beta$ and $\sigma$ that maximize the log-likelihood also maximize the likelihood.)

For any value of $\sigma$ the value of $\beta$ that maximizes the log-likelihood is the value that minimizes the sum of squared residuals,

$$\begin{equation}
\widehat{\beta}=\arg\min_\beta \|\mathbf{y} - \mathbf{X}\beta\|^2
\end{equation}$$
"""

# ╔═╡ 9895061a-a14d-4ada-bf9f-cf74b4c2957d
md"""
## A simple linear regression model

Data from a calibration experiment on the optical density versus the concentration of Formaldehyde are available as the `Formaldehyde` data in `Rdatasets`.

```julia
Formaldehyde = rcopy(R"Formaldehyde")

R\"""
library(ggplot2)
qplot(x=carb, y=optden, data=Formaldehyde, geom="point")
\"""
```
"""

# ╔═╡ 6006bde4-9a29-4e06-89ec-50309d61998d
Formaldehyde = dataset("datasets", "Formaldehyde")

# ╔═╡ 02b3aaa6-a65f-4744-a059-938c3fe6d515
md"""

In a _simple linear regression_ the model matrix, $\mathbf{X}$, consists of a column of 1's and a column of the covariate values; `carb`, in this case.

```julia
X = hcat(ones(size(Formaldehyde, 1)), Formaldehyde.carb)
y = Formaldehyde.optden
β = X\y     # least squares estimate
r = y - X*β   #residual
```

One of the conditions for $\hat{\beta}$ being the least squares estimate is that the residuals must be orthogonal to the columns of $\mathbf{X}$

```julia
X'r   # not exactly zero but very small entries
```
"""

# ╔═╡ 2593dd71-8d51-40de-be78-d42746727c66
md"""
## Creating the model matrix from a formula

Creating model matrices from a data table can be a tedious and error-prone operation.  In addition, _statistical inference_ regarding a linear model often considers groups of columns generated by model _terms_.  The `GLM` package provides methods to fit and analyze linear models and generalized linear models (described later) using a _formula/data_ specification similar to that in _R_.

```julia
using GLM

m1 = fit(LinearModel, @formula(optden ~ 1 + carb), Formaldehyde)
```

The evaluation of the formula is performed by the `StatsModels` package in stages.

```julia
f1 = @formula(optden ~ 1 + carb)
y, X = modelcols(apply_schema(f1, schema(Formaldehyde)), Formaldehyde)
X
```
"""

# ╔═╡ 64bd0357-f726-436f-a81f-3bca54997044
md"""
## Matrix decompositions for least squares

According to the formulas given in text books, the least squares estimates are calculated as

$$\widehat{\mathbf{\beta}}=\mathbf{X^\prime X}^{-1}\mathbf{X^\prime y}$$

In practice, this formula is not the way the estimates are calculated, because it is wasteful to evaluate the inverse of a matrix if you just want to solve a system of equations.

Recall that the least squares estimate satisfies the condition that the residual is orthogonal to the columns of $\mathbf{X}$.

$$\mathbf{X^\prime (y - X\widehat{\beta})} = \mathbf{0}$$

which can be re-written as

$$\mathbf{X^\prime X}\widehat{\mathbf{\beta}}=\mathbf{X^\prime y}$$

These are called the _normal equations_ - "normal" in the sense of orthogonal, not in the sense of the normal distribution.

The matrix $\mathbf{X^\prime X}$ is symmetric and _positive definite_.  The latter condition means that

$$\mathbf{v^\prime(X^\prime X)v}=\mathbf{(Xv)^\prime Xv} = \|\mathbf{Xv}\|^2 > 0\quad\forall \mathbf{v}\ne\mathbf{0}$$

if $\mathbf{X}$ has full column rank.

We will assume that the model matrices $\mathbf{X}$ we will use do have full rank.  It is possible to handle rank-deficient model matrices but we will not cover that here.

A positive-definite matrix has a "square root" in the sense that there is a $p\times p$ matrix $\mathbf{A}$ such that

$$\mathbf{A^\prime A}=\mathbf{X^\prime X}.$$

In fact, when $p>1$ there are several.  A specific choice of $\mathbf{A}$ is an upper triangular matrix with positive elements on the diagonal, usually written $\mathbf{R}$ and called the upper Cholesky factor of $\mathbf{X^\prime X}$.

```julia
X
```

```julia
xpx = X'X
```

```julia
ch = cholesky(xpx)
```

```julia
ch.U'ch.U
```

```julia
ch.U'ch.U ≈ xpx
```

Because the Cholesky factor is triangular, it is possible to solve systems of equations of the form 

$$\mathbf{R^\prime R}\widehat{\mathbf{\beta}}=\mathbf{X^\prime y}$$

in place in two stages.  First solve for $\mathbf{v}$ in

$$\mathbf{R^\prime v}=\mathbf{X^\prime y}$$

```julia
v = ldiv!(ch.U', X'y)
```

then solve for $\widehat{\mathbf{\beta}}$ in

$$\mathbf{R}\widehat{\mathbf{\beta}}=\mathbf{v}$$

```julia
βc = ldiv!(ch.U, copy(v))     # solution from the Cholesky factorization
```

```julia
βc ≈ β
```

These steps are combined in one of the many `LinearAlgebra` methods for solutions of equations.

```julia
ldiv!(ch, X'y)
```
"""

# ╔═╡ f9a27d27-2c24-44d6-b382-97a31a652ec2
md"""
## Sum of squared residuals as a quadratic form

Another way of approaching the least squares problem is to write the sum of squared residuals as what is called a _quadratic form_.

$$\begin{aligned}
r^2(\mathbf{\beta}) & = \|\mathbf{y} - \mathbf{X\beta}\|^2\\
&=\left\|\begin{bmatrix}\mathbf{X}&\mathbf{y}\end{bmatrix}\begin{bmatrix}\mathbf{-\beta}\\ 1\end{bmatrix}\right\|^2\\
&=\begin{bmatrix}\mathbf{-\beta}&1\end{bmatrix}\begin{bmatrix}\mathbf{X^\prime X} & \mathbf{X^\prime y}\\
  \mathbf{y^\prime X}&\mathbf{y^\prime y}\end{bmatrix}
  \begin{bmatrix}\mathbf{-\beta}\\ 1\end{bmatrix}\\
&=\begin{bmatrix}\mathbf{-\beta}&1\end{bmatrix}
  \begin{bmatrix}
    \mathbf{R_{XX}}^\prime&\mathbf{0}\\
    \mathbf{r_{Xy}}^\prime&r_{\mathbf{yy}}
  \end{bmatrix}
  \begin{bmatrix}
    \mathbf{R_{XX}}&\mathbf{r_{Xy}}\\
    \mathbf{0}&r_{\mathbf{yy}}
  \end{bmatrix}
  \begin{bmatrix}\mathbf{-\beta}\\ 1\end{bmatrix}\\
&= \left\|  \begin{bmatrix}
    \mathbf{R_{XX}}&\mathbf{r_{Xy}}\\
    \mathbf{0}&r_{\mathbf{yy}}
  \end{bmatrix}
  \begin{bmatrix}\mathbf{-\beta}\\ 1\end{bmatrix}\right\|^2\\
&= \|\mathbf{r_{Xy}}-\mathbf{R_{XX}\beta}\|^2 + r_{\mathbf{yy}}^2
\end{aligned}$$

where 

$$\begin{bmatrix}\mathbf{R_{XX}}&\mathbf{r_{Xy}}\\ \mathbf{0}&r_{\mathbf{yy}}\end{bmatrix}$$

is the upper Cholesky factor of the augmented matrix

$$\begin{bmatrix}\mathbf{X^\prime X} & \mathbf{X^\prime y}\\ \mathbf{y^\prime X}&\mathbf{y^\prime y}\end{bmatrix}.$$

```julia
Xy = hcat(X, y)              # augmented model matrix
```

```julia
cha = cholesky(Xy'Xy)        # augmented Cholesky factor
```

Note that $\mathbf{R_{XX}}$ is just the Cholesky factor of $\mathbf{X^\prime X}$ which was previously calculated and the vector $\mathbf{r_{Xy}}$ is the solution to $\mathbf{R^\prime v}=\mathbf{X^\prime y}$.  The minimum sum of squares is $r^{\mathbf{yy}}$ which is attained when $\mathbf{\beta}$ is the solution to

$$\mathbf{R_{XX}}\widehat{\beta}=\mathbf{r_{Xy}}$$

```julia
RXX = UpperTriangular(view(cha.U, 1:2, 1:2))
```

```julia
RXX ≈ ch.U
```

```julia
rXy = cha.U[1:2, end]     # creates a copy ("view" doesn't copy)
```

```julia
rXy ≈ v
```

```julia
βac = ldiv!(RXX, copy(rXy))     # least squares solution from the augmented Cholesky
```

```julia
βac ≈ β
```

```julia
abs2(cha.U[end,end]) ≈ sum(abs2, y - X*β)   # check on residual sum of squares
```

One reason for writing the least squares solution in this way is that we will use a similar decomposition for linear mixed models later.  Another is that when dealing with very large data sets we may wish to parallelize the calculation over many cores or over many processors.  The natural way to parallelize the calculation is in blocks of rows and the augmented Cholesky can be formed row by row using a `lowrankupdate`.
"""

# ╔═╡ 667012e1-5bf8-4f63-866a-43636b552de4
md"""
### A row-wise approach to least squares

To show this we create a row-oriented table from our `Formaldehyde` data set, which is in a column-oriented format.

```julia
Formrows = Tables.rowtable(Formaldehyde)
```

then initialize a Cholesky factor and zero out its contents

```julia
chr = cholesky(zeros(3, 3) + I)  # initialize
```

```julia
fill!(chr.factors, 0);   # zero out the contents
chr
```

Update by rows

```julia
fill!(chr.factors, 0)
for r in Formrows
    lowrankupdate!(chr, [1.0, r.carb, r.optden])
end
chr
```

This is the same augmented Cholesky factor as before but obtained in a different way.  For generalized linear mixed models and for nonlinear mixed models it can be an advantage to work row-wise when performing some of the least squares calculations.
"""

# ╔═╡ e367df82-507e-4763-b8fc-11633af0632c
md"""
### Other decompositions for least squares solutions

There are other ways of solving a least squares problem, such as using an _orthogonal-triangular_ decomposition, also called a _QR_ decomposition, or a singular value decomposition.  The bottom line is that we decompose $\mathbf{X}$ or $\mathbf{X^\prime X}$ into some convenient product of orthogonal or triangular or diagonal matrices and work with those.  Just to relate these ideas, the _QR_ decomposition of $\mathbf{X}$ is


```julia
qrX = qr(X)
```

Notice that the `R` factor is the upper Cholesky factor of $\mathbf{X^\prime X}$ with the first row multiplied by -1 so its transposed product with itself is $\mathbf{X^\prime X}$.

```julia
qrX.R'qrX.R
```

That is,

```julia
qrX.R'qrX.R ≈ xpx
```

The original solution for $\widehat{\mathbf{\beta}}$ from the expression `X\y` is actually performed by taking a QR decomposition of `X`.
"""

# ╔═╡ 46a3d1ee-8dd5-468b-9df9-117dea1ccd52
md"""
## Reference
* [Original Post](https://github.com/dmbates/CopenhagenEcon/blob/master/jmd/03-LinearAlgebra.jmd)
* [Discussion Thread](https://discourse.julialang.org/t/efficient-way-of-doing-linear-regression/31232/27)
"""

# ╔═╡ b5028983-3bf1-4529-b030-e789e994272e
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
# ╠═49d5613d-0d67-4253-b36b-8aa603490184
# ╟─fb7eb8d0-ecf9-11eb-0334-c3db5458d86a
# ╟─835955f9-f586-449a-8b0c-330d587dff21
# ╠═fbe7d9cf-1b5c-478d-9e74-c76faea6ec21
# ╠═52339415-3c5b-4403-a0f8-5c6be720edfd
# ╠═822b2ad6-5958-45f2-af13-e975ce0e95d9
# ╠═5148129c-449e-4dc6-b120-2f25f93db5d8
# ╟─8a21d817-5625-4796-98fa-d95117a9064c
# ╟─00a9d3cf-e461-4d75-b148-9295a51e0a22
# ╟─f434c9af-63be-4512-8639-5d6e9a23bdec
# ╠═9895061a-a14d-4ada-bf9f-cf74b4c2957d
# ╠═6006bde4-9a29-4e06-89ec-50309d61998d
# ╟─02b3aaa6-a65f-4744-a059-938c3fe6d515
# ╟─2593dd71-8d51-40de-be78-d42746727c66
# ╟─64bd0357-f726-436f-a81f-3bca54997044
# ╟─f9a27d27-2c24-44d6-b382-97a31a652ec2
# ╟─667012e1-5bf8-4f63-866a-43636b552de4
# ╟─e367df82-507e-4763-b8fc-11633af0632c
# ╟─46a3d1ee-8dd5-468b-9df9-117dea1ccd52
# ╟─b5028983-3bf1-4529-b030-e789e994272e
