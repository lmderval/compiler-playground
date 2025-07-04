open Ast

let create_global_scope stmt =
  match stmt with
  | BaseAst.BlockStmt _ -> stmt
  | _ -> BaseAst.BlockStmt [ stmt ]
