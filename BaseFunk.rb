require_relative 'Ast_fill_table.rb'

dummytoken = TipoNumero.new("number", 0, 0)
dummytype = Tipo.new(dummytoken)
dummynumber = Argumento.new(dummytype, [])

home = TablaSimbolos.new("Funciones Base", "home", $tabla_de_funciones, nil, Argumentos.new([]))
openeye = TablaSimbolos.new("Funciones Base", "openeye", $tabla_de_funciones, nil, Argumentos.new([]))
closeeye = TablaSimbolos.new("Funciones Base", "closeeye", $tabla_de_funciones, nil, Argumentos.new([]))
forward = TablaSimbolos.new("Funciones Base", "forward", $tabla_de_funciones, nil, Argumentos.new([dummynumber])) # number
backward = TablaSimbolos.new("Funciones Base", "backward", $tabla_de_funciones, nil, Argumentos.new([dummynumber])) # number
rotatel = TablaSimbolos.new("Funciones Base", "rotatel", $tabla_de_funciones, nil, Argumentos.new([dummynumber])) # number
rotater = TablaSimbolos.new("Funciones Base", "rotater", $tabla_de_funciones, nil, Argumentos.new([dummynumber])) # number
setposition = TablaSimbolos.new("Funciones Base", "setposition", $tabla_de_funciones, nil, Argumentos.new([dummynumber, dummynumber])) # number, number
arc = TablaSimbolos.new("Funciones Base", "arc", $tabla_de_funciones, nil, Argumentos.new([dummynumber, dummynumber])) # number, number