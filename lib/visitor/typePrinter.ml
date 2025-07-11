open Ast

let rec visit_stmt stmt lvl =
  match stmt with
  | TypedAst.DeclareStmt (id, ty) ->
      Printf.printf "declare %s#%a" id Types.print_ty ty
  | TypedAst.AssignStmt (id, e) ->
      Printf.printf "%s <- " id;
      visit_expr e lvl
  | TypedAst.PrintStmt e ->
      Printf.printf "print ";
      visit_expr e lvl
  | TypedAst.IfStmt (c, s1, s2) ->
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
  | TypedAst.BlockStmt ss -> (
      match ss with
      | [] -> Printf.printf "{ }"
      | [ TypedAst.IfStmt _ ] ->
          Printf.printf "{\n";
          visit_block ss (lvl + 1);
          if lvl > 0 then Printf.printf "%*s" lvl " ";
          Printf.printf "}"
      | [ ss1 ] ->
          Printf.printf "{ ";
          visit_stmt ss1 lvl;
          Printf.printf " }"
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
      | Operators.EQ -> Printf.printf " == "
      | Operators.NE -> Printf.printf " != "
      | Operators.LT -> Printf.printf " < "
      | Operators.LE -> Printf.printf " <= "
      | Operators.GT -> Printf.printf " > "
      | Operators.GE -> Printf.printf " >= ");
      visit_expr e2 lvl

and visit_expr expr lvl =
  match expr with
  | TypedAst.IdExpr (id, ty) -> Printf.printf "%s#%a" id Types.print_ty ty
  | TypedAst.IntExpr (n, ty) -> Printf.printf "%d#%a" n Types.print_ty ty
  | TypedAst.OperationExpr ((e1, op, e2), ty) ->
      Printf.printf "(";
      visit_expr e1 lvl;
      (match op with
      | Operators.ADD -> Printf.printf " + "
      | Operators.SUB -> Printf.printf " - "
      | Operators.MUL -> Printf.printf " * "
      | Operators.DIV -> Printf.printf " / ");
      visit_expr e2 lvl;
      Printf.printf ")#%a" Types.print_ty ty

let print_types stmt =
  visit_stmt stmt 0;
  Printf.printf "\n"
