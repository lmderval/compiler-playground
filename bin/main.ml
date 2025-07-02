open Parse

let lexbuf = Lexing.from_channel stdin
let _ = Parser.program Lexer.lex lexbuf
