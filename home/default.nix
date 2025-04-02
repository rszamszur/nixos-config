{ pkgs, config, ... }:

{
  home = {
    packages = [
      pkgs.nmap
      pkgs.zip
      pkgs.unzip
      pkgs.gnumake
      pkgs.gcc
      pkgs.htop
      pkgs.flameshot
      pkgs.nixpkgs-fmt
      pkgs.nix-index
      pkgs.hydra-check
      pkgs.fzf
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.manix
    ];
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    starship = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    bash = {
      enable = true;
      bashrcExtra = builtins.readFile ../modules/bash/bashrc;
      shellAliases = {
        "l" = "ls -lah";
      };
    };

    vim = {
      enable = true;
      extraConfig = builtins.readFile ../modules/vim/vimrc;
      plugins = [
        pkgs.vimPlugins.YouCompleteMe
        pkgs.vimPlugins.syntastic
        pkgs.vimPlugins.vim-flake8
        pkgs.vimPlugins.nerdtree
        pkgs.vimPlugins.vim-airline
        pkgs.vimPlugins.gruvbox
        pkgs.vimPlugins.vim-nix
      ];
    };

    git = {
      enable = true;
      userName = "Radosław Szamszur";
      userEmail = "github@rsd.sh";
      extraConfig = {
        init = {
          defaultBranch = "master";
        };
        core = {
          editor = "vim";
        };
      };
    };
  };
}
