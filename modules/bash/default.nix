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

  manix = pkgs.callPackage ../../pkgs/tools/nix/manix {
    lib = pkgs.lib;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    rustPlatform = pkgs.rustPlatform;
  };
in
{

  options = {
    my.bash = {
      enable = lib.mkEnableOption "Enables bash.";
      gitUser = lib.mkOption {
        type = lib.types.str;
        default = "Radosław Szamszur";
        description = "Git user name.";
      };
      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "github@rsd.sh";
        description = "Git user email.";
      };
      homepkgs = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "List of additional home packages.";
        example = lib.literalExpression "[ pkgs.vlc ]";
      };
      comma = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to add comma to user packages.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {
      
      home.stateVersion = "22.11";

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      programs.bash = {
        enable = true;
        bashrcExtra = builtins.readFile ./bashrc;
      };

      programs.git = {
        enable = true;
        userName = cfg.gitUser;
        userEmail = cfg.gitEmail;
        extraConfig = {
          init = {
            defaultBranch = "master";
          };
          core = {
            editor = "vim";
          };
        };
      };

      home.packages = [
        pkgs.nmap
        pkgs.zip
        pkgs.unzip
        pkgs.gnumake
        pkgs.gcc
        pkgs.htop
        pkgs.flameshot
        pkgs.nix-linter
        pkgs.nixpkgs-fmt
        pkgs.nix-index
        pkgs.hydra-check
        pkgs.fzf
        manix
      ] ++ cfg.homepkgs ++ lib.optionals cfg.comma [ comma ];

    };

  };

}
