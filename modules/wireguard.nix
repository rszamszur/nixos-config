{ config, lib, ... }:

let
  cfg = config.my.wireguard;
in
{

  options.my.wireguard = {
    enable = lib.mkEnableOption "Enables Wireguard interface.";
    endpoint = lib.mkOption {
      type = lib.types.str;
      description = "Wireguard peer endpoint";
    };
    address = mkOption {
      example = [ "192.168.2.1/24" ];
      default = [
        "192.168.40.5/32"
      ];
      type = with types; listOf str;
      description = "The IP addresses of the interface.";
    };
    dns = mkOption {
      example = [ "192.168.2.2" ];
      default = [
        "192.168.10.5"
        "192.168.25.5"
      ];
      type = with types; listOf str;
      description = "The IP addresses of DNS servers to configure.";
    };
    privateKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Private key file";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wg-quick.interfaces = {
      wg0 = {
        address = cfg.address;
        dns = cfg.dns;
        listenPort = 51820;
        privateKeyFile = cfg.privateKeyFile;
        autostart = false;
        peers = [
          {
            publicKey = "Af88ZLNV0MgaGn4jad+ZW8WcgzDKlXSnp5gpuxV4AwA=";
            allowedIPs = [
              "0.0.0.0/0"
            ];
            endpoint = cfg.endpoint;
          }
        ];
      };
    };

    networking.firewall = {
      allowedUDPPorts = [ config.networking.wg-quick.interfaces.wg0.listenPort ];
    };
  };
}
