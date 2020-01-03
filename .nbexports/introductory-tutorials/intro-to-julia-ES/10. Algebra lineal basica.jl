# ------------------------------------------------------------------------------------------
# # Álgebra lineal básica en Julia
# Autor: Andreas Noack Jensen (MIT) (http://www.econ.ku.dk/phdstudent/noack/)
# (con edición de Jane Herriman)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Julia's syntax is very similar to other languages but there are some important
# differences. Define a matrix of random normal variates
# ------------------------------------------------------------------------------------------

A = rand(1:4,3,3)

# ------------------------------------------------------------------------------------------
# Definir un vector de unos
# ------------------------------------------------------------------------------------------

x = fill(1.0, (3))

# ------------------------------------------------------------------------------------------
# Notamos que $A$ tiene el tipo Array{Int64,2} pero $x$ tiene tipo Array{Int64,1}. Julia
# define los alias a Vector{Type}=Array{Type,1} y Matrix{Type}=Array{Type,2}.
#
# Muchas de las operaciones básicas son idénticas a otros lenguajes
#
# #### Multiplicación
# ------------------------------------------------------------------------------------------

b = A*x

# ------------------------------------------------------------------------------------------
# #### Traspuestas
# Como en otros lenguajes, `A'` es la transpuesta conjugada mientras que `A.'` es sólo la
# traspuesta
# ------------------------------------------------------------------------------------------

Asym = A + A'

# ------------------------------------------------------------------------------------------
# #### Multiplicación traspuesta
# Julia nos permite escribir esto sin *
# ------------------------------------------------------------------------------------------

Apd = A'A

# ------------------------------------------------------------------------------------------
# #### Resolviendo sistemas lineales
# El problema $Ax=b$ para $A$ cuadrada se resulve con la función \.
# ------------------------------------------------------------------------------------------

A\b

# ------------------------------------------------------------------------------------------
# #### Sistemas sobredeterminados
# Cuando nuestra matriz es alta (número de renglones mayores al número de columnas), tenemos
# un sistema lineal sobredeterminado.
#
#
# En este caso \ calcula la de mínimos cuadrados
# ------------------------------------------------------------------------------------------

Atall = rand(3, 2)
display(Atall)
Atall\b

# ------------------------------------------------------------------------------------------
# La función \ también sirve ocn problemas deficientes de rango de mínimos cuadrados. En
# este caso, la solución no es única y Julia regresa el valor con la menor norma.
#
# Para crear un problema de rango deficiente de mínimos cuadrados, vamos a crear una matriz
# deficiente en rango con columnas linealmente dependientes
# ------------------------------------------------------------------------------------------

v = randn(3)
rankdef = [v v]

rankdef\b

# ------------------------------------------------------------------------------------------
# #### Sistemas indeterminados
# cuando A es corta (número de columnas mayor al número de renglones), tenemos un sistema
# indeterminado
#
# En este caso \ regresa la solución con la norma mínima
# ------------------------------------------------------------------------------------------

Ashort = rand(2, 3)
display(Ashort)
Ashort\b[1:2]

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
#
#
# ```
# A = [
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  1  2  3  4  5  6  7  8  9  10
#  ]
# ```
#
# Quieres obtener
#
# ```
# A = [
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  7  8  9  10  1  2  3  4  5  6
#  ]
# ```
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 10.2 Toma el producto de un vector `v` con sí mismo.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 10.3 Toma el producto de un vector `v` con sí mismo.
# ------------------------------------------------------------------------------------------


