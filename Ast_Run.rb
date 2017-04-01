require_relative 'Ast.rb'
require_relative 'Ast_check_table.rb'
require_relative 'ValTable.rb'
require_relative 'Run_Expr.rb'
require_relative 'PortableBitMapGen.rb'

###############################################################################
# Definiciones de los métodos necesarios para "traducir" cada Instrucción de
# Retina a su equivalente en Ruby y luego ejecutarla de manera adecuada.
#
#El método común run_inst será el método que ejecuta la instrucción.
###############################################################################


$tabla_de_valores = TablaValores.new("de Valores")	#Tabla que recolecta los valores Numéricos y Booleanos que van siendo utilizados a lo largo de un programa de Retina
													#Los valores son guardados como [nombre del identificador, tipo, valor]
$tabla_de_inst_de_funcion = {}						#Tabla con la lista de instrucciones de cada funcion y su nombre, usada como referencia para llamadas
$stack_funciones = []								#Stack que permite identificar casos de corecursión
$retina = Turtle.new()								#Objeto que permite dibujar mediante metodos de Turtle graphics.

#Ejecución principal de un programa de retina
class Programa
	def run_inst
		#Las instrucciones de las funciones son guardadas en su Tabla
		if @funciones.respond_to? :lista
			@funciones.lista.each do |f|
				if f.argumentos.respond_to? :lista
					#Junto con el número de argumentos que estas requieren
					$tabla_de_inst_de_funcion[f.ident.nombre] = {:inst => f.instruccionesfu, :args => f.argumentos.lista} 
				else
					$tabla_de_inst_de_funcion[f.ident.nombre] = {:inst => f.instruccionesfu, :args => []}
				end
			end
		end
		#Luego se corren las instrucciones, en orden.
		if @instrucciones.respond_to? :lista
			@instrucciones.lista.each do |i|
				i.run_inst($tabla_de_valores) if i.respond_to? :run_inst
			end
		end
	end
end

#Instrucción Bloque
class Bloque
	def run_inst padre
		#Crea su propia tabla de valores para limitar el alcance de los valores definidos dentro de este.
		tabla = TablaValores.new("Bloque", padre)
		#Guarda en su tabla el valor de cada definicion
		if @declaraciones.respond_to? :lista
			#Si es una asignación, guarda el valor dado
			@declaraciones.lista.each do |d|
				if d.identoAsig.is_a?(AsignacionParser)
					tp = d.tipo.nombre
					#corriendo su run_inst
					d.identoAsig.run_inst(tabla, tp, true) if d.identoAsig.respond_to? :run_inst
				end
			#En cambio, si es solo un identificador
				if d.identoAsig.is_a?(Identificador)
					var = d.identoAsig
					#Se guarda con su valor default
					if d.tipo.nombre == "number"
						tabla.insertar(var.nombre, 0.0, d.tipo.nombre)
					elsif d.tipo.nombre == "boolean"
						tabla.insertar(var.nombre, false, d.tipo.nombre)
					end
				end
			end
		end
		#Luego las instrucciones del bloque son corridas en orden, con la tabla
		#creada acá como la tabla usada/en la que se guardará cualquier nuevo valor definido
		if @instrucciones.respond_to? :lista
			@instrucciones.lista.each do |i|
				i.run_inst(tabla) if i.respond_to? :run_inst
			end
		end
	end
	
	def toBoolean str
		if str == "false"
			return false
		else
			return true
		end
	end
end

#La funcion foo.encontrar_valor busca el valor que una expresión tendría a momento de ejecución,
#si es un identificador, lo busca en la tabla de valores dada.

#Instruccion Salida por terminal
class Salidas
	def run_inst padre
		#Sobre cada objeto dentro de la instruccion de impresion
		@lista.each do |s|
			#se busca su valor
			f = s.encontrar_valor(padre)
			if s.encontrar_valor(padre).respond_to? :round
				if s.encontrar_valor(padre).round == s.encontrar_valor(padre)
					f = s.encontrar_valor(padre).round
				end
			end
			#luego es impreso mediante los metodos de ruby
			if f.respond_to? :each
				f.each do |g|
					print g
				end
			elsif
				print f
			end
		end
		#si la instruccion es writeln, simulamos puts "" de Ruby
		if @salto
			puts
		end
	end
