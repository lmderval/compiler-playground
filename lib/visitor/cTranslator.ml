open Ast

let rec merge l1 l2 = match l1 with [] -> l2 | h :: t -> h :: merge t l2

let rec make_compound_stmt stmt =
  match stmt with
  | TypedAst.BlockStmt ss -> make_compounds ss
  | _ -> make_compounds [ stmt ]

and make_compounds stmts =
  match stmts with [] -> [] | h :: t -> make_compound h :: make_compounds t

and make_compound stmt =
  match stmt with
  | TypedAst.DeclareStmt (id, ty) -> CAst.Dec (CAst.VarDec (id, ty))
  | TypedAst.AssignStmt (id, e) ->
      let e = translate_expr e in
      CAst.Stmt (CAst.Expr (CAst.Assign (id, e)))
  | TypedAst.PrintStmt e ->
      let e = translate_expr e in
      CAst.Stmt (CAst.Expr (CAst.Call ("print_int", [ e ])))
  | TypedAst.IfStmt (c, s1, s2) ->
      let c = translate_cond c in
      let s1 = make_compound_stmt s1 in
      let s2 = make_compound_stmt s2 in
      CAst.Stmt (CAst.If (c, CAst.Compound s1, CAst.Compound s2))
  | TypedAst.BlockStmt ss ->
      let ss = make_compounds ss in
      CAst.Stmt (CAst.Compound ss)

and translate_cond cond =
  match cond with
  | e1, op, e2 ->
      let e1 = translate_expr e1 in
      let e2 = translate_expr e2 in
      CAst.Operator (e1, CAst.Comparison op, e2)

and translate_expr expr =
  match expr with
  | TypedAst.IdExpr (id, _) -> CAst.Identifier id
  | TypedAst.IntExpr (n, _) -> CAst.IntConst n
  | TypedAst.OperationExpr ((e1, op, e2), _) ->
      let e1 = translate_expr e1 in
      let e2 = translate_expr e2 in
      CAst.Operator (e1, CAst.Arithmetic op, e2)

let translate_to_c stmt =
  [
    CAst.FunctionDec
      ( "main",
        [],
        merge (make_compound_stmt stmt)
          [ CAst.Stmt (CAst.Return (CAst.IntConst 0)) ],
        Types.IntTy );
  ]
