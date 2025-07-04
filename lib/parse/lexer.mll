{
  open Parser
}

let id = ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*
let num = ['0'-'9']+
let ws = [' ' '\t']
let nl = "\n" | "\r" | "\n\r" | "\r\n"

rule lex = parse
(* Keywords *)
| "declare" { DECLARE }
| "print" { PRINT }
| "if" { IF }
| "then" { THEN }
| "else" { ELSE }
| "end" { END }
(* Operators *)
| "<-" { ASSIGN }
| "{" { LBRACE }
| "}" { RBRACE }
| "," { COMMA }
| "(" { LPAR }
| ")" { RPAR }
| "==" { EQ }
| "!=" { NE }
| "<" { LT }
| "<=" { LE }
| ">" { GT }
| ">=" { GE }
| "+" { ADD }
| "-" { SUB }
| "*" { MUL }
| "/" { DIV }
(* Valued tokens *)
| id { let lxm = Lexing.lexeme lexbuf in
       ID(lxm) }
| num { let lxm = Lexing.lexeme lexbuf in
        let num = int_of_string lxm in
        INT(num) }
(* Spaces *)
| ws+ { lex lexbuf }
| nl { Lexing.new_line lexbuf;
       lex lexbuf }
(* End of file *)
| eof { EOF }
| _ { raise (Failure "lexical error") }
{ }
