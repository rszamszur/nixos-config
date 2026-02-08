{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.vim;
in
{
  options.my.vim.enable = lib.mkEnableOption "Enable vim with plugins.";

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur =
      { ... }:
      {

        programs.vim = {
          enable = true;
          extraConfig = builtins.readFile ./vimrc;
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

      };

  };
}
