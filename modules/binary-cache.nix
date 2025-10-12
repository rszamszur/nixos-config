{ config, options, lib, ... }:

let
  cfg = config.my.binary-cache;
in
{
  options.my.binary-cache = {
    enable = lib.mkEnableOption "Enable self-hosted Nix binary cache.";
    binaryCacheKey = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        The full path to a file which contains the binary cache private key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    services.nix-serve = {
      enable = true;
      secretKeyFile = cfg.binaryCacheKey;
    };
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "nixgard.szamszur.cloud" = {
          locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
