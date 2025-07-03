open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let explicit_ast = Expliciter.explicit base_ast
let () = ExplicitPrinter.explicit_print explicit_ast
