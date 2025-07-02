open Parse

let lexbuf = Lexing.from_channel stdin
let () = Parser.program Lexer.lex lexbuf
