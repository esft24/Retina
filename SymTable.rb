require_relative 'SegregateTks'

#Clase que permite asociar varias tablas de hash de manera que estas puedan ser
#consultadas de manera ascendente para simular así una tabla de datos sintácticos
#que permitan verificar la correctitud de un programa hecho en Retina antes de su corrida

class TablaSimbolos
	attr_accessor :indent, :hijo, :retorno, :tabla, :argumentos, :nombre
	
	def initialize bloqueTipo, nombre, padre = nil, retorno = nil, argumentos = nil
		@bloqueTipo = bloqueTipo
		@padre = padre
		@nombre = nombre
		@retorno = retorno
		@argumentos = argumentos
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
	
	def insertar token, tipo
		@tabla[token.text] = { :token => token, :tipo => tipo}
	end
	
	def encontrar k
		if @tabla.has_key?(k) then
			return @tabla[k]
		elsif @padre.nil? then
			return nil
		end
		@padre.encontrar(k)
	end
	
	def encontrarBloque nombre
		return @hijo.has_key?(nombre)
	end
	
	def retornoTipo
		if @retorno.nil? then
			if @padre.nil? then
				return nil
			else
				return @padre.retornoTipo
			end
		else
			return @retorno
		end
	end
	
	def print_symtab
		print "#{indent}Tabla #{@nombre}, categoría \"#{@bloqueTipo}\""
		if not(@retorno.nil?)
			print " con retorno de tipo \"#{@retorno}\""
		end
		print ".\n"
		puts "#{indent}   Variables:"
		if @tabla.empty?
			puts "#{indent}     None."
		else
			@tabla.each do |tk, hsh|
				puts "#{indent}     " + tk + " de tipo " + hsh[:tipo] + "."
			end
		end
		puts "#{indent}   Sub-Bloques:"
		if @hijo.empty?
			puts "#{indent}     None."
		else
			@hijo.each do |nmb, tbl|
				tbl.print_symtab
			end
		end
	end
end