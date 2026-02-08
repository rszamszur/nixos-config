{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.docker;
in
{
  options.my.docker = {
    enable = lib.mkEnableOption "Enables global settings required by docker.";
    enableNvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable nvidia-docker wrapper, supporting NVIDIA GPUs inside docker containers.";
    };
    extraDockerGroupUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = lib.mdDoc "Adds extra users to the docker group.";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
    };

    hardware.nvidia-container-toolkit.enable = cfg.enableNvidia;
    virtualisation.docker.daemon.settings.features.cdi = cfg.enableNvidia;
    virtualisation.docker.rootless.daemon.settings.features.cdi = cfg.enableNvidia;

    users.extraGroups.docker.members = [ "rszamszur" ] ++ cfg.extraDockerGroupUsers;

    environment.systemPackages = [
      pkgs.dive
      pkgs.trivy
    ];
  };
}
