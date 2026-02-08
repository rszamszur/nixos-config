{ config, lib, ... }:

let
  cfg = config.my.vbox;
in
{

  options.my.vbox.enable = lib.mkEnableOption "Enables global settings required by virtualbox.";

  config = lib.mkIf cfg.enable {

    virtualisation.virtualbox.host = {
      enable = true;
      enableHardening = false;
      enableExtensionPack = true;
      addNetworkInterface = true;
      headless = false;
    };

    users.extraGroups.vboxusers.members = [ "rszamszur" ];

  };

}
