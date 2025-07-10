{
  description = "A flake for the Compiler Playground";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [ "x86_64-linux" ];
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_14;
        pythonPackages = pkgs.python313Packages;
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          playground = pkgs.stdenv.mkDerivation {
            pname = "playground";
            version = "0.1.0";
            src = self;
            nativeBuildInputs = (
              with ocamlPackages;
              [
                ocaml
                dune_3
                ocaml-lsp
                ocamlformat
                menhir
              ]
            ) ++ (with pythonPackages;
              [
                python
                pytest
              ]
            );
            buildPhase = ''
              dune build
            '';
            installPhase = ''
              cp -r _build/default/ $out/
              cp $out/bin/main.exe $out/bin/${self.packages.${system}.playground.pname}
            '';
          };
          runtime = pkgs.stdenv.mkDerivation {
            pname = "runtime";
            version = "0.1.0";
            src = self;
            nativeBuildInputs = with pkgs; [ gcc gnumake ];
            buildPhase = ''
              make -C runtime/c/
            '';
            installPhase = ''
              mkdir -p $out/runtime/include
              cp runtime/c/libruntime.a $out/runtime/libruntime.a
              cp runtime/c/runtime.h $out/runtime/include/runtime.h
            '';
          };
          all = pkgs.symlinkJoin {
            pname = "all";
            version = "0.1.0";
            paths = [
              self.packages.${system}.playground
              self.packages.${system}.runtime
            ];
          };
          default = self.packages.${system}.all;
        };
      });
}
