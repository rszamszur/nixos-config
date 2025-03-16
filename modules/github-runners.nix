{ config, options, lib, pkgs, ... }:

let
  inherit (pkgs.mylib.trivial) inheritAllExcept filterRemovedOptions;
  cfg = config.my.github-runners;
in
{
  options.my.github-runners = filterRemovedOptions (options.services.github-runners.type.getSubOptions [ config.my.github-runners.name.value ]) // {
    enable = lib.mkEnableOption "Enable self-hosted GitHub runners.";
    name = lib.mkOption {
      type = lib.types.str;
      default = "nixos-runner";
      description = lib.mdDoc ''
        GitHub runner name.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    services.github-runners = {
      "${cfg.name}" = inheritAllExcept cfg [ "enable" ] // {
        enable = true;
      };
    };

  };

}
