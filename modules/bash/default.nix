{ config, lib, pkgs, ... }:

let
  cfg = config.my.bash;

  comma = import
    (pkgs.fetchFromGitHub {
      owner = "Shopify";
      repo = "comma";
      rev = "67f26046b946f1eceb7e4df36875fef91cf39a04";
      sha256 = "sha256-ZRfyv46N3oQbpDwobXMPp9PDnAyceN+9GoOeHj4oWWk=";
    })
    { };
in
{

  options.my.bash.enable = lib.mkEnableOption "Enables bash.";

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      programs.bash = {
        enable = true;
        bashrcExtra = builtins.readFile ./bashrc;
      };

      home.packages = [
        pkgs.nix-linter
        pkgs.nixpkgs-fmt
        pkgs.nix-index
        pkgs.hydra-check
        pkgs.manix
        pkgs.fzf
        comma
      ];

    };

  };

}
