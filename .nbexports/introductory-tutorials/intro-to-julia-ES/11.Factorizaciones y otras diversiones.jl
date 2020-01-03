# ------------------------------------------------------------------------------------------
# # Factorizaciones y otras diversiones
# Autor: Andreas Noack Jensen (MIT) (http://www.econ.ku.dk/phdstudent/noack/)
# (con edición de Jane Herriman=
#
# ## Sinopsis
#  - Factorizaciones
#  - Estructuras de matrices especiales
#  - Álgebra lineal genérica
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Empezamos con un sistema lineal de la forma
#
# `Ax = b`
# ------------------------------------------------------------------------------------------

A = randn(3,3)

x = fill(1.0, (3))
b = A*x

# ------------------------------------------------------------------------------------------
# ### Factorización
# La función `\` esconde cómo regularmente se resuelve el problema.
#
# Dependiendo de las dimensiones de `A`, distintos métodos son elegidos para resolver el
# problema.
#
# ```
# Ax = b
# ```
#
# Un paso intermedio en la solución es el cálculo de la factorización de la matriz `A`.
#
# Básicamente, una factorización de `A` es una manera de expresar `A` como el producto de
# matrices triangulares, unitarias, y de permutación.
#
# Julia guarda estas factorizaciones usando un tipo abstracto llamado `Factorization` y
# varios subtipos.
#
# Un objeto `Factorization` entonces debería ser pensado como una represenatación de la
# matriz `A`.
#
# #### LU
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Cuando `A` es cuadrada, el sistema linear es resuelto factorizando `A` vía
#
# ```
# PA=LU
# ```
#
# donde `P` es una matriz de permutación, `L` es un triangular inferior unitaria y `U` es
# triangular superior.
#
# Julia permita calcular la facorización LU y define un tipo de factorización compuesta para
# guardarlo.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Podemos hacer una factorización LU sobre `A` vía `lu(A)` ó `lufact(A)`.
#
# La función `lu` regresa matrices `l` y `u` y un vector de permutación `p`.
# ------------------------------------------------------------------------------------------

l,u,p = lu(A)

# ------------------------------------------------------------------------------------------
# El pivoteo está prendido por default, o sea que no podemos assumir que A == LU.
# Vamos a comprobar esto viendo la norma de `LU - A`:
# ------------------------------------------------------------------------------------------

norm(l*u - A)

# ------------------------------------------------------------------------------------------
# Esto nos muestra que queremos tomar en cuenta el pivoteo!
#
# Podemos pensar en `A[p,:]` como la sintaxis para `PA`, o como el producto de una matriz de
# permutación con `A`
# ------------------------------------------------------------------------------------------

norm(l*u - A[p,:])

# ------------------------------------------------------------------------------------------
# Por otro lado, podemos apagar el pivoteo usando `Val{false}` en Julia 0.6 ó `Val(false)`
# en versiones más modernas.
# ------------------------------------------------------------------------------------------

l,u,p = lu(A, Val{false})

# ------------------------------------------------------------------------------------------
# Cuando apagamos el pivoteo, `LU = A`
# ------------------------------------------------------------------------------------------

norm(l*u - A)

# ------------------------------------------------------------------------------------------
# Una segunda manera de hacer la factorización es con `lufact`.
# ------------------------------------------------------------------------------------------

Alu = lufact(A)

# ------------------------------------------------------------------------------------------
# Distintas partes de la factorización las puedes accesar con índices especiales
# ------------------------------------------------------------------------------------------

Alu[:P]

Alu[:L]

Alu[:U]

# ------------------------------------------------------------------------------------------
# Podemos calcular la solución de $Ax=b$ del objecto de factorización
# ------------------------------------------------------------------------------------------

# PA = LU
# A = P'LU
# P'LUx = b
# LUx = Pb
# Ux = L\Pb
# x = U\L\Pb
Alu[:U]\(Alu[:L]\(Alu[:P]b))

# ------------------------------------------------------------------------------------------
# *Más importantemente,* podemos despachar sobre el tipo de `LU` y simplemente resolver el
# problema por medio de
# ------------------------------------------------------------------------------------------

Alu\b

# ------------------------------------------------------------------------------------------
# Esto puede ser útil si el mismo lado izquierdo es usado para lados derechos.
#
# La factorización también se puede usar para calcular el determinante pues
#
# $\det(A)=\det(PLU)=\det(P)\det(U)=\pm \prod u_{ii}$
#
# porque $U$ es triangular y el signo está definido por $\det(P)$.
# ------------------------------------------------------------------------------------------

