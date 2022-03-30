{ config, lib, pkgs, ... }:

let
  cfg = config.my.awesome;
in
{
  options.my.awesome.enable = lib.mkEnableOption "Enable common awesome window manager options.";

  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;
    services.xserver.windowManager.awesome.enable = true;
    # Necessary config to run awesome without desktop
    services.udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];
    programs.dconf.enable = true;
    # Needed for nautilus USB devices discovery and mount
    services.gvfs.enable = true;

    environment.systemPackages = [
      pkgs.gnome3.adwaita-icon-theme
      pkgs.gnomeExtensions.appindicator
      pkgs.gnome3.nautilus
      pkgs.gnome3.gnome-terminal
      pkgs.arc-icon-theme
    ];

  };

}
