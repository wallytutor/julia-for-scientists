### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 20d1d250-25ee-11ee-0d93-7374b5a110ac
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using Plots
    using Printf
    using Unitful
end

# ╔═╡ 349589a1-e262-4238-a16e-c5d4bfe36f70
md"""
# Equação da advecção em 1D

Vamos abordar neste tutorial a implementação de um integrador para a equação de advecção nas suas formas linear e não linear. Como este é o primeiro *bloco* da construção da equação de Navier-Stokes que almejamos alcançar ao final do livro texto, vamos clarificar alguns pontos sobre a metodologia que será empregada.

O leitor que já tenha estudado o tópico através de outras fontes, como [CFDPython](https://github.com/barbagroup/CFDPython), mais conhecido como *12 passos para Navier Stokes* vai observar que nossos códigos são mais estruturados e menos explícitos. Isso vem da nossa observação de que existe uma pletora de fontes instruindo o básico de programação científica, mas faltam fontes aonde não somente as equações são abordadas. É de nossa experiência o excesso de cientistas e engenheiros que vieram a aprender a estruturar um programa tardivamente, o que resulta em uma infinidade de repositórios com código que, embora às vezes funcional, é praticamente impossível de se realizar a manutenção ou mesmo utilizar.

Dessa crítica ao *status quo*, vamos ao longo desta série não somente resolver os problemas de uma ótica numérica, mas também progressivamente *pensar antes de programar* a forma do programa que desejamos conceber. O estudante que se engajar nessas práticas sem a menor dúvida terá uma carreira técnica de maior sucesso e performance que os demais.

Aqui nos deparamos com um primeiro *conundrum*: uma interface interativa como Pluto não é o meio ideal para se conceber um programa a ser mantido ao longo dos anos. Esse tipo de documento é perfeito para realizar demonstrações e usar interfaces de implementações mais complexas fornecidas através de pacotes. Vamos nesse primeiro momento ignorar esse fato porque, embora buscamos transmitir o conhecimento de como conceber um programa de qualidade, seríamos frustrados por uma tentativa de ensinar isso diretamente com a concepção de pacotes, tema que é abordado anexamente ao livro texto.

No que se segue neste *notebook* (vamos aceitar este anglicismo eventual ao longo do texto) e nos subsequentes adotaremos uma estrutura típica. Começamos com uma descrição do problema que desejamos resolver a as funcionalidades almejadas. Com isso podemos pensar nas ferramentas que vamos necessitar e como dita a boa prática importá-las logo no início do programa. Em seguida provemos todo o código que é auxiliar ao problema numérico, como por exemplo a geração de gráficos, de maneira a eliminar suas interferências na leitura do código principal. Finalmente concebemos o código com o conteúdo matemático abordado e seguimos com um programa de aplicação. Essa forma será empregada nos demais *notebooks* sem que tenhamos que repetir essa descrição.
"""

# ╔═╡ 9a022e79-5680-4a0c-9ff0-c5b67c16e3e6
md"""
## Objetivos

"""

# ╔═╡ 3e4d4298-e107-4b39-aeaf-a5e741b16105
md"""
## Funções auxiliares
"""

# ╔═╡ a9ac739f-aee8-4780-b6b9-0da3600fd967
function display_results(x, sol)

    # Layout to stack plots.
    l = @layout [a ; b]

    # Kymograph of advection.
    p1 = heatmap(ustrip(sol),
                 color  = :thermal,
                 xlabel = "Coordinate index",
                 ylabel = "Time step")

    # Compare initial/final states.
    p2 = plot();
    plot!(p2, x, sol[1,   :], label = "Initial state", linewidth = 2)
    plot!(p2, x, sol[end, :], label = "Final state",   linewidth = 2)
    xlabel!(p2, "Coordinate, \$\\mathrm{m}\$")
    ylabel!(p2, "Velocity, \$\\mathrm{m.s^{-1}}\$")

    return plot(p1, p2, layout = l, sizes  = (700, 800))
end

# ╔═╡ 915dbda4-7565-4c2a-b38e-c5a0e83d9ee9
md"""
## Funções de integração
"""

