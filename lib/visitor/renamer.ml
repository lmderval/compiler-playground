open Ast

let enter env = Hashtbl.create 16 :: env

let leave env =
  match env with
  | [] ->
      Printf.eprintf "failure: no scope to leave\n";
      exit 1
  | _ :: t -> t

let rec lookup env id =
  match env with
  | [] ->
      Printf.eprintf "binding error: no variable matching '%s'\n" id;
      exit 4
  | h :: t -> (
      match Hashtbl.find_opt h id with None -> lookup t id | Some id -> id)

let rename env id fresh =
  match env with
  | [] ->
      Printf.eprintf "failure: no scope to push variable\n";
      exit 1
  | h :: t ->
      let fresh_id = Printf.sprintf "%s%d" id fresh in
      Hashtbl.replace h id fresh_id;
      (fresh_id, h :: t, fresh + 1)

let rec rename_stmt stmt env fresh =
  match stmt with
  | BaseAst.DeclareStmt id ->
      let id, env, fresh = rename env id fresh in
      (BaseAst.DeclareStmt id, env, fresh)
  | BaseAst.AssignStmt (id, e) ->
      let id = lookup env id in
      let e, env, fresh = rename_expr e env fresh in
      (BaseAst.AssignStmt (id, e), env, fresh)
  | BaseAst.PrintStmt e ->
      let e, env, fresh = rename_expr e env fresh in
      (BaseAst.PrintStmt e, env, fresh)
  | BaseAst.IfStmt (c, s1, s2) ->
      let c, env, fresh = rename_cond c env fresh in
      let s1, env, fresh = rename_stmt s1 env fresh in
      let s2, env, fresh = rename_stmt s2 env fresh in
      (BaseAst.IfStmt (c, s1, s2), env, fresh)
  | BaseAst.WhileStmt (c, s) ->
      let c, env, fresh = rename_cond c env fresh in
      let s, env, fresh = rename_stmt s env fresh in
      (BaseAst.WhileStmt (c, s), env, fresh)
  | BaseAst.BlockStmt ss ->
      let env = enter env in
      let ss, env, fresh = rename_block ss env fresh in
      let env = leave env in
      (BaseAst.BlockStmt ss, env, fresh)

and rename_block stmts env fresh =
  match stmts with
  | [] -> ([], env, fresh)
  | h :: t ->
      let h, env, fresh = rename_stmt h env fresh in
      let t, env, fresh = rename_block t env fresh in
      (h :: t, env, fresh)

and rename_cond cond env fresh =
  match cond with
  | e1, op, e2 ->
      let e1, env, fresh = rename_expr e1 env fresh in
      let e2, env, fresh = rename_expr e2 env fresh in
      ((e1, op, e2), env, fresh)

and rename_expr expr env fresh =
  match expr with
  | BaseAst.IdExpr id ->
      let id = lookup env id in
      (BaseAst.IdExpr id, env, fresh)
  | BaseAst.OperationExpr (e1, op, e2) ->
      let e1, env, fresh = rename_expr e1 env fresh in
      let e2, env, fresh = rename_expr e2 env fresh in
      (BaseAst.OperationExpr (e1, op, e2), env, fresh)
  | _ -> (expr, env, fresh)

let rename_var stmt =
  let stmt, _, _ = rename_stmt stmt (enter []) 0 in
  stmt
