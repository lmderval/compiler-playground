open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let simplified_ast = BlockSimplifier.simplify_blocks base_ast
let explicit_ast = Expliciter.explicit_declaration simplified_ast
let renamed_ast = Renamer.rename_var explicit_ast
let linearized_ast = BlockLinearizer.linearize_blocks renamed_ast
let () = PrettyPrinter.pretty_print linearized_ast
