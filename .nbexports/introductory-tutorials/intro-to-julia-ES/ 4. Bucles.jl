# ------------------------------------------------------------------------------------------
# # Bucles
#
# Temas:
# 1. bucles `while`
# 2. bucles `for`
# <br>
#
# ## bucles while
#
# La sintaxis para un `while` es
#
# ```julia
# while *condición*
#     *cuerpo de bucle*
# end
# ```
#
# Por ejemplo, usaremos un `while` para contar o iterar sobre un arreglo.
# ------------------------------------------------------------------------------------------

n = 0
while n < 10
    n += 1
    println(n)
end

myfriends = ["Ted", "Robyn", "Barney", "Lily", "Marshall"]

i = 1
while i <= length(myfriends)
    friend = myfriends[i]
    println("Hola $friend, ¡gusto en verte!")
    i += 1
end

# ------------------------------------------------------------------------------------------
# ## bucles for
#
# La sintaxis para un bucle `for` es
#
# ```julia
# for *var* in *iterable de bucle*
#     *cuerpo de bucle*
# end
# ```
#
# Podemos usar un bucle for para generar los datos anteriores
# ------------------------------------------------------------------------------------------

for n in 1:10
    println(n)
end

myfriends = ["Ted", "Robyn", "Barney", "Lily", "Marshall"]

for friend in myfriends
    println("Hi $friend, it's great to see you!")
end

# ------------------------------------------------------------------------------------------
# Nota: se puede reemplazar `in` con `=` ó `∈`.
# ------------------------------------------------------------------------------------------

for n = 1:10
    println(n)
end

for n ∈ 1:10
    println(n)
end

# ------------------------------------------------------------------------------------------
# Ahora usemos bucles `for` para crear tablas de sumas donde el valor de cada entrada es la
# suma de los índices del renglón y la columna. <br>
#
# Primero, inicializamos el arreglo con puros 0s.
# ------------------------------------------------------------------------------------------

m, n = 5, 5
A = fill(0, (m, n))

for i in 1:m
    for j in 1:n
        A[i, j] = i + j
    end
end
A

# ------------------------------------------------------------------------------------------
# Aquí va un poquito de azúcar sintáctica para el bucle `for`
# ------------------------------------------------------------------------------------------

B = fill(0, (m, n))

for i in 1:m, j in 1:n
    B[i, j] = i + j
end
B

# ------------------------------------------------------------------------------------------
# La manera mas "Juliana" de crear esta tabla es por medio de un *array comprehension /
# comprehensión de arreglo*.
# ------------------------------------------------------------------------------------------

C = [i + j for i in 1:m, j in 1:n]

# ------------------------------------------------------------------------------------------
# En el próximo ejemplo, embebimos un arreglo de comprehensión en un bucle `for`, generando
# tablas de adición de tamaño creciente.
# ------------------------------------------------------------------------------------------

for n in 1:10
   A = [i + j for i in 1:n, j in 1:n]
   display(A)
end

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 4.1 Crea un diccionario `squares`, que tiene llaves de valores de 1 a 100. El valor
# asociado a cada llave es el cuadrado de la llave. Guarda los valores asociados a las
# llaves pares como enteros y las impares como cadenas. Por ejemplo,
#
# ```julia
# squares[10] == 100
# squares[11] == "121"
# ```
#
# (¡No necesitas condicionales para esto!)
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 4.2 Usa `fill` para crea una matriz de `10x10` de solo `0`'s. Pobla las primeras 10
# entradas con el índice de esa entrada. ¿Julia usa el orden de primero columna o primero
# renglón? (O sea, ¿el "segundo" elemento es el de la primera columna en el primer renglón,
# ó es el de el primer renglón en la segunda columna?)
# ------------------------------------------------------------------------------------------