# ╔═╡ bcbd8cee-0168-49fa-b637-7e367df83326
function step_linear!(u, τ, δ, c)
    α = c * τ / δ
    u[2:end] = (1 - α) * u[2:end] + α * u[1:end-1]
end

# ╔═╡ 754e3ef7-6a28-4382-93c9-1b3b0cfe5803
function step_nonlinear!(u, τ, δ, c)
    αₖ = (τ / δ) .* u[2:end]
    u[2:end] = (1.0 .- αₖ) .* u[2:end] + αₖ .* u[1:end-1]
end

# ╔═╡ 28346bc0-f446-4d83-b608-df24abde00bb
md"""
## Initial state helper function
"""

# ╔═╡ b5e9944d-e800-488a-b2e9-10592f06f732
function make_peak(x, nₓ, u₀, xᵤ)
    mask = ((xᵤ[1] .< x) .& (x .< xᵤ[2]))
    u = u₀ * ones(Float64, (nₓ, 1))
    u[.~mask] .= 0.5 .* u₀
    return u
end

# ╔═╡ ec6e57a5-3038-4e4d-8cff-50b6f7d0b6dd
md"""
## Condições do problema.

Considere um domínio hipotético de comprimento $L=2\:\mathrm{m}$ na direção do eixo $x$ sobre o qual temos uma *onda de uma substância insolúvel* localizada nas coordenadas $x\in[0.5;1.0]\:\mathrm{m}$ movendo-se a $u=1\:\mathrm{m\cdotp{}s^{-1}}$ e sendo a metade deste valor no restante do espaço. No instante inicial $t=0\:\mathrm{s}$ um fluxo de fluido com velocidade constante $c=1\:\mathrm{m\cdotp{}s^{-1}}$ é força através do domínio, o qual já se encontra imerso no fluido.

---

Determine a posição e velocidade $u(x,t)$ da substância no intervalo de $T=1.0\:\mathrm{s}$ que se segue.

---
"""

# ╔═╡ 36a620c5-25f3-4de6-8536-dc237cc656ec
md"""
Com esses elementos temos a descrição suficiente do problema para iniciar a sua tranposição na forma de código com Julia. Para asseguramos a consistência física do problema vamos utilizar valores numéricos acompanhados de unidades providas pelo pacote [Unitful](https://painterqubits.github.io/Unitful.jl/stable/).

**Nota:** em problemas de larga escala essa abordagem talvez traga inconvenientes de sobrecarga computacional, no entanto é recomendado que se concebam programas compatíveis com `Unitful` para a verificação de consistência em casos de teste.

Na próxima célula provemos todos os elementos numéricos presentes na descrição do problema.
"""

# ╔═╡ 953db8f3-cffd-41df-94d9-4e4c17c7c0cb
begin
    # Domain length.
    L = 2.0u"m"

    # Time domain.
    T = 1.0u"s"

    # Fluid velocity.
    c = 1.0u"m/s"

    # Wave velocity.
    u₀ = 1.0u"m/s"

    # Position of peak.
    xᵤ = [0.5u"m", 1.0u"m"]
end

# ╔═╡ ee2a3676-4b8a-4244-948a-3429e67afd02
md"""
To remain within the region where the error introduced by the discretization scheme remains *small*, we need to *think* what would be a good number of steps and nodes to split our system. Thinking physically, we would not want the density $u$ to be transported by more than one node distance $\delta$ in a time step $\tau$, otherwise we would be *skipping* information transfer. Thus, there is some logic constraining $\delta\le{}c\tau$ to be respected here. We also have infinite gradients in the specified square wave of mass density, so space step should not be too small otherwise it would lead to a overflow error..., well, there are many other aspects to be considered, but we did not introduce them yet. So let's just assume that as a rule of thumb *both space and time discretization must be reasonably smaller than the integration domains*.

Below we assume this *reasonably small* criterium is 1/500 the size of the system and compute the required nodal distance and time step. Notice the `- 1` in the denominator, because the number of intervals between $k$ nodes is $k-1$. The computed values are displayed with their respective units.
"""

