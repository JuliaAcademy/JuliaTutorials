# ------------------------------------------------------------------------------------------
# # Paquetes
#
# Julia tiene màs de 1686 paquetes registrados, conformando una gran parte del ecosistema de
# Julia.
#
# Para ver todos los paquetes, visita
#
# https://pkg.julialang.org/
#
# o bien
#
# https://juliaobserver.com/
#
# Ahora vamos a aprender a usarlos
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# La primera vez que quieres usar un paquete en Julia, hay que agregarlo
# ------------------------------------------------------------------------------------------

#Pkg.add("Example")

# ------------------------------------------------------------------------------------------
# Cada vez que usas Julia (empezar una nueva sesión en el REPL, abrir un notebook por
# primera vez, por ejemplo), tienes que cargar el paquete usando la palabra reservada
# `using`
# ------------------------------------------------------------------------------------------

using Example

# ------------------------------------------------------------------------------------------
# En el código fuente de  `Example.jl` en
#
# https://github.com/JuliaLang/Example.jl/blob/master/src/Example.jl
#
# Vemos una función declarada como
#
# ```
# hello(who::String) = "Hello, $who"
# ```
#
# Si cargamos `Example`, debemos poder llamar `hello`
# ------------------------------------------------------------------------------------------

hello("it's me. I was wondering if after all these years you'd like to meet.")

# ------------------------------------------------------------------------------------------
# Ahora vamos a jugar con el paquete de Colors
# ------------------------------------------------------------------------------------------

#Pkg.add("Colors")

using Colors

# ------------------------------------------------------------------------------------------
# Creemos una bandeja de 100 colores
# ------------------------------------------------------------------------------------------

bandeja = distinguishable_colors(100)

# ------------------------------------------------------------------------------------------
# y podemos crear una matriz colorida aleatoriamente con rand
# ------------------------------------------------------------------------------------------

rand(bandeja, 3, 3)

# ------------------------------------------------------------------------------------------
# En el próximo notebook, vamos a usar un nuevo paquete para graficar datos
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 7.1 Usa el paquete de  (código fuente en https://github.com/JuliaMath/Primes.jl) para
# encontrar el número primer más grande menor a 1,000,000
# ------------------------------------------------------------------------------------------


