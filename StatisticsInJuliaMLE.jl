### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 45e2a810-e6a0-11eb-05f3-55c239b22688
md"""
# Statistics in Julia - Maximum Likelihood Estimation
"""

# ╔═╡ d2f7e7ac-2990-4f29-96d5-32e350d8cae7
html"""
	<span style="display: block; text-align: right;"><b>John Myles White</b>: Jun 21, 2020</span>
"""


# ╔═╡ 61d2bd62-f1ca-46b9-a81a-7a7f47d9f8c9
md"""
!!! note "Disclaimer"
	This Pluto notebook is a conversion of John Myles White's original Jupyter notebook found [here](https://github.com/johnmyleswhite/julia_tutorials/blob/master/Statistics%20in%20Julia%20-%20Maximum%20Likelihood%20Estimation.ipynb) with some minor changes to work with Pluto. All credits are John's.
"""

# ╔═╡ 9c0708e4-d09f-4d80-931d-cabb3edcd221
html"""<h2 style="color:red">Intended Audience</h2>"""

# ╔═╡ 7aa29bd6-7623-4a16-954a-bc1503f30e26
md"""
This notebook is intended to be read by people with an interest in statistical computing that already have:
* An intermediate knowledge of statistics. For example, the reader should already understand most of the material in a book like [All of Statistics](https://www.stat.cmu.edu/~larry/all-of-statistics/).
* An intermediate knowledge of programming. For example, the reader should already understand most of the material in a book like [Advanced R](https://adv-r.hadley.nz/).

In contrast, little to no knowledge of Julia is assumed. Characteristics of Julia that are not shared with languages like Python and R will be explicitly called out.
"""

# ╔═╡ 6582b975-67b3-4d73-a54c-a41f63caa7f6
html"""<h2 style="color:red">Mastering Julia for Statistical Computing</h2>"""

# ╔═╡ 12f2123e-a3c1-4d5b-8cf9-6955c2c5789a
md"""
The core Julia language has exceptionally [good documentation](https://docs.julialang.org/en/v1/), but the documentation is focused on describing the language itself rather than on how to use the language to solve problems. Because of this gap, I find that many potential Julia users wish there were learning materials that (a) work through solving specific problems in detail rather than through language features in the abstract and (b) discuss best practices for programming in Julia as part of the exposition of solving specific problems. For statistics, this kind of documentation for Julia is, as of April 2020, still largely underdeveloped, and some of what does exist is not freely available online.

This notebook represents my attempt to help just a little bit by writing up one specific problem in great detail. My hope is that reading through this notebook and internalizing the main ideas will help bring a user from "able to write Julia that mostly works" to "writing Julia code that is competitive with code written by experts". To do that, I'll describe how to implement maximum likelihood estimation for the logistic regression model. The final result is not intended to serve as the state of the art implementation of logistic regression for Julia, but, despite that, it should be clear to readers how to make the final implementation competitive with any other implementation in terms of numerical accuracy or execution performance.

One major goal I have for this document is to put down in writing the many alternative ways of writing code that are plausible and help the reader understand the pros and cons of each. I find that too little of the educational material that programmers are exposed to focuses on comparisons between implementations, even though such comparisons often form the essence of how effective mentors educate their mentees. Learning to program well requires that one learn a causal mental model about how small changes in code lead to large changes in accuracy or performance; developing such a causal mental model requires that one see many small changes alongside the effects those changes have.

In addition to these goals, the approach I'll take in this notebook is intended to emphasize broadly applicable principles that apply to model fitting for any probabilistic model. As such, we will not dig into special propreties of the logistic regression model.
"""

