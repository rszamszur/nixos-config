{ config, lib, ... }:

let
  cfg = config.my.comin;
in
{
  options.my.comin = {
    enable = lib.mkEnableOption "Enable GitOps For NixOS Machines.";
    localRepoPath = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc "The full path to a local nixos-config repository";
      example = "/var/nixos-config";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Open port in firewall for incoming connections to the Prometheus exporter.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    services.comin = {
      enable = true;
      exporter = {
        openFirewall = cfg.openFirewall;
      };
      remotes = [
        {
          name = "origin";
          url = "https://github.com/rszamszur/nixos-config.git";
          branches.main.name = "master";
          poller.period = 600;
        }
        {
          name = "local";
          url = cfg.localRepoPath;
          branches.main.name = "master";
          poller.period = 60;
        }
      ];
    };

  };
}
