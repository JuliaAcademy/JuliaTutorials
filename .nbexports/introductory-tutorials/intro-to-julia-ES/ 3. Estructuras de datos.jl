# ------------------------------------------------------------------------------------------
# # Estructuras de datos
#
# Una vez que empecemos a trabajar con muchos datos a la vez, será conveniente guardar
# nuestros datos en estructuras como arreglos o diccionarios (más allá que sólo
# variables).<br>
#
# Tipos de estructuras de datos que cubrimos
# 1. Tuplas
# 2. Diccionarios
# 3. Arreglos
#
# <br>
# Como repaso, las tuplas y los arreglos ambos son secuencias ordenadas de elementos
# (entonces podemos accesarlos por medio de un índice).
# Los diccionarios y los arreglos son mutables.
#
# ¡Explicaremos más brevemente!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Tuplas / Tuples
#
# Podemos crear una tupla encerrando una secuencia ordenada de elementos con `( )`.
#
# Sintaxis: <br>
# ```julia
# (item1, item2, ...)```
# ------------------------------------------------------------------------------------------

mis_animales_favoritos = ("pingüino", "gato", "petauro_del_azúcar")

# ------------------------------------------------------------------------------------------
# Podemos accesar con el índice a esta tupla,
# ------------------------------------------------------------------------------------------

myfavoriteanimals[1]

# ------------------------------------------------------------------------------------------
# Pero como las tuplas con inmutables, no la podemos modificar
# ------------------------------------------------------------------------------------------

mis_animales_favoritos[1] = "nutria"

# ------------------------------------------------------------------------------------------
# ## Diccionarios
#
# Si tenemos conjuntos de datos relacionados entre sí, podemos guardar los datos en un
# diccionario. Un buen ejemplo es una lista de contactos, donde asociamos nombres a números
# de teléfono.
#
# Sintaxis:
# ```julia
# Dict(llave1 => valor1, llave2 => valor2, ....)```
# ------------------------------------------------------------------------------------------

miagenda = Dict("Jenny" => "867-5309", "Cazafantasmas" => "555-2368")

# ------------------------------------------------------------------------------------------
# En este ejemplo, cada nombre y número es un par de "llave" y "valor". Podemos tomar el
# númer de Jenny (un valor) usando la llave asociada.
# ------------------------------------------------------------------------------------------

miagenda["Jenny"]

# ------------------------------------------------------------------------------------------
# Podemos agregar otra entrada al diccionario de la manera siguiente
# ------------------------------------------------------------------------------------------

miagenda["Kramer"] = "555-FILK"

# ------------------------------------------------------------------------------------------
# Veamos como se ve nuestro diccionario ahora...
# ------------------------------------------------------------------------------------------

miagenda

# ------------------------------------------------------------------------------------------
# Para borrar a Kramer de nuestro diccionario - y simultáneamente tomar su número - usamos
# pop!
# ------------------------------------------------------------------------------------------

pop!(miagenda, "Kramer")

miagenda

# ------------------------------------------------------------------------------------------
# A diferencia de las tuplas y los arreglos, los diccionarios no están ordenados y no
# podemos accesarlos con un índice
# ------------------------------------------------------------------------------------------

miagenda[1]

# ------------------------------------------------------------------------------------------
# En el ejemplo anterior, `julia` piensa que estás tratando de accesar a un valor asociado a
# la llave `1`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Arreglos
#
# A diferencia de las tuplas, los arreglos son mutables. A diferencia de los diccionarios,
# los arreglos contienen secuencias ordenadas de elementos. <br>
# Podemos crear un arreglo encapsulando esta secuencia de elementos con `[ ]`.
#
# Sintaxis: <br>
# ```julia
# [item1, item2, ...]```
#
#
# Por ejemplo, podemos usar un arreglo para recordar a mis amigos
# ------------------------------------------------------------------------------------------

myfriends = ["Ted", "Robyn", "Barney", "Lily", "Marshall"]

