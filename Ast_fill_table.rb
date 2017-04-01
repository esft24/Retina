require_relative 'Ast.rb'
require_relative 'SymTable.rb'

$tabla_de_tablas = TablaSimbolos.new("Principal", "Maestra")
$tabla_de_funciones = TablaSimbolos.new("Principal", "Funciones", $tabla_de_tablas)
$tabla_de_programa = TablaSimbolos.new("Principal", "Programa", $tabla_de_tablas)
$Bloque_COunt = 0
$lista_errores_sintacticos = []
$calls_to_check = []
$func_to_define = {}

######################################################################

class AST
	def fill_table padre = $tabla_de_tablas
		attrs.each do |a|
			a.fill_table(padre) if a.respond_to? :fill_table
		end
	end
	
	def buscarRetorno
		retorno = false
		attrs.each do |i|
			if i.is_a?(Retorno)
				retorno = true
			else
				retorno = i.buscarRetorno if i.respond_to? :buscarRetorno
				if retorno == true
					break
				end
			end
		end
		return retorno
	end
end

class Listas
	def buscarRetorno
		retorno = false
		@lista.each do |i|
			if i.is_a?(Retorno)
				retorno = true
				return retorno
			else
				retorno = i.buscarRetorno if i.respond_to? :buscarRetorno
				if retorno == true
					break
				end
			end
		end
		return retorno
	end
end

class Programa
	def fill_table
		if @funciones.respond_to? :lista
			@funciones.lista.each do |f| 
				if f.is_a?(FuncionConTipo)
					$func_to_define[f.ident.nombre] = [f.tipo.nombre, f.argumentos]
				else
					$func_to_define[f.ident.nombre] = [nil, f.argumentos]
				end
			end
		end
		@funciones.fill_table($tabla_de_funciones) if @funciones.respond_to? :fill_table
		@instrucciones.fill_table($tabla_de_programa) if @instrucciones.respond_to? :fill_table
	end
end

class Instrucciones
	def fill_table padre = $tabla_de_tablas
		@lista.each do |f|
			f.fill_table(padre) if f.respond_to? :fill_table
		end
		
		@lista.each do |f|
			if f.is_a?(AsignacionParser)
				f.check_table(padre)
			end
			
			if f.is_a?(CondIf) || f.is_a?(CondIfElse) || f.is_a?(IterWhile)
				f.check_table(padre)
			end
			
			if f.is_a?(Llamada)
				f.check_table(padre)
			end
			
			if f.is_a?(Retorno)
				f.check_table(padre)
			end
			
			if f.is_a?(IterFor) || f.is_a?(IterForBy) || f.is_a?(IterRepeat)
				f.check_table(padre)
			end
			
			if f.is_a?(Entrada) || f.is_a?(Salidas) || f.is_a?(SalidasConSalto)
				f.check_table(padre)
			end
		end
	end
end

class Bloque
	def fill_table padre
		tabla = TablaSimbolos.new("Bloque", "Bloque #{$Bloque_COunt}", padre)
		$Bloque_COunt += 1
		simbolos = @declaraciones.conseguir_decl(tabla) if @declaraciones.respond_to? :conseguir_decl
		if simbolos.respond_to? :each
			simbolos.each do |s|
				tabla.insertar(s[0], s[1])
			end
		end
		attrs.each do |a|
			a.fill_table(tabla) if a.respond_to? :fill_table
		end
	end
end

class Declaraciones
	def conseguir_decl tabla
		lista_de_simbolos = []
		forma_del_simbolo = {}
		@lista.each do |s|
			check_tipo_decl(s, tabla) if s.identoAsig.is_a?(AsignacionParser)
			lista_de_simbolos << [s.identoAsig.token, s.tipo.nombre]
			if forma_del_simbolo.has_key?(s.identoAsig.token.text)	
				$lista_errores_sintacticos << "Variables no pueden ser redeclaradas dentro del mismo bloque (linea #{s.identoAsig.token.line})"
			end
			forma_del_simbolo[s.identoAsig.token.text] = s.identoAsig.token
		end
		return lista_de_simbolos
	end
	
	def check_tipo_decl declaracion, tabla
		if declaracion.tipo.nombre != declaracion.identoAsig.derecha.encontrar_tipo(tabla)
			$lista_errores_sintacticos << "Variable declarada en la linea #{declaracion.identoAsig.izquierda.token.line} no corresponde al tipo declarado"
		end
	end
end

class AsignacionParser
	def token
		return @izquierda.token
	end
end

######################################################################

class Funciones
	def fill_table padre = $tabla_de_tablas
		@lista.each do |f|
			f.fill_table(padre) if f.respond_to? :fill_table
		end
	end
end

class Funcion
	def fill_table padre = $tabla_de_funciones
		if padre.encontrarBloque(@ident.nombre) == true
			$lista_errores_sintacticos << "Una función no puede ser declarada si tiene el mismo nombre de una declarada anteriormente (linea #{@ident.token.line})"
		end
		tabla = TablaSimbolos.new("Funcion", "#{@ident.nombre}", padre, nil, @argumentos)
		if @argumentos != []
			@argumentos.conseguir_decl(tabla)
		end
		if @instruccionesfu.buscarRetorno == true
			$lista_errores_sintacticos << "La función #{@ident.nombre} no puede tener una instrucción de retorno"
		end
		@instruccionesfu.fill_table(tabla)
	end
end

class FuncionConTipo 
	def fill_table padre = $tabla_de_funciones
		if padre.encontrarBloque(@ident.nombre) == true
			$lista_errores_sintacticos << "Una función no puede ser declarada si tiene el mismo nombre de una declarada anteriormente (linea #{@ident.token.line})"
		end
		tabla = TablaSimbolos.new("Funcion", "#{@ident.nombre}", padre, "#{@tipo.nombre}", @argumentos)
		if @argumentos != []
			@argumentos.conseguir_decl(tabla)
		end
		if @instruccionesfu.buscarRetorno == false
			$lista_errores_sintacticos << "La función #{@ident.nombre} debe tener una instrucción de retorno"
		end
		@instruccionesfu.fill_table(tabla)
	end
end

class Argumentos
	def conseguir_decl tabla
		lista_de_simbolos = []
		@lista.each do |s|
			if tabla.tabla.has_key?(s.ident.token.text)
				$lista_errores_sintacticos << "2 argumentos no pueden tener el mismo nombre en una misma funcion (linea #{s.ident.token.line})"
			end
			tabla.insertar(s.ident.token, s.tipo.nombre)
		end
		return lista_de_simbolos
	end
end

#######################################################################

class IterFor
	def fill_table padre = $tabla_de_tablas
		tabla = TablaSimbolos.new("Iteracion for", "For", padre)
		tabla.insertar(@ident.token, "number")
		@instruccion.fill_table(tabla)
	end
end

class IterForBy
	def fill_table padre = $tabla_de_tablas
		tabla = TablaSimbolos.new("Iteracion for", "For", padre)
		tabla.insertar(@ident.token, "number")
		@instruccion.fill_table(tabla)
	end
end