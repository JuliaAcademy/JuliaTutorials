
# ------------------------------------------------------------------------------------------
# # Strings字符串
#
# 话题：
# 1. 如何构建一个字符串
# 2. 格式化字符串
# 3. 字符串拼接
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## 如何构建一个字符串
#
# 用`" "`或者`""" """`包围一系列字符就得到字符串！
# ------------------------------------------------------------------------------------------

s1 = "I am a string."

s2 = """I am also a string. """

# ------------------------------------------------------------------------------------------
# 一个双引号与三个双引号所构造的字符串有两个功能性的区别。 <br>
# 一个区别是，三个双引号所构造的字符串中可以使用双引号作为字符串的一部分。
# ------------------------------------------------------------------------------------------

"Here, we get an "error" because it's ambiguous where this string ends "

"""Look, Mom, no "errors"!!! """

# ------------------------------------------------------------------------------------------
# 注意`' '`定义的是字符（character），不是字符串！
# ------------------------------------------------------------------------------------------

typeof('a')

'We will get an error here'

# ------------------------------------------------------------------------------------------
# ## 格式化字符串（String interpolation）
#
# `$`符号可以将已有的变量插入一个字符串，也可以在字符串中代入表达式的值。<br>
# 下面这个例子含有高度敏感的个人信息。
# ------------------------------------------------------------------------------------------

name = "Jane"
num_fingers = 10
num_toes = 10

println("Hello, my name is $name.")
println("I have $num_fingers fingers and $num_toes toes.")

 println("That is $(num_fingers + num_toes) digits in all!!")



# ------------------------------------------------------------------------------------------
# ## 字符串拼接
#
# 下面介绍三种拼接字符串的方法！【译注：好像只有两种？算上格式化字符串的方式有三种？】<br><br>
# 第一种方式是使用`string()`函数。<br>
# `string()`函数将非字符串的输入转化为字符串。
# ------------------------------------------------------------------------------------------

s3 = "How many cats ";
s4 = "is too many cats?";
😺 = 10

string(s3, s4)

string("I don't know, but ", 😺, " is too few.")

# ------------------------------------------------------------------------------------------
# 也可以使用`*`进行拼接！
# ------------------------------------------------------------------------------------------

s3*s4

# ------------------------------------------------------------------------------------------
# ### 练习
#
# #### 2.1
# 创建一个有1000个"hi"的字符串`hi`，先用`repeat`函数，在试试指数运算符，它会在后台调用`*`。
# ------------------------------------------------------------------------------------------



@assert hi == "hihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihihi"

# ------------------------------------------------------------------------------------------
# #### 2.2
# 声明两个变量
#
# ```julia
# a = 3
# b = 4
# ```
# 然后用这两个变量创建两个字符串：
# ```julia
# "3 + 4"
# "7"
# ```
# 将这两个字符串分别赋值给`c`和`d`
# ------------------------------------------------------------------------------------------



@assert c == "3 + 4"
@assert d == "7"

# ------------------------------------------------------------------------------------------
# 请在完成练习后点击顶部的`Validate`。
# ------------------------------------------------------------------------------------------
