open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let () = PrettyPrinter.pretty_print base_ast
let _ = Expliciter.explicit base_ast
