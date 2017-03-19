require_relative 'Ast_fill_table.rb'

##################################################################################
# Chequeo de asignaciones y expresiones unarias-binarias
class AsignacionParser
	def check_table tabla
		tipoident = @izquierda.encontrar_tipo(tabla)
		linea = @izquierda.token.line
		
		if @derecha.respond_to? :checked
			if @derecha.checked == false
				@derecha.check_table(tabla) if @derecha.respond_to? :check_table
			end
		end
		
		if @derecha.encontrar_tipo(tabla).nil?
			return
		end
		
		if tipoident != @derecha.encontrar_tipo(tabla)
			if !tipoident.nil?
				$lista_errores_sintacticos << "El tipo de la variable a asignar debe ser igual al de la expresion asignada. (linea #{linea})"
			end
		end
	end
end

class ExpresionAritmetica
	def check_table tabla		
		if @derecha.respond_to? :checked
			if @derecha.checked == false
				@derecha.check_table(tabla) if @derecha.respond_to? :check_table
			end
		end
		
		if @izquierda.respond_to? :checked
			if @izquierda.checked == false
				@izquierda.check_table(tabla) if @izquierda.respond_to? :check_table
			end
		end

		@checked = true
		
		if derecha.encontrar_tipo(tabla).nil? || izquierda.encontrar_tipo(tabla).nil?
			return
		end
		
		if derecha.encontrar_tipo(tabla) != "number" || izquierda.encontrar_tipo(tabla) != "number"
			$lista_errores_sintacticos << "Los tipos en expresiones aritméticas han de ser number. (linea #{@linea})."
		end
	end
	
	def encontrar_tipo tabla
		return tipo
	end
end

class ExpresionBooleana
	def check_table tabla
		if @derecha.respond_to? :checked
			if @derecha.checked == false
				@derecha.check_table(tabla) if @derecha.respond_to? :check_table
			end
		end
		
		if @izquierda.respond_to? :checked
			if @izquierda.checked == false
				@izquierda.check_table(tabla) if @izquierda.respond_to? :check_table
			end
		end

		@checked = true
		
		if derecha.encontrar_tipo(tabla).nil? || izquierda.encontrar_tipo(tabla).nil?
			return
		end
	
		if derecha.encontrar_tipo(tabla) != "boolean" || izquierda.encontrar_tipo(tabla) != "boolean"
			$lista_errores_sintacticos << "Los tipos en expresiones booleanas han de ser boolean. (linea #{@linea})"
		end
	end
	
	def encontrar_tipo tabla
		return tipo
	end
end

class ExpresionMixta
	def check_table tabla		
		if @derecha.respond_to? :checked
			if @derecha.checked == false
				@derecha.check_table(tabla) if @derecha.respond_to? :check_table
			end
		end
		
		if @izquierda.respond_to? :checked
			if @izquierda.checked == false
				@izquierda.check_table(tabla) if @izquierda.respond_to? :check_table
			end
		end

		@checked = true

	
		if derecha.encontrar_tipo(tabla).nil? || izquierda.encontrar_tipo(tabla).nil?
			return
		end
	
		if derecha.encontrar_tipo(tabla) != izquierda.encontrar_tipo(tabla)
			$lista_errores_sintacticos << "Los tipos en expresiones de igualdad y diferencia han de ser iguales. (linea #{@linea})."
		end
	end
	
	def encontrar_tipo tabla
		return tipo
	end
end

class Numero
	def encontrar_tipo tabla
		return tipo
	end
end

class Booleano
	def encontrar_tipo tabla
		return tipo
	end
end

class Identificador
	def encontrar_tipo tabla
		#es alcanzable
		if tabla.encontrar(@token.text).nil?
			$lista_errores_sintacticos << "La variable no está declarada. (linea #{token.line})"
			return nil
		else #es de tipo correcto
			return tabla.encontrar(@token.text)[:tipo]
		end
	end
end

class Negacion
	def check_table tabla
		if @op.respond_to? :checked
			if @op.checked == false
				@op.check_table(tabla) if @op.respond_to? :check_table
			end
		end
		
		@checked = true

		if @op.encontrar_tipo(tabla).nil?
			return
		end
		
		if @op.encontrar_tipo(tabla) != "boolean"
			$lista_errores_sintacticos << "El tipo del valor a negar con un \"not \" debe ser boolean. (linea #{@linea})"
		end
	end
	
	def encontrar_tipo tabla
		return tipo
	end
end

class Minus
	def check_table tabla
		if @op.respond_to? :checked
			if @op.checked == false
				@op.check_table(tabla) if @op.respond_to? :check_table
			end
		end
		
		@checked = true

		if @op.encontrar_tipo(tabla).nil?
			return
		end
		
		if @op.encontrar_tipo(tabla) != "number"
			$lista_errores_sintacticos << "El tipo del valor a negar con un \"-\" unario debe ser number. (linea #{@linea})"
		end
	end
	
	def encontrar_tipo tabla
		return tipo
	end
end

##################################################################################
# Chequeo de Instrucciones condicionales

class CondIf
	def check_table tabla
		if @guardia.respond_to? :checked
			if @guardia.checked == false
				@guardia.check_table(tabla) if @guardia.respond_to? :check_table
			end
		end
		
		if @guardia.encontrar_tipo(tabla).nil?
			return
		end
		
		if @guardia.encontrar_tipo(tabla) != "boolean"
			$lista_errores_sintacticos << "El tipo de una expresion de guardia en una instrucción condicional debe ser booleano. (linea #{@linea})"
		end
	end
end

