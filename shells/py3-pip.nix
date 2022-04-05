{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3.pkgs.pip
    pkgs.python3.pkgs.setuptools
    pkgs.python3.pkgs.wheel
  ];
  shellHook = ''
    export PIP_PREFIX=$(pwd)/.pip
    export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    export PATH="$(pwd):$PYTHONPATH"
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
    unset SOURCE_DATE_EPOCH
  '';
}
