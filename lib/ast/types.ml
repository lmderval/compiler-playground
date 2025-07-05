type ty = IntTy

let string_of_ty ty = match ty with IntTy -> "int"
let print_ty chan ty = output_string chan (string_of_ty ty)
