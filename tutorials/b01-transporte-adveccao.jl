### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 20d1d250-25ee-11ee-0d93-7374b5a110ac
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using Plots;
    using Printf;
    using Unitful;
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
    l = @layout [a ; b];

    # Kymograph of advection.
    p1 = heatmap(ustrip(sol),
                 color  = :thermal,
                 xlabel = "Coordinate index",
                 ylabel = "Time step");

    # Compare initial/final states.
    p2 = plot();
    plot!(p2, x, sol[1,   :], label = "Initial state", linewidth = 2);
    plot!(p2, x, sol[end, :], label = "Final state",   linewidth = 2);
    xlabel!(p2, "Coordinate, \$\\mathrm{m}\$");
    ylabel!(p2, "Velocity, \$\\mathrm{m.s^{-1}}\$");

    return plot(p1, p2, layout = l, sizes  = (700, 800));
end

# ╔═╡ 915dbda4-7565-4c2a-b38e-c5a0e83d9ee9
md"""
## Funções de integração
"""

# ╔═╡ bcbd8cee-0168-49fa-b637-7e367df83326
function step_linear!(u, τ, δ, c)
    α = c * τ / δ;
    u[2:end] = (1 - α) * u[2:end] + α * u[1:end-1];
end

# ╔═╡ 754e3ef7-6a28-4382-93c9-1b3b0cfe5803
function step_nonlinear!(u, τ, δ, c)
    αₖ = (τ / δ) .* u[2:end];
    u[2:end] = (1.0 .- αₖ) .* u[2:end] + αₖ .* u[1:end-1];
end

# ╔═╡ 28346bc0-f446-4d83-b608-df24abde00bb
md"""
## Initial state helper function
"""

# ╔═╡ b5e9944d-e800-488a-b2e9-10592f06f732
function make_peak(x, nₓ, u₀, xᵤ)
    mask = ((xᵤ[1] .< x) .& (x .< xᵤ[2]));
    u = u₀ * ones(Float64, (nₓ, 1));
    u[.~mask] .= 0.5 .* u₀;
    return u;
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
    L = 2.0u"m";

    # Time domain.
    T = 1.0u"s";

    # Fluid velocity.
    c = 1.0u"m/s";

    # Wave velocity.
    u₀ = 1.0u"m/s";

    # Position of peak.
    xᵤ = [0.5u"m", 1.0u"m"];
end

# ╔═╡ ee2a3676-4b8a-4244-948a-3429e67afd02
md"""
To remain within the region where the error introduced by the discretization scheme remains *small*, we need to *think* what would be a good number of steps and nodes to split our system. Thinking physically, we would not want the density $u$ to be transported by more than one node distance $\delta$ in a time step $\tau$, otherwise we would be *skipping* information transfer. Thus, there is some logic constraining $\delta\le{}c\tau$ to be respected here. We also have infinite gradients in the specified square wave of mass density, so space step should not be too small otherwise it would lead to a overflow error..., well, there are many other aspects to be considered, but we did not introduce them yet. So let's just assume that as a rule of thumb *both space and time discretization must be reasonably smaller than the integration domains*.

Below we assume this *reasonably small* criterium is 1/500 the size of the system and compute the required nodal distance and time step. Notice the `- 1` in the denominator, because the number of intervals between $k$ nodes is $k-1$. The computed values are displayed with their respective units.
"""

# ╔═╡ d92d5220-2f61-489a-834d-5173f1eea6b8
begin
    nₓ = 501;
    nₜ = 501;

    δ = L / (nₓ - 1);
    τ = T / (nₜ - 1);

    δ, τ
end

# ╔═╡ de024a53-df91-4289-bf31-d667a475fddf
function solve_advection!(step!, u₀, x, t, u, τ, δ, c)
    sol = u₀ * zeros(Float64, (nₜ, nₓ));

    for (k, _) in enumerate(t)
        sol[k, :] = copy(u);
        step!(u, τ, δ, c);
    end

    return display_results(x, sol)
end

# ╔═╡ 476433ff-8622-40f4-8a64-8bdc9c3b1854


# ╔═╡ 5bdb45d1-a04d-4d06-b97d-d35e870fd780
begin
    x = 0.0u"m":δ:L;
    t = 0.0u"s":τ:T;

    x, t
end

# ╔═╡ 7148fcff-66dc-438c-aa80-14af2780b9bd
md"""
## Advecção linear
"""

# ╔═╡ b1062cbd-f782-465b-97f3-51b213932422
begin
    u = make_peak(x, nₓ, u₀, xᵤ);
    solve_advection!(step_linear!, u₀, x, t, u, τ, δ, c)
end

# ╔═╡ 5934c86e-3b2e-4dfd-a189-c6b358fb096c
md"""
## Advecção não-linear
"""

# ╔═╡ c0fad725-e2b9-4d77-9a76-9bb010a88fcf
begin
    v = make_peak(x, nₓ, u₀, xᵤ);
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[compat]
Plots = "~1.38.16"
Unitful = "~1.14.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "acc1b6582e04c454e92e97d1b3bcb891cae41bde"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "be6ab11021cd29f0344d5c4357b163af05a48cba"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.21.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "4e88377ae7ebeaf29a047aa1ee40826e0b708a5d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.7.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "96d823b94ba8d187a6d8f0826e731195a74b90e9"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "738fec4d684a9a6ee9598a8bfee305b26831f28c"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.2"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "8b8a2fd4536ece6e554168c21860b6820a8a83db"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.7"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "19fad9cd9ae44847fe842558a744748084a722d1"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.7+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "2613d054b0e18a3dea99ca1594e9a3960e025da4"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.9.7"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "c3ce8e7420b3a6e071e0fe4745f5d4300e37b13f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.24"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1aa4b74f80b01c6bc2b89992b861b5f210e665b5"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.21+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "75ca67b2c6512ad2d0c767a7cfc55e75075f8bbc"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.16"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "7beb031cf8145577fbccacd94b8a8f4ce78428d3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "75ebe04c5bed70b91614d684259b661c9e6274a4"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "ba4aa36b2d5c98d6ed1f149da916b3ba46527b2b"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.14.0"

    [deps.Unitful.extensions]
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.7.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
