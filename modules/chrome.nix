{ config, lib, ... }:

let
  cfg = config.my.chrome;
in
{
  options.my.chrome.enable = lib.mkEnableOption "Enable chomium browser with plugins.";

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {

      programs.chromium = {
        enable = true;
        extensions = [
          {
            id = "eggkanocgddhmamlbiijnphhppkpkmkl";
            version = "1.4.141";
          }
          {
            id = "hjobfcedfgohjkaieocljfcppjbkglfd";
            version = "1.2.1";
          }
          {
            id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";
            version = "14.1054.0";
          }
          {
            id = "fgmjlmbojbkmdpofahffgcpkhkngfpef";
            version = "1.1.2";
          }
          {
            id = "nhdogjmejiglipccpnnnanhbledajbpd";
            version = "6.1.3";
          }
          {
            id = "gighmmpiobklfepjocnamgkkbiglidom";
            version = "4.44.0";
          }
        ];
      };

    };

  };
}
