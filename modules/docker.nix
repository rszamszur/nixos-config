{ config, lib, pkgs, ... }:

let
  cfg = config.my.docker;
in
{

  options.my.docker.enable = lib.mkEnableOption "Enables global settings required by docker.";

  config = lib.mkIf cfg.enable {

    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
    };

    users.extraGroups.docker.members = [ "rszamszur" ];

    environment.systemPackages = [
      pkgs.minikube
      pkgs.kubeclt
      pkgs.kubernetes-helm
    ];

  };

}
