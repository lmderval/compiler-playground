type stmt =
  | AssignStmt of string * expr
  | PrintStmt of expr
  | IfStmt of cond * stmt * stmt
  | BlockStmt of stmt list

and cond = expr * Operators.comparator * expr

and expr =
  | IdExpr of string
  | IntExpr of int
  | OperationExpr of expr * Operators.operator * expr
