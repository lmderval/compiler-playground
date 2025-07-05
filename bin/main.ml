open Visitor
open Parse

let lexbuf = Lexing.from_channel stdin
let base_ast = Parser.program Lexer.lex lexbuf
let globally_scoped_ast = GlobalScoper.create_global_scope base_ast
let scoped_ast = IfScoper.create_if_scopes globally_scoped_ast
let simplified_ast = BlockSimplifier.simplify_blocks scoped_ast
let explicit_ast = Expliciter.explicit_declaration simplified_ast
let renamed_ast = Renamer.rename_var explicit_ast
let linearized_ast = BlockLinearizer.linearize_blocks renamed_ast
let typed_ast = TypeChecker.type_check linearized_ast

let () =
  Printf.printf "# Base AST\n";
  PrettyPrinter.pretty_print base_ast;
  Printf.printf "\n";
  Printf.printf "# Scoped AST\n";
  PrettyPrinter.pretty_print scoped_ast;
  Printf.printf "\n";
  Printf.printf "# Simplified AST\n";
  PrettyPrinter.pretty_print simplified_ast;
  Printf.printf "\n";
  Printf.printf "# Explicit AST\n";
  PrettyPrinter.pretty_print explicit_ast;
  Printf.printf "\n";
  Printf.printf "# Renamed AST\n";
  PrettyPrinter.pretty_print renamed_ast;
  Printf.printf "\n";
  Printf.printf "# Linearized AST\n";
  PrettyPrinter.pretty_print linearized_ast;
  Printf.printf "\n";
  Printf.printf "# Typed AST\n";
  TypePrinter.print_types typed_ast;
  Printf.printf "\n"
