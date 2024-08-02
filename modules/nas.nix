{ config, lib, pkgs, ... }:

let
  cfg = config.my.nas;
in
{
  options.my.nas = {
    enable = lib.mkEnableOption "Enable my NAS mount.";
    fqdn = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc "NAS FQDN.";
      default = "truenas.szamszur.cloud";
    };
    shareName = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc "NAS samba share name.";
      default = "rszamszur";
    };
    mountPath = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc "The full path to mount point.";
      default = "/mnt/rszamszur";
    };
    credentialsPath = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        The full path to a file which contains the credentials to samba share.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.cifs-utils
    ];

    fileSystems."${cfg.mountPath}" = {
      device = "//${cfg.fqdn}/${cfg.shareName}";
      fsType = "cifs";
      options = [
        "credentials=${cfg.credentialsPath}"
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "rw"
        "uid=${builtins.toString config.users.users.rszamszur.uid}"
        "gid=${builtins.toString config.users.groups.users.gid}"
      ];
    };

  };

}
