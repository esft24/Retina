#Clase token la cual sera heredada por cada uno de los tipos de tokens
#    t: contenido del token
#    l: linea en la que se encuentra en el archivo
#    c: columna en la qye se encuentra en el archivo
class Token
	attr_accessor :text, :line, :column
	def initialize t, l, c
		@text = t
		@line = l
		@column = c
	end

	def unexpected
		return "linea #{@line}, columna #{@column}. Token Inesperado: #{self.class.name}: '#{@text}' "

	end

end

#Las clases que vienen a continuacion heredan de token y se les agrega la funcion de impresion

class LiteralesNumericos < Token
	def to_s 
		"linea #{@line}, columna #{@column}: literal numerico '#{@text}' "
	end
end


class PalabrasReservadas < Token
	def to_s 
		"linea #{@line}, columna #{@column}: palabra reservada '#{@text}' "
	end
end


class Signos < Token
	def to_s 
		"linea #{@line}, columna #{@column}: signo '#{@text}' "
	end
end


class TipoDeDato < Token
	def to_s 
		"linea #{@line}, columna #{@column}: tipo de dato '#{@text}' "
	end
end


class Identificadores < Token
	def to_s 
		"linea #{@line}, columna #{@column}: identificador '#{@text}' "
	end
end


class CaracterInesperado < Token
	def to_s 
		"linea #{@line}, columna #{@column}: caracter inesperado '#{@text}' "
	end
end


class CadenaDeCaracteres < Token
	def to_s
		"linea #{@line}, columna #{@column}: cadena de caracteres '#{@text}' "
	end
end

# Separador de Tokens de tipo Signo, Palabra Reservada y Tipo de Dato, para ser usados individualmente en el parser

$pR = Hash.new

palabraReservada = %w(program end with do begin read write writeln if then else
					  while for from to by repeat times func return true false)

$signos = {
	'IgualQue'  			=>  /\=\=/,
  	'DiferenteA'  		=>  /\/\=/,
   	'MayorIgualQue'  =>  /\>\=/,
    'MenorIgualQue'  =>  /\<\=/,
	'Div'   					=>  /div/,
	'Mod'   					=>  /mod/,
	'Not'   					=>  /not/,
	'And'   	  				=>  /and/,
	'Or'    	  				=>  /or/,
	'PuntoYComa'  	=>  /\;/,
	'Asignacion'  		=>  /\=/, 
	'FirmaFuncion'  	=>  /\-\>/, 
	'ParentesisAbre'  =>  /\(/,
	'ParentesisCierra'=>  /\)/,
	'Coma'  				=>  /\,/,
	'Mas'  					=>  /\+/,
	'Menos'  				=>  /\-/,
	'Por'  					=>  /\*/,
	'Entre'  				=>  /\//,
	'Modulo'  				=>  /\%/,
    'MayorQue'  		=>  /\>/,
    'MenorQue'  		=>  /\</
}

$tipoDeDato = {
	'TipoBooleano' => /boolean/,
	'TipoNumero'   => /number/
}


palabraReservada.each do |s|
  $pR[s.capitalize] = /#{s}/
end

$signos.each do |id,regex|
  newclass = Class::new(Signos) do
  end
  Object::const_set("#{id}", newclass)
end

$tipoDeDato.each do |id,regex|
  newclass = Class::new(TipoDeDato) do
  end
  Object::const_set("#{id}", newclass)
end

$pR.each do |id,regex|
  newclass = Class::new(PalabrasReservadas) do
  end
  Object::const_set("#{id}", newclass)
end

a = TipoBooleano.new("true", 5, 4)

a.unexpected