class CondIfElse
	def check_table tabla
		if @guardia.respond_to? :checked
			if @guardia.checked == false
				@guardia.check_table(tabla) if @guardia.respond_to? :check_table
			end
		end
		
		if @guardia.encontrar_tipo(tabla).nil?
			return
		end
		
		if @guardia.encontrar_tipo(tabla) != "boolean"
			$lista_errores_sintacticos << "El tipo de una expresion de guardia en una instrucción condicional debe ser booleano. (linea #{@linea})"
		end
	end
end

class IterWhile
	def check_table tabla
		if @guardia.respond_to? :checked
			if @guardia.checked == false
				@guardia.check_table(tabla) if @guardia.respond_to? :check_table
			end
		end
		
		if @guardia.encontrar_tipo(tabla).nil?
			return
		end
		
		if @guardia.encontrar_tipo(tabla) != "boolean"
			$lista_errores_sintacticos << "El tipo de una expresion de guardia en una instrucción condicional debe ser booleano. (linea #{@linea})"
		end
	end
end

###################################################################################
# Chequeo de Llamadas a Función

class Llamada
	def check_table padre
		@argumentos.lista.each do |f|
			f.check_table(padre) if f.respond_to? :check_table
		end
		
		#chequear existencia de funcion
		if !$tabla_de_funciones.hijo.has_key?(@ident.nombre)
			$lista_errores_sintacticos << "La función #{@ident.nombre} no existe (linea #{@ident.token.line})"
			return
		end
		#chequear numero argumentos
		if @argumentos.lista.size != $tabla_de_funciones.hijo[@ident.nombre].argumentos.lista.size
			$lista_errores_sintacticos << "La función #{@ident.nombre} recibe #{@argumentos.lista.size} argumento(s) cuando requiere #{$tabla_de_funciones.hijo[@ident.nombre].argumentos.lista.size} (linea #{@ident.token.line})"
			return
		end
		#chequear tipo argumentos
		listaparam = $tabla_de_funciones.hijo[@ident.nombre].argumentos.lista
		
		v = @argumentos.lista.size
		for i in (0..v - 1)
			if @argumentos.lista[i].encontrar_tipo(padre) != listaparam[i].tipo.nombre
				$lista_errores_sintacticos << "La función #{@ident.nombre} recibe argumentos de tipo incorrecto. Argumento #{i + 1} de tipo #{@argumentos.lista[i].encontrar_tipo(padre)} debe ser un #{listaparam[i].tipo.nombre}"
			end
		end
	end
	
	def encontrar_tipo tabla
		if !$tabla_de_funciones.hijo[@ident.nombre].retorno.nil?
			return $tabla_de_funciones.hijo[@ident.nombre].retorno
		else
			$lista_errores_sintacticos << "Una función sin retorno no puede ser parte de una asignación (linea #{@ident.token.line})"
			return nil
		end
	end
end

########################################################################################################
# Chequeo de instruccion de retorno

class Retorno
	def check_table tabla
		@op.check_table if @op.respond_to? :check_table
		
		ret = tabla.retornoTipo
		
		if @op.encontrar_tipo(tabla) != ret
			$lista_errores_sintacticos << "La función #{tabla.nombre} no regresa un valor del tipo especificado."
		end
	end
end

##########################################################################################################
# Chequeo de Iteradores cuantitativos

class IterFor
	def check_table tabla
		@desde.check_table(tabla) if @desde.respond_to? :check_table
		@hasta.check_table(tabla) if @hasta.respond_to? :check_table
		
		if @desde.encontrar_tipo(tabla).nil?
			return
		end
		
		if @hasta.encontrar_tipo(tabla).nil?
			return
		end
		
		if @desde.encontrar_tipo(tabla) != "number" || @desde.encontrar_tipo(tabla) != "number"
			$lista_errores_sintacticos << "El tipo de una expresion de guardia en una instrucción de iteración determinada debe ser number. (linea tal)"
		end
	end
end

class IterForBy
	def check_table tabla
		@desde.check_table(tabla) if @desde.respond_to? :check_table
		@hasta.check_table(tabla) if @hasta.respond_to? :check_table
		@por.check_table(tabla) if @por.respond_to? :check_table
		
		if @desde.encontrar_tipo(tabla).nil?
			return
		end
		
		if @hasta.encontrar_tipo(tabla).nil?
			return
		end
		
		if @por.encontrar_tipo(tabla).nil?
			return
		end
		
		if @desde.encontrar_tipo(tabla) != "number" || @hasta.encontrar_tipo(tabla) != "number" || @por.encontrar_tipo(tabla) != "number"
			$lista_errores_sintacticos << "El tipo de una expresion de guardia en una instrucción de iteración determinada debe ser number. (linea tal)"
		end
	end
end

class IterRepeat
	def check_table tabla
		@veces.check_table(tabla) if @veces.respond_to? :check_table
		
		if @veces.encontrar_tipo(tabla).nil?
			return
		end
		
		if @veces.encontrar_tipo(tabla) != "number"
			$lista_errores_sintacticos << "El tipo de una expresion de guardia en una instrucción de iteración determinada debe ser number. (linea tal)"
		end
	end
end

##########################################################################################################
# Chequeo de Entradas, Salidas y Salidas con Salto

class Entrada
	def check_table tabla
		@op.encontrar_tipo(tabla)
	end
end

class Salidas
	def check_table tabla
		@lista.each do |s|
			s.check_table(tabla) if s.respond_to? :check_table
			s.encontrar_tipo(tabla) if s.respond_to? :check_table
		end
	end
end

class SalidasConSalto
	def check_table tabla
		@lista.each do |s|
			s.check_table(tabla) if s.respond_to? :check_table
			s.encontrar_tipo(tabla) if s.respond_to? :check_table
		end
	end
end
