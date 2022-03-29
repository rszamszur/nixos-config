{ config, lib, pkgs, ... }:

let
  cfg = config.my.podman;
in
{

  options.my.podman.enable = lib.mkEnableOption "Enables global settings required by podman.";

  config = lib.mkIf cfg.enable {

    virtualisation.podman.enable = true;

    environment.systemPackages = [
      pkgs.dive
      pkgs.trivy
    ];
    
  };

}