det(A)

det(Alu)

# ------------------------------------------------------------------------------------------
# #### QR
# Cuando `A` es alta,
# ------------------------------------------------------------------------------------------

Atall = randn(3, 2)

# ------------------------------------------------------------------------------------------
# Julia calcula la solución de mínimos cuadrados $\hat{x}$ que minimiza $\|Ax-b\|_2$.
#
# Esto se puede hacer factorizando
#
# ```
# A=QR
# ```
#
# donde $Q$ es unitaria/ortogonal y
#
# $R=\left(\begin{smallmatrix}R_0\\0\end{smallmatrix}\right)$ y  $R_0$ es triangular
# superior.
#
# con la factorización QR la norma mínima se puede expresar como
#
# \begin{equation*}
# \|Ax-b\|=\|QRx-b\|=\|Q(Rx-Q'b)\|=\|Rx-Q'b\|=\left\|\begin{pmatrix}R_0x-Q_0'b\\Q_1'b\end{pm
# atrix}\right\|=\|R_0x-Q_0'b\|+\|Q_1'b\|
# \end{equation*}
#
# Y entonces el problema se puede reducir a resolver el problema cuadrado $R_0x=Q_0'b$ para
# $x$.
#
# Podemos factorizar QR sobre `Atall` vía
# ------------------------------------------------------------------------------------------

Aqr = qrfact(Atall)

# ------------------------------------------------------------------------------------------
# Otra característica de la factorización QR es que los tipos `Q` para guardar las matrices
# unitarias $Q$. Se pueden extraer de tipos `QR` con los índices
# ------------------------------------------------------------------------------------------

Aqr[:Q]

# ------------------------------------------------------------------------------------------
# Similarmente, la matriz superior triangular $R$ se puede extraer con el índice
# ------------------------------------------------------------------------------------------

Aqr[:R]

# ------------------------------------------------------------------------------------------
# En este caso se guarda R como una matriz 2x2 en vez de 3x2 porque el último renglón de R
# está lleno de 0's.<br><br>
#
#
# Aunque la matriz `Aqr[:Q]` se imprime como $3\times 3$ en el objeto de factorización, en
# la práctica puede representar la versión delgada también. Así
# ------------------------------------------------------------------------------------------

Aqr[:Q]*ones(2)

# ------------------------------------------------------------------------------------------
# funciona y representa a $3 x 2$ matrix por un vector de 2-elementos.
#
# Similarmente,
# ------------------------------------------------------------------------------------------

Aqr[:Q]*ones(3)

# ------------------------------------------------------------------------------------------
# funciona representando la matriz $3x3$ y un vector de 3 elementos.
#
# Sin embargo, esto no significa que podemos multiplicar a `Q` por vectores de longitued
# arbitraria.
# ------------------------------------------------------------------------------------------

Aqr[:Q]*ones(4)

# ------------------------------------------------------------------------------------------
# La matriz tiene representación interna compacta, entonces indexar sólo hace sentido si uno
# sabe cómo la factorización guarda datos.
# ------------------------------------------------------------------------------------------

Aqr[:Q][1]

# ------------------------------------------------------------------------------------------
# El objeto QRCompactWY `\` tiene un método para QR y entonces el problema de los mínimos
# cuadrados es resuelto con
# ------------------------------------------------------------------------------------------

Aqr\b

# ------------------------------------------------------------------------------------------
# Y si en vez escribimos
# ------------------------------------------------------------------------------------------

Atall\b

# ------------------------------------------------------------------------------------------
# En vez de factorizar con QR a `Atall` primero, Julia va a defaultear factorizar *con*
# pivoteo.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Este default a pivotear la factorización QR le permite a Julia resolver problemas
# deficientes de rango.
#
# Podemos explícitamente escoger pivotear durante la factorización QR (de una matriz
# singular, por ejemplo) con `Val{true}`.
# ------------------------------------------------------------------------------------------

v = randn(3)
# Tomar el producto exterio de un vector consigo mismo nos da una matriz singular
singmatriz = v * v'

Aqrp = qrfact(singmatriz,Val{true})

# ------------------------------------------------------------------------------------------
# Notamos que el tipo que resulta del objecto de Factorization es distinto que antes.
#
# `\` también tiene un método de `QRPivoted` y el problema con rango deficiente es entonces
# calculado como
# ------------------------------------------------------------------------------------------

