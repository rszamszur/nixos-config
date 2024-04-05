{ config, lib, pkgs, ... }:

let
  cfg = config.my.github-runners;
in
{
  options.my.github-runners = {
    enable = lib.mkEnableOption "Enable self-hosted GitHub runners.";
    namePrefix = lib.mkOption {
      type = lib.types.str;
      default = "pve-nixos-tyr";
      description = lib.mdDoc ''
        GitHub runners name prefix.
      '';
    };
    tokenFile = lib.mkOption {
      type = lib.lib.types.path;
      description = lib.mdDoc ''
        The full path to a file which contains either

        * a fine-grained personal access token (PAT),
        * a classic PAT
        * or a runner registration token

        Changing this option or the `tokenFile`’s content triggers a new runner registration.

        We suggest using the fine-grained PATs. A runner registration token is valid
        only for 1 hour after creation, so the next time the runner configuration changes
        this will give you hard-to-debug HTTP 404 errors in the configure step.

        The file should contain exactly one line with the token without any newline.
        (Use `echo -n '…token…' > …token file…` to make sure no newlines sneak in.)

        If the file contains a PAT, the service creates a new registration token
        on startup as needed.
        If a registration token is given, it can be used to re-register a runner of the same
        name but is time-limited as noted above.

        For fine-grained PATs:

        Give it "Read and Write access to organization/repository self hosted runners",
        depending on whether it is organization wide or per-repository. You might have to
        experiment a little, fine-grained PATs are a `beta` Github feature and still subject
        to change; nonetheless they are the best option at the moment.

        For classic PATs:

        Make sure the PAT has a scope of `admin:org` for organization-wide registrations
        or a scope of `repo` for a single repository.

        For runner registration tokens:

        Nothing special needs to be done, but updating will break after one hour,
        so these are not recommended.
      '';
      example = "/run/secrets/github-runner/nixos.token";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/rszamszur/nixos-config";
      description = lib.mdDoc ''
        Repository to add the runner to.

        Changing this option triggers a new runner registration.

        IMPORTANT: If your token is org-wide (not per repository), you need to
        provide a github org link, not a single repository, so do it like this
        `https://github.com/nixos`, not like this
        `https://github.com/nixos/nixpkgs`.
        Otherwise, you are going to get a `404 NotFound`
        from `POST https://api.github.com/actions/runner-registration`
        in the configure script.
      '';
      example = "https://github.com/nixos/nixpkgs";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = lib.mdDoc ''
        Extra packages to add to `PATH` of the service to make them available to workflows.
      '';
      default = [
        pkgs.cachix
        pkgs.git
      ];
    };
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = lib.mdDoc ''
        User under which to run the service. If null, will use a systemd dynamic user.
      '';
      default = null;
      defaultText = lib.literalExpression "username";
    };
    extraLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = lib.mdDoc ''
        Extra labels in addition to the default (`["self-hosted", "Linux", "X64"]`).

        Changing this option triggers a new runner registration.
      '';
      example = lib.literalExpression ''[ "nixos" ]'';
      default = [ "nixos" ];
    };
  };

  config = lib.mkIf cfg.enable {

    services.github-runners = {
      runner1 = {
        enable = true;
        name = "${cfg.namePrefix}-runner1";
        tokenFile = cfg.tokenFile;
        user = cfg.user;
        replace = true;
        extraPackages = cfg.extraPackages;
        extraLabels = cfg.extraLabels;
        url = cfg.url;
      };
      runner2 = {
        enable = true;
        name = "${cfg.namePrefix}-runner2";
        tokenFile = cfg.tokenFile;
        user = cfg.user;
        replace = true;
        extraPackages = cfg.extraPackages;
        extraLabels = cfg.extraLabels;
        url = cfg.url;
      };
    };

  };

}
