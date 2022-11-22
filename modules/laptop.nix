{ config, lib, pkgs, ... }:

let
  cfg = config.my.laptop;
in
{
  options.my.laptop.enable = lib.mkEnableOption "Enable laptop related modules.";

  config = lib.mkIf cfg.enable {

    my.sound.enable = true;

    environment.systemPackages = [
      pkgs.acpi
    ];

    services.acpid.enable = true;
    services.tlp.enable = true;
    # A userspace daemon to enable security levels for Thunderbolt 3
    services.hardware.bolt.enable = true;
    # Enable touchpad
    services.xserver.libinput.enable = true;
    # A keyboard shortcut daemon
    services.actkbd.enable = true;

    home-manager.users.rszamszur = { ... }: {

      services.screen-locker = {
        enable = true;
        lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
        inactiveInterval = 5;
        xautolock.enable = false;
        xss-lock = {
          package = pkgs.xss-lock;
          extraOptions = [
            "-n"
            "${pkgs.xsecurelock}/libexec/xsecurelock/dimmer"
            "-l"
          ];
          screensaverCycle = 5;
        };
      };

    };

  };

}
