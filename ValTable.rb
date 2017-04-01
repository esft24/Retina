#Clase que permite asociar varias tablas de hash de manera que estas puedan ser
#consultadas de manera ascendente para simular así una tabla de valores
#que permitan verificar la los datos de las distintas variables de un programa de
#Retina durante su corrida.

class TablaValores
	attr_accessor :tabla, :hijo, :nombre, :padre, :indent
	def initialize nombre, padre = nil
		@nombre = nombre
		@padre = padre
		@hijo = {}
		if not(padre.nil?) then
			@padre.hijo[nombre] = self
		end
		@tabla = {}
		@indent = ""
		if not(@padre.nil?) then
			@indent = @padre.indent + "      "
		end
	end
	
	def insertar nombre, valor, tipo
		@tabla[nombre] = { :valor => valor, :tipo => tipo}
	end
	
	def encontrar_insertar nombre, valor, tipo
		tabla = buscaTabla(nombre)
		tabla[nombre] = { :valor => valor, :tipo => tipo}
	end
	
	def buscaValor nombre
		if @tabla.has_key?(nombre)
			val = @tabla[nombre][:valor]
		else
			val = @padre.buscaValor(nombre)
		end
		return val
	end
	
	def buscaTipo nombre
		if @tabla.has_key?(nombre)
			val = @tabla[nombre][:tipo]
		else
			val = @padre.buscaTipo(nombre)
		end
		return val
	end
	
	def buscaTabla nombre
		if @tabla.has_key?(nombre)
			tablare = @tabla
		else
			tablare = @padre.buscaTabla(nombre)
		end
		return tablare
	end
	
	def insertarRetorno nombre, valor
		tabla = buscaTabla(:retorno)
		tabla[:retorno] = { :valor => valor}
	end
	
	def print_valtab
		puts "#{indent}Tabla #{@nombre}."
		puts "#{indent}   Variables:"
		if @tabla.empty?
			puts "#{indent}     None."
		else
			@tabla.each do |tk, hsh|
				puts "#{indent}     " + tk + " de tipo " + hsh[:tipo] + " con valor " + "#{hsh[:valor]}" + "."
			end
		end
		puts "#{indent}   Sub-Tablas:"
		if @hijo.empty?
			puts "#{indent}     None."
		else
			@hijo.each do |nmb, tbl|
				tbl.print_valtab
			end
		end
	end
	
end