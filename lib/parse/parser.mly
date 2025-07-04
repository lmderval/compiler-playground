%token <string> ID
%token <int> INT

%token DECLARE "declare"
%token PRINT "print"
%token IF "if"
%token THEN "then"
%token ELSE "else"
%token END "end"

%token ASSIGN "<-"
%token LBRACE "{"
%token RBRACE "}"
%token COMMA ","
%token LPAR "("
%token RPAR ")"
%token EQ "=="
%token NE "!="
%token LT "<"
%token LE "<="
%token GT ">"
%token GE ">="
%token ADD "+"
%token SUB "-"
%token MUL "*"
%token DIV "/"

%token EOF "<eof>"

%left ADD SUB
%left MUL DIV

%{
  open Ast
%}

%start <BaseAst.stmt> program

%%

program:
| s = stmt EOF
  { s }

stmt:
| DECLARE id = ID
  { BaseAst.DeclareStmt id }
| id = ID ASSIGN e = expr
  { BaseAst.AssignStmt (id, e) }
| PRINT e = expr
  { BaseAst.PrintStmt e }
| IF c = cond THEN s = stmt END
  { BaseAst.IfStmt (c, s, (BlockStmt [])) }
| IF c = cond THEN s1 = stmt ELSE s2 = stmt END
  { BaseAst.IfStmt (c, s1, s2) }
| LBRACE ss = separated_list(COMMA, stmt) RBRACE
  { BaseAst.BlockStmt ss }

cond:
| e1 = expr EQ e2 = expr
  { (e1, Operators.EQ, e2) }
| e1 = expr NE e2 = expr
  { (e1, Operators.NE, e2) }
| e1 = expr LT e2 = expr
  { (e1, Operators.LT, e2) }
| e1 = expr LE e2 = expr
  { (e1, Operators.LE, e2) }
| e1 = expr GT e2 = expr
  { (e1, Operators.GT, e2) }
| e1 = expr GE e2 = expr
  { (e1, Operators.GE, e2) }

expr:
| id = ID
  { BaseAst.IdExpr id }
| n = INT
  { BaseAst.IntExpr n }
| e1 = expr ADD e2 = expr
  { BaseAst.OperationExpr (e1, Operators.ADD, e2) }
| e1 = expr SUB e2 = expr
  { BaseAst.OperationExpr (e1, Operators.SUB, e2) }
| e1 = expr MUL e2 = expr
  { BaseAst.OperationExpr (e1, Operators.MUL, e2) }
| e1 = expr DIV e2 = expr
  { BaseAst.OperationExpr (e1, Operators.DIV, e2) }
| LPAR e = expr RPAR
  { e }

%%
