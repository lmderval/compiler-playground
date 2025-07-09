open Ast

let rec merge l1 l2 = match l1 with [] -> l2 | h :: t -> h :: merge t l2

let invert_condition cond =
  match cond with
  | CAst.Operator (e1, CAst.Comparison op, e2) ->
      let op = Operators.invert_comparator op in
      CAst.Operator (e1, CAst.Comparison op, e2)
  | _ ->
      let e1 = cond in
      let op = CAst.Comparison Operators.EQ in
      let e2 = CAst.IntConst 0 in
      CAst.Operator (e1, op, e2)

let rec desugar_program program =
  match program with
  | [] -> []
  | h :: t ->
      let h = desugar_declaration h in
      let t = desugar_program t in
      h :: t

and desugar_declaration declaration =
  match declaration with
  | CAst.FunctionDec (id, pars, stmt, ty) ->
      let stmt = desugar_compound_stmt stmt in
      CAst.FunctionDec (id, pars, stmt, ty)
  | _ -> declaration

and desugar_compound_stmt stmt =
  match stmt with
  | [] -> []
  | h :: t ->
      let h = desugar_compound h in
      let t = desugar_compound_stmt t in
      merge h t

and desugar_compound compound =
  match compound with
  | CAst.Stmt stmt ->
      let stmt = desugar_stmt stmt in
      List.map (fun stmt -> CAst.Stmt stmt) stmt
  | _ -> [ compound ]

and desugar_stmt stmt =
  match stmt with
  | CAst.While (c, s) ->
      let c = invert_condition c in
      [
        CAst.Label "loop";
        CAst.If (c, CAst.Compound [ CAst.Stmt (CAst.Goto "end") ], s);
        CAst.Goto "loop";
        CAst.Label "end";
      ]
  | _ -> [ stmt ]

let desugar_while program = desugar_program program
