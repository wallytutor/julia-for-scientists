# Julia para Cientistas

Julia *from zero to hero* com uma abordagem para computação científica.

## Antes de começar

1. Ler [este anexo](tutorials/a01-colaboracao-cientifica.jl) para se
    familiarizar com alguns elementos que vamos abordar no que se segue.

1. [Instalar Julia](https://julialang.org/downloads/) na versão
    estável para seu sistema operacional.

1. [Instalar Pluto](https://github.com/fonsp/Pluto.jl) para
    visualizar e editar os notebooks do curso.

1. Clonar este repositório com todos os materiais usando a seguinte
    ordem de prioridade:

    - Usando a linha de comando `git clone https://github.com/wallytutor/julia-for-scientists.git`
    - Com a interface gráfica de [GitHub Desktop](https://desktop.github.com/)
    - Usando o botão de [Download](https://github.com/wallytutor/julia-for-scientists/archive/refs/heads/main.zip)

**Importante:** caso a última opção de download tenha sido a sua escolha, observe
que o arquivo `.zip` não contem os elementos de *repositório git* para controle de
versão, implicando que as suas modificações e notas tomadas deverão ser geridas
localmente, o que não é recomendável. Para estudantes ainda não familiarizados com
*git*, a opção de utilizar GitHub Desktop é a mais apropriada.

## Como seguir os materiais

- Os conteúdos são majoritariamente sequenciais: exceto para os tópicos mais
    avançados (para aqueles que já programam em Julia), é necessário seguir
    os notebooks na ordem provida.

- Um canal YouTube do curso está em fase de concepção para abordar os detalhes
    entre-linhas, involvendo aspectos que não necessariamente estão escritos.

## Conteúdos

Abaixo você encontra a lista de conteúdos disponíveis e planejados.
Na lista com indentação principal econtram-se os conteúdos deste
repositório, os quais se manifestam com um link em *itálico* para os
arquivos caso já disponíveis. As sub-listas de cada tópico apresentam
links externos que julgo interessante para ir mais longe no aprendizado
ou simplesmente que foram utilizados como referências para os conteúdos
aqui resumidos.

- [*Preâmbulo e Pluto*](tutorials/000-preambulo-e-pluto.jl)
- [*Primeiros passos*](tutorials/001-primeiros-passos.jl)
- [*Manipulação textual*](tutorials/002-manipulacao-textual.jl)
- [*Estruturas de dados I*](tutorials/003-estruturas-de-dados.jl)
- [*Estruturas de dados II*](tutorials/004-estruturas-de-dados.jl)
- [Laços e conditionais](tutorials/005-lacos-e-condicionais.jl)
- [Funções e despacho múltiplo](tutorials/006-funcoes-e-despacho.jl)
- [Pacotes e ecossistema](tutorials/007-pacotes-e-ecossistema.jl)
- [Avaliando performance](tutorials/008-avaliando-performance.jl)
- [Álgebra linear](tutorials/009-algebra-linear.jl)
- [Expressões regulares](tutorials/010-expressoes-regulares.jl)
- [Execução concorrente](tutorials/011-execucao-concorrente.jl)
- [Trabalhando com arquivos](tutorials/012-trabalhando-com-arquivos.jl)
- [Bibliotecas gráficas](tutorials/013-bibliotecas-graficas.jl)
- [Gráficos para publicações](tutorials/014-graficos-para-publicacoes.jl)
- [Tipos de dados e estruturas](tutorials/015-tipos-de-dados-e-estruturas.jl)
- [Metaprogramação e macros](tutorials/016-metaprogramacao-e-macros.jl)
  - [Workshop - JuliaCon 2021](https://www.youtube.com/watch?v=2QLhw6LVaq0&t=3275s)
- [Interoperação com C](tutorials/017-interoperacao-com-c.jl)
- Equações diferenciais ordinárias
- Equações diferenciais parciais
- Redes neuronais clássicas
- Aprendizado com suporte físico
- Análise quantitativa de imagens
- Criando seus próprios pacotes
- ...

## Para aonde ir depois?

- [Julia Academy](https://juliaacademy.com/): nesta página encontram-se cursos
    abertos em várias temáticas comumente abordadas com a linguagem Julia. Você
    encontrará cursos parcialmente equivalentes aos materiais tratados aqui, mas
    também vários conteúdos que não são abordados nesta introdução, especialmente
    em tópicos ligados a Ciência de Dados.

- [Introduction to Computational Thinking](https://computationalthinking.mit.edu/Fall23/):
    esse é provavelmente o melhor curso generalista para aplicações científicas
    da linguagem. O curso é ministrado inclusive pelo [Pr. Dr. Alan Edelman](https://en.wikipedia.org/wiki/Alan_Edelman)
    um dos criadores de Julia. Os tópicos abordados vão de tratamento de imagens,
    séries temporais, a resolução de equações diferenciais parciais.

- [*SciML Book*](https://book.sciml.ai/): este livro é o resultado dos materiais
    de suporte do curso *Parallel Computing and Scientific Machine Learning
    (SciML): Methods and Applications* no MIT. Os tópicos são suportados por
    vídeo aulas e entram em mais profundidade nos assuntos avançados que tratamos
    aqui.

- [Exercism Julia Track](https://exercism.org/tracks/julia): a plataforma
    *Exercism* propõe no percurso de Julia vários exercícios de algoritmos de
    nível fácil à intermediário-avançado. Minha recomendação é que essa prática
    venha a complementar os materiais propostos acima como forma de sedimentar
    o aprendizado da linguagem.

- [Julia Community Zulipchat](https://julialang.zulipchat.com/): precisando de
    ajuda ou buscando um projeto para contribuir? Este chat aberto da comunidade
    Julia é o ponto de encontro para discutir acerca dos diferenter projetos
    e avanços na linguagem.

- [Julia Packages](https://juliapackages.com/): o repositório mestre do índice
    de pacotes escritos na linguagem Julia ou provendo interfaces à outras
    ferramentas. A página contém um sistema de busca e um índice por temas.

- [JuliaHub](https://juliahub.com/): esta plataforma comercial provê tudo que
    é necessário para se passar da prototipagem à escala industrial de soluções
    concebidas em Julia. Atualmente é a norma em termos de escalabilidade para
    a linguagem.