# ╔═╡ 4d5e18c4-d07f-4ff9-a1a9-7dbbf76fe8f1
md"""
## Review of the Mathematics of Logistic Regression via MLE
Before we begin, let's review the logistic regression in purely mathematical terms, which I assume you've seen before. The formulation we'll use here works as follows:

* There's a constant (*e.g.* non-random) design matrix, $$X$$, that has $$n$$ rows and $$d + 1$$ columns. Each row describes an observation; each observation consists of $$d$$ features and a constant term that defines the intercept term of the logistic regression model.

* There's a random, but observed, vector, $$y$$, of length $$n$$ that contains the binary outcome of the logistic regression model.

* There's a constant (*e.g.* non-random) vector of parameters, $$\beta$$, of length $$d + 1$$ that defines the coefficients of the logistic regression model.

* Given the design matrix and the coefficients, we can construct the matrix-vector product $$X \beta$$ and call it $$z$$. This vector defines the probabilities that $$y_i = 1$$ for all $$i$$, but the probabilities are in the logit-space. To get probabilities in probability space, we map $$z_i \to y_i$$ via the inverse logit function, $$\text{logit}^{-1}(z) = (1 + \exp(-z))^{-1}$$.

Summarizing all of that in distributional notation:

$$\begin{equation}
\begin{gathered}
X \in \mathbb{R}^{n, d + 1} \\ 
\beta \in \mathbb{R}^{d + 1} \\ 
z = X \beta \\ 
p_i = \text{logit}^{-1}(z_i) \\ 
y_i \sim \text{Bernoulli}(p_i)
\end{gathered}
\end{equation}$$

The likelihood function for the full dataset of $$n$$ observations is therefore:

$$L(\beta) = \prod_{i = 1}^{n} p_i^{y_i} (1 - p_i)^{1 - y_i}$$
The log likelihood function, which is both mathematically and numerically better suited for use, is:

$$\mathcal{L}(\beta) = \sum_{i = 1}^{n} y_i \log(p_i) + (1 - y_i) \log(1 - p_i)$$

We find the maximum likelihood estimate of $$\beta$$ by maximizing the log likelihood. This is equivalent to minimizing the negative log likelihood. Because blackbox optimization API's usually default to minimization, we'll work with the negative log likelihood in our implementation.
"""

# ╔═╡ bf63ac1c-49f8-495f-bca9-77b6524fcae1
md"""
## Step 1: Import Relevant Julia Libraries
A common belief among programmers is that it's usually better to re-use existing code (especially public libraries that have been used by many other people) than to write code from scratch. For learning purposes, we will write several pieces of code from scratch in this notebook. But we will also try to use existing libraries as much as possible.

In what follows, I'm going to assume you're using Julia 1.4, which is what I have installed on my machine. In addition to making use of the basic Julia installation, we'll use a few packages in this example that need to be manually installed by the user. If you do not already have these required packages installed, change `false` to `true` below and execute this block of code to install the missing packages.
"""

# ╔═╡ d9f647e7-76d4-428a-825d-ef8143e5db94
md"""
In this example, we're going to use the following packages:

* Standard Library
  - *LinearAlgebra*: The package provides functions and types for linear algebra, including computing dot products and matrix-vector multiplication.
  - *Statistics*: This package provides functions for computing the most fundamental statistics like `mean` and `var`.
* User-Installed Libraries
  - *Distributions*: This package provides functions and types for working with probability distributions. We'll use it to define Bernoulli and Normal distributions.
  - *ForwardDiff*: This package provides functions for automatically differentation quasi-arbitrary Julia functions.
  - *Optim*: This packages provides functions for optimization of quasi-arbitrary Julia functions.
  - *StatsFuns*: This package provides implementations of common statistical functions like the CDF of the logistic distribution (*i.e.* the inverse logit function).

We'll going to pull in each of these packages using Julia's `import` keyword, which doesn't import any names into the local scope except for the names explicitly specified by the user. If you prefer to get access to everything in the package in the way that Python's `from foo import *` works or R's `library(foo)`, you can do `using Foo` instead.
"""

# ╔═╡ f2b9812b-746d-43b2-b020-31d613b5670e
begin
	import LinearAlgebra: diag, dot, mul!
	import Statistics: cov, mean, var

	import Distributions: Bernoulli, Normal, cquantile
	import ForwardDiff: hessian
	import Optim: LBFGS, minimizer, optimize
	import StatsFuns: logistic, log1pexp, logit
end

# ╔═╡ 4fc944f5-8942-43be-a9e5-9254808eba0b
md"""
## Step 2: Write a Data Generation Function
Before we implement a function for fitting a logistic regression via maximum likelhood, we're going to implement a function to generate a set of samples from the model given the design matrix, $X$, and the parameter vector, $\beta$. I see starting this way as a broad principle for writing correct code for probabilistic models, so let's call it out as an explicit principle:

**When implementing a probabilistic model, write the data generating function first.**

More broadly, whenever possible, I like to work in the following order:

* *Step 1: Write the generative model code.*
* *Step 2: Use that code to generate data that is truly generated by the model you're estimating.*
* *Step 3: Write the model fitting code.*
* *Step 4: Evaluate the model fitting code by checking how it behaves on data generated by the model. Exploit the fact that the parameters are fully known when you assess performance using generated data.*

The virtue of taking this approach is that it becomes far easier to test your model fitting code; all of the frequentist statistical theory about the quality of estimated parameters can be applied directly to your code as unit tests. If, in contrast, you work with an existing dataset whose data generating process you don't know, you can only check whether your code produces the same answers as existing software or analytic calculations. Since analytic calculations for logistic regressions are not generally tractable, that appproach is not particularly fulfilling.

With all that in mind, let's start to implement our data generation function:
"""

