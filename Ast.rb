#Arbol Sintactico 
#Clase que sirve como modelo general para cada uno de los elementos sintacticos
#usados en el lenguaje retina, en particular está definida su impresión por terminal
#en forma de arbol sintactico
class AST
	def print_ast indent = ""
		puts "#{indent}#{self.class}"
		attrs.each do |a|
			a.print_ast indent + "      " if a.respond_to? :print_ast
		end
	end

	def attrs
		instance_variables.map do |a|
			instance_variable_get a
		end
	end
end

class Programa < AST
	attr_accessor :funciones, :bloque
	def initialize f, i
		@funciones = f  		#Listas>Funciones o []
		@instrucciones = i  	#Listas>Instrucciones o []
	end
end

class Bloque < AST
	attr_accessor :declaraciones, :instrucciones
	def initialize d, i
		@declaraciones = d	#Listas>Declaraciones o []
		@instrucciones = i	#Listas>Instrucciones
	end
end

class Funcion < AST
	attr_accessor :ident, :argumentos, :instruccionesfu
	def initialize i, a, ifu
		@ident = i					#Identificador
		@argumentos = a		#Listas>Argumentos o []
		@instruccionesfu = ifu	#Listas>Instrucciones
	end
end

class FuncionConTipo < AST
	attr_accessor :ident, :argumentos, :instruccionesfu, :tipo
	def initialize i, a, t, ifu
		@ident = i						#Identificador 
		@argumentos = a			#Listas>Argumentos o []
		@tipo = t							#Tipo
		@instruccionesfu = ifu		#Listas>Instrucciones
	end

	def print_ast indent = ""
		puts "#{indent}Funcion con Tipo"
		attrs.each do |a|
			a.print_ast indent + "      " if a.respond_to? :print_ast
		end
	end
end

class Argumento < AST
	attr_accessor :tipo, :ident
	def initialize t, i
		@tipo = t					#Tipo
		@ident = i				#Identificador
	end
end

class Tipo < AST
	attr_accessor :nombre, :token
	def initialize n
		@token = n				#Token
		@nombre = n.text	#Token.text
	end
	def print_ast indent = ""
		puts "#{indent}#{self.class}"
		puts "#{indent}     nombre: #{@nombre}"
	end
end

class Declaracion < AST
	attr_accessor :tipo, :identoAsig
	def initialize t, i
		@tipo = t					#Tipo
		@identoAsig = i 		#Identificador o Asignacion
	end
end

################################################Elementos con forma de lista#############################################

class Listas < AST
  attr_accessor :lista
	def initialize a
		@lista = a #Atributo es un arreglo de objetos AST
	end

	def print_ast indent = ""
		puts "#{indent}#{self.class}" #Se imprime el nombre de la clase

		@lista.each do |f|
			f.print_ast indent + "      " if f.respond_to? :print_ast #Luego cada elemento de la lista
		end
	end
end

class Funciones < Listas; end		#Funcion
class Argumentos < Listas; end		#Argumento
class Declaraciones < Listas; end	#Declaracion
class Instrucciones < Listas; end	#Instruccion (*)
class Salidas < Listas
	attr_accessor :lista, :salto
	def initialize a, salto
		@lista = a #Atributo es un arreglo de objetos AST
		@salto = salto
	end
end	
################################################################################################################

###############################################Instrucciones varias############################

class CondIf < AST
	def initialize g, i, line
		@guardia = g #Guardia o rango iteratico
		@instruccion = i #Instrucciones
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Condicional If" #Se imprime el nombre
		indent = indent + "      "
		puts "#{indent}Guardia:" #Se avisa la guardia
		@guardia.print_ast indent + "      " if @guardia.respond_to? :print_ast # Y se imprimen sus elementos
		@instruccion.print_ast indent + "      " if @instruccion.respond_to? :print_ast
	end
end

