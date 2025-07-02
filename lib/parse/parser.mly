%token <string> ID
%token <int> INT

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

%start <unit> program

%%

program:
| stmt EOF
  { }

stmt:
| ID ASSIGN expr
  { }
| PRINT expr
  { }
| IF cond THEN stmt END
  { }
| IF cond THEN stmt ELSE stmt END
  { }
| LBRACE separated_list(COMMA, stmt) RBRACE
  { }

cond:
| expr EQ expr
  { }
| expr NE expr
  { }
| expr LT expr
  { }
| expr LE expr
  { }
| expr GT expr
  { }
| expr GE expr
  { }

expr:
| ID
  { }
| INT
  { }
| expr ADD expr
  { }
| expr SUB expr
  { }
| expr MUL expr
  { }
| expr DIV expr
  { }
| LPAR expr RPAR
  { }

%%
