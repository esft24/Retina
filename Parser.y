class Parser
	token 'program' 'end' 'with' 'do' 'begin' 'boolean' 'number'
		  'read' 'write' 'writeln' 'if' 'then' 'else'
		  'while' 'for' 'from' 'to' 'by' 'repeat' 'times'
		  'func' 'return' 'div' 'mod' 'true' 'false' 'not'
		  'and' 'or' ';' '=' '->' '(' ')' ',' '+' '-' '*' '/'
		  '%' '==' '/=' '>=' '<=' '>' '<' UMINUS 'String' 'Ident' 'Num'

	prechigh
		right 'not'
		right UMINUS
		left '*'
		left '/'
		left '%'
		left 'div'
		left 'mod'
		left '+'
		left '-'
		left '=='
		left '/='
		left '>='
		left '<='
		left '>'
		left '<'
		left 'and'
		left 'or'
	preclow

	convert
		'program' 	'Program'
		'end' 		'End'
		'with'		'With'
		'do' 		'Do'
		'begin'		'Begin'
		'boolean'	'TipoBooleano'
		'number'	'TipoNumero'
		'read'		'Read'
		'write'		'Write'
		'writeln'	'Writeln'
		'if'		'If'
		'then'		'Then'
		'else'		'Else'
		'while'		'While'
		'for'		'For'
		'from'		'From'
		'to'		'To'
		'by'		'By'
		'repeat'	'Repeat'
		'times'		'Times'
		'func'		'Func'
		'return'	'Return'
		'div'		'Div'
		'mod'		'Mod'
		'true'		'True'
		'false'		'False'
		'not'		'Not'
		'and'		'And'
		'or'		'Or'
		';'			'PuntoYComa'
		'='			'Asignacion'
		'->'		'FirmaFuncion'
		'('			'ParentesisAbre'
		')'			'ParentesisCierra'
		','			'Coma'
		'+'			'Mas'
		'-'			'Menos'
		'*'			'Por'
		'/'			'Entre'
		'%'			'Modulo'
		'=='		'IgualQue'
		'/='		'DiferenteA'
		'>='		'MayorIgualQue'
		'<='		'MenorIgualQue'
		'>'			'MayorQue'
		'<'			'MenorQue'
		'String'	'CadenaDeCaracteres'
		'Ident'		'Identificadores'
		'Num'		'LiteralesNumericos'
	end

	start Inicio

	rule
		Inicio: Alcance
			  ;

		Alcance: 'program' Instruccion 'end' ';' 				{result = Programa.new([], Instrucciones.new(val[1]))}
			  | Funciones 'program' Instruccion 'end' ';'		{result = Programa.new(Funciones.new(val[0]), Instrucciones.new(val[2]))}
			  | Funciones 'program' 'end' ';'					{result = Programa.new(Funciones.new(val[0]), [])}
			  | Funciones										{result = Programa.new(Funciones.new(val[0]), [])}
			  ;

		Bloque: 'with' Declaracion 'do' Instruccion 'end' ';'   {result = Bloque.new(Declaraciones.new(val[1]), Instrucciones.new(val[3]))}
			  | 'with' 'do' Instruccion 'end' ';'   			{result = Bloque.new([], Instrucciones.new(val[2]))}
			  | 'with' 'do' 'end' ';'   						{result = Bloque.new([], [])}
			  | 'with' Declaracion 'do' 'end' ';'   			{result = Bloque.new(Declaraciones.new(val[1]), [])}
			  ;

		Funciones: Funcion Funciones	{result = [val[0]] + val[1]}
				 | Funcion 				{result = [val[0]]}
				 ;

		Funcion: 'func' 'Ident' '(' Argumento ')' 'begin' InstruccionFun 'end' ';' 			 	 {result = Funcion.new(Identificador.new(val[1]), Argumentos.new(val[3]), Instrucciones.new(val[6]))}
			   | 'func' 'Ident' '(' Argumento ')' '->' Tipo 'begin' InstruccionFun 'end' ';' 	 {result = FuncionConTipo.new(Identificador.new(val[1]), Argumentos.new(val[3]), val[6], Instrucciones.new(val[8]))}
			   | 'func' 'Ident' '(' ')' 'begin' InstruccionFun 'end' ';' 				     	 {result = Funcion.new(Identificador.new(val[1]), [], Instrucciones.new(val[5]))}
			   | 'func' 'Ident' '(' ')' '->' Tipo 'begin' InstruccionFun 'end' ';' 			 	 {result = FuncionConTipo.new(Identificador.new(val[1]), [], val[5], Instrucciones.new(val[7]))}
			   | 'func' 'Ident' '(' Argumento ')' 'begin' 'end' ';' 			 	 			 {result = Funcion.new(Identificador.new(val[1]), Argumentos.new(val[3]), [])}
			   | 'func' 'Ident' '(' Argumento ')' '->' Tipo 'begin' 'end' ';' 	 				 {result = FuncionConTipo.new(Identificador.new(val[1]), Argumentos.new(val[3]), val[6], [])}
			   | 'func' 'Ident' '(' ')' 'begin' 'end' ';' 				     	 				 {result = Funcion.new(Identificador.new(val[1]), [], [])}
			   | 'func' 'Ident' '(' ')' '->' Tipo 'begin' 'end' ';' 			 	 			 {result = FuncionConTipo.new(Identificador.new(val[1]), [], val[5], [])}
			   ;

		Argumento: Tipo 'Ident' ',' Argumento {result = [Argumento.new(val[0], Identificador.new(val[1]))] + val[3]}
				 | Tipo 'Ident'				  {result = [Argumento.new(val[0], Identificador.new(val[1]))]}
				 ;

		Tipo: 'boolean'	{result = Tipo.new(val[0])}
			| 'number'	{result = Tipo.new(val[0])}
			;

		Declaracion: DeclaF Declaracion	{result = [val[0]] + val[1]}
				   | DeclaF				{result = [val[0]]}
				   ;

		Instruccion: InstrF Instruccion {result = [val[0]] + val[1]}
				   | InstrF 			{result = [val[0]]}
				   ;
				   
		InstruccionFun: InstrFun InstruccionFun {result = [val[0]] + val[1]}
				   | InstrFun 					{result = [val[0]]}
				   ;
						
		InstrF: Bloque					  	{result = val[0]}
			  | IO 						  	{result = val[0]}
			  | Condicional				  	{result = val[0]}
			  | Iteracion				  	{result = val[0]}
			  | Llamada ';'				  	{result = val[0]}
			  | 'Ident' '=' Expresion ';' 	{result = AsignacionParser.new(Identificador.new(val[0]), val[2])}
			  ;
		
		InstrFun: 'Ident' '=' Expresion ';' 	{result = AsignacionParser.new(Identificador.new(val[0]), val[2])}
			  | BloqueFun					  	{result = val[0]}
			  | IO 						  		{result = val[0]}
			  | CondicionalFun				  	{result = val[0]}
			  | IteracionFun				  	{result = val[0]}
			  | Llamada ';'				  		{result = val[0]}
			  | 'return' Expresion ';'	  		{result = Retorno.new(val[1])}
			  ;
		
		BloqueFun: 'with' Declaracion 'do' InstruccionFun 'end' ';'   	{result = Bloque.new(Declaraciones.new(val[1]), Instrucciones.new(val[3]))}
			  | 'with' 'do' InstruccionFun 'end' ';'   					{result = Bloque.new([], Instrucciones.new(val[2]))}
			  | 'with' 'do' 'end' ';'   								{result = Bloque.new([], [])}
			  | 'with' Declaracion 'do' 'end' ';'   					{result = Bloque.new(Declaraciones.new(val[1]), [])}
			  ;

		DeclaF: Tipo 'Ident' ';'		  		{result = Declaracion.new(val[0], Identificador.new(val[1]))}
			  | Tipo 'Ident' '=' Expresion ';'	{result = Declaracion.new(val[0], AsignacionParser.new(Identificador.new(val[1]), val[3]))}
			  ;

		IO: 'read' 'Ident' ';'	{result = Entrada.new(Identificador.new(val[1]))}
		  |	'write' Salida		{result = Salidas.new(val[1], false)}
		  | 'writeln' Salida 	{result = Salidas.new(val[1], true)}
		  ;

		Condicional: 'if' Expresion 'then' Instruccion 'end' ';'					    {result = CondIf.new(val[1], Instrucciones.new(val[3]), val[0].line)}
				   | 'if' Expresion 'then' Instruccion 'else' Instruccion 'end' ';' 	{result = CondIfElse.new(val[1], Instrucciones.new(val[3]), Instrucciones.new(val[5]), val[0].line)}
				   | 'if' Expresion 'then' 'end' ';'					    			{result = CondIf.new(val[1], [], val[0].line)}
				   | 'if' Expresion 'then' 'else' 'end' ';' 							{result = CondIfElse.new(val[1], [], [], val[0].line)}
				   | 'if' Expresion 'then' 'else' Instruccion 'end' ';' 				{result = CondIfElse.new(val[1], [], Instrucciones.new(val[4]), val[0].line)}
				   | 'if' Expresion 'then' Instruccion 'else' 'end' ';' 				{result = CondIfElse.new(val[1], Instrucciones.new(val[3]), [], val[0].line)}
				   ;
		
		CondicionalFun: 'if' Expresion 'then' InstruccionFun 'end' ';'					    {result = CondIf.new(val[1], Instrucciones.new(val[3]), val[0].line)}
				   | 'if' Expresion 'then' InstruccionFun 'else' InstruccionFun 'end' ';' 	{result = CondIfElse.new(val[1], Instrucciones.new(val[3]), Instrucciones.new(val[5]), val[0].line)}
				   | 'if' Expresion 'then' 'end' ';'					    				{result = CondIf.new(val[1], [], val[0].line)}
				   | 'if' Expresion 'then' 'else' 'end' ';' 								{result = CondIfElse.new(val[1], [], [], val[0].line)}
				   | 'if' Expresion 'then' 'else' InstruccionFun 'end' ';' 					{result = CondIfElse.new(val[1], [], Instrucciones.new(val[4]), val[0].line)}
				   | 'if' Expresion 'then' InstruccionFun 'else' 'end' ';' 					{result = CondIfElse.new(val[1], Instrucciones.new(val[3]), [], val[0].line)}
				   ;

		Iteracion: 'while' Expresion 'do' Instruccion 'end' ';' 											{result = IterWhile.new(val[1], Instrucciones.new(val[3]), val[0].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'do' Instruccion 'end' ';' 				{result = IterFor.new(Identificador.new(val[1]), val[3], val[5], Instrucciones.new(val[7]), val[2].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'by' Expresion 'do' Instruccion 'end' ';'  {result = IterForBy.new(Identificador.new(val[1]), val[3], val[5], val[7], Instrucciones.new(val[9]), val[2].line)}
				 | 'repeat' Expresion 'times' Instruccion 'end' ';' 										{result = IterRepeat.new(val[1], Instrucciones.new(val[3]), val[0].line)}
				 | 'while' Expresion 'do' 'end' ';' 														{result = IterWhile.new(val[1], [], val[0].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'do' 'end' ';' 							{result = IterFor.new(Identificador.new(val[1]), val[3], val[5], [], val[2].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'by' Expresion 'do' 'end' ';'  			{result = IterForBy.new(Identificador.new(val[1]), val[3], val[5], val[7], [], val[2].line)}
				 | 'repeat' Expresion 'times' 'end' ';' 													{result = IterRepeat.new(val[1], [], val[0].line)}
				 ;
		
		IteracionFun: 'while' Expresion 'do' InstruccionFun 'end' ';' 											{result = IterWhile.new(val[1], Instrucciones.new(val[3]), val[0].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'do' InstruccionFun 'end' ';' 					{result = IterFor.new(Identificador.new(val[1]), val[3], val[5], Instrucciones.new(val[7]), val[2].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'by' Expresion 'do' InstruccionFun 'end' ';'  	{result = IterForBy.new(Identificador.new(val[1]), val[3], val[5], val[7], Instrucciones.new(val[9]), val[2].line)}
				 | 'repeat' Expresion 'times' InstruccionFun 'end' ';' 											{result = IterRepeat.new(val[1], Instrucciones.new(val[3]), val[0].line)}
				 | 'while' Expresion 'do' 'end' ';' 															{result = IterWhile.new(val[1], [], val[0].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'do' 'end' ';' 								{result = IterFor.new(Identificador.new(val[1]), val[3], val[5], [], val[2].line)}
				 | 'for' 'Ident' 'from' Expresion 'to' Expresion 'by' Expresion 'do' 'end' ';'  				{result = IterForBy.new(Identificador.new(val[1]), val[3], val[5], val[7], [], val[2].line)}
				 | 'repeat' Expresion 'times' 'end' ';' 														{result = IterRepeat.new(val[1], [], val[0].line)}
				 ;
				 ;

		Llamada: 'Ident' '(' ')'				{result = Llamada.new(Identificador.new(val[0]), [])}
			   | 'Ident' '(' ArgumLlamada ')' 	{result = Llamada.new(Identificador.new(val[0]), Argumentos.new(val[2]))}
			   ;

		Salida: SalF ',' Salida {result = [val[0]] + val[2]}
			  | SalF ';'		{result = [val[0]]}
			  ;

		SalF: Expresion			{result = val[0]}
			| 'String'			{result = CadenaDeCaracteresParser.new(val[0])}
			;

		ArgumLlamada: Expresion ',' ArgumLlamada {result = [val[0]] + val[2]}
					| Expresion					 {result = [val[0]]}
					;

		Expresion:  Llamada					 {result = val[0]}
				 | 'Num'					 {result = Numero.new(val[0])}
				 | 'Ident'					 {result = Identificador.new(val[0])}
				 | 'true'					 {result = Booleano.new(val[0])}
				 | 'false'					 {result = Booleano.new(val[0])}
				 | '-' Expresion =UMINUS 	 {result = Minus.new(val[1], val[0].line)}
				 | 'not' Expresion 			 {result = Negacion.new(val[1], val[0].line)}
				 | '(' Expresion ')'		 {result = val[1]}
				 | Expresion '+' Expresion   {result = Suma.new(val[0], val[2], val[1].line)}
				 | Expresion '-' Expresion 	 {result = Resta.new(val[0], val[2], val[1].line)}
				 | Expresion '*' Expresion   {result = Multiplicacion.new(val[0], val[2], val[1].line)}
				 | Expresion '/' Expresion   {result = Division.new(val[0], val[2], val[1].line)}
				 | Expresion '%' Expresion   {result = Resto.new(val[0], val[2], val[1].line)}
				 | Expresion 'div' Expresion {result = DivisionEntera.new(val[0], val[2], val[1].line)}
				 | Expresion 'mod' Expresion {result = RestoEntero.new(val[0], val[2], val[1].line)}
				 | Expresion 'and' Expresion {result = Conjuncion.new(val[0], val[2], val[1].line)}
				 | Expresion 'or' Expresion  {result = Disyuncion.new(val[0], val[2], val[1].line)}
				 | Expresion '==' Expresion  {result = IgualQueParser.new(val[0], val[2], val[1].line)}
				 | Expresion '>=' Expresion  {result = MayorIgualQueParser.new(val[0], val[2], val[1].line)}
				 | Expresion '<=' Expresion  {result = MenorIgualQueParser.new(val[0], val[2], val[1].line)}
				 | Expresion '/=' Expresion  {result = DiferenteAParser.new(val[0], val[2], val[1].line)}
				 | Expresion '>' Expresion   {result = MayorQueParser.new(val[0], val[2], val[1].line)}
				 | Expresion '<' Expresion   {result = MenorQueParser.new(val[0], val[2], val[1].line)}
				 ;


---- header ----
require_relative 'Ast.rb'
require_relative 'Lexer.rb'
require_relative 'SegregateTks'

class SyntacticError < RuntimeError
	def initialize(tk)
		@token = tk
	end

	def to_s
		tk.unexpected
	end
end

---- inner ----
	def on_error(id, token, stack)
	  puts "Error Sintáctico"
      puts token.unexpected
    end

	def next_token
		token = @catch.shift
		return [false, false] unless token
		return [token.class, token]
	end

	def parse(lexerCatch)
		@yydebug = true
		@catch = lexerCatch
		ast = do_parse
		return ast
	end
---- footer ----
