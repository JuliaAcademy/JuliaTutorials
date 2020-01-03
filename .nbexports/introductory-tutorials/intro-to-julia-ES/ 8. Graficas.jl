# ------------------------------------------------------------------------------------------
# # Plotting / Gráficas
#
# ## Introducción
#
# Hay muchas manera de graficar en Julia (además de usar PyPlot). <br>
#
# Aquí veremos como usar `Plots.jl`.
# ------------------------------------------------------------------------------------------

#Pkg.add("Plots")
using Plots

# ------------------------------------------------------------------------------------------
# Una de las ventajas de `Plots.jl` Es que permite cambiar los backends sin costo alguno. En
# este notebook, vamos a intentar usar `gr()` y `plotlyjs()` como backends.<br>
#
# Primero vamos a generar datos artificiales para graficar
# ------------------------------------------------------------------------------------------

x = -3:0.1:3
f(x) = x^2

y = f.(x)

# ------------------------------------------------------------------------------------------
# **Carguemos el backend de GR**
# ------------------------------------------------------------------------------------------

gr()

plot(x, y, label="linea")  
scatter!(x, y, label="puntos") 

# ------------------------------------------------------------------------------------------
# El `!` al final de `scatter!` indica que sea una función mutante,  indicando que los
# puntos se van a agregar a la gráfica preexistente.
#
# Por contraste, en vez de usar `scatter!`, usa `scatter` para ver como funciona.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# **Sin cambiar de sintaxis, cambiamos al backend de `plotlyjs()`**
# ------------------------------------------------------------------------------------------

plotlyjs()

plot(x, y, label="line")  
scatter!(x, y, label="points") 

# ------------------------------------------------------------------------------------------
# Y nos fijamos como cambia la primera gráfica de la segunda
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Subiendo de nivel
#
# La sintaxis para agregar títulos y líneas es bastante directa.
#
# Ahora, en el nombre de la ciencia, vamos a examinar la relación entre la temperatura
# global y el número de piratas entre 1860 y 2000.
# ------------------------------------------------------------------------------------------

globaltemperatures = [14.4, 14.5, 14.8, 15.2, 15.5, 15.8]
numpirates = [45000, 20000, 15000, 5000, 400, 17]

# Primero plotteamos los datos
plot(numpirates, globaltemperatures, legend=false)
scatter!(numpirates, globaltemperatures, legend=false)

# Agregamos Títulos y etiquetas/labels.
xlabel!("Número de piratas [Apróx.]")
ylabel!("Temperatura Global (C)")
title!("Influencia de población de piratas en calentamiento global")

# Primero graficamos datos
plot(numpirates, globaltemperatures, legend=false)
scatter!(numpirates, globaltemperatures, legend=false)

# Este comando invierte el eje x para que podamos ver los cambios hacia adelante en el tiempo, de 1860 a 2000
xflip!()

# Add titles and labels
xlabel!("Number of Pirates [Approximate]")
ylabel!("Global Temperature (C)")
title!("Influence of pirate population on global warming")

# ------------------------------------------------------------------------------------------
# Para crear una gráfica con subráficas, sólo nombramos a cada una de las subgráficas y las
# ponemos junto con la especificación de diseño en una sóla llamada a `plot`.
# ------------------------------------------------------------------------------------------

p1 = plot(x, x)
p2 = plot(x, x.^2)
p3 = plot(x, x.^3)
p4 = plot(x, x.^4)
plot(p1,p2,p3,p4,layout=(2,2),legend=false)

# ------------------------------------------------------------------------------------------
# ### Ejercicios
#
# 8.1 Grafica y vs x para `y = x^2` usando el backend de PyPlot.
# ------------------------------------------------------------------------------------------


