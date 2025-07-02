(lang dune 3.15)

(using menhir 3.0)

(name playground)

(generate_opam_files true)

(source
 (github lmderval/compiler-playground))

(authors "Louis-Maël DERVAL")

(maintainers "Louis-Maël DERVAL")

(license MIT)

(documentation https://github.com/lmderval/compiler-playground)

(package
 (name playground)
 (synopsis "A compiler playground")
 (description
  "A compiler playground to test things about compiler implementation")
 (depends ocaml dune)
 (tags
  (compiler playground ocaml)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
