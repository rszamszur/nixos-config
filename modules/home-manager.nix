{ config, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
in 
{
  imports = [
    (import "${home-manager}/nixos")
  ];
}