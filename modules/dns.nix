{ config, lib, ... }:

let
  cfg = config.my.dns;
in
{
  options.my.dns = {
    enable = lib.mkEnableOption "Enables my DNS configuration.";
    puqu.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables puqu.io dnsmasq entry.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      settings.server = [
        "/szamszur.cloud/192.168.10.5"
        (lib.mkIf cfg.puqu.enable "/puqu.io/192.168.25.5")
      ];
    };
  };
}
