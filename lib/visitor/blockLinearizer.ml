open Ast

let rec merge l1 l2 = match l1 with [] -> l2 | h :: t -> h :: merge t l2

let rec linearize_stmt stmt =
  match stmt with
  | BaseAst.IfStmt (c, s1, s2) ->
      let s1 = linearize_stmt s1 in
      let s2 = linearize_stmt s2 in
      BaseAst.IfStmt (c, s1, s2)
  | BaseAst.WhileStmt (c, s) ->
      let s = linearize_stmt s in
      BaseAst.WhileStmt (c, s)
  | BaseAst.BlockStmt ss ->
      let ss = linearize_block ss in
      BaseAst.BlockStmt ss
  | _ -> stmt

and linearize_block stmts =
  match stmts with
  | [] -> []
  | BaseAst.BlockStmt ss :: t ->
      let ss = linearize_block ss in
      let t = linearize_block t in
      merge ss t
  | h :: t ->
      let h = linearize_stmt h in
      let t = linearize_block t in
      h :: t

let linearize_blocks stmt = linearize_stmt stmt