end

# Instruccion de Asignacion
class AsignacionParser
	# decl permite saber si la asignacion es parte de una declaracion, 
	# o una instruccion nueva
	def run_inst padre, iztipo = nil, decl = false
		# identificamos el valor de la derecha
		de = @derecha.encontrar_valor(padre)
		if iztipo.nil?
			iztipo = padre.buscaTipo(@izquierda.nombre)
		end
		if decl
			#lo insertamos como valor nuevo
			padre.insertar(@izquierda.nombre, de, iztipo)
		else
			#o lo modificamos segun el identificador de la izquierda
			padre.encontrar_insertar(@izquierda.nombre, de, iztipo)
		end
	end
end

# Instruccion If

class CondIf
	def run_inst padre
		#Encontramos el valor de la instruccion de guardia
		g = @guardia.encontrar_valor(padre)
		if g #Si es true
			if @instruccion.respond_to? :lista
				#corremos la lista de instrucciones del if, en orden.
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
		end
	end
end

# Instruccion If-Else

class CondIfElse
	def run_inst padre
		#Encontramos el valor de la instruccion de guardia
		g = @guardia.encontrar_valor(padre)
		if g #Si es true
			if @instruccion.respond_to? :lista
				#corremos la lista de instrucciones del if, en orden.
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
		else #Si no
			if @instruccion2.respond_to? :lista
				#corremos la lista de instrucciones del else, en orden.
				@instruccion2.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
		end
	end
end

#Instruccion While

class IterWhile
	def run_inst padre
		#Encontramos el valor de la instruccion de guardia
		g = @guardia.encontrar_valor(padre)
		while g #mientras sea true
			if @instruccion.respond_to? :lista
				#corremos la lista de instrucciones en orden.
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
			#Y encontramos el valor de la instruccion de guardia una vez más
			g = @guardia.run_inst(padre) if @guardia.respond_to? :run_inst
		end
	end
end

#instruccion For

class IterFor
	def run_inst padre
		#Encontramos el valor del rango de iteracion
		d = @desde.encontrar_valor(padre).floor
		h = @hasta.encontrar_valor(padre).floor
		tabla = TablaValores.new("For", padre)
		#Y guardamos el contador en una nueva tabla, única del for
		#con el valor del inicio de la iteracion
		tabla.insertar(@ident.nombre, d, "number")
		
		while d <= h #Mientras el contador esté en su rango
			if @instruccion.respond_to? :lista
				#Se corren las instrucciones del for, en orden
				@instruccion.lista.each do |i|
					i.run_inst(tabla) if i.respond_to? :run_inst
				end
			end
			# Se aumenta en 1 el contador
			d += 1
			# Y su nuevo valor es guardado en su tabla
			tabla.encontrar_insertar(@ident.nombre, d, "number")
		end
		
	end
end

#Instruccion For con by
class IterForBy
	def run_inst padre
		#Encontramos el valor del rango de iteracion
		d = @desde.encontrar_valor(padre).floor
		h = @hasta.encontrar_valor(padre).floor
		#Y el de salto de rango
		t = @por.encontrar_valor(padre)
		#Y guardamos el contador en una nueva tabla, única del for
		#con el valor del inicio de la iteracion
		tabla = TablaValores.new("ForBy", padre)
		tabla.insertar(@ident.nombre, d, "number")
		
		while d <= h #Mientras el contador esté en su rango
			if @instruccion.respond_to? :lista
				#Se corren las instrucciones del for, en orden
				@instruccion.lista.each do |i|
					i.run_inst(tabla) if i.respond_to? :run_inst
				end
			end
			# Se aumenta en t el contador
			d += t
			# Y su nuevo valor es guardado en su tabla
			tabla.encontrar_insertar(@ident.nombre, d, "number")
		end
	end
end

#Instruccion Repeat

class IterRepeat
	def run_inst padre
		#Encontramos el valor del numero de iteraciones
		v = @veces.encontrar_valor(padre).floor
		count = 1
		while count <= v
			#Se corren las instrucciones del repeat, en orden
			if @instruccion.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
			#Y se suma en 1 el contador
			count += 1
		end
	end
end

