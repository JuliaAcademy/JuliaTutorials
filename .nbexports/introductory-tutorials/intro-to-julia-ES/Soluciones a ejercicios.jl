# ------------------------------------------------------------------------------------------
# ### Notebook 1
# #### 1.1
# Buscar `convert` y `parse` en la documentación.
# ------------------------------------------------------------------------------------------

?convert;
# ?parse

# ------------------------------------------------------------------------------------------
# #### 1.2
# Asignar `365` a una variable llamada `days`. Convierte `days` a flotante.
# ------------------------------------------------------------------------------------------

days = 365
convert(Float64, days)

# ------------------------------------------------------------------------------------------
# #### 1.3
# Ver que sucede ejectuando
#
# ```julia
# convert(Int64, '1')
# ```
# and
#
# ```julia
# parse(Int64, '1')
# ```
# ------------------------------------------------------------------------------------------

# Esto regresa el código ascii (un entero) asociado con el caracter '1'
convert(Int64, '1')

# Esto regresa un entero encapsulado entre comillas
parse(Int64, '1')

# ------------------------------------------------------------------------------------------
# ### Notebook 2
# #### 2.1
# Crea una cadena que dice "hola" 1000 veces
# ------------------------------------------------------------------------------------------

"hola"^1000

# ------------------------------------------------------------------------------------------
# #### 2.2
# Agrega dos números dentro de una cadena
# ------------------------------------------------------------------------------------------

m, n = 1, 1
"$m + $n = $(m + n)"

# ------------------------------------------------------------------------------------------
# ### Notebook 3
#
# #### 3.1
# Crea un arreglo, `arreglo`, que es un arreglo en 1D de 2 elementos, cada uno conteniendo
# el número 0.
# Agrega a `arreglo` para agregar un segundo número, `1`, a cada arreglo.
# ------------------------------------------------------------------------------------------

a_ray = [[0], [0]]
push!(a_ray[1], 1)
push!(a_ray[2], 1)
a_ray

# ------------------------------------------------------------------------------------------
# ### 3.2
# Trata de agregar "Emergencia" a `miagenda` con el valor `911`. Trata de agregar `911` como
# un entero y no como cadena. ¿Porqué no funciona?
# ------------------------------------------------------------------------------------------

