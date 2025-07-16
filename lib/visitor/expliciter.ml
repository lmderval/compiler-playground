open Ast
module VarSet = Set.Make (String)

let enter env = VarSet.empty :: env

let leave env =
  match env with
  | [] ->
      Printf.eprintf "failure: no scope to leave\n";
      exit 1
  | _ :: t -> t

let rec lookup env id =
  match env with
  | [] -> false
  | h :: t -> (
      match VarSet.find_opt id h with None -> lookup t id | Some _ -> true)

let push env id =
  match env with
  | [] ->
      Printf.eprintf "failure: no scope to push variable\n";
      exit 1
  | h :: t -> VarSet.add id h :: t

let rec explicit_stmt stmt env =
  match stmt with
  | BaseAst.DeclareStmt id ->
      let env = push env id in
      (BaseAst.DeclareStmt id, env)
  | BaseAst.AssignStmt (id, e) ->
      if lookup env id then (BaseAst.AssignStmt (id, e), env)
      else
        ( BaseAst.BlockStmt
            [ BaseAst.DeclareStmt id; BaseAst.AssignStmt (id, e) ],
          env )
  | BaseAst.IfStmt (c, s1, s2) ->
      let s1, env = explicit_stmt s1 env in
      let s2, env = explicit_stmt s2 env in
      (BaseAst.IfStmt (c, s1, s2), env)
  | BaseAst.WhileStmt (c, s) ->
      let s, env = explicit_stmt s env in
      (BaseAst.WhileStmt (c, s), env)
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
      let assign = BaseAst.AssignStmt (id, e) in
      if lookup env id then
        let t, env = explicit_block t env in
        (assign :: t, env)
      else
        let env = push env id in
        let t, env = explicit_block t env in
        (BaseAst.DeclareStmt id :: assign :: t, env)
  | h :: t ->
      let h, env = explicit_stmt h env in
      let t, env = explicit_block t env in
      (h :: t, env)

let explicit_declaration stmt =
  let stmt, _ = explicit_stmt stmt (enter []) in
  stmt