# ╔═╡ 4c586705-93ec-4eca-8271-040fe231e624
function generate_v1!(y, X, β)
    for i in eachindex(y)
        zᵢ = dot(X[i, :], β)
        pᵢ = logistic(zᵢ)
        y[i] = rand(Bernoulli(pᵢ))
    end
    y
end;

# ╔═╡ 1eefc492-0814-4a5b-9937-02914221b8b8
md"""
Let's walk through this function line-by-line to understand what's happening and why we've implemented things this way.
"""

# ╔═╡ 7d4a4ff0-6df7-4936-9765-a97d48f70896
md"""
#### Line 1

```julia
function generate_v1!(y, X, β)
```
The first line indicates that we're defining a function called `generate!` that takes in three arguments: `y`, `X` and `β`. The function name has an exclamation mark at the end to indicate that the function mutates at least one of its arguments. In particular, the function mutates `y`, which is the first argument because there's a convention in Julia of placing the arguments that will be mutated at the start of the argument list.

Why are we writing this function so that it operates via mutation? Because mutating functions generally have better performance since they make it possible to remove memory allocations from the function body. If we want a pure function, we can write a wrapper for this mutating function that allocates a new arrray for `y`, calls this mutating function and then return the newly allocated `y`. This argument derives from another design principle:

* **Write a mutating function that performs no allocations first and then write a pure wrapper for it that automatically allocates memory.**

This principle is itself a special case of a broader principle:

* **When faced with a tradeoff between performance and safety between functions `X` and `Y`, consider whether `X` can be built on top of `Y` or `Y` can be built on top of `X`. If, for example, `Y` can be built from `X` but `X` cannot be built from `Y`, implement `X` and provide it -- then expose `Y` built on top of `X` to users who prefer a safer, slower approach.**

Note that we did not specify the types of any arguments. We could have written something like this instead:

```julia
function generate_v1!(y::Vector{Float64}, X::Matrix{Float64}, β::Vector{Float64})
```

Why did we not specify types in that way? Because we want to keep our code generic. This reflects a general tension in how types are used in Julia. We can specify types either because:

* We want to block certain types from being passed to the function by forcing a method error.
* We want to make use of multiple dispatch to overload the function name to do slightly different things for different argument types.

We don't want to do either of those things right now. Later on we might want to restrict our input types a bit more after understanding the space of valid inputs we want to allow. But for now we want to keep our code generic as we explore the design space. To give a sense of inputs we probably want to accept, all of the following seem reasonable:

```julia
y::Vector{Int8}
y::Vector{Int32}
y::Vector{Int64}
y::Vector{Float32}
```

By not writing any input types, we allow all of these. If we had chosen the monomorphic `y::Vector{Float64}` declaration, we would have banned all of them from use.

Note also that the absence of types will not introduce any performance problems. There are important cases in writing Julia code in which type information should be specified for maximum performance. The argument definitions for a function is never one of those cases. This is important enough to deserve being called out explicitly:

* **You do not need to annotate the types of function parameters to write fast Julia code.**
"""

# ╔═╡ 2c0f779c-feae-4d49-bbdb-3a4f410f214a
md"""
#### Line 2

```julia
for i in eachindex(y)
```

In this line, we start a loop over the indices for `y`. The `eachindex(y)` function is a popular way to extract indices for arrays in Julia because it can provide the most efficient indexing strategy depending on the type of array you're using, whereas a more straightforward for `i in 1:length(y)` idiom might be sub-optimal for more complex array types like sparse arrays. If you're interested to see more, try running `eachindex` on a 10x10 dense matrix like `rand(10, 10)` versus running it on `SparseArrays.spzeros(10, 10)` from the *SparseArrays* package that's part of Julia's standard library.

One thing to note about this line is that we're going to implicitly assume in the body of the looop that the following invariants hold, but we will not be testing them: `length(y) == size(X, 1)` and `size(X, 2) == length(β)`. We are skipping these checks for the same reason we're mutating our inputs: they can be hoisted out of this part of the code and tested before we enter any loop that invokes this code. We make code like this fast by not doing work we don't have to do, although the result is code that's less safe. In some settings, Julia might be smart enough to remove redundant checks, but we're going to take a bit more control for ourselves.

Stated as a design principle: it's better to write an inner function that assumes invariants hold and then write outer functions to enforce them than it is to constantly recheck them inside the inner function, especially if the inner function could only throw an exception if the invariants failed in the outer functions. This principle and the previous principle of starting with a mutating function reflect a broader principle: acknowledge asymmetries in what can be built on top of what. It's easy to build a safe, slower function on top of an unsafe, faster function -- but the reverse is not true. Likewise it's easy to build a pure wrapper that allocates outputs on top of a mutating function, but it's not possible to avoid allocations if your pure function always performs them.

Having set the loop start and end, we enter the loop body where we'll generate our observations one-by-one. For each observation, we generate some scalar intermediates. (We could also generate all of them at once using a mutating operation. We can even get away without needing to allocate memory because we can reuse the same vector.)
"""

