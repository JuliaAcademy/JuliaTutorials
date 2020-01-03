# ------------------------------------------------------------------------------------------
# # Funciones
#
# Temas:
# 1. Cómo declara una función
# 2. Duck-typing en Julia
# 3. Funciones mutantes vs. no-mutantes
# 4. Broadcasting
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Cómo declarar una función
# Julia nos permite definir una función de varias maneras. La primera requiere de las
# palabras reservadas `function` y `end`
# ------------------------------------------------------------------------------------------

function sayhi(name)
    println("Hi $name, it's great to see you!")
end

function f(x)
    x^2
end

# ------------------------------------------------------------------------------------------
# Y las podemos llamar así
# ------------------------------------------------------------------------------------------

sayhi("C-3PO")

f(42)

# ------------------------------------------------------------------------------------------
# Alternativamente, las podemos declarar en una sóla línea
# ------------------------------------------------------------------------------------------

sayhi2(name) = println("Hi $name, it's great to see you!")

f2(x) = x^2

sayhi2("R2D2")

f2(42)

# ------------------------------------------------------------------------------------------
# Finalmente, pudimos declararlas como funciones "anónimas"
# ------------------------------------------------------------------------------------------

sayhi3 = name -> println("Hi $name, it's great to see you!")

f3 = x -> x^2

sayhi3("Chewbacca")

f3(42)

# ------------------------------------------------------------------------------------------
# ## Duck-typing en Julia
# *"If it quacks like a duck, it's a duck."*
# *"Si suena como pato, es un pato"*
# <br><br>
# En Julia, las funciones operaran con el cualquier valor que haga sentido. <br><br>
# Por ejemplo, `sayhi` funciona con el nombre de este personaje de tele, escrito como
# entero...
# ------------------------------------------------------------------------------------------

sayhi(55595472)

# ------------------------------------------------------------------------------------------
# Y `f` va a funcionar en una matriz.
# ------------------------------------------------------------------------------------------

A = rand(3, 3)
A

f(A)

# ------------------------------------------------------------------------------------------
# `f` funcionará con "hi" porque `*` para inputs de cadenas como concatenación.
# ------------------------------------------------------------------------------------------

f("hi")

# ------------------------------------------------------------------------------------------
# Por el otro lado, `f` no funcionará sobre un vector. A diferencia de `A^2`, la cual es una
# operación bien definida, el signifiado de `v^2` para un vector, `v`, es ambigua.
# ------------------------------------------------------------------------------------------

v = rand(3)

f(v)

# ------------------------------------------------------------------------------------------
# ## Funciones mutantes vs no-mutantes
#
# Por convención, funciones seguidas por un `!` alteran, o bien mutan, sus contenidos y las
# que carecen de un `!` no lo hacen.
#
# Por ejemplo, `sort` y `sort!`.
# 
# ------------------------------------------------------------------------------------------

v = [3, 5, 2]

sort(v)

v

# ------------------------------------------------------------------------------------------
# `sort(v)` regresa el arreglo ordenado de `v`, pero `v` no cambia. <br><br>
#
# Por otro lado, si corremos `sort!(v)`, el contenido del arreglo es ordenado dentro de `v`.
# ------------------------------------------------------------------------------------------

sort!(v)

v

# ------------------------------------------------------------------------------------------
# ## Broadcasting
#
# Si ponemos `.` entre el nombre de la funcion y su lista de argumento,<br>
# le estamos diciendo a la función que se "difunda"/haga broadcasting sobre los elementos
# del input. <br>
#
# Primero veamos la diferencia entre `f()` y `f.()`.<br>
#
# Primero definimos una nueva matriz `A` que hará la diferencia fácil de observar
# ------------------------------------------------------------------------------------------

A = [i + 3*j for j in 0:2, i in 1:3]

f(A)

# ------------------------------------------------------------------------------------------
# Cómo se vio antes, para una matriz, `A`,
# ```
# f(A) = A^2 = A * A
# ```
#
# `f.(A)` por el otro lado va a regresar un objeto que contiene el cuadrado de `A[i, j]` en
# su entrada correspondiente.
# ------------------------------------------------------------------------------------------

B = f.(A)

A[2, 2]

A[2, 2]^2

B[2, 2]

# ------------------------------------------------------------------------------------------
# Esto significa que para `v`, `f.(v)` está definido, pero no para `f(v)` :
# ------------------------------------------------------------------------------------------

v = [1, 2, 3]

f.(v)

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 6.1 En vez de broadcastear `f` sobre `v`,  pudimos haber hecho `v .^ 2`.
#
# Sin declarar una nueva funcion, agrega 1 a cada elemento de una matriz de `3x3` llena de
# `0`'s.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 6.3 Una cifra de César recorre cada letra un número determinado de plazas más adelante en
# el abecedario. Un corrimiento, o shift, de 1 manda "A" a "B". Escribe una función llamada
# `cesar` que toma una cadena como input y un corrimiento y regresa una cadena desencriptada
# tal que obtengas
#
# ```julia
# cesar("abc", 1)
# "bcd"
#
# cesar("hello", 4)
# "lipps"
# ```
# ------------------------------------------------------------------------------------------


