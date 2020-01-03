# ------------------------------------------------------------------------------------------
# # Despacho múltiple / multiple dispatch
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# En este notebook vamos a explorar **multiple dispatch**, un concepto fundamental en Julia.
#
# Multiple dispatch permite software:
# - rápido
# - extendible
# - programable
# - divertido para experimentar
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Para entender el despacho múltiple en Julia, observemos el operador `+`. <br>
#
# Si llamamos `methods()` sobre `+`, podemos ver todas las definiciones de `+`
# ------------------------------------------------------------------------------------------

methods(+)

# ------------------------------------------------------------------------------------------
# Podemos usar el macro de `@which` para saber qué método en particular estamos usando de
# `+`.<br>
#
# Distintos métodos se usan en cada uno de estos ejemplos.
# ------------------------------------------------------------------------------------------

@which 3 + 3

@which 3.0 + 3.0 

@which 3 + 3.0

# ------------------------------------------------------------------------------------------
# Aún más, pues podemos definir nuevos métodos de `+`. <br>
#
# Primero tenemos que importar `+` de Base.
# ------------------------------------------------------------------------------------------

import Base: +

# ------------------------------------------------------------------------------------------
# Digamos que queremos concatenar elementos con  `+`. Sin extender el método, no funciona
# ------------------------------------------------------------------------------------------

"hello " + "world!"

@which "hello " + "world!"

# ------------------------------------------------------------------------------------------
# Entonces agregamos a `+` un método que toma dos cadenas y las concatena
# ------------------------------------------------------------------------------------------

+(x::String, y::String) = string(x, y)

"hello " + "world!"

# ------------------------------------------------------------------------------------------
# ¡Funciona! Y si queremos más, podemos comprobarnos que Julia ha despachado sobre los tipos
# de "hello" y "world!", sobre el método que acabamos de definir
# ------------------------------------------------------------------------------------------

@which "hello " + "world!"

# ------------------------------------------------------------------------------------------
# Vamos por un ejemplo más
# ------------------------------------------------------------------------------------------

foo(x, y) = println("duck-typed foo!")
foo(x::Int, y::Float64) = println("foo con entero y flotante!")
foo(x::Float64, y::Float64) = println("foo con dos flotantes!")
foo(x::Int, y::Int) = println("foo con dos enteros!")

foo(1, 1)

foo(1., 1.)

foo(1, 1.0)

foo(true, false)

# ------------------------------------------------------------------------------------------
# Nota que el último ejemplo aplica por default el caso de 'duck-typed foo' porque no había
# un método definido exclusivamente para dos booleanos.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Ejercicios
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



# ------------------------------------------------------------------------------------------
# #### 9.2
#
# Checa que has extendido propiamente `+` recorriendo la próxima cadena para atrás por 3
# letras:
#
# "Gr#qrw#phggoh#lq#wkh#diidluv#ri#gudjrqv#iru#|rx#duh#fuxqfk|#dqg#wdvwh#jrrg#zlwk#nhwfkxs1"
# ------------------------------------------------------------------------------------------