Aqrp\b

# ------------------------------------------------------------------------------------------
# #### Eigendescompisición y los SVDs (Valores de descomposición Singular)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Los resultados de eigendescomposición y de la descomposición singular de valores se
# guardan en los tipos`Factorization`. Esto también incluye la factorización de Hessenberg y
# de Schur
#
# La eigendescomposición puede ser calculada como
# ------------------------------------------------------------------------------------------

Asym = A + A'
AsymEig = eigfact(Asym)

# ------------------------------------------------------------------------------------------
# Los valores y vectores se pueden recoger del tipo Eigen con un índice especial
# ------------------------------------------------------------------------------------------

AsymEig[:values]

AsymEig[:vectors]

# ------------------------------------------------------------------------------------------
# Una vez más, como la descomposición se guarda en un tipo, podemos despatchar sobre esos
# tipos y explotar un método especializado para cada factorización, e.g. que
# $A^{-1}=(V\Lambda V^{-1})^{-1}=V\Lambda^{-1}V^{-1}$.
# ------------------------------------------------------------------------------------------

inv(AsymEig)*Asym

# ------------------------------------------------------------------------------------------
# Julia también tiene una función `eig` que regresa una tupla con los valores y vectores
# ------------------------------------------------------------------------------------------

eig(Asym)

# ------------------------------------------------------------------------------------------
# No recomendamos esta versión.
#
# La función `svdfact` calcula la descomposición singular de valores
# ------------------------------------------------------------------------------------------

Asvd = svdfact(A[:,1:2])

# ------------------------------------------------------------------------------------------
# y de nuevo `\` tiene un método para el tipo que permite los mínimos cuadrados por SVD
# ------------------------------------------------------------------------------------------

Asvd\b

# ------------------------------------------------------------------------------------------
# Existen funciones especiales para proporcionar los valores sólamente: `eigvals` and
# `svdvals`.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Estructuras especiales de matrices
#
# La estructura de matrices es muy importante en el álgebra linear. Ésta estructura se le
# puede hacer explícita a Julia por medio de los tipos compuestos. Ejemplos: `Diagonal`,
# `Triangular`, `Symmetric`, `Hermitian`, `Tridiagonal` y `SymTridiagonal`. Se han escrito
# métodos especializados para cada tipo de matriz especial para aprovechar su estructura.
# Siguen algunos ejemplos:
# ------------------------------------------------------------------------------------------

A

# ------------------------------------------------------------------------------------------
# Creando una matriz Diagonal
# ------------------------------------------------------------------------------------------

Diagonal(diag(A))

Diagonal(A)

# ------------------------------------------------------------------------------------------
# Creando una matriz triangular inferior
# ------------------------------------------------------------------------------------------

LowerTriangular(tril(A))

LowerTriangular(A)

# ------------------------------------------------------------------------------------------
# Creando una matriz simétrica
# ------------------------------------------------------------------------------------------

Symmetric(Asym)

SymTridiagonal(diag(Asym),diag(Asym,1))

# ------------------------------------------------------------------------------------------
# Cuando se sabe que una matriz es e.g. triangular o simétrica Julia puede que resuelva el
# problema más rápido convirtiendo a una matriz especial.
#
# Para algunos procedimientos, Julia checa si el input de matriz es triangular o simétrica y
# lo convierte a tal estructura si lo detecta.
#
# Debería notarse que `Symmetric`, `Hermitian` y `Triangular` no copian la matriz original.
#
# #### Eigenproblema simétrico
# La capacidad de Julia para poder detectar si una matriz es simétrica/Hermitian puede
# influenciar muchísimo sobre qué tan rápido se puede resolver un problema de eigenvalor.
# ------------------------------------------------------------------------------------------

n = 1000;
A = randn(n,n);

# ------------------------------------------------------------------------------------------
# Usamos `A` para genera una matriz simétrica `Asym`
# ------------------------------------------------------------------------------------------

Asym = A + A';

# ------------------------------------------------------------------------------------------
# Ahora creemos una matriz Asym para simular una matriz simétrica con errores de punto
# flotante
# ------------------------------------------------------------------------------------------

Asym_noisy = copy(Asym); Asym_noisy[1,2] += 5eps();

# ------------------------------------------------------------------------------------------
# ¿Puede Julia determinar que ambas `Asym` y `Asym_noisy` son matrices simétricas?
# ------------------------------------------------------------------------------------------