class CondIfElse < AST
	def initialize g, i, i2, line
		@guardia = g
		@instruccion = i
		@instruccion2 = i2
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Condicional If"
		indent = indent + "      "
		puts "#{indent}Guardia:"
		@guardia.print_ast indent + "      " if @guardia.respond_to? :print_ast
		puts "#{indent}Instruccion If:"
		@instruccion.print_ast indent + "      " if @instruccion.respond_to? :print_ast
		puts "#{indent}Instruccion Else:"
		@instruccion2.print_ast indent + "      " if @instruccion2.respond_to? :print_ast
	end
end

class IterWhile < AST
	def initialize g, i, line
		@guardia = g
		@instruccion = i
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Iterador While"
		indent = indent + "      "
		puts "#{indent}Guardia:"
		@guardia.print_ast indent + "      " if @guardia.respond_to? :print_ast
		@instruccion.print_ast indent + "      " if @instruccion.respond_to? :print_ast
	end
end

class IterFor < AST
	def initialize i, d, h, ins, line
		@ident = i
		@desde = d
		@hasta = h
		@instruccion = ins
		@line = line
	end
	def print_ast indent = ""
		puts "#{indent}Iterador For"
		indent = indent + "      "
		puts "#{indent}Contador:"
		@ident.print_ast indent + "      " if @ident.respond_to? :print_ast
		puts "#{indent}Inicio:"
		@desde.print_ast indent + "      " if @desde.respond_to? :print_ast
		puts "#{indent}Fin:"
		@hasta.print_ast indent + "      " if @hasta.respond_to? :print_ast
		@instruccion.print_ast indent + "      " if @instruccion.respond_to? :print_ast
	end
end

class IterForBy < AST
	def initialize i, d, h, pp, ins, line
		@ident = i
		@desde = d
		@hasta = h
		@por = pp
		@instruccion = ins
		@line = line
	end
	def print_ast indent = ""
		puts "#{indent}Iterador For by"
		indent = indent + "      "
		puts "#{indent}Contador:"
		@ident.print_ast indent + "      " if @ident.respond_to? :print_ast
		puts "#{indent}Inicio:"
		@desde.print_ast indent + "      " if @desde.respond_to? :print_ast
		puts "#{indent}Fin:"
		@hasta.print_ast indent + "      " if @hasta.respond_to? :print_ast
		puts "#{indent}Cuanto:"
		@por.print_ast indent + "      " if @por.respond_to? :print_ast
		@instruccion.print_ast indent + "      " if @instruccion.respond_to? :print_ast
	end
end

class IterRepeat < AST
	def initialize v, ins, line
		@veces = v
		@line = line
		@instruccion = ins
	end
	def print_ast indent = ""
		puts "#{indent}Iterador Repeat"
		indent = indent + "      "
		puts "#{indent}Veces:"
		@veces.print_ast indent + "      " if @veces.respond_to? :print_ast
		@instruccion.print_ast indent + "      " if @instruccion.respond_to? :print_ast
	end
end

##############################################Expresiones#######################################

class ExpresionUnaria < AST
	attr_accessor :op
	def initialize op
		@op = op
	end
end

class Entrada < ExpresionUnaria;end

class Retorno < ExpresionUnaria
	def run_inst padre
		padre.encontrar_insertar($stack_funciones[-1].capitalize, @op.encontrar_valor(padre), "number")
	end
end

class Minus < ExpresionUnaria
	attr_accessor :op, :tipo, :checked, :linea
	def initialize op, line
		@op = op
		@tipo = "number"
		@checked = false
		@linea = line
	end
end

class Negacion < ExpresionUnaria
	attr_accessor :op, :tipo, :checked, :linea
	def initialize op, line
		@op = op
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
end

class Llamada < AST
	attr_accessor :ident, :argumentos, :checked
	def initialize i, a
		@ident = i				#Identificador
		@argumentos = a	#Listas<Argumentos o []
		@checked = false
	end

	def print_ast indent = ""
		puts "#{indent}Llamada a Funcion"
		attrs.each do |a|
			a.print_ast indent + "      " if a.respond_to? :print_ast
		end
	end
end

