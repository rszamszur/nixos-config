{ config, lib, pkgs, ... }:

let
  cfg = config.my.rbe;
in
{
  options.my.rbe = {
    enable = lib.mkEnableOption "Enable my ghetto Nix RBE.";
    hostName = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc "Nix remote builder host name.";
      default = "nix-rbe";
    };
    knownHosts = lib.mkOption {
      type = lib.types.attrs;
      description = lib.mdDoc ''
        Public keys that should be added to the user’s authorized keys.
      '';
      default = {
        "nix-rbe.szamszur.cloud".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG1rbLgcCMYEsJ98VQilrOyCGCcYSYZy3zPRxj+g41g";
      };
    };
    maxJobs = lib.mkOption {
      type = lib.types.int;
      description = lib.mdDoc ''
        Defines the maximum number of jobs that Nix will try to build in parallel.
      '';
      default = 24;
    };
    speedFactor = lib.mkOption {
      type = lib.types.int;
      description = lib.mdDoc ''
        Defines the relative speed of the remote build machine as a positive integer.
      '';
      default = 1;
    };
    rbePrivateKey = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        The full path to a file which contains the ssh private key for rbe auth.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    programs.ssh = {
      knownHosts = cfg.knownHosts;
      extraConfig = ''
        HOST ${cfg.hostName}
             HostName nix-rbe.szamszur.cloud
             User nixremote
             Port 22
             IdentityFile ${cfg.rbePrivateKey}
      '';
    };

    nix = {
      buildMachines = [{
        hostName = cfg.hostName;
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = cfg.maxJobs;
        speedFactor = cfg.speedFactor;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }];
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
        # Ensure we can still build when missing-server is not accessible
        fallback = true
      '';
    };

  };

}
