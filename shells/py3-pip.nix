{ pkgs ? import <nixpkgs> { }
, python ? "python39"
}:

let
  pythonPackage = builtins.getAttr (python) pkgs;
in

pkgs.mkShell {
  buildInputs = [
    pythonPackage
    pythonPackage.pkgs.pip
    pythonPackage.pkgs.setuptools
    pythonPackage.pkgs.wheel
  ];
  shellHook = ''
    export PIP_PREFIX=$(pwd)/.pip
    export PYTHONPATH="$PIP_PREFIX/${pythonPackage.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    export PYTHONPATH="$(pwd):$PYTHONPATH"
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
    unset SOURCE_DATE_EPOCH
  '';
}
