{ config, lib, ... }:

let
  cfg = config.my.zerotier;
in
{

  options.my.zerotier = {
    enable = lib.mkEnableOption "Enables global settings required by virtualbox.";
    networkId = lib.mkOption {
      example = "a8a2c3c10c1a68de";
      type = lib.types.str;
      description = ''
        ZeroTier Network ID to join on startup.
        Note that networks are only ever joined, but not automatically left after removing them from the list.
        To remove networks, use the ZeroTier CLI: `zerotier-cli leave <network-id>`
      '';
    };
  };

  config = lib.mkIf cfg.enable rec {
    services.zerotierone = {
      enable = true;
      joinNetworks = [
        cfg.networkId
      ];
    };
    # TODO: Changes in the bellow activation script should trigger restart of zerotierone.service
    system.activationScripts.makeNetworkConf = lib.stringAfter [ "var" ] ''
      mkdir -p /var/lib/zerotier-one/networks.d
        
      cat <<EOF >> /var/lib/zerotier-one/networks.d/${cfg.networkId}.local.conf
      allowManaged=1
      allowGlobal=0
      allowDefault=0
      allowDNS=1
      EOF
    '';
    my.dns = {
      enable = true;
      puqu.enable = true;
    };
  };

}