# ╔═╡ d039b5c3-c844-49c8-b817-70473bd2937a
md"""
#### Line 3

```julia
zᵢ = dot(X[i, :], β)
```

Here we extract the *i*-th row of `X` and take its dot product with β using the `LinearAlgebra.dot` function, which takes in two vectors and produces a scalar. The result is stored in the scalar variable `zᵢ`.
"""

# ╔═╡ 7bbc81db-625f-46db-8b1e-c1b697f45f1b
md"""
#### Lines 4-5

```julia
pᵢ = logistic(zᵢ)
y[i] = rand(Bernoulli(pᵢ))
```

Here we use the logistic function from the *StatsFuns* package to transform ``z_i`` into ``p_i``. The benefit of using the version of this function from the *StatsFuns* package is that it's been written to support the largest set of inputs possible; a naive `logistic(z) = 1 / (1 + exp(-z))` implementation will generate exact 0.0 probabilities earlier than it should.

After computing ``p_i``, we generate the observed `y[i]` Bernoulli outcomes. We do this by constructing a Bernoulli distribution object and calling the rand function on it. This is very efficient because the Bernoulli object is immutable.
"""

# ╔═╡ 2f119d00-5f05-4edb-8c98-40f7a45b683e
md"""
#### Lines 6-8

These lines mostly contain the ends of blocks, which Julia marks with end.

The interesting part is Line 7, where we return `y` at the end to make it easy to use our function with inputs that aren't named variables.
"""

# ╔═╡ 5943bc0c-2272-4514-b560-30bde741b7bc
md"""
### Some Small Possible Variations

There are a couple of minor changes we could make that might be important in some settings. For example, we can use views instead of copies to replace `X[i, :]` with `@view(X[i, :])`. For very large arrays, this can help reduce the amount of memory we allocate, but it's worth noting that complex views can cause downstream code to be slow because they have to constantly perform quirky indexing operations that are not cache-friendly.

We could also replace `LinearAlgebra.dot(X[i, :], β)` with `X[i, :]' * β` using Julia's lazy transpose operation.

Finally we could draw random samples from the logistic distribution and compare them with $$z_i$$ instead of ever generating $$p_i$$. This is the latent variable representation of logistic regression, but it's not clear that it would provide performance benefits to make this change.

In what follows, we make a few of these changes and also use the builtin Julia macro `@inbounds` to turn off bounds checking inside of a code block. This changes the code from throwing a bounds-checking exception if the invariants we mentioned earlier are false to segfaulting. There are non-trivial performance benefits to doing this in some cases since the Julia compiler isn't always able to convince itself that bounds-checks are safe to eliminate automatically.
"""

# ╔═╡ 548f0cb1-daa7-4a1e-b50e-8426e3c41e8c
function generate_v2!(y, X, β)
    @inbounds for i in eachindex(y)
        zᵢ = @view(X[i, :])' * β
        pᵢ = logistic(zᵢ)
        y[i] = rand(Bernoulli(pᵢ))
    end
    y
end;

# ╔═╡ 99c459b7-4817-486e-a8b3-fcca0098074d
md"""
If you're interested in deciding which of the many combinatorial variants is best, you should use the `@btime` macro from the *BenchmarkTools* package to compare them explicitly in terms of speed and memory usage.
"""

# ╔═╡ 687efdff-b3c8-40c7-bfce-2d67ae496c41
md"""
### A Different Coding Style

All of the variants we've seen so far have explicit iterative loops over the data. This is often the easiest way to write code like this and it's quite fast because of Julia's language design. But there are other approaches:

* We could exploit the embarassingly parallel nature of the sum we're computing: there's no relationship between the *i*-th term in our inputs or outputs to any other term. We could employ threads that operate on disjoint set of observations to take advantage of this independence, for example.
* Write a "vectorized" solution that operates on the entire dataset at once at the function call level (but where implementation still has to think about how to process individual elements)
* Make use of BLAS calls to get some peformance improvements at the cost of potentially requiring allocating memory. In this example, there is no such cost because we get away with writing the value of `z` temporarily into the `y` array and then writing over that array with the value of `y`.

Below, we'll use this BLAS approach by calling `LinearAlgebra.mul!`. At that same time, we'll show a "vectorized" approach to evaluating logistic and calling rand by using Julia's dot broadcasting notation, which explicitly "vectorizes" any scalar function we already have. Dot broadcasting is very special part of Julia because it uses syntax to lift scalar functions to vectorized functions, but it strictly more performant than traditional vectorization because it sees a whole sequence of operations at once and can perform loop fusion to avoid having to loop over an array multiple times.
"""

