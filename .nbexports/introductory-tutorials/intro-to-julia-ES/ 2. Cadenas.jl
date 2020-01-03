# ------------------------------------------------------------------------------------------
# # Cadenas (Strings)
#
# Temas:
# 1. Cómo conseguir una cadena
# 2. Interpolación de cadenas
# 3. Concatenación de cadenas
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Cómo conseguir una cadena
#
# Enclose your characters in " " or """ """!
# ------------------------------------------------------------------------------------------

s1 = "Yo soy una cadena."

s2 = """Yo también soy una cadena. """

# ------------------------------------------------------------------------------------------
# Existen algunas diferencias funcionales entre expresas cadenas con una sola y triple
# comillas. <br>
# Una diferencia es que en la segunda opción puedes usar comillas dentro de tu cadena.
# ------------------------------------------------------------------------------------------

"Aquí me sale un "error" porque es ambiguo dónde se acaba la cadena. "

"""Mira Mamá, sin "errors"!!! """

# ------------------------------------------------------------------------------------------
# Ojo, '' define a un caracter, ¡ NO una cadena!
# ------------------------------------------------------------------------------------------

typeof('a')

'Esto va a dar un error'

# ------------------------------------------------------------------------------------------
# NOTA: En Julia todas las cadenas por default son del tipo UTF-8. Esto significa que
# podemos usar nuestros querídisimos acentos del habla hispana y nuestros signos de apertura
# de interrogación sin miedo a que nuestro código no corra en una máquina ajena. ¡Inténtalo!
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Interpolación de cadenas
#
# Podemos usar el símbolo $ para insertar variables existentes a una cadena y para evaluar
# expresiones en una cadena. <br>
# Abajo hay un ejemplo con información súmamente sensible.
# ------------------------------------------------------------------------------------------

nombre = "Jane"
num_dedos = 10
num_dedos_de_los_pies = 10

println("Hola, me llamo $nombre.")
println("Yo tengo $num_dedos dedos y $num_dedos_de_los_pies. ¡Esos son $(num_dedos + num_dedos_de_los_pies) dígitos en total!!")

# ------------------------------------------------------------------------------------------
# ## Concatenación de cadenas
#
# ¡Abajo hay tres maneras de concatenar cadenas! <br><br>
# La primera es usando la función de `string()` <br>
# `string()` convierte no-cadenas en cadenas.
# ------------------------------------------------------------------------------------------

string("¿Cuántos gatos ", "son demasiados?")

string("No lo sé, pero ", 10, " son muy pocos.")

# ------------------------------------------------------------------------------------------
# We can also use `*` or string interpolation!
# ------------------------------------------------------------------------------------------

s3 = "¿Cuántos gatos ";
s4 = "son demasiados?";

s3*s4

"$s3$s4"

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 2.1 Crea una cadena que diga "hola" 1000 veces.
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 2.2 Agrega dos números dentro de una cadena.
# ------------------------------------------------------------------------------------------