miagenda = Dict("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

miagenda["Emergency"] = 911
#= 

Julia infiere que "miagenda" toma ambos llaves
y valores del tipo "String". Podemos ver que miagenda
es un Dict{String,String} con 2 entradas. Esto significa que
Julia no va a aceptar enteros como valores en miagenda.

=#

# ------------------------------------------------------------------------------------------
# #### 3.3
# Crea un nuevo diccionario que se llame `agenda_flexible` que tenga el número de Jenny
# guardado como cadena y el de los Cazafantasmas como entero.
# ------------------------------------------------------------------------------------------

agenda_flexible = Dict("Jenny" => "867-5309", "Ghostbusters" => 5552368)

# ------------------------------------------------------------------------------------------
# #### 3.4
# Add the key "Emergency" with the value `911` (an integer) to `flexible_phonebook`.
# ------------------------------------------------------------------------------------------

flexible_phonebook["Emergency"] = 911

# ------------------------------------------------------------------------------------------
# ##### 3.5
# 3.5 ¿Porqué podemos agregar un entero como valor a `agenda_flexible` pero no a
# `miagenda`? ¿Cómo pudimos haber inicializado `miagenda` para que aceptara enteros como
# valores?
# ------------------------------------------------------------------------------------------

#= 

Julia infiere que miagenda_flexible toma valores del tipo
Any. A diferencia de miagenda, miagenda_flexible es un
Dict{String,Any} con 2 entradas.

Para evitar esto, podemos inicializar miagenda a un
diccionario vacío y agregamos entradas después. O podemos
decirle a Julia explícitamente que queremos un diccionario
que acepte objectos del tipo Any como valores.

¡Ve los ejemplos!

=#

miagenda = Dict()

miagenda = Dict{String, Any}("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

# ------------------------------------------------------------------------------------------
# ### Notebook 4
#
# #### 4.1
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

squares = Dict()
iterable = range(1, 2, 50)
#  Otra opción 
# iterable = 1:2:99
for key in iterable
    squares[key] = "$(key^2)"
    squares[key + 1] = (key + 1)^2
end

@show squares[10]
@show squares[11]

# ------------------------------------------------------------------------------------------
# #### 4.2
#
# 4.2 Usa `fill` para crea una matriz de `10x10` de solo `0`'s. Pobla las primeras 10
# entradas con el índice de esa entrada. ¿Julia usa el orden de primero columna o primero
# renglón? (O sea, ¿el "segundo" elemento es el de la primera columna en el primer renglón,
# ó es el de el primer renglón en la segunda columna?)
# ------------------------------------------------------------------------------------------

A = fill(0, (10, 10))
for i in 1:10
    A[i] = i
end
A
# ¡Julia usa order columnar! Los primeros 10 elementos van a poblar la primera columna.

# ------------------------------------------------------------------------------------------
# ### Notebook 5
#
# #### 5.1
#
# 5.1 Reescribe FizzBuzz sin usar `elseif`.
# ------------------------------------------------------------------------------------------

N = 16
if (N % 3 == 0) & (N % 5 == 0)
    println("FizzBuzz")
else
    if (N % 3 == 0)
        println("Fizz")
    else
        if (N % 5 == 0)
            println("Buzz")
        else
            println(N)
        end
    end
end

# ------------------------------------------------------------------------------------------
# #### 5.2
#
# Reescribe FizzBuzz usando el operador ternario.
# ------------------------------------------------------------------------------------------

((N % 3 == 0) & (N % 5 == 0)) ? println("FizzBuzz") : ((N % 3 == 0) ? println("Fizz") : ((N % 5 == 0) ? println("Buzz") : println(N)))

# ------------------------------------------------------------------------------------------
# ### Notebook 6
#
# #### 6.1
#
# 6.1 En vez de broadcastear `f` sobre `v`,  pudimos haber hecho `v .^ 2`.
#
# Sin declarar una nueva funcion, agrega 1 a cada elemento de una matriz de `3x3` llena de
# `0`'s.
# ------------------------------------------------------------------------------------------

fill(0, (3, 3)) .+ 1

# ------------------------------------------------------------------------------------------
# #### 6.2
#
# 6.2 En vez de broadcastear `f` sobre el vector `v` con la sintaxis de punto, aplica `f` a
# todos los elementos de`v` usando `map` como función.
# ------------------------------------------------------------------------------------------

f(x) = x^2
v = [1, 2, 3]
map(f, v)

# ------------------------------------------------------------------------------------------
# #### 6.3
#
# Una cifra de César recorre cada letra un número determinado de plazas más adelante en el
# abecedario. Un corrimiento, o shift, de 1 manda "A" a "B". Escribe una función llamada
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

caesar(input_string, shift) = map(x -> x + shift, input_string)

# ------------------------------------------------------------------------------------------
# ### Notebook 7
#
# #### 7.1
#
# 7.1 Usa el paquete de  (código fuente en https://github.com/JuliaMath/Primes.jl) para
# encontrar el número primer más grande menor a 1,000,000
# ------------------------------------------------------------------------------------------

#Pkg.add("Primes")
using Primes
maximum(primes(1000000))

# ------------------------------------------------------------------------------------------
# ### Notebook 8
#
# #### 8.1
#
# 8.1 Grafica y vs x para `y = x^2` usando el backend de PyPlot.
# ------------------------------------------------------------------------------------------

using Plots
pyplot()
x = 1:10
y = x .^ 2
plot(x, y)

# ------------------------------------------------------------------------------------------
# ### Notebook 9
#
# #### 9.1
#
# Agrega un método para `+` que aplique un cifrado de César a una cadena (cómo en el
# notebook 6) tal que
#
# ```julia
# "hello" + 4 == "lipps"
# ```
# ------------------------------------------------------------------------------------------

import Base: +
+(x::String, y::Int) = map(x -> x + y, x)

# ------------------------------------------------------------------------------------------
# #### 9.2
#
# Checa que has extendido propiamente `+` recorriendo la próxima cadena para atrás por 3
# letras:
#
# "Gr#qrw#phggoh#lq#wkh#diidluv#ri#gudjrqv#iru#|rx#duh#fuxqfk|#dqg#wdvwh#jrrg#zlwk#nhwfkxs1"
# ------------------------------------------------------------------------------------------

"Gr#qrw#phggoh#lq#wkh#diidluv#ri#gudjrqv#iru#|rx#duh#fuxqfk|#dqg#wdvwh#jrrg#zlwk#nhwfkxs1" + -3

# ------------------------------------------------------------------------------------------
# ### Notebook 10
#
# #### 10.1
#
# 10.1 Usa `circshift` para obtener una matriz con las columnas de A cíclicamente recorridas
# a la derecha por 3 columnas.
#
# Empezando con
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

circshift(A, (0, 4))

# ------------------------------------------------------------------------------------------
# #### 10.2
#
# 10.2 Toma el producto de un vector `v` con sí mismo.
# ------------------------------------------------------------------------------------------

v = [1, 2, 3]
v * v'

# ------------------------------------------------------------------------------------------
# #### 10.3
# 10.3 Toma el producto de un vector `v` con sí mismo.
# ------------------------------------------------------------------------------------------

v' * v

# ------------------------------------------------------------------------------------------
# ### Notebook 11
#
# #### 11.1
#
#  ¿Cuáles son los eigenvalores de la Matriz A
#
# ```
# A =
# [
#  140   97   74  168  131
#   97  106   89  131   36
#   74   89  152  144   71
#  168  131  144   54  142
#  131   36   71  142   36
# ]
# ```
# ------------------------------------------------------------------------------------------

A =
[
 140   97   74  168  131
  97  106   89  131   36
  74   89  152  144   71
 168  131  144   54  142
 131   36   71  142   36
]

eigdec = eigfact(A)
eigdec[:values]

# ------------------------------------------------------------------------------------------
# #### 11.2
#
# Crea una matriz diagonal de los eigenvalores de A
# ------------------------------------------------------------------------------------------

Diagonal(eigdec[:values])

# ------------------------------------------------------------------------------------------
# #### 11.3
#
# Realiza un factorización de Hessenberg sobre la matriz A. Verifica que `A = QHQ'`.
# ------------------------------------------------------------------------------------------

F = hessfact(A)

isapprox(A, F[:Q] * F[:H] * F[:Q]')


