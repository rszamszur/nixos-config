{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
  ];
}
