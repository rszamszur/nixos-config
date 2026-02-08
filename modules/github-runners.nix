{ config, options, lib, pkgs, ... }:

let
  inherit (pkgs.nix-utils.trivial) inheritAllExcept filterRemovedOptions;
  cfg = config.my.github-runners;
in
{
  options.my.github-runners = {
    enable = lib.mkEnableOption "Enable self-hosted GitHub runners.";
    runners = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (
        { name, config, ... }:
        {
          options = (inheritAllExcept (filterRemovedOptions (options.services.github-runners.type.getSubOptions { inherit name config; })) [ "enable" "name" "_module" ]) // {
            name = lib.mkOption {
              type = lib.types.str;
              default = "nixos-runner";
              description = lib.mdDoc ''
                GitHub runner name.
              '';
            };
            enable = lib.mkOption {
              default = true;
              example = true;
              description = "Whether to enable GitHub Actions runner.";
              type = lib.types.bool;
            };
          };
        }
      )
      );
    };
  };

  config = lib.mkIf cfg.enable {

    services.github-runners = cfg.runners;

  };

}
