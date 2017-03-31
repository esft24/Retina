require_relative 'Ast.rb'
require_relative 'Ast_check_table.rb'
require_relative 'ValTable.rb'
require_relative 'Run_Expr.rb'
require_relative 'PortableBitMapGen.rb'

$tabla_de_valores = TablaValores.new("de Valores")
$tabla_de_inst_de_funcion = {}
$stack_funciones = []
$retina = Turtle.new()

class Programa
	def run_inst
		if @funciones.respond_to? :lista
			@funciones.lista.each do |f|
				$tabla_de_inst_de_funcion[f.ident.nombre] = {:inst => f.instruccionesfu, :args => f.argumentos.lista}
			end
		end
		if @instrucciones.respond_to? :lista
			@instrucciones.lista.each do |i|
				i.run_inst($tabla_de_valores) if i.respond_to? :run_inst
			end
		end
	end
end

class Bloque
	def run_inst padre
		tabla = TablaValores.new("Bloque", padre)
		if @declaraciones.respond_to? :lista
			@declaraciones.lista.each do |d|
				if d.identoAsig.is_a?(AsignacionParser)
					tp = d.tipo.nombre
					d.identoAsig.run_inst(tabla, tp, true) if d.identoAsig.respond_to? :run_inst
				end
				
				if d.identoAsig.is_a?(Identificador)
					var = d.identoAsig
					
					if d.tipo.nombre == "number"
						tabla.insertar(var.nombre, 0.0, d.tipo.nombre)
					elsif d.tipo.nombre == "boolean"
						tabla.insertar(var.nombre, false, d.tipo.nombre)
					end
				end
			end
		end
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

class Salidas
	def run_inst padre
		@lista.each do |s|
			f = s.encontrar_valor(padre)
			if s.encontrar_valor(padre).respond_to? :round
				if s.encontrar_valor(padre).round == s.encontrar_valor(padre)
					f = s.encontrar_valor(padre).round
				end
			end
			if f.respond_to? :each
				f.each do |g|
					print g
				end
			elsif
				print f
			end
		end
		if @salto
			puts
		end
	end
end

class AsignacionParser
	def run_inst padre, iztipo = nil, decl = false
		de = @derecha.encontrar_valor(padre)
		if iztipo.nil?
			iztipo = padre.buscaTipo(@izquierda.nombre)
		end
		if decl
			padre.insertar(@izquierda.nombre, de, iztipo)
		else
			padre.encontrar_insertar(@izquierda.nombre, de, iztipo)
		end
	end
end

class CondIf
	def run_inst padre
		g = @guardia.encontrar_valor(padre)
		if g
			if @instruccion.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
		end
	end
end

class CondIfElse
	def run_inst padre
		g = @guardia.encontrar_valor(padre)
		if g
			if @instruccion.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
		else
			if @instruccion2.respond_to? :lista
				@instruccion2.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
		end
	end
end

class IterWhile
	def run_inst padre
		g = @guardia.encontrar_valor(padre)
		while g
			if @instruccion.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
			g = @guardia.run_inst(padre) if @guardia.respond_to? :run_inst
		end
	end
end

class IterFor
	def run_inst padre
		d = @desde.encontrar_valor(padre).floor
		h = @hasta.encontrar_valor(padre).floor
		tabla = TablaValores.new("For", padre)
		tabla.insertar(@ident.nombre, d, "number")
		
		while d <= h
			if @instruccion1.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(tabla) if i.respond_to? :run_inst
				end
			end
			d += 1
			tabla.encontrar_insertar(@ident.nombre, d, "number")
		end
		
	end
end

class IterForBy
	def run_inst padre
		d = @desde.encontrar_valor(padre).floor
		h = @hasta.encontrar_valor(padre).floor
		t = @por.encontrar_valor(padre)
		tabla = TablaValores.new("ForBy", padre)
		tabla.insertar(@ident.nombre, d, "number")
		
		while d <= h
			if @instruccion.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(tabla) if i.respond_to? :run_inst
				end
			end
			d += t
			tabla.encontrar_insertar(@ident.nombre, d, "number")
		end
	end
end

class IterRepeat
	def run_inst padre
		v = @veces.encontrar_valor(padre).floor
		count = 1
		while count <= v
			if @instruccion2.respond_to? :lista
				@instruccion.lista.each do |i|
					i.run_inst(padre) if i.respond_to? :run_inst
				end
			end
			count += 1
		end
	end
end

class Entrada
	def run_inst padre
		ioin = STDIN.gets().chomp
		catchin = /\A[-]?[0-9]+\.[0-9]+|\A[-]?[0-9]+|\Afalse|\Atrue/
		ioin =~ catchin
		str = $&
		afterstr = $'
		if afterstr != ""
			puts "La entrada no es un dato válido."
			abort
		end
		tipo = padre.buscaTipo(@op.nombre)
		if tipo == "boolean"
			if toBoolean(str) == 0
				puts "La entrada no es un dato válido. (debe ser 'true' o 'false')"
				abort
			else
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

class Llamada
	def run_inst padre
		rtn = nil
		if $stack_funciones.include?(@ident.nombre)
			if !($stack_funciones.pop == @ident.nombre)
				puts "No se permite corecursión sobre las funciones. (función #{@ident.nombre} llamada durante su corrida desde una función distinta)"
				abort
			else
				$stack_funciones << @ident.nombre
			end
		end
		$stack_funciones << @ident.nombre
		if $basefunc.has_key?(@ident.nombre)
			listargs = @argumentos.lista
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
			
			$basefunc[@ident.nombre].call(a, b)
		else
			rtn = run_func(padre)
		end
		$stack_funciones.pop
		
		return rtn
	end
	
	def run_func padre
		listinst = $tabla_de_inst_de_funcion[@ident.nombre][:inst]
		listargs = $tabla_de_inst_de_funcion[@ident.nombre][:args]
		tabla_func = TablaValores.new("Funcion #{@indent}")
		count_arg = 0
		@argumentos.lista.each do |a|
			tabla_func.insertar(listargs[count_arg].ident.nombre, a.encontrar_valor(padre), listargs[count_arg].tipo.nombre)
			count_arg += 1
		end
		
		tabla_func.insertar(@ident.nombre.capitalize, 0, "number")
		
		listinst.lista.each do |i|
			i.run_inst(tabla_func) if i.respond_to? :run_inst
		end

		
		return tabla_func.buscaValor(@ident.nombre.capitalize)
	end
	
	def encontrar_valor padre
		return run_inst(padre)
	end
end