# ╔═╡ d92d5220-2f61-489a-834d-5173f1eea6b8
begin
    nₓ = 501
    nₜ = 501

    δ = L / (nₓ - 1)
    τ = T / (nₜ - 1)

    δ, τ
end

# ╔═╡ de024a53-df91-4289-bf31-d667a475fddf
function solve_advection!(step!, u₀, x, t, u, τ, δ, c)
    sol = u₀ * zeros(Float64, (nₜ, nₓ))

    for (k, _) in enumerate(t)
        sol[k, :] = copy(u)
        step!(u, τ, δ, c)
    end

    return display_results(x, sol)
end

# ╔═╡ 476433ff-8622-40f4-8a64-8bdc9c3b1854


# ╔═╡ 5bdb45d1-a04d-4d06-b97d-d35e870fd780
begin
    x = 0.0u"m":δ:L
    t = 0.0u"s":τ:T

    x, t
end

# ╔═╡ 7148fcff-66dc-438c-aa80-14af2780b9bd
md"""
## Advecção linear
"""

# ╔═╡ b1062cbd-f782-465b-97f3-51b213932422
begin
    u = make_peak(x, nₓ, u₀, xᵤ)
    solve_advection!(step_linear!, u₀, x, t, u, τ, δ, c)
end

# ╔═╡ 5934c86e-3b2e-4dfd-a189-c6b358fb096c
md"""
## Advecção não-linear
"""

# ╔═╡ c0fad725-e2b9-4d77-9a76-9bb010a88fcf
begin
    v = make_peak(x, nₓ, u₀, xᵤ)
    solve_advection!(step_nonlinear!, u₀, x, t, v, τ, δ, c)
end

