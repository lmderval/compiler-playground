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
      match Hashtbl.find_opt h id with None -> lookup t id | Some ty -> ty)

let typevar env id ty =
  match env with
  | [] ->
      Printf.eprintf "failure: no scope to push variable\n";
      exit 1
  | h :: t ->
      Hashtbl.replace h id ty;
      h :: t

let rec type_stmt stmt env =
  match stmt with
  | BaseAst.DeclareStmt id ->
      let env = typevar env id Types.IntTy in
      (TypedAst.DeclareStmt (id, Types.IntTy), env)
  | BaseAst.AssignStmt (id, e) ->
      let id_ty = lookup env id in
      let e, env = type_expr e env in
      if id_ty = TypedAst.typeof e then (TypedAst.AssignStmt (id, e), env)
      else (
        Printf.eprintf "typing error: types mismatch\n";
        exit 5)
  | BaseAst.PrintStmt e ->
      let e, env = type_expr e env in
      (TypedAst.PrintStmt e, env)
  | BaseAst.IfStmt (c, s1, s2) ->
      let c, env = type_cond c env in
      let s1, env = type_stmt s1 env in
      let s2, env = type_stmt s2 env in
      (TypedAst.IfStmt (c, s1, s2), env)
  | BaseAst.BlockStmt ss ->
      let env = enter env in
      let ss, env = type_block ss env in
      let env = leave env in
      (TypedAst.BlockStmt ss, env)

and type_block stmts env =
  match stmts with
  | [] -> ([], env)
  | h :: t ->
      let h, env = type_stmt h env in
      let t, env = type_block t env in
      (h :: t, env)

and type_cond cond env =
  match cond with
  | e1, op, e2 -> (
      let e1, env = type_expr e1 env in
      let e2, env = type_expr e2 env in
      match (TypedAst.typeof e1, TypedAst.typeof e2) with
      | Types.IntTy, Types.IntTy -> ((e1, op, e2), env))

and type_expr expr env =
  match expr with
  | BaseAst.IdExpr id ->
      let ty = lookup env id in
      (TypedAst.IdExpr (id, ty), env)
  | BaseAst.IntExpr n -> (TypedAst.IntExpr (n, Types.IntTy), env)
  | BaseAst.OperationExpr (e1, op, e2) -> (
      let e1, env = type_expr e1 env in
      let e2, env = type_expr e2 env in
      match (TypedAst.typeof e1, TypedAst.typeof e2) with
      | Types.IntTy, Types.IntTy ->
          (TypedAst.OperationExpr ((e1, op, e2), Types.IntTy), env))

let type_check stmt =
  let stmt, _ = type_stmt stmt (enter []) in
  stmt
