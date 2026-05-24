{
  config,
  options,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.nix-utils.trivial) inheritAllExcept filterRemovedOptions;
  cfg = config.my.forgejo-runners;
in
{
  options.my.forgejo-runners = {
    enable = lib.mkEnableOption "Enable self-hosted Forgejo runners.";
    runners = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          {
            options =
              (inheritAllExcept
                (filterRemovedOptions (
                  options.services.gitea-actions-runner.instances.type.getSubOptions { inherit name config; }
                ))
                [
                  "enable"
                  "name"
                  "_module"
                ]
              )
              // {
                name = lib.mkOption {
                  type = lib.types.str;
                  default = "nixos-runner";
                  description = lib.mdDoc ''
                    forgejo runner name.
                  '';
                };
                enable = lib.mkOption {
                  default = true;
                  example = true;
                  description = "Whether to enable forgejo Actions runner.";
                  type = lib.types.bool;
                };
              };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {

    services.gitea-actions-runner.instances = cfg.runners;

  };

}