# ╔═╡ 656eae8f-c690-4223-a18c-2a40dda8009f
function generate_v3!(y, X, β)
    mul!(y, X, β)
    y .= rand.(Bernoulli.(logistic.(y)))
    y
end;

# ╔═╡ fcae4798-ffc4-4e61-9beb-c1774532cf2d
md"""
Testing our implementations of the `generate!` function to ensure they're equivalent is really hard. We can check they generate similar data according to summary statistics and use frequentist bounds to ensure the summaries are credible, but that's all I know how to do. In this example, I'm very confident all the modifications are safe.
"""

# ╔═╡ 3095773c-1306-42bb-942b-d5f54736107b
md"""
## Step 3: Generate Data

Now that we have a function to sample data, let's create some data with it and use it to test the model fitting code we'll write. We'll start with a decent number of observations so that our estimates are tolerably precise without being so accurate that confidence intervals are uninteresting.
"""

# ╔═╡ 7f6fef1b-a7cc-4299-a8a4-5a20f72d1951
generate! = generate_v3!;

# ╔═╡ 68ba2f3c-ebd5-4e62-8bcd-b2e4ecc2db65
function simulate_data(n, d)
    X = hcat(ones(n), rand(Normal(0, 1), n, d));
    β = rand(Normal(0, 1), d + 1)
    y = Array{Float64}(undef, n)
    generate!(y, X, β)
    y, X, β
end;

# ╔═╡ 11721033-30ae-4d41-b915-f5a21a7105f5
y, X, β = simulate_data(10_000, 2);

# ╔═╡ 895d5280-b8a6-4751-9f05-7ca3dc42d122
β

# ╔═╡ f8c33c43-a9fe-457a-8e34-f53af17cbd4d
md"""
## Step 4: Implementing the Log Likelihood Function

Now that we have data in hand, let's code up the log likelihood function. I like to do this by copying the body of the generate! function and then changing it appropriately so the two pieces of code are maximally similar. A formal PPL would make it easier to reuse code between them.
"""

# ╔═╡ bf2077a9-1278-4d0a-9b0d-cd7995807694
function log_likelihood_naive(X, y, β)
    ll = 0.0
    @inbounds for i in eachindex(y)
        zᵢ = dot(X[i, :], β)
        pᵢ = logistic(zᵢ)
        ll += y[i] * log(pᵢ) + (1 - y[i]) * log(1 - pᵢ)
    end
    ll
end;

# ╔═╡ b545cc1e-f9de-41ff-8b9f-6c968dcb2cbe
md"""
This code has some problems of numerical accuracy and it also performs computations we don't really need to perform to produce the correct output. The essence of the problem with this naive translation of the log likelihoood equation is that we're doing work to compute `logistic(zᵢ)` when we really only need `log(logistic(zᵢ))`. We can improve on this using the `log1pexp` method we imported earlier, which also provides substantially better numerical accuracy when any of the `zᵢ < -710.0`.
"""

# ╔═╡ bb2c24c8-cbbb-4e5c-adcc-a89033114662
function log_likelihood(X, y, β)
    ll = 0.0
    @inbounds for i in eachindex(y)
        zᵢ = dot(X[i, :], β)
        c = -log1pexp(-zᵢ) # Conceptually equivalent to log(1 / (1 + exp(-zᵢ))) == -log(1 + exp(-zᵢ))
        ll += y[i] * c + (1 - y[i]) * (-zᵢ + c) # Conceptually equivalent to log(exp(-zᵢ) / (1 + exp(-zᵢ)))
    end
    ll
end;

# ╔═╡ 6dbf02bd-00e2-423b-8d20-83932a67f839
md"""
We can reassure ourselves that our changes are correct:
"""

# ╔═╡ b75226b4-fd72-40f6-b3d9-d0483c622f0d
(log_likelihood_naive(X, y, β), log_likelihood(X, y, β))

# ╔═╡ d5386090-d973-4e93-bdb3-bd6dab95f83c
md"""
The log likelihood as we've written it is a function of both the data and the parameters, but mathematically it should only depend on the parameters, $$\beta$$. In addition to that mathetical reason for creating a new function, we want a function only of the parameters because the optimization algorithms in *Optim* assume the inputs have that property. To achieve both goals, we'll construct a closure that partially applies the log likelihood function for us and negates it to give us the negative log likelihood we want to minimize.
"""

