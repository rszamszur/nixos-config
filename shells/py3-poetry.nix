{ pkgs ? import <nixpkgs> { }
, python ? "python39"
}:

let
  pythonPackage = builtins.getAttr (python) pkgs;
in

pkgs.mkShell {
  buildInputs = [
    pythonPackage
    (pkgs.poetry.override { python = pythonPackage; })
  ];
  shellHook = ''
    export POETRY_HOME=${pkgs.poetry}
    export POETRY_VIRTUALENVS_IN_PROJECT=true
    unset SOURCE_DATE_EPOCH
  '';
}
