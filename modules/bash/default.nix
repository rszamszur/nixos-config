{ config, lib, pkgs, ... }:

let
  cfg = config.my.bash;
in
{

  options.my.bash.enable = lib.mkEnableOption "Enables bash.";

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {

        programs.direnv.enable = true;
        programs.direnv.nix-direnv.enable = true;

        programs.bash = {
            enable = true;
            bashrcExtra = builtins.readFile ./.bashrc;
        };

        home.packages = [
            pkgs.nix-linter
            pkgs.nixpkgs-fmt
            pkgs.nix-index
            pkgs.hydra-check
            pkgs.fzf
        ];

    };
    
  };

}