class ExpresionBinaria < AST
	attr_accessor :derecha, :izquierda, :checked
	def initialize o1, o2
		@izquierda = o1 # Lado Izquierdo
		@derecha = o2 # Lado Direcho
		@checked = false
	end
	def print_ast indent = "" 
		puts "#{indent}#{self.class}" #Se imprime el nombre de la clase, luego:
		puts "#{indent}    Lado izquierdo" #Se avisa el elemento sintáctico de cada lado
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast #Y se imprime el elemento
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class ExpresionAritmetica < ExpresionBinaria
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #Numero
		@derecha = o2   #Numero
		@tipo = "number"
		@checked = false
		@linea = line
	end
end

class ExpresionBooleana < ExpresionBinaria
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #boolean
		@derecha = o2   #Booleano
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
end

class ExpresionMixta < ExpresionBinaria
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #Booleano
		@derecha = o2   #Booleano
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
end

class Suma < ExpresionAritmetica; end
class Resta < ExpresionAritmetica; end
class Multiplicacion < ExpresionAritmetica; end
class Division < ExpresionAritmetica; end
class Resto < ExpresionAritmetica; end
class DivisionEntera < ExpresionAritmetica; end
class RestoEntero < ExpresionAritmetica; end
class Conjuncion < ExpresionBooleana; end
class Disyuncion < ExpresionBooleana; end

class AsignacionParser < ExpresionBinaria
	def print_ast indent = ""
		puts "#{indent}Asignacion"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class IgualQueParser < ExpresionMixta
	def print_ast indent = ""
		puts "#{indent}Igual Que"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class MayorQueParser < ExpresionAritmetica
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #Booleano
		@derecha = o2   #Booleano
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Mayor Que"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class MenorQueParser < ExpresionAritmetica
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #Booleano
		@derecha = o2   #Booleano
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Menor Que"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class DiferenteAParser < ExpresionMixta
	def print_ast indent = ""
		puts "#{indent}Diferente Que"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class MayorIgualQueParser < ExpresionAritmetica
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #Booleano
		@derecha = o2   #Booleano
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Mayor Igual Que"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

class MenorIgualQueParser < ExpresionAritmetica
	attr_accessor :tipo, :izquierda, :derecha, :checked, :linea
	def initialize o1, o2, line
		@izquierda = o1 #Booleano
		@derecha = o2   #Booleano
		@tipo = "boolean"
		@checked = false
		@linea = line
	end
	def print_ast indent = ""
		puts "#{indent}Menor Igual Que"
		puts "#{indent}    Lado izquierdo"
		@izquierda.print_ast indent + "      " if @izquierda.respond_to? :print_ast
		puts "#{indent}    Lado derecho"
		@derecha.print_ast indent + "      " if @derecha.respond_to? :print_ast
	end
end

################################################Elementos con forma Variable (Hojas del Arbol)###########################################

class Identificador < AST
	attr_accessor :token, :nombre
	def initialize token
		@nombre = token.text #Esta es su forma
		@token = token
	end
	def print_ast indent = ""
		puts "#{indent}#{self.class}"
		puts "#{indent}    nombre: #{@nombre}" #Se avisa y se imprime su forma
	end
end

class Numero < AST
	attr_accessor :valor, :token, :tipo
	def initialize v
		@valor = v.text
		@token = v
		@tipo = "number"
	end
	def print_ast indent = ""
		puts "#{indent}Literal Numerico "
		puts "#{indent}    valor: #{@valor}"
	end
end

class Booleano < AST
	attr_accessor :valor, :token, :tipo
	def initialize v
		@valor = v.text
		@token = v
		@tipo = "boolean"
	end
	def print_ast indent = ""
		puts "#{indent}Booleano"
		puts "#{indent}    valor: #{@valor}"
	end
end

class CadenaDeCaracteresParser < AST
	attr_accessor :valor, :token
	def initialize f
		@token = f
		@valor = f.text
	end
	def print_ast indent = ""
		puts "#{indent}Cadena De Caracteres"
		puts "#{indent}    forma: #{@valor}"
	end
end
################################################################