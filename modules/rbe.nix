{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.rbe;
in
{
  options.my.rbe = {
    enable = lib.mkEnableOption "Enable my ghetto Nix RBE.";
    buildersConfig = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            addToBuildMachines = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = lib.mdDoc ''
                Adds this builder to build machinges used for distributed builds.
                If false then only ssh confg for this builder will be created.
              '';
            };
            host = lib.mkOption {
              type = lib.types.str;
              description = lib.mdDoc ''
                The remote builder IPv4 address of a FQDN.
              '';
              example = "nix-rbe.szamszur.cloud";
            };
            user = lib.mkOption {
              type = lib.types.str;
              default = "nixremote";
              description = lib.mdDoc ''
                The user used for remote builds.
              '';
            };
            publicKey = lib.mkOption {
              type = lib.types.str;
              description = lib.mdDoc ''
                The public ssh key of a remote builder host user (used for remote builds).
              '';
              default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG1rbLgcCMYEsJ98VQilrOyCGCcYSYZy3zPRxj+g41g";
            };
            privateKeyPath = lib.mkOption {
              type = lib.types.path;
              description = lib.mdDoc ''
                The full path to a file which contains the ssh private key for rbe auth.
              '';
            };
            maxJobs = lib.mkOption {
              type = lib.types.int;
              description = lib.mdDoc ''
                Defines the maximum number of jobs that Nix will try to build in parallel.
              '';
              default = 8;
            };
            speedFactor = lib.mkOption {
              type = lib.types.int;
              description = lib.mdDoc ''
                Defines the relative speed of the remote build machine as a positive integer.
              '';
              default = 1;
            };
          };
        }
      );
      example = lib.literalExpression ''
        {
          "pve-nixos-tyr1" = {
            host = "192.168.20.60";
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG1rbLgcCMYEsJ98VQilrOyCGCcYSYZy3zPRxj+g41g";
            privateKeyPath = /path/to/private/key;
            speedFactor = 2;
            maxJobs = 8;
          };
        };
      '';
      description = "Declarative Nix remote builders config";
    };

  };

  config = lib.mkIf cfg.enable {

    programs.ssh =
      let
        sshConfigText = host: hostname: user: key: ''
          HOST ${host}
               HostName ${hostname}
               User ${user}
               Port 22
               IdentityFile ${key}
        '';
        buildConfigText = builtins.concatStringsSep "\n" (
          lib.mapAttrsToList (n: v: sshConfigText n v.host v.user v.privateKeyPath) cfg.buildersConfig
        );
      in
      {
        knownHosts = lib.mapAttrs' (
          _: v: lib.nameValuePair v.host { publicKey = v.publicKey; }
        ) cfg.buildersConfig;
        extraConfig = ''
          ${buildConfigText}
        '';
      };

    nix = {
      buildMachines = lib.mapAttrsToList (n: v: {
        hostName = n;
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = v.maxJobs;
        speedFactor = v.speedFactor;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }) (lib.filterAttrs (_: v: v.addToBuildMachines == true) cfg.buildersConfig);
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
        # Ensure we can still build when missing-server is not accessible
        fallback = true
      '';
    };

  };

}
