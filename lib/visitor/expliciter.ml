open Ast
module VarSet = Set.Make (String)

let enter env = VarSet.empty :: env

let leave env =
  match env with
  | _ :: t -> t
  | _ ->
      Printf.eprintf "No scope to leave\n";
      exit 1

let rec lookup env id =
  match env with
  | [] -> false
  | h :: t -> (
      match VarSet.find_opt id h with None -> lookup t id | Some _ -> true)

let push env id =
  match env with
  | [] ->
      Printf.eprintf "No scope to push variable\n";
      exit 1
  | h :: t -> VarSet.add id h :: t

let rec explicit_stmt stmt env =
  match stmt with
  | BaseAst.AssignStmt (id, e) ->
      let e, env = explicit_expr e env in
      if lookup env id then (BaseAst.AssignStmt (id, e), env)
      else
        ( BaseAst.BlockStmt [ BaseAst.VarDecStmt id; BaseAst.AssignStmt (id, e) ],
          env )
  | BaseAst.PrintStmt e ->
      let e, env = explicit_expr e env in
      (BaseAst.PrintStmt e, env)
  | BaseAst.IfStmt (c, s1, s2) ->
      let c, env = explicit_cond c env in
      let s1, env = explicit_stmt s1 env in
      let s2, env = explicit_stmt s2 env in
      (BaseAst.IfStmt (c, s1, s2), env)
  | BaseAst.BlockStmt ss ->
      let env = enter env in
      let ss, env = explicit_block ss env in
      let env = leave env in
      (BaseAst.BlockStmt ss, env)
  | _ -> (stmt, env)

and explicit_block stmts env =
  match stmts with
  | [] -> ([], env)
  | BaseAst.AssignStmt (id, e) :: t ->
      let e, env = explicit_expr e env in
      let assign = BaseAst.AssignStmt (id, e) in
      if lookup env id then
        let t, env = explicit_block t env in
        (assign :: t, env)
      else
        let env = push env id in
        let t, env = explicit_block t env in
        (BaseAst.VarDecStmt id :: assign :: t, env)
  | h :: t ->
      let h, env = explicit_stmt h env in
      let t, env = explicit_block t env in
      (h :: t, env)

and explicit_cond cond env =
  match cond with
  | e1, op, e2 ->
      let e1, env = explicit_expr e1 env in
      let e2, env = explicit_expr e2 env in
      ((e1, op, e2), env)

and explicit_expr expr env =
  match expr with
  | BaseAst.IdExpr id -> (BaseAst.IdExpr id, env)
  | BaseAst.IntExpr n -> (BaseAst.IntExpr n, env)
  | BaseAst.OperationExpr (e1, op, e2) ->
      let e1, env = explicit_expr e1 env in
      let e2, env = explicit_expr e2 env in
      (BaseAst.OperationExpr (e1, op, e2), env)

let explicit stmt =
  let stmt, _ = explicit_stmt stmt (enter []) in
  stmt
