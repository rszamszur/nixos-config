{ config, lib, pkgs, ... }:

let
  cfg = config.my.local-llm;
  tls-cert = { alt ? [ ] }: (pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
    mkdir -p $out
    openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 365 -nodes \
      -keyout $out/cert.key -out $out/cert.crt \
      -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,${builtins.concatStringsSep "," (["IP:127.0.0.1"] ++ alt)}"
  '');
in
{
  options.my.local-llm = {
    enable = lib.mkEnableOption "Enable stack for local large language models.";
    ollamaPackage = lib.mkPackageOption pkgs "ollama" { };
    webuiPackage = lib.mkPackageOption pkgs "open-webui" { };
    loadModels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Download these models using `ollama pull` as soon as `ollama.service` has started.

        This creates a systemd unit `ollama-model-loader.service`.

        Search for models of your choice from: https://ollama.com/library
      '';
    };
    ollamaHome = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ollama";
      example = "/home/foo";
      description = ''
        The home directory that the ollama service is started in.
      '';
    };
    webuiStateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui";
      example = "/home/foo";
      description = "State directory of Open-WebUI.";
    };
    ingressFQDN = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The FQDN for the open-webui ingress through the Nginx reverse proxy.
        If this is not specified, the Nginx service and the open-webui virtual host will not be deployed.
      '';
    };
  };

  config = lib.mkIf cfg.enable rec {

    services.ollama = {
      package = cfg.ollamaPackage;
      enable = true;
      user = "ollama";
      acceleration = "cuda";
      loadModels = cfg.loadModels;
      home = cfg.ollamaHome;
    };

    services.open-webui = {
      enable = true;
      package = cfg.webuiPackage;
      stateDir = cfg.webuiStateDir;
    };

    services.nginx = lib.mkIf (cfg.ingressFQDN != null) {
      enable = true;
      virtualHosts = {
        "${cfg.ingressFQDN}" =
          let
            cert = tls-cert { alt = [ "DNS:${cfg.ingressFQDN}" ]; };
          in
          {
            serverName = "${cfg.ingressFQDN}";
            listen = [
              {
                addr = "0.0.0.0";
                port = 443;
                ssl = true;
              }
            ];
            forceSSL = true;
            sslCertificate = "${cert}/cert.crt";
            sslCertificateKey = "${cert}/cert.key";
            extraConfig = ''
              ssl_protocols TLSv1.2 TLSv1.3;
            '';
            locations."/" = {
              proxyPass = "http://${config.services.open-webui.host}:${builtins.toString config.services.open-webui.port}";
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";

                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_buffering off;
              '';
            };
          };
      };
    };
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.ingressFQDN != null) [ 80 443 ];
  };

}
