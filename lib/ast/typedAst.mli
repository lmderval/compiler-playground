type stmt =
  | DeclareStmt of string * Types.ty
  | AssignStmt of string * expr
  | PrintStmt of expr
  | IfStmt of cond * stmt * stmt
  | BlockStmt of stmt list

and cond = expr * Operators.comparator * expr

and expr =
  | IdExpr of string * Types.ty
  | IntExpr of int * Types.ty
  | OperationExpr of (expr * Operators.operator * expr) * Types.ty

val typeof : expr -> Types.ty
