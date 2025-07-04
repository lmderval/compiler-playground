open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let simplified_ast = BlockSimplifier.simplify_blocks base_ast
let globally_scoped_ast = GlobalScoper.create_global_scope simplified_ast
let explicit_ast = Expliciter.explicit_declaration globally_scoped_ast
let renamed_ast = Renamer.rename_var explicit_ast
let linearized_ast = BlockLinearizer.linearize_blocks renamed_ast
let _ = TypeChecker.type_check linearized_ast

let () =
  Printf.printf "# Base AST\n";
  PrettyPrinter.pretty_print base_ast;
  Printf.printf "# Globally Scoped AST\n";
  PrettyPrinter.pretty_print globally_scoped_ast;
  Printf.printf "# Linearized AST\n";
  PrettyPrinter.pretty_print linearized_ast
