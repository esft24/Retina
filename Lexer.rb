require_relative 'SegregateTks.rb'

#Tabla de hash con las distintas expresiones regulares con las que verificaremos cada token
$tokens = {
	LiteralesNumericos: 		/\A[0-9]+\.[0-9]+|\A[0-9]+/,
	PalabrasReservadas: 		/\Aread\b|\Awrite\b|\Awriteln\b|\Aif\b|\Athen\b|\Aend\b|\Awith\b|\Ado\b|\Aprogram\b|\Afor\b|\Afrom\b|\Ato\b|\Awhile\b|\Aby\b|\Arepeat\b|\Atimes\b|\Afunc\b|\Abegin\b|\Atrue\b|\Afalse\b|\Aelse\b|\Areturn\b/,
	CadenaDeCaracteres:			/\A"([^\\\n]?\\\\|[^\\\n]?\\n|[^\\\n]?\\"|[^\\\n])*?"/,
	Signos: 					/\A\-\>|\A\/\=|\A\>\=|\A\<\=|\A\=\=|\A\+|\A\-|\A\*|\A\/|\A\=|\A\>|\A\<|\A\,|\A\;|\A\(|\A\)|\A\%|\Adiv\b|\Amod\b|\Aand\b|\Aor\b|\Anot\b/,
	TipoDeDato: 				/\Anumber\b|\Aboolean\b/,
	Identificadores: 			/\A[a-z][A-Za-z0-9\_]*/,
	CaracterInesperado: 		/\A\S/
}

#Clase lexer que realiza la descomposicion en tokens del archivo
#    Tokens: lista que contiene los tokens que han sido identificados
#    TokensError: lista que contiene tokens que no cumplen con ninguna de las especificaciones de Retina
#    Archivo: String que contiene el archivo a descomponer
#    linea: Contador que especifica la linea actual
#    columna: Contador que especifica la columna actual
#    TokenClass: Esta variable especifica la clase a la cual pertenece el token encontrado

class Lexer
	attr_accessor :Tokens
	def initialize archivo
		@Tokens = []
		@TokensError = []
		@Archivo = archivo
		@linea = 1
		@columna = 1
		@TokenClass = Token
	end
	
	#Funcion que descompone el archivo en tokens y los clasifica
	def capturador
		#La funcion termina si no hay mas nada que procesar en el string
		return if @Archivo.length == 0
		#Eliminamos los espacios entre los tokens y calculamos la columna
		@Archivo =~ /\A[ \t\r\f]*\#[^\n]*|\A[ \t\r\f]+/
		if not$&.nil?
			@columna += $&.length
			@Archivo = $'
		end
		#Verificamos si hay un salto de linea y en caso de haberlo actualizamos los datos de linea y columna
		@Archivo =~ /\A\n/
		if not$&.nil?
			@linea += 1
			@columna = 1
			@Archivo = $'
			self.capturador
		end
		
		#Contador para verificar si ha encontrado un error
		i = 0
		#Con el string separado del siguiente token a procesar, lo corremos por las expresiones regulares que establecimos arriba y es clasificado
		$tokens.each do |k,v|
			i += 1
			if @Archivo =~ v
				matchtk = $&
				matchcontinue = $'
				if i == 2
					$pR.each do |id, regexp|
						if matchtk =~ regexp
							@TokenClass = Object::const_get(id)
							@Tokens<<@TokenClass.new(matchtk, @linea, @columna)
							@columna += matchtk.length
							@Archivo = matchcontinue
							self.capturador()
							break
						end
					end
				elsif i == 4
					$signos.each do |id, regexp|
						if matchtk =~ regexp
							@TokenClass = Object::const_get(id)
							@Tokens<<@TokenClass.new(matchtk, @linea, @columna)
							@columna += matchtk.length
							@Archivo = matchcontinue
							self.capturador()
							break
						end
					end
				elsif i == 5
					$tipoDeDato.each do |id, regexp|
						if matchtk =~ regexp
							@TokenClass = Object::const_get(id)
							@Tokens<<@TokenClass.new(matchtk, @linea, @columna)
							@columna += matchtk.length
							@Archivo = matchcontinue
							self.capturador()
							break
						end
					end
				#Si el contador ha llegado a 7 significa que hemos encontrado un error y se agrega a la lista de errores
				elsif i == 7
					@TokenClass = Object::const_get(k)
					@TokensError<<@TokenClass.new(matchtk, @linea, @columna)
					@columna += matchtk.length
					@Archivo = matchcontinue
					self.capturador()
					break
				else
					@TokenClass = Object::const_get(k)
					@Tokens<<@TokenClass.new(matchtk, @linea, @columna)
					@columna += matchtk.length
					@Archivo = matchcontinue
					self.capturador()
				end
			end
		end
	end

	#Funcion que toma la lista correspondiente de tokens y los imprime
	def impresion
		x = @TokensError
		if @TokensError.empty?
			x = @Tokens
		end
		x.each do |m|
			puts m
		end
	end

	def enviarCaptura
		if @TokensError.empty?
			return @Tokens
		else
			puts "Error Lexicografico"
			self.impresion
			return nil
		end
	end
end
