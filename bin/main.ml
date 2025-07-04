open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let simplified_ast = BlockSimplifier.simplify_blocks base_ast
let explicit_ast = Expliciter.explicit simplified_ast
let () = ExplicitPrinter.explicit_print explicit_ast
