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
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Download these models using `ollama pull` as soon as `ollama.service` has started.

        This creates a systemd unit `ollama-model-loader.service`.

        Search for models of your choice from: https://ollama.com/library
      '';
    };
    ingressFQDN = lib.mkOption {
      type = types.nullOr types.str;
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
    };

    services.open-webui = {
      enable = true;
      package = cfg.webuiPackage;
    };

    services.nginx = lib.mkIf (cfg.ingressFQDN != null) {
      enable = true;
      virtualHosts =
        let
          cert = tls-cert { alt = [ "${ingressFQDN}" ]; };
        in
        {
          "${ingressFQDN}" = {
            serverName = "${ingressFQDN}";
            listen = [
              {
                port = 443;
                ssl = true;
              }
            ];
            sslCertificate = "${cert}/cert.crt";
            sslCertificateKey = "${cert}/cert.key";
            extraConfig = ''
              ssl_protocols TLSv1.2 TLSv1.3;
            '';
            locations."/" = {
              proxyPass = "http://${services.open-webui.host}:${services.open-webui.port}";
              extraConfig = ''
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

  };

}
