{ config, lib, ... }:

let
  cfg = config.my.duplicati;
in
{

  options.my.duplicati.enable = lib.mkEnableOption "Enables duplicati service.";

  config = lib.mkIf cfg.enable {

    services.duplicati = {
      enable = true;
      interface = "127.0.0.1";
      port = 8200;
    };

  };

}
