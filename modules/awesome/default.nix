{ config, lib, pkgs, ... }:

let
  cfg = config.my.awesome;
in
{
  options.my.awesome.enable = lib.mkEnableOption "Enable common awesome window manager options.";

  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;
    services.xserver.windowManager.awesome.enable = true;
    services.udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];
    programs.dconf.enable = true;

    environment.systemPackages = [
      pkgs.gnome3.adwaita-icon-theme
      pkgs.gnomeExtensions.appindicator
      pkgs.gnome3.nautilus
      pkgs.gnome3.gnome-terminal
      pkgs.arc-icon-theme
    ];

  };

}
