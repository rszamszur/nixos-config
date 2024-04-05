{ config, lib, pkgs, ... }:

let
  cfg = config.my.remote-builder;
in
{
  options.my.remote-builder = {
    enable = lib.mkEnableOption "Enable cache module.";
    user = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc "User for running remote builds.";
      default = "nixremote";
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = lib.mdDoc ''
        Public keys that should be added to the user’s authorized keys.
      '';
      default = [ ];
    };
    maxJobs = lib.mkOption {
      type = lib.types.int;
      description = lib.mdDoc ''
        Defines the maximum number of jobs that Nix will try to build in parallel.
      '';
      default = 6;
    };
    binaryCacheKey = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        The full path to a file which contains the binary cache private.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    users = {
      groups."${cfg.user}" = { };
      users = {
        "${cfg.user}" = {
          uid = 2001;
          isSystemUser = true;
          description = "User for remote builds";
          createHome = true;
          group = "${cfg.user}";
          openssh.authorizedKeys.keys = cfg.authorizedKeys;
          shell = pkgs.bash;
        };
      };
    };

    nix = {
      settings = {
        max-jobs = cfg.maxJobs;
        trusted-users = [ "${cfg.user}" ];
      };
      extraOptions = ''
        secret-key-files = ${cfg.binaryCacheKey}
      '';
    };

  };

}
