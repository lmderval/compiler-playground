open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let globally_scoped_ast = GlobalScoper.create_global_scope base_ast
let scoped_ast = IfScoper.create_if_scopes globally_scoped_ast
let simplified_ast = BlockSimplifier.simplify_blocks scoped_ast
let explicit_ast = Expliciter.explicit_declaration simplified_ast
let renamed_ast = Renamer.rename_var explicit_ast
let () = PrettyPrinter.pretty_print renamed_ast
