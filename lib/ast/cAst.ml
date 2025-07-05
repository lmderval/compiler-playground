type program = declaration list

and declaration =
  | FunctionDef of string * (string * Types.ty) list * Types.ty
  | FunctionDec of string * (string * Types.ty) list * compound_stmt * Types.ty
  | VarDec of string * Types.ty

and compound = Stmt of stmt | Dec of declaration
and compound_stmt = compound list

and stmt =
  | Expr of expr
  | Compound of compound_stmt
  | If of expr * stmt * stmt
  | Return of expr

and expr =
  | Assign of string * expr
  | Call of string * expr list
  | IntConst of int
  | Identifier of string
  | Operator of expr * operator * expr

and operator =
  | Arithmetic of Operators.operator
  | Comparison of Operators.comparator
