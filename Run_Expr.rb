class ExpresionBinaria
	def encontrar_valor padre
		return run_inst(padre)
	end
end

class ExpresionUnaria
	def encontrar_valor padre
		return run_inst(padre)
	end
end

class Identificador
	def encontrar_valor padre
		return padre.buscaValor(@nombre)
	end
end

class Numero
	def encontrar_valor padre
		return @valor.to_f
	end
end

class Booleano
	def encontrar_valor padre
		return toBoolean(@valor)
	end
	
	def toBoolean str
		if str == "false"
			return false
		else
			return true
		end
	end
end

class CadenaDeCaracteresParser
	def encontrar_valor padre
		f = fixstr
		return f
	end
	
	def fixstr
		str = @valor[0..-2]
		char = /\A[^\\]*/
		strfin = []
		while str.size != 0
			if str[1] != "n"
				str = str[1..-1]
			else
				str = str[2..-1]
				strfin << "\n"
			end
			str =~ char
			strfin << $&
			str = $'
		end
		return strfin
	end
end

class Suma 
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		return (iz + de)
	end
end

class Resta 
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz - de)
	end
end

class Multiplicacion
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz * de)
	end
end

class Division
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		if de == 0.0
			puts "No se puede dividir entre 0 (linea #{@line})"
			abort
		end
		
		return (iz / de)
	end
end

class DivisionEntera
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		if de == 0.0
			puts "No se puede dividir entre 0 (linea #{@line})"
			abort
		end
		
		return (iz / de).floor
	end
end

class Resto
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		if de == 0.0
			puts "No se puede dividir entre 0 (linea #{@line})"
			abort
		end
		
		return (iz % de)
	end
end

class RestoEntero
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		if de == 0.0
			puts "No se puede dividir entre 0 (linea #{@line})"
			abort
		end
		return (iz.floor % de.floor).floor
	end
end

class Conjuncion
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz && de)
	end
end

class Disyuncion
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz || de)
	end
end

class IgualQueParser
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz == de)
	end
end

class MayorIgualQueParser
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz >= de)
	end
end

class MenorIgualQueParser
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz <= de)
	end
end

class DiferenteAParser
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz != de)
	end
end

class MayorQueParser
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz > de)
	end
end

class MenorQueParser
	def run_inst padre
		iz = @izquierda.encontrar_valor(padre)
		de = @derecha.encontrar_valor(padre)
		
		return (iz < de)
	end
end

class Minus
	def run_inst padre
		val = @op.encontrar_valor(padre)
		
		return (-val)
	end
end

class Negacion
	def run_inst padre
		val = @op.encontrar_valor(padre)
		
		return (!val)
	end
end