# ╔═╡ 8ffa1dc0-3e37-41f4-9f87-5d9cd463ac43
md"""
## DRAFT

Other higher order expansions are available in the literature, but they are not well-suited for an introductory course on numerical implementation of the solution of PDE's, so we stick with this low order approximation in what follows. An analogous expansion can be performed for the time derivative of the advection equation. Notice that for time the expansion is performed towards the *future*. This leads to the following space-time discretization to the problem

```math
\frac{u(t+\Delta{}t)-u(t)}{\Delta{}t}+c\frac{u(x)-u(x-\Delta{}x)}{\Delta{}x}=0
```

This approximate representation of the advection PDE is difficult to read and distant from what it would look in a computer, where it can be represented through indexed arrays or matrices. It is common in the FDM to use subscripts for denoting space indices, and superscript for time-steps. This way we translate $t+\Delta{}t$ as $n+1$, where $n$ is the time-step number, and $x-\Delta{}x$ becomes $i-1$, where $i$ is the index of the FDM space coordinate node. Also it is useful to maker shorthands $\tau=\Delta{}t$ and $\delta=\Delta{}x$. The equation becomes

```
\frac{u_{i}^{n+1}-u_{i}^n}{\tau}+c\frac{u_{i}^n-u_{i-1}^n}{\delta}=0
```
Our goal of approaching the equation to the computer implementation format has been reached. So far we are only considering fixed time-steps $\tau$ and node distances $\delta$, and constant advection velocity $c$, thus there are still a three constants hanging around. Since problem initial state is *a priori* knowledge for PDE integration, at $n=0$ and $\forall{}i$ we dispose of the state $u_{i}^{n}=u_{i}^{0}$, so the only unknown in the above equation is $u_{i}^{n+1}$, for which it can be solved

```
u_{i}^{n+1}=(1-\alpha)u_{i}^{n}+\alpha{}u_{i-1}^n
```

Such approximation that makes use of current state to predict a future one is called an *explicit* time-stepping scheme and has been implied without explanation in the above discretization approach. With this expression we have the complete mathematical tooling to solve the simplest advection equation. Notice that for $c<0$ the direction of the upwind space derivative would change and the solution becomes $u_{i}^{n+1}=(1+\alpha)u_{i}^{n}-\alpha{}u_{i+1}^n$.

Now suppose we want to solve advection of a given wave over a 1-D space domain. The discrete solution derived above provides most information we need to gather before starting to develop a computer solution, but it says nothing about the sizes of discrete steps $\tau$ and $\delta$. For now we rely only on the mathematical background we have on Taylor series expansion to think about it, and we postpone the methods of computing suitable steps for later. Let's experiment with a hand-on example to get some insights.

### Example


For allocating arrays of same shapes, Julia provides the method `similar`. Since we are using units with our values, that method cannot be used here with array for $x$ to allocate the density array $u$, otherwise the result would carray space dimensions. Instead we create a `ones` array of appropriate numerical type and dimensions and provide it with units carried by $u_{0}$. Notice that this initializes the whole array with the value found in the square wave.

To modify the regions ouside the peak we create a boolean mask. In Julia, to evaluate a binary operation elementwise, a dot is placed in front of the operator. So here `xᵤ[1] .< x` means true where elements of `x` are less than the first element of `xᵤ`, for instance. Since the mask we created represent the square wave region, we negate the resulting array to set zero elsewhere in the density array `u`. Also observe the `.=` notation to attribute results. This vectorized operations supported by Julia avoid the excessive use of loops and result in easier to maintain code.

**Note:** method `ustrip` from `Uniful` was used to remove units from arrays before plotting because their rendering is not converted to $\LaTeX$ in axes.

With all this elements we prepare the solution. We start by computing the constant $\alpha$ known as *Courant number*. Observe that this is a dimensionless number since it results from the product of a velocity by the inverse of a *numerical velocity*. Depending on the choice of derivative approximations there may be a upper limit for which the numerical integration will be *stable*. We are not entering in these details yet, for now you can read more about this [here](https://en.wikipedia.org/wiki/Courant%E2%80%93Friedrichs%E2%80%93Lewy_condition) to get a taste of the numerical analysis to come.

In the present case we might want to store the solution of all time steps for performing an animation or display a kymograph, what will be the case here. For small to medium sized problems, it is more effecient to allocate the memory for solution storage ahead of time, especially when working with fixed time steps. For larger problems or variable time step size, it is sometimes necessary to allocate memory for part of the solution and from times to times dump current chunk to the disk, or handle a buffer with limited memory.

Since this is a very simple 1-D problem, we chose to have a matrix will one row per time step, so its dimensions are $n_t\times{}n_x$, as follows.

Because they will be reused several times in this chapter, we wrap the kymograph and comparison plotting in the functions given below. It is generally a good idea to follow some [DRY directives](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself), but care must be take not to create new methods for simple one-liners, which could become hard to maintain later.

The solution loop is straightforward: we store the current state and solve over the same array the next time solution, what constitutes a simple explicit *Euler* time-stepping scheme. Since Julia supports vectorized operations we use the slice syntax to evaluate $(1-\alpha)u_{i}^{n}+\alpha{}u_{i-1}^n$ and attribute it elementwise to $u_{i}^{n+1}$. Notice that element `u[1]` is never updated here, think for a moment what are the implications of this.

The analytical solution to this problem states that the shape of the density profile should not evolve in time, just its position. In the kymograph above that would mean that the only valid values in the heat map would be those originally in the initial state array. This is not actually what we observe. We get just qualitative agreement between the expected and actual position of our moving hump $u$, which apparently *diffused* over the domain. And this exaclty what happened, from a numerical standpoint. When we approximated the spacial derivative, we were actually truncating a Taylor series expansion of $u$ at the first term, as in:

```
u(x) = u(x-\Delta{}x) + \frac{(\Delta{}x)^{1}}{1!}\frac{\mathrm{d}u}{\mathrm{d}x} +
                        \frac{(\Delta{}x)^{2}}{2!}\frac{\mathrm{d}^{2}u}{\mathrm{d}x^{2}} +
                        \mathcal{O}((\Delta{}x)^{3})
```

so that the derivative we approximated was in fact:

```
\frac{u(x) - u(x-\Delta{}x)}{\Delta{}x} =
    \frac{\mathrm{d}u}{\mathrm{d}x} +
    \frac{(\Delta{}x)}{2!}\frac{\mathrm{d}^{2}u}{\mathrm{d}x^{2}} +
    \mathcal{O}((\Delta{}x)^{2}) =
    \frac{\mathrm{d}u}{\mathrm{d}x} +
    \mathcal{O}((\Delta{}x)^1)
```

Our numerical approximation to the first derivative implicitly contains a *diffusion* term in the truncation error! The same is valid for the time derivative. We could use higher order schemes but always there will be some numerical diffusion in upwind schemes for convection. From the expression above we see that this diffusion term is proportional to $\Delta{}x$, so increasing the number of points in space could be a solution, but this can become prohibitive in real-world 3-D problems.

Below we display a comparison between initial and final states of the advected wave.

### Exercises

1. Solve the problem with an increasingly larger number of space nodes and plot the MSE of the difference between the numerical and analytical solutions. What kind of behavior do you observe? Is there any limiting value for the number of nodes under constant time discretization? Discuss your findings.

2. Increase the integration interval to $T=3\:\mathrm{s}$ and adapt problem solution to handle periodic boundary conditions. Does the meaning of space coordinates remain the same all over the array? Do not forget to use an adequate number of time steps for keeping solution stable.

## Nonlinear advection

In order to introduce more complex phenomena, we modify the advection equation so that there is no external field transporting the wave but itself. In this case the previous $c$ is replaced by $u$ and the equation writes

```
\frac{\partial{}u}{\partial{}t} + u \frac{\partial{}u}{\partial{}x} = 0
```

Applying the same approach and symbol convention used before, we can find that

```
u_{i}^{n+1}=(1-\alpha_{i})u_{i}^{n}+\alpha_{i}u_{i-1}^n\qquad\text{where}\qquad\alpha_{i}=\frac{\tau}{\delta}u_{i}^{n}
```

### Example

As an example we solve the transport of the same wave integrated in linear advection example with a self-advective transport instead. Other than a small rearrangement in the equation there are no changes in the time-stepping.

Analysing the $u\cdotp{}u^\prime$ term in the nonlinear advection equation we see that it has units of acceleration. Because now the transport coefficient is the local velocity itself, different locations accelerate at different rates, leading to the *shock wave* phenomenon. Below we compare the initial and final waves.

### Exercises

1. It is possible use the product derivative rule to replace $u\cdotp{}u^\prime=½(u^2)^\prime$ in advection equation, what is known as its *conservative* form. How would you implement this in Julia and what are the implications of this on solution in terms of space and time discretization? Provide some numerical examples.

## Courant-Friedrichs-Lewy criterium

The previous examples and proposed exercises have shown that the explicit numerical scheme that was introduced does not lead to a correct problem solution no matter the choice of number of time steps and nodes. In fact, we have discussed the idea that these are actually mutually dependent and provided a tip regarding the origin of the Courant number $\alpha$. In order to ensure the stability of this explicit scheme, we apply the Courant–Friedrichs–Lewy (CFL) condition which states that:

```
\alpha = c \frac{\tau}{\delta} \le \alpha_{crit}
```

Here the value of $\alpha_{crit}$ changes with the integration method. Before proceeding with the numerical analysis, let's start again with some numerical experimentation. To do so we will conceive a few methods for automating multiple solutions of linear advection equation with different discretization levels. The idea is to have the possibility to solve a Courant number constrained problem as well as a free discretization. The first step is to conceive a method `compute_cfl` which will discretize space as provided by the user, then compute time step in a CFL-constrained way it the number to time steps is not provided, or simply discretize time with a user-defined number of steps.

Below we test the method with the inputs inherited from previous examples. The underscore in front of returned values is a reminder that these parameters are to be discarded in what follows.

If the number of time steps is not provided with a `nothing` instead of an integer, the method performs the CFL-constrained discretization a wished.

Now we put together everything we learned about the solution of advection equation in a single method `linear_advection_explicit` which will ingest our space and time domain, fluid velocity, wave parameters, and discretization, to then output the solution with respective space and time axes.

Before going further we test it is working as expected.

To perform an automated numerical experiment we put it all together in `scan_advection`. This method will receive everything to setup the problem as provided above, but instead of a single space discretization, it takes a range of number of nodes. This way it will be able to show us the role of nodal length over the accuracy of the solution. It also takes an optional number of time steps, which will be useful for testing the CFL-bounded integration.

The following examples were integrated for a shorter physical time to allow faster and didactic computations when scanning over different number of nodes in space domain.

Now we discretize the spacial axis with different number of nodes in the range $[40;70]$. As you may observe in the figure below, numerical diffusion decreases for larger $n_x$, as it was expected from previous discussion. The number of time points is held constant here and equal to 24. Solution seems to better preserve wave shape when $\alpha$ approaches unity.

Next we increase the upper limit of the number of space nodes $n_x$ to 85, while keeping $n_t$ as before. Apparently the solution *exploses*. If we check the value of $\alpha$, for 85 nodes it has reached 1.21.

Following the observations made on the first trial, we can increase $n_t$ to force $\alpha\le1$. Apparently we identified *empirically* the critical value of CFL for this problem integration method. What happens if you further increase $n_t$, and why does it happen?

## A (not so) formal stability analysis

One important question that arrises when solving PDE's numerically is whether the system is *stable*, *i.e.* if the numerical solution remains bounded as time-step goes to zero. That means that perturbations such as the rounding error do not increase in time. There are no general methods for perform such analysis and one gets restricted to linear problems. The standard method for this was proposed by John von Neumann, who proposes to use Fourier series to represent the rounding error. Notice that this implies periodic boundary conditions, otherwise these need to be artificially introducted to the problem in order to be tractable.

Suppose the numerical scheme used for integration can be represented by a nonlinear operator $\mathcal{J}$, allowing for the progression in time as:

```
u^{n+1}=\mathcal{J}[u^{n}]
```

This operator will produce a sequence of values $u(t_{n})=\{u^0,u^1,u^2,...,u^n\}$ Since the numerical scheme is only an approximation, each step introduces a small cummulative error such that this sequence is in fact $\{u^0+\varepsilon^0,u^1+\varepsilon^1,u^2+\varepsilon^2,...,u^n+\varepsilon^n\}$, what can be represented by:

```
u^{n+1}+\varepsilon^{n+1}=\mathcal{J}(u^{n}+\varepsilon^{n})
```

Assuming the Taylor series expansion of $\mathcal{J}$ is possible, after linearization we can express the amplification of the error as the next expression, known as the *error propagation law*. Matrix $G$ is called the *amplification matrix*. We promptly identify that this is an eigenvalue problem.

```
\varepsilon^{n+1}=\frac{\partial{}\mathcal{J}(u^{n})}{\partial{}u^{n}}\varepsilon^{n}=G\varepsilon^{n}
```

The numerical stability of the system depends on the eigenvalues $g_{\mu}$ of $G$. In order that the error remains bounded, the following condition is required for stability:

```
\vert{}g_{\mu}\vert\le{}1\qquad\forall\mu
```

In general the solution of a PDE will be represented by $u(t_{n},x_{p})\equiv{}u^{n}_{p}$ (notice the change of the subscript used for position here to avoid confusion with the imaginary unit $i$ and the wave-number $k$ that will be used later). The error propagation at one node $p$ is coupled to every other node $q$ by means of the Jacobian matrix element $G_{pq}$, what is expressed by:

```
\varepsilon^{n+1}_{p}=\sum_{q}G_{pq}\varepsilon^{n}_{q}
\qquad\text{where}\qquad
G_{pq}=\frac{\partial{}\mathcal{J}(u^{n}_{p})}{\partial{}u^{n}_{q}}
```

The error $\varepsilon^{n}_{p}$ can be expanded as a Fourier series of wavenumbes $k$ over the problem domain. Since the cummulative error must decay or grow exponentially in time, we can assume that the Fourier coefficients $\hat{\varepsilon}^{n}(k)$ vary as $\exp{(\omega{}t_{n})}$, where the frequency $\omega$ is a constant.

```
\varepsilon^{n}_{p}=\sum_{k}\hat{\varepsilon}^{n}(k)\exp{(ikx_{p})}=\sum_{k}\exp{(\omega{}t_{n})}\exp{(ikx_{p})}
```

It is important to notice that the functions $\exp{(ikx_{p})}$ are eigenfunctions of $G$, so the last expression can be interpreted as an expansion of eigenfunctions og $G$. Furthermore, since the equation for the error is linear, it is enough to study the growth of an arbitrary element in the sum, such as $\varepsilon^{n}_{p}=\exp{(\omega{}t_{n})}\exp{(ikx_{p})}
$. From this we have:

```
\varepsilon^{n+1}_{p}=g(k)\varepsilon^{n}_{p}
```

As such, one can take the $\exp{(ikx_{p})}$ as an eigenvector corresponding to eigenvalue $g(k)$, which is known as the amplification factor. The *von Neumann stability criterium* is then:

```
\vert{}g(k)\vert\le{}1\qquad\forall{}k
```

### Application to 1-D convection

To start with, at an arbitrary point $p$ in the grid we inject the corresponding error propagation term $\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$ at the correct time instant. Notice here that we made $x_{p}=p\Delta{}x$ for allowing proper manipulation in what follows. Using the *upwind explicit* scheme we are dealing with one produces:

```
\hat{\varepsilon}^{n+1}(k)\exp{(ikp\Delta{}x)}=
\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}-
\alpha\left[
    \hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}-
    \hat{\varepsilon}^{n}(k)\exp{(ik(p-1)\Delta{}x)}
\right]
```

The error amplification factor $g(k)$ can then be identified by simultaneously dividing the previous expression by $\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$. Notice that this expression is independent of the position $p$ and thus remains valid for the whole domain.

```
g(k)=\frac{\hat{\varepsilon}^{n+1}(k)}{\hat{\varepsilon}^{n}(k)}=
1-\alpha+\alpha\exp{(-ik\Delta{}x)}
```

In order to respect von Neumann stability condition for all $k$ we need $1-\alpha\le{}0$, what provides the value of $\alpha_{crit}=1$ that we previously identified through our numerical experiments. Thus, we say the *upwind explicit* scheme for 1-D convection is *conditionally stable*, *i.e* the physical velocity *c* must not be bigger than the numerical *spreading velocity* $\frac{\Delta{}x}{\Delta{}t}$.

By not providing the number of time steps in our scanning model forces CFL criterium to be respected for all number of nodes in space, as expected from the previous analysis. In this case, we cannot ensure that the time step required to respect CFL will produce an integer number of steps to reach exactly the time position we wish the calculation to terminate at. In another moment we will deal with this.
"""

