type comparator = EQ | NE | LT | LE | GT | GE
type operator = ADD | SUB | MUL | DIV

let invert_comparator op =
  match op with
  | EQ -> NE
  | NE -> EQ
  | LT -> GE
  | LE -> GT
  | GT -> LE
  | GE -> LT
