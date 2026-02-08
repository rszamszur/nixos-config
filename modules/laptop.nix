{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.laptop;
in
{
  options.my.laptop.enable = lib.mkEnableOption "Enable laptop related modules.";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.acpi
    ];

    services.acpid.enable = true;
    services.tlp.enable = true;
    # A userspace daemon to enable security levels for Thunderbolt 3
    services.hardware.bolt.enable = true;
    # Enable touchpad
    services.libinput.enable = true;
    # A keyboard shortcut daemon
    services.actkbd.enable = true;

  };

}