# ╔═╡ 21cc610b-2f8e-4feb-af0f-280c3ab92542
md"""
### The Log Likelihood Function Should Be a Closure
"""

# ╔═╡ 8fc99752-f12e-4e15-bbd3-a9d3ee745eab
make_closures(X, y) = β -> -log_likelihood(X, y, β);

# ╔═╡ de765f55-f7f3-4b54-ac57-73401457bbe4
nll = make_closures(X, y);

# ╔═╡ 850008cc-7a4d-4972-92bc-cac0ad6545c8
md"""
## Step 5: Minimizing the Negative Log Likelihood Function

Now that we have the negative log likelihood we'll want to minimize it starting from some point. It's common to initialize all of the parameters to zero, so let's start there:
"""

# ╔═╡ 9f5085bc-89f0-4ecb-bb49-41a461f1fb06
β₀ = zeros(2 + 1); # d = 2 and we want an intercept term

# ╔═╡ 3e9a5330-7750-48b4-b734-90923d34b49e
md"""
We can then check whether the negative log likelihood evaluated relative to the zero parameter function gives a value that seems plausible:
"""

# ╔═╡ d87c0d0f-e283-41f7-88f8-9f867167dc6b
nll(β₀)

# ╔═╡ 688137a2-8491-48bd-ab42-114fb289d3dd
md"""
Now we want to minimixe the negative log likelihood. To do that, we'll use the [Optim.jl](https://github.com/JuliaNLSolvers/Optim.jl) library, which provides an `optimize` method for minimization of blackbox functions. We'll pass two options to `optimize` to improve our results:

1. We'll use the L-BFGS algorithm to exploit the gradient that can be compute for the negative log likelihood function rather than let the algorithm default to Nelder-Mead.
1. We'll pass in an argument to use forward-mode automatic differentation to ensure that we get exact gradients rather than approximate ones. Without this, the algorithm will sometimes (or even often) fail to converge to a highly precise result because the finite-difference gradients that calculated by default will become inaccurate.
"""

# ╔═╡ 87dd6015-5b54-4227-9e51-aa5975800ded
res = optimize(nll, β₀, LBFGS(), autodiff=:forward)

# ╔═╡ c4edd01d-651c-4033-ae2f-78233fb271de
md"""
I personally like to initialize the parameters to values that I'm hopeful will let the algorithm converge faster without being costly to compute. One heuristic I've used for logistic regression is the following:

Set the intercept to be exactly right if there were no other parameters.
Set the other coefficients based on doing a standard univariate OLS fit to the logit-transformed data after replacing 0's with $\epsilon$ and 1's with $$1 - \epsilon$$. I use a large $$\epsilon = 0.1$$.
"""

# ╔═╡ 311df8ba-7c46-4688-8209-06731344954c
function initialize!(β₀, X, y, ϵ = 0.1)
    β₀[1] = logit(mean(y))
    logit_y = [ifelse(y_i == 1.0, logit(1 - ϵ), logit(ϵ)) for y_i in y]
    for j in 2:length(β₀)
         β₀[j] = cov(logit_y, @view(X[:, j])) / var(@view(X[:, j]))
    end
    β₀
end;

# ╔═╡ 040236c9-ed3c-4561-9818-238602719afb
initialize!(β₀, X, y)

# ╔═╡ 264b8ef6-f523-4ef4-9dc6-36a2cdf76746
res2 = optimize(nll, β₀, LBFGS(), autodiff=:forward)

# ╔═╡ d86e6d38-5997-4915-8827-7bd9f079d4e2
md"""
If you compare the work counters, you can see that the optimization procedure had to compute the log likelihood and its gradient fewer times. I don't know how to prove that my initialization approach will always have this effect and think it's very possible that this initialization won't always find an optimum faster. But in practice I've found it can make things a bit faster because the initialization step costs much less than evaluating `f(x)` and `∇f(x)` a few times.

Given the results of optimization, we can extract our estimates using the `Optim.minimizer` method:
"""

# ╔═╡ 3ffbd57c-7330-4476-8622-919a69368698
β̂ = minimizer(res)

