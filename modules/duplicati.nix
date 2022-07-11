{ config, lib, pkgs, ... }:

let
  cfg = config.my.duplicati;
in
{

  options.my.duplicati.enable = lib.mkEnableOption "Enables duplicati service.";

  config = lib.mkIf cfg.enable {

    services.duplicati.enable = true;

  };

}
