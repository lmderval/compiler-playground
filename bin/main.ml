open Visitor
open Parse

let main () =
  let lexbuf = Lexing.from_channel stdin in
  let base_ast = Parser.program Lexer.lex lexbuf in
  let globally_scoped_ast = GlobalScoper.create_global_scope base_ast in
  let scoped_ast = InnerScoper.create_inner_scopes globally_scoped_ast in
  let simplified_ast = BlockSimplifier.simplify_blocks scoped_ast in
  let explicit_ast = Expliciter.explicit_declaration simplified_ast in
  let renamed_ast = Renamer.rename_var explicit_ast in
  let linearized_ast = BlockLinearizer.linearize_blocks renamed_ast in
  let typed_ast = TypeChecker.type_check linearized_ast in
  let c_program = CTranslator.translate_to_c typed_ast in
  CPrinter.print_program c_program

let () =
  try main () with
  | Lexer.Error ->
      Printf.eprintf "lexing error\n";
      exit 2
  | Parser.Error ->
      Printf.eprintf "parsing error\n";
      exit 3