# ╔═╡ 983609e3-ad0e-4828-a72a-d37ba88da826
md"""
## Step 6: Testing Our Estimates via Confidence Interval Coverage Checks

Now we have estimates, but how do we know if the estimates are good enough?

Given results about the convergence in probability of logistic regression coefficients, we know that as $$n$$ goes to infinity, `β̂` converges to `β`. Unfortunately, we can't simulate infinite data. In finite sample the convergence isn't complete, so there's some error.

So the question for evaluating our code becomes: how do we know the error is reasonable? This is a place where frequentist statistics is very useful -- if the model is true (which we're trying to ensure occurs by construction), then asymptotically we can use the Fisher Information Matrix to compute confidence intervals for `β̂` and check whether they contain `β`. We'll follow a standard of using the observed Fisher information matrix instead, since that only requires us to evaluate the Hesssian of the negative log likelihood function.
"""

# ╔═╡ 81935b3b-2090-4cbb-9b92-b2ee104f9c8f
function compute_ses(nll, β̂)
    H = hessian(nll, β̂)
    ses = sqrt.(diag(inv(H)))
    ses
end;

# ╔═╡ 9f8cb84a-58a1-47b4-9003-f78f90033389
md"""
See Chapter 9 of Wasserman's *All of Statistics* for details on the math we're using here.
"""

# ╔═╡ 474e9558-1e99-4621-a1f7-2bcc5f1eb9d5
function compute_cis(nll, β̂, α)
    ses = compute_ses(nll, β̂)
    τ = cquantile(Normal(0, 1), α)
    lower = β̂ - τ * ses
    upper = β̂ + τ * ses
    lower, upper
end;

# ╔═╡ fe38fef4-62c8-4c3f-962e-d80ac18225f9
md"""
Standard CI computation using quantiles from the normal distribution.
"""

# ╔═╡ 6a2f2586-49fe-4074-94e3-5d0e2250c6e4
check_cis(β, lower, upper) = all(lower .<= β .<= upper);

# ╔═╡ 02796712-ba34-4d03-a8ba-eb24155e650c
begin
	α = 0.001
	check_cis(β, compute_cis(nll, β̂, α)...)
end

# ╔═╡ e5274a1f-d43a-40bb-a8b7-b7971f3f4e51
md"""
Conclusion
Hopefully this short tutorial gives a flavor of how to fit models via MLE in Julia. There's many more topics that we could have explored, but I wanted to keep things relatively short. A few topics that I'd encourage the reader to investigate:

* Is it better to use the analytic gradient in `optimize` in terms of accuracy or performance?
* Do our results match the results from Julia's GLM package or R's `glm` function?
* Should we modify the `log_likelihood` function to automatically scale inputs so they have a standard deviation of 1?
* How do we construct robust standard errors when the model is misspecified? There's an intro in Julia to robust standard errors [here](https://github.com/PaulSoderlind/FinancialEconometrics/blob/master/Ch12_MLE.ipynb).
"""

# ╔═╡ 613e5fb0-3972-4fc9-b2ba-a856cbd245fb
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
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Optim = "429524aa-4258-5aef-a3af-852621145aeb"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsFuns = "4c63d2b9-4356-54db-8cca-17b64c39e42c"

[compat]
Distributions = "~0.25.11"
ForwardDiff = "~0.10.18"
Optim = "~1.3.0"
StatsFuns = "~0.9.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "a71d224f61475b93c9e196e83c17c6ac4dedacfa"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.18"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "ad613c934ec3a3aa0ff19b91f15a16d56ed404b5"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.0.2"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "214c3fcac57755cfda163d91c58893a8723f93e9"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.0.2"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3889f646423ce91dd1055a76317e9a1d3a23fff1"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.11"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "693210145367e7685d8604aee33d9bfb85db8b31"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.11.9"

