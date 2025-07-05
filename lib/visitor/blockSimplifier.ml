open Ast

let rec simplify_stmt stmt =
  match stmt with
  | BaseAst.IfStmt (c, s1, s2) ->
      BaseAst.IfStmt (c, simplify_stmt s1, simplify_stmt s2)
  | BaseAst.WhileStmt (c, s) -> BaseAst.WhileStmt (c, simplify_stmt s)
  | BaseAst.BlockStmt ss -> (
      match ss with
      | [ ss1 ] -> (
          match ss1 with
          | BaseAst.BlockStmt _ -> simplify_stmt ss1
          | _ -> BaseAst.BlockStmt (simplify_block ss))
      | _ -> BaseAst.BlockStmt (simplify_block ss))
  | _ -> stmt

and simplify_block stmts =
  match stmts with [] -> [] | h :: t -> simplify_stmt h :: simplify_block t

let simplify_blocks stmt = simplify_stmt stmt