#Instruccion Entrada
class Entrada
	def run_inst padre
		#Se toma por la entrada standard de la terminal de ruby un valor dado por el usuario
		ioin = STDIN.gets().chomp
		#La entrada es segregada mediante expresiones regulares
		catchin = /\A[-]?[0-9]+\.[0-9]+|\A[-]?[0-9]+|\Afalse|\Atrue/
		ioin =~ catchin
		str = $&
		afterstr = $'
		#Si la entrada es distinta a un valor numérico o booleano, se aborta el programa y se imprime un mensaje de error
		if afterstr != ""
			puts "La entrada no es un dato válido."
			abort
		end
		#Si la entrada es distinta al tipo del identificador usado, se aborta el programa y se imprime un mensaje de error
		tipo = padre.buscaTipo(@op.nombre)
		if tipo == "boolean"
			if toBoolean(str) == 0
				puts "La entrada no es un dato válido. (debe ser 'true' o 'false')"
				abort
			else
				#Si es válida entonces se guarda en la tabla usada el valor conseguido
				padre.encontrar_insertar(@op.nombre, toBoolean(str) , "boolean")
			end
		else
			if str.to_f == 0 && (str != "0" && str != "0.0" && str != "-0" && str != "-0.0")
				puts "La entrada no es un dato válido. (debe ser un valor numérico)"
				abort
			else
				padre.encontrar_insertar(@op.nombre, str.to_f , "number")
			end
		end
	end
	
	def toBoolean str
		if str == "false"
			return false
		elsif str == "true"
			return true
		else
			return 0
		end
	end
end

#LLamadas a funcion 
class Llamada
	def run_inst padre
		rtn = nil
		# En principio revisa si la llamada ya está en el stack, si lo está significa que hay correcursion y se aborta el programa
		if $stack_funciones.include?(@ident.nombre)
			if !($stack_funciones.pop == @ident.nombre)
				puts "No se permite corecursión sobre las funciones. (función #{@ident.nombre} llamada durante su corrida desde una función distinta)"
				abort
			else
				$stack_funciones << @ident.nombre
			end
		end
		#Si no, entra en el stack de funciones
		$stack_funciones << @ident.nombre
		
		#Luego se busca si su nombre está entre las funciones base de retina
		
		if $basefunc.has_key?(@ident.nombre)
			listargs = @argumentos.lista if @argumentos.respond_to? :lista
			if listargs[0].nil?
				a = nil
			else
				a = listargs[0].encontrar_valor(padre)
			end
			
			if listargs[1].nil?
				b = nil
			else
				b = listargs[1].encontrar_valor(padre)
			end
			#Y esta es llamada con los argumentos dados
			$basefunc[@ident.nombre].call(a, b)
		else
			#Si no, se corren las instrucciones como especifica la funcion run_func
			rtn = run_func(padre)
		end
		#Por ultimo, sale del stack la funcion
		$stack_funciones.pop
		
		return rtn
	end
	
	def run_func padre
		#La lista de instrucciones y argumentos necesarios es buscada según el nombre de la funcion que se corre
		listinst = $tabla_de_inst_de_funcion[@ident.nombre][:inst]
		listargs = $tabla_de_inst_de_funcion[@ident.nombre][:args]
		#Se crea una nueva tabla de alcance unico para la funcion
		tabla_func = TablaValores.new("Funcion #{@indent}")
		count_arg = 0
		#Cada parametro es guardado en esta tabla con el identificador que le corresponde
		if @argumentos.respond_to? :lista
			@argumentos.lista.each do |a|
				tabla_func.insertar(listargs[count_arg].ident.nombre, a.encontrar_valor(padre), listargs[count_arg].tipo.nombre)
				count_arg += 1
			end
		end
		tabla_func.insertar(@ident.nombre.capitalize, 0, "number")
		
		#Se corre cada instrucción en orden
		
		if listinst.respond_to? :lista
			listinst.lista.each do |i|
				i.run_inst(tabla_func) if i.respond_to? :run_inst
			end
		end
		
		#Se retorna el valor de retorno de la función
		return tabla_func.buscaValor(@ident.nombre.capitalize)
	end
	
	def encontrar_valor padre
		#esta funcion permite que buscar el valor de una llamada sea equivalente a correrla
		return run_inst(padre)
	end
end