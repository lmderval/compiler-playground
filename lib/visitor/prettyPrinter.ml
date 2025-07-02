open Ast

let rec visit_stmt stmt lvl =
  match stmt with
  | BaseAst.AssignStmt (id, e) ->
      Printf.printf "%s <- " id;
      visit_expr e lvl
  | BaseAst.PrintStmt e ->
      Printf.printf "print ";
      visit_expr e lvl
  | BaseAst.IfStmt (c, s1, s2) ->
      Printf.printf "if ";
      visit_cond c lvl;
      Printf.printf "\n";
      Printf.printf "%*s" (lvl + 1) " ";
      Printf.printf "then ";
      visit_stmt s1 (lvl + 1);
      Printf.printf "\n";
      Printf.printf "%*s" (lvl + 1) " ";
      Printf.printf "else ";
      visit_stmt s2 (lvl + 1);
      Printf.printf "\n";
      if lvl > 0 then Printf.printf "%*s" lvl " ";
      Printf.printf "end"
  | BaseAst.BlockStmt [] -> Printf.printf "{ }"
  | BaseAst.BlockStmt ss -> (
      match ss with
      | [ ss1 ] -> (
          match ss1 with
          | BaseAst.BlockStmt _ -> visit_stmt ss1 lvl
          | BaseAst.IfStmt _ ->
              Printf.printf "{\n";
              visit_block ss (lvl + 1);
              if lvl > 0 then Printf.printf "%*s" lvl " ";
              Printf.printf "}"
          | _ ->
              Printf.printf "{ ";
              visit_stmt ss1 lvl;
              Printf.printf " }")
      | _ ->
          Printf.printf "{\n";
          visit_block ss (lvl + 1);
          if lvl > 0 then Printf.printf "%*s" lvl " ";
          Printf.printf "}")

and visit_block stmts lvl =
  Printf.printf "%*s" lvl " ";
  match stmts with
  | [] -> ()
  | [ s ] ->
      visit_stmt s lvl;
      Printf.printf "\n"
  | h :: t ->
      visit_stmt h lvl;
      Printf.printf ",\n";
      visit_block t lvl

and visit_cond cond lvl =
  match cond with
  | e1, op, e2 ->
      visit_expr e1 lvl;
      (match op with
      | BaseAst.EQ -> Printf.printf " == "
      | BaseAst.NE -> Printf.printf " != "
      | BaseAst.LT -> Printf.printf " < "
      | BaseAst.LE -> Printf.printf " <= "
      | BaseAst.GT -> Printf.printf " > "
      | BaseAst.GE -> Printf.printf " >= ");
      visit_expr e2 lvl

and visit_expr expr lvl =
  match expr with
  | BaseAst.IdExpr id -> Printf.printf "%s" id
  | BaseAst.IntExpr n -> Printf.printf "%d" n
  | BaseAst.OperationExpr (e1, op, e2) ->
      Printf.printf "(";
      visit_expr e1 lvl;
      (match op with
      | BaseAst.ADD -> Printf.printf " + "
      | BaseAst.SUB -> Printf.printf " - "
      | BaseAst.MUL -> Printf.printf " * "
      | BaseAst.DIV -> Printf.printf " / ");
      visit_expr e2 lvl;
      Printf.printf ")"

let pretty_print stmt =
  visit_stmt stmt 0;
  Printf.printf "\n"
