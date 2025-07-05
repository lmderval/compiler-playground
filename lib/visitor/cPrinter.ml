open Ast

let indent lvl = if lvl > 0 then Printf.printf "%*s" (lvl * 4) " "

let rec visit_program program =
  match program with
  | [] -> ()
  | [ d ] ->
      visit_declaration d 0;
      Printf.printf "\n"
  | h :: t ->
      visit_declaration h 0;
      Printf.printf "\n\n";
      visit_program t

and visit_declaration declaration lvl =
  match declaration with
  | CAst.FunctionDef (id, pars, ty) ->
      indent lvl;
      Printf.printf "%a %s(" Types.print_ty ty id;
      visit_pars pars;
      Printf.printf ");"
  | CAst.FunctionDec (id, pars, stmt, ty) ->
      indent lvl;
      Printf.printf "%a %s(" Types.print_ty ty id;
      visit_pars pars;
      Printf.printf ")\n";
      indent lvl;
      visit_compound_stmt stmt 0
  | CAst.VarDec (id, ty) ->
      indent lvl;
      Printf.printf "%a %s;" Types.print_ty ty id

and visit_pars pars =
  match pars with
  | [] -> Printf.printf "void"
  | [ (id, ty) ] -> Printf.printf "%a %s" Types.print_ty ty id
  | (id, ty) :: t ->
      Printf.printf "%a %s, " Types.print_ty ty id;
      visit_pars t

and visit_compound_stmt stmt lvl =
  Printf.printf "{";
  visit_compounds stmt (lvl + 1);
  Printf.printf "\n";
  indent lvl;
  Printf.printf "}"

and visit_compounds compounds lvl =
  match compounds with
  | [] -> ()
  | h :: t ->
      Printf.printf "\n";
      visit_compound h lvl;
      visit_compounds t lvl

and visit_compound compound lvl =
  match compound with
  | CAst.Dec d -> visit_declaration d lvl
  | CAst.Stmt s -> visit_stmt s lvl

and visit_stmt stmt lvl =
  indent lvl;
  match stmt with
  | CAst.Expr e ->
      visit_expr e;
      Printf.printf ";"
  | CAst.Compound s -> visit_compound_stmt s lvl
  | CAst.If (c, s1, s2) ->
      Printf.printf "if (";
      visit_expr c;
      Printf.printf ")\n";
      visit_stmt s1 lvl;
      Printf.printf "\n";
      indent lvl;
      Printf.printf "else\n";
      visit_stmt s2 lvl
  | CAst.While (c, s) ->
      Printf.printf "while (";
      visit_expr c;
      Printf.printf ")\n";
      visit_stmt s lvl
  | CAst.Return e ->
      Printf.printf "return ";
      visit_expr e;
      Printf.printf ";"

and visit_expr expr =
  match expr with
  | CAst.Assign (id, e) ->
      Printf.printf "%s = " id;
      visit_expr e
  | CAst.Call (id, args) ->
      Printf.printf "%s(" id;
      visit_args args;
      Printf.printf ")"
  | CAst.IntConst n -> Printf.printf "%d" n
  | CAst.Identifier id -> Printf.printf "%s" id
  | CAst.Operator (e1, op, e2) ->
      Printf.printf "(";
      visit_expr e1;
      (match op with
      | CAst.Comparison Operators.EQ -> Printf.printf " == "
      | CAst.Comparison Operators.NE -> Printf.printf " != "
      | CAst.Comparison Operators.LT -> Printf.printf " < "
      | CAst.Comparison Operators.LE -> Printf.printf " <= "
      | CAst.Comparison Operators.GT -> Printf.printf " > "
      | CAst.Comparison Operators.GE -> Printf.printf " >= "
      | CAst.Arithmetic Operators.ADD -> Printf.printf " + "
      | CAst.Arithmetic Operators.SUB -> Printf.printf " - "
      | CAst.Arithmetic Operators.MUL -> Printf.printf " * "
      | CAst.Arithmetic Operators.DIV -> Printf.printf " / ");
      visit_expr e2;
      Printf.printf ")"

and visit_args args =
  match args with
  | [] -> ()
  | [ a ] -> visit_expr a
  | h :: t ->
      visit_expr h;
      Printf.printf ", ";
      visit_args t

let print_program program =
  Printf.printf "#include <runtime.h>\n\n";
  visit_program program
