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
    assertions = [
      {
        assertion = config.my.acme.enable;
        message = "Module my.acme is required to expose https reverse proxy for binary cache";
      }
    ];

    services.ncps = {
      enable = true;
      cache = {
        hostName = "nixgard";
        lru.schedule = "0 2 * * *";
        maxSize = "900G";
        allowPutVerb = true;
        allowDeleteVerb = true;
        secretKeyPath = cfg.binaryCacheKey;
      };
      server.addr = "0.0.0.0:8501";
      upstream = {
        caches = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        publicKeys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "nixgard.szamszur.cloud" = {
          serverName = "nixgard.szamszur.cloud";
          listen = [
            {
              addr = "0.0.0.0";
              port = 443;
              ssl = true;
            }
          ];
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            ssl_protocols TLSv1.2 TLSv1.3;
            client_max_body_size 100G;
            client_body_timeout 7200s;
            send_timeout 7200s;
          '';
          locations."/".proxyPass = "http://${config.services.ncps.server.addr}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];
  };
}