# ╔═╡ Cell order:
# ╟─349589a1-e262-4238-a16e-c5d4bfe36f70
# ╟─9a022e79-5680-4a0c-9ff0-c5b67c16e3e6
# ╠═20d1d250-25ee-11ee-0d93-7374b5a110ac
# ╟─3e4d4298-e107-4b39-aeaf-a5e741b16105
# ╠═a9ac739f-aee8-4780-b6b9-0da3600fd967
# ╟─915dbda4-7565-4c2a-b38e-c5a0e83d9ee9
# ╠═de024a53-df91-4289-bf31-d667a475fddf
# ╠═bcbd8cee-0168-49fa-b637-7e367df83326
# ╠═754e3ef7-6a28-4382-93c9-1b3b0cfe5803
# ╟─28346bc0-f446-4d83-b608-df24abde00bb
# ╠═b5e9944d-e800-488a-b2e9-10592f06f732
# ╟─ec6e57a5-3038-4e4d-8cff-50b6f7d0b6dd
# ╟─36a620c5-25f3-4de6-8536-dc237cc656ec
# ╠═953db8f3-cffd-41df-94d9-4e4c17c7c0cb
# ╟─ee2a3676-4b8a-4244-948a-3429e67afd02
# ╠═d92d5220-2f61-489a-834d-5173f1eea6b8
# ╠═476433ff-8622-40f4-8a64-8bdc9c3b1854
# ╠═5bdb45d1-a04d-4d06-b97d-d35e870fd780
# ╟─7148fcff-66dc-438c-aa80-14af2780b9bd
# ╠═b1062cbd-f782-465b-97f3-51b213932422
# ╟─5934c86e-3b2e-4dfd-a189-c6b358fb096c
# ╠═c0fad725-e2b9-4d77-9a76-9bb010a88fcf
# ╟─8ffa1dc0-3e37-41f4-9f87-5d9cd463ac43