println("Is Asym symmetric? ", issymmetric(Asym))
println("Is Asym_noisy symmetric? ", issymmetric(Asym_noisy))

# ------------------------------------------------------------------------------------------
# Ahora veamos como el ruido de `Asym_noisy` impacta el tiempo en llevar a cabo una
# eigendescomposición
# ------------------------------------------------------------------------------------------

@time eigvals(Asym);

@time eigvals(Asym_noisy);

# ------------------------------------------------------------------------------------------
# Por suerte, le podeemos proveer información explícita sobre la estructura de la matriz a
# Julia
# En este ejemplo, usamos la palabra clave `Symmetric`
# ------------------------------------------------------------------------------------------

@time eigvals(Symmetric(Asym_noisy));

# ------------------------------------------------------------------------------------------
# Y así nuestros cálculos son mucho más eficientes :)
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### Un gran problema
# Usar matrices tridiagonales permite trabajar con problemas potencialmente muy grandes. El
# siguiente problema no seria posible resolverlo en una laptop si la matriz se tuviera que
# guardar como tipo `Matrix`.
# ------------------------------------------------------------------------------------------

n = 1_000_000;
A = SymTridiagonal(randn(n), randn(n-1));
@time eigmax(A)

# ------------------------------------------------------------------------------------------
# ### Álgebra lineal numérica
# La manera usual de agregar soporte para álgebra lineal numérica es haciendo un wrapper
# para subrutinas de BLAS y LAPACK. Para matrices con elementos `Float32`, `Float64`,
# `Complex{Float32}` ó `Complex{Float64}` esto es lo que hace Julia. Desde hace rato, Julia
# ha tnido soport para la multiplicación genérica de tipos. Así, cuando uno multiplica
# matrices de enteros, obtiene una matriz de enteros.
# ------------------------------------------------------------------------------------------

rand(1:10,3,3)*rand(1:10,3,3)

# ------------------------------------------------------------------------------------------
# Recientemente, más métodos de álgebra lineal se han añadido a Julia y ahora soporta
# factorizaciones generales de tipo `LU` y `QR`. Métodos generales para eigenvalores y SVD
# han sido escritos más recientemente en paquetería externa.
#
# En general, la factorización `LU` puede ser calculada cuando los elementos de la matriz se
# cierraon sobre los operadores `+`, `-`, `*` y `\`. Por supuesto, la matriz también deben
# tener rango completo. El método general de factorización `LU` en Julia aplica pivoteo y
# por lo tanto debe poder soportar `<` y `abs`. Por lo tanto es posible resolver sistemas de
# ecuaciones de e.g. números racionales como en los ejemplos que siguen.
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# Para usar números racionales, usamos un doble //:
# ------------------------------------------------------------------------------------------

1//2

# ------------------------------------------------------------------------------------------
# #### Ejemplo 1: Sistemas racionales lineales de ecuaciones
# Julia cuenta con números racionales ya instalados. El siguiente ejemplo consta de un
# sistema lineal de ecuaciones resulto sin promover a tipos de punto flotanto. Puede haber
# un error de overflow fácilmente al trabajar con racionales, así que usamos `BigInt`s.
# ------------------------------------------------------------------------------------------

Ar = convert(Matrix{Rational{BigInt}}, rand(1:10,3,3))/10

x = fill(1, (3))
b = Ar*x

Ar\b

lufact(Ar)

# ------------------------------------------------------------------------------------------
# #### Ejemplo 2: Matriz racional de eigenestructura
#
# El siguiente ejemplo muestra como la artimética de matriz racional puede ser usada para
# calcular una matriz dados los eigenvalores y eigenvectores racionales. Yo he encontrado
# ésto útil para mostrar ejemplos de sistemas dinámicos lineales.
# ------------------------------------------------------------------------------------------

λ1,λ2,λ3 = 1//1,1//2,1//4
v1,v2,v3 = [1,0,0],[1,1,0],[1,1,1]
V,Λ = [v1 v2 v3], Diagonal([λ1,λ2,λ3])
A = V*Λ/V

# ------------------------------------------------------------------------------------------
# ### Exercises
#
# 11.1 ¿Cuáles son los eigenvalores de la Matriz A
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



# ------------------------------------------------------------------------------------------
# 11.2 Crea una matriz diagonal de los eigenvalores de A
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# 11.3 Realiza un factorización de Hessenberg sobre la matriz A. Verifica que `A = QHQ'`.
# ------------------------------------------------------------------------------------------