# ------------------------------------------------------------------------------------------
# O guardar una secuencia de números
# ------------------------------------------------------------------------------------------

fibonacci = [1, 1, 2, 3, 5, 8, 13]

mezcla = [1, 1, 2, 3, "Ted", "Robyn"]

# ------------------------------------------------------------------------------------------
# Una vez que tenenmos un arreglo, podemos tomar los datos individualmente dentro del
# arreglo accesándolos por su índice. Por ejemplo, si queremos al tercer amigo en myfriends,
# escribimos
# ------------------------------------------------------------------------------------------

myfriends[3]

# ------------------------------------------------------------------------------------------
# Podemos usar el índice para mutar la entrada del arreglo
# ------------------------------------------------------------------------------------------

myfriends[3] = "Baby Bop"

# ------------------------------------------------------------------------------------------
# También se puede editar con las fuciones de `push!` y `pop!`. `push!` agrega un elemento
# al final del arreglo y `pop!` quita al último elemento del arreglo.
#
# Podemos agregar otro número a la secuencia fibonacci
# ------------------------------------------------------------------------------------------

push!(fibonacci, 21)

# ------------------------------------------------------------------------------------------
# y quitarlo
# ------------------------------------------------------------------------------------------

pop!(fibonacci)

fibonacci

# ------------------------------------------------------------------------------------------
# Hasta ahora hemos dado ejemplos de arreglos de escalars unidimensionales, pero los
# arreglos pueden tener un número arbitrario de dimensiones y también pueden guardar otros
# arreglos.
# <br><br>
# Por ejemplo, estos son arreglos de arreglos
# ------------------------------------------------------------------------------------------

favoritos = [["koobideh", "chocolate", "eggs"],["penguins", "cats", "sugargliders"]]

numbers = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]

# ------------------------------------------------------------------------------------------
# Abajo hay arreglos de 2D y 3D poblados con valores aleatorios
# ------------------------------------------------------------------------------------------

rand(4, 3)

rand(4, 3, 2)

# ------------------------------------------------------------------------------------------
# ¡Cuidado copiando los arreglos!
# ------------------------------------------------------------------------------------------

fibonacci

somenumbers = fibonacci

somenumbers[1] = 404

fibonacci

# ------------------------------------------------------------------------------------------
# Editar `somenumbers` causa que `fibonacci` se edite también!
#
# En el ejemplo superior, en realidad no hicimos una copia de `fibonacci`. Sólo creamos una
# nueva manera de accesar las entradas del arreglo relacionado a `fibonacci`.
#
# Si queremos hacer una copia de un arreglo amarrado a `fibonacci`, usamos la función de
# `copy`.
# ------------------------------------------------------------------------------------------

# Primero restauramos a fibonnaci
fibonacci[1] = 1
fibonacci

somemorenumbers = copy(fibonacci)

somemorenumbers[1] = 404

fibonacci

# ------------------------------------------------------------------------------------------
# En el último ejemplo, no se editó a fibonacci. Entonces vemos que los arreglos amarrados a
# `somemorenumbers` y `fibonacci` son distintos.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# 3.1 Crea un arreglo, `arreglo`, que sea un arreglo de 1D de 2-elementos de 1-elemento de
# 1D, cada uno guardando el número 0.
# Accesa a `arreglo` para agregar un `1` a cada uno de los arreglos que contiene.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 3.2 Trata de agregar "Emergencia" a `miagenda` con el valor `911`. Trata de agregar `911`
# como un entero y no como cadena. ¿Porqué no funciona?
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 3.3 Crea un nuevo diccionario que se llame `agenda_flexible` que tenga el número de Jenny
# guardado como cadena y el de los Cazafantasmas como entero.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 3.4 Agrega la llave de "Emergencia al valor (entero) `911` a `agenda_flexible`.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 3.5 ¿Porqué podemos agregar un entero como valor a `agenda_flexible` pero no a
# `miagenda`? ¿Cómo pudimos haber inicializado `miagenda` para que aceptara enteros como
# valores?
# ------------------------------------------------------------------------------------------