[[FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "8b3c09b56acaf3c0e581c66638b85c8650ee9dca"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.8.1"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "e2af66012e08966366a43251e1fd421522908be6"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.18"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "f27132e551e959b3667d8c93eae90973225032dd"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.1.1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "6a8a2a625ab0dea913aba95c11370589e0239ff0"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.6"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "50608f411a1e178e0129eab4110bd56efd08816f"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Optim]]
deps = ["Compat", "FillArrays", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "d34366a3abc25c41f88820762ef7dfdfe9306711"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.3.0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "508822dca004bf62e210609148511ad03ce8f1d8"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.0"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "62701892d172a2fa41a1f829f66d2b0db94a9a63"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "5b2f81eeb66bcfe379947c500aae773c85c31033"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.8"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2f6792d523d7448bbe2fec99eca9218f06cc746d"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.8"

[[StatsFuns]]
deps = ["LogExpFunctions", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "30cd8c360c54081f806b1ee14d2eecbef3c04c49"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.8"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─45e2a810-e6a0-11eb-05f3-55c239b22688
# ╟─d2f7e7ac-2990-4f29-96d5-32e350d8cae7
# ╟─61d2bd62-f1ca-46b9-a81a-7a7f47d9f8c9
# ╟─9c0708e4-d09f-4d80-931d-cabb3edcd221
# ╟─7aa29bd6-7623-4a16-954a-bc1503f30e26
# ╟─6582b975-67b3-4d73-a54c-a41f63caa7f6
# ╟─12f2123e-a3c1-4d5b-8cf9-6955c2c5789a
# ╟─4d5e18c4-d07f-4ff9-a1a9-7dbbf76fe8f1
# ╟─bf63ac1c-49f8-495f-bca9-77b6524fcae1
# ╟─d9f647e7-76d4-428a-825d-ef8143e5db94
# ╠═f2b9812b-746d-43b2-b020-31d613b5670e
# ╟─4fc944f5-8942-43be-a9e5-9254808eba0b
# ╠═4c586705-93ec-4eca-8271-040fe231e624
# ╟─1eefc492-0814-4a5b-9937-02914221b8b8
# ╟─7d4a4ff0-6df7-4936-9765-a97d48f70896
# ╟─2c0f779c-feae-4d49-bbdb-3a4f410f214a
# ╟─d039b5c3-c844-49c8-b817-70473bd2937a
# ╟─7bbc81db-625f-46db-8b1e-c1b697f45f1b
# ╟─2f119d00-5f05-4edb-8c98-40f7a45b683e
# ╟─5943bc0c-2272-4514-b560-30bde741b7bc
# ╠═548f0cb1-daa7-4a1e-b50e-8426e3c41e8c
# ╟─99c459b7-4817-486e-a8b3-fcca0098074d
# ╟─687efdff-b3c8-40c7-bfce-2d67ae496c41
# ╠═656eae8f-c690-4223-a18c-2a40dda8009f
# ╟─fcae4798-ffc4-4e61-9beb-c1774532cf2d
# ╟─3095773c-1306-42bb-942b-d5f54736107b
# ╠═7f6fef1b-a7cc-4299-a8a4-5a20f72d1951
# ╠═68ba2f3c-ebd5-4e62-8bcd-b2e4ecc2db65
# ╠═11721033-30ae-4d41-b915-f5a21a7105f5
# ╠═895d5280-b8a6-4751-9f05-7ca3dc42d122
# ╟─f8c33c43-a9fe-457a-8e34-f53af17cbd4d
# ╠═bf2077a9-1278-4d0a-9b0d-cd7995807694
# ╟─b545cc1e-f9de-41ff-8b9f-6c968dcb2cbe
# ╠═bb2c24c8-cbbb-4e5c-adcc-a89033114662
# ╟─6dbf02bd-00e2-423b-8d20-83932a67f839
# ╠═b75226b4-fd72-40f6-b3d9-d0483c622f0d
# ╟─d5386090-d973-4e93-bdb3-bd6dab95f83c
# ╟─21cc610b-2f8e-4feb-af0f-280c3ab92542
# ╠═8fc99752-f12e-4e15-bbd3-a9d3ee745eab
# ╠═de765f55-f7f3-4b54-ac57-73401457bbe4
# ╟─850008cc-7a4d-4972-92bc-cac0ad6545c8
# ╠═9f5085bc-89f0-4ecb-bb49-41a461f1fb06
# ╟─3e9a5330-7750-48b4-b734-90923d34b49e
# ╠═d87c0d0f-e283-41f7-88f8-9f867167dc6b
# ╟─688137a2-8491-48bd-ab42-114fb289d3dd
# ╠═87dd6015-5b54-4227-9e51-aa5975800ded
# ╟─c4edd01d-651c-4033-ae2f-78233fb271de
# ╠═311df8ba-7c46-4688-8209-06731344954c
# ╠═040236c9-ed3c-4561-9818-238602719afb
# ╠═264b8ef6-f523-4ef4-9dc6-36a2cdf76746
# ╟─d86e6d38-5997-4915-8827-7bd9f079d4e2
# ╠═3ffbd57c-7330-4476-8622-919a69368698
# ╟─983609e3-ad0e-4828-a72a-d37ba88da826
# ╠═81935b3b-2090-4cbb-9b92-b2ee104f9c8f
# ╟─9f8cb84a-58a1-47b4-9003-f78f90033389
# ╠═474e9558-1e99-4621-a1f7-2bcc5f1eb9d5
# ╟─fe38fef4-62c8-4c3f-962e-d80ac18225f9
# ╠═6a2f2586-49fe-4074-94e3-5d0e2250c6e4
# ╠═02796712-ba34-4d03-a8ba-eb24155e650c
# ╟─e5274a1f-d43a-40bb-a8b7-b7971f3f4e51
# ╟─613e5fb0-3972-4fc9-b2ba-a856cbd245fb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
