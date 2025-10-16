{ config, lib, ... }:

let
  cfg = config.my.acme;
in
{
  options.my.acme = {
    enable = lib.mkEnableOption "Enable ACME DNS-01 for my domains.";
    ovhCredentialsFile = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        The full path to a file which contains the OVH credentials.
        https://go-acme.github.io/lego/dns/ovh/index.html
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "nixos-acme@rsd.sh";
        dnsProvider = "ovh";
        webroot = null;
        environmentFile = cfg.ovhCredentialsFile;
      };
      certs = {
        "nixgard.szamszur.cloud" = lib.mkIf config.my.binary-cache.enable {
          inheritDefaults = true;
          domain = "nixgard.szamszur.cloud";
          group = "nginx";
        };
      };
    };

  };
}
