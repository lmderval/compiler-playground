open Ast

let rec scope_stmt stmt =
  match stmt with
  | BaseAst.IfStmt (c, s1, s2) ->
      let s1 = scope_stmt s1 in
      let s2 = scope_stmt s2 in
      BaseAst.IfStmt (c, BaseAst.BlockStmt [ s1 ], BaseAst.BlockStmt [ s2 ])
  | BaseAst.WhileStmt (c, s) ->
      let s = scope_stmt s in
      BaseAst.WhileStmt (c, BaseAst.BlockStmt [ s ])
  | BaseAst.BlockStmt ss ->
      let ss = scope_block ss in
      BaseAst.BlockStmt ss
  | _ -> stmt

and scope_block stmts =
  match stmts with
  | [] -> []
  | h :: t ->
      let h = scope_stmt h in
      let t = scope_block t in
      h :: t

let create_inner_scopes stmt = scope_stmt stmt
