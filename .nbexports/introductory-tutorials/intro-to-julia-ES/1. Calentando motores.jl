# ------------------------------------------------------------------------------------------
# # Empezando
#
# Temas:
# 1. Cómo conseguir documentación
# 2. Cómo imprimir a pantalla
# 3. Cómo asignar variables
# 4. Cómo poner comentarios
# 5. Sintáxis para matemáticas básicas
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Cómo conseguir documentación para funciones de Julia
#
# Para conseguir docs para funciones con las que uno no está familiarizado, pon un signo de
# interrogación antes. (¡También funciona en la terminal!)
# ------------------------------------------------------------------------------------------

?println

# ------------------------------------------------------------------------------------------
# ## Cómo imprimir
#
# En Julia usamos `println()` para imprimir texto a la pantalla.
# ------------------------------------------------------------------------------------------

println("¡Estoy emocionado por aprender Julia!")

# ------------------------------------------------------------------------------------------
# Si es tu primera vez usando los notebooks, toma nota que la última línea de cada casilla
# es la que imprime cuando ejecutas la casilla.
# ------------------------------------------------------------------------------------------

123
456

# ------------------------------------------------------------------------------------------
# ## Cómo asignar variables
#
# ¡Sólo necesitas un nombre y un signo de igualdad!<br>
# Julia se encargará de saber el tipo de los datos por nosotros.
# ------------------------------------------------------------------------------------------

my_answer = 42
typeof(my_answer)

my_pi = 3.14159
typeof(my_pi)

my_name = "Jane"
typeof(my_name)

# ------------------------------------------------------------------------------------------
# Después de asignar un valor a una variable, podemos reasignar un valor de un tipo
# diferente a esa variable sin ningún problema.
# ------------------------------------------------------------------------------------------

my_answer = my_name

typeof(my_answer)

# ------------------------------------------------------------------------------------------
# ## Cómo comentar
# ------------------------------------------------------------------------------------------

# Puedes dejar un comentario en una sola línea usando la tecla de gato

#=

Para comentarios de varias lineas,
usa la secuencia de '#= =#' .

=#

# ------------------------------------------------------------------------------------------
# ## Sintáxis para matemáticas básicas
# ------------------------------------------------------------------------------------------

suma = 3 + 7

resta = 10 - 3

producto = 20 * 5

cociente = 100 / 10

potencia = 10 ^ 2

módulo = 101 % 2

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 1.1 Busca los docs para las funciones `convert` y `parse`.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 1.2 Asigna `365` a una variable llamada `days`. Convierte `days` a un número flotante.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 1.3 Fíjate que sucede cuando ejecutas
#
# ```julia
# convert(Int64, '1')
# ```
# y
#
# ```julia
# parse(Int64, '1')
# ```
#
# ¿Cuál es la diferencia?
# ------------------------------------------------------------------------------------------


