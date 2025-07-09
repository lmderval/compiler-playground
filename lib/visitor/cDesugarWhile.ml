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

let rec desugar_program program fresh =
  match program with
  | [] -> ([], fresh)
  | h :: t ->
      let h, fresh = desugar_declaration h fresh in
      let t, fresh = desugar_program t fresh in
      (h :: t, fresh)

and desugar_declaration declaration fresh =
  match declaration with
  | CAst.FunctionDec (id, pars, stmt, ty) ->
      let stmt, fresh = desugar_compound_stmt stmt fresh in
      (CAst.FunctionDec (id, pars, stmt, ty), fresh)
  | _ -> (declaration, fresh)

and desugar_compound_stmt stmt fresh =
  match stmt with
  | [] -> ([], fresh)
  | h :: t ->
      let h, fresh = desugar_compound h fresh in
      let t, fresh = desugar_compound_stmt t fresh in
      (merge h t, fresh)

and desugar_compound compound fresh =
  match compound with
  | CAst.Stmt stmt ->
      let stmt, fresh = desugar_stmt stmt fresh in
      (List.map (fun stmt -> CAst.Stmt stmt) stmt, fresh)
  | _ -> ([ compound ], fresh)

and desugar_stmt stmt fresh =
  match stmt with
  | CAst.While (c, s) ->
      let c = invert_condition c in
      let loop_label = Printf.sprintf "loop%d" fresh in
      let end_label = Printf.sprintf "end%d" fresh in
      ( [
          CAst.Label loop_label;
          CAst.If (c, CAst.Compound [ CAst.Stmt (CAst.Goto end_label) ], s);
          CAst.Goto loop_label;
          CAst.Label end_label;
        ],
        fresh + 1 )
  | _ -> ([ stmt ], fresh)

let desugar_while program =
  let program, _ = desugar_program program 0 in
  program
