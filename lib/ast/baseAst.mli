type comparator = EQ | NE | LT | LE | GT | GE
type operator = ADD | SUB | MUL | DIV

type stmt =
  | AssignStmt of string * expr
  | PrintStmt of expr
  | IfStmt of cond * stmt * stmt
  | BlockStmt of stmt list

and cond = expr * comparator * expr

and expr =
  | IdExpr of string
  | IntExpr of int
  | OperationExpr of expr * operator * expr
