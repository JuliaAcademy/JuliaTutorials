# ------------------------------------------------------------------------------------------
# # Condicionales
#
# En Julia, la sintaxis
#
# ```julia
# if *condición 1*
#     *opción 1*
# elseif *condición 2*
#     *opción 2*
# else
#     *opción 3*
# end
# ```
#
# Nos permite eventualmente evaluar una de nuestras opciones.
# <br><br>
# Por ejemplo, tal vez queremos implementar la prueba de FizzBuzz: Dado un número N, imprime
# "Fizz" si N es divisible entre 3, "Buzz" si N es divisible entre 5, y "FizzBuzz" si N es
# divisible entre ambos 3 y 5. En cualquier otro caso, imprimo el número mismo.
# ------------------------------------------------------------------------------------------

N = 

if (N % 3 == 0) & (N % 5 == 0)
    println("FizzBuzz")
elseif N % 3 == 0
    println("Fizz")
elseif N % 5 == 0
    println("Buzz")
else
    println(N)
end

# ------------------------------------------------------------------------------------------
# Ahora digamos que queremos regresar el mayor número de ambos. Escoge tus propios x y y
# ------------------------------------------------------------------------------------------

x = 
y = 

if x > y
    x
else
    y
end

# ------------------------------------------------------------------------------------------
# Para el último bloque, podemos usar el operador ternario, con la sintaxis
#
# ```julia
# a ? b : c
# ```
#
# que equivale a
#
# ```julia
# if a
#     b
# else
#     c
# end
# ```
# ------------------------------------------------------------------------------------------

(x > y) ? x : y

# ------------------------------------------------------------------------------------------
# Un truco relacionado es la evaluación de corto-circuito
#
# ```julia
# a && b
# ```
# ------------------------------------------------------------------------------------------

(x > y) && println(x)

(x < y) && println(y)

# ------------------------------------------------------------------------------------------
# Cuando escribimos `a && b`, `b` se ejecuta sólo si `a` se evalúa a `true`.
# <br>
# Si `a` se evalúa a `false`, la expresión `a && b` regresa `false`
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 5.1 Reescribe FizzBuzz sin usar `elseif`.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 5.2 Reescribe FizzBuzz usando el operador ternario.
# ------------------------------------------------------------------------------------------


