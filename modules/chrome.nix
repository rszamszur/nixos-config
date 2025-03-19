{ config, pkgs, lib, ... }:

let
  cfg = config.my.chrome;
in
{
  options.my.chrome = {
    enable = lib.mkEnableOption "Enable chomium browser with plugins.";
    package = lib.mkPackageOption pkgs "ungoogled-chromium" { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {

      programs.chromium = {
        inherit (cfg) package;
        enable = true;
        extensions = [
          {
            # Tabs Outliner
            id = "eggkanocgddhmamlbiijnphhppkpkmkl";
            version = "1.4.153";
          }
          {
            # Grammarly
            id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";
            version = "14.1227.1";
          }
          {
            # Start page
            id = "fgmjlmbojbkmdpofahffgcpkhkngfpef";
            version = "3.0.7";
          }
          {
            # Vue.js devtools
            id = "nhdogjmejiglipccpnnnanhbledajbpd";
            version = "7.7.0";
          }
          {
            # Ublock
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            version = "1.63.0";
          }
        ];
      };

    };

  };
}
