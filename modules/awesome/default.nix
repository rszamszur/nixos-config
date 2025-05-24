{ config, lib, pkgs, ... }:

let
  cfg = config.my.awesome;
in
{
  options = {
    my.awesome = {
      enable = lib.mkEnableOption "Enable common awesome window manager options.";
      rclua = lib.mkOption {
        type = lib.types.path;
        default = ./rc.lua;
        description = "Awesome wm configuration to use.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;
    services.xserver.xkb.layout = "pl";
    services.xserver.windowManager.awesome.enable = true;
    # Necessary config to run awesome without desktop
    services.udev.packages = if (lib.trivial.release == "25.05") then [ pkgs.gnome-settings-daemon ] else [ pkgs.gnome3.gnome-settings-daemon ];
    programs.dconf.enable = true;
    # Needed for nautilus USB devices discovery and mount
    services.gvfs.enable = true;

    environment.systemPackages =
      if (lib.trivial.release == "25.05") then [
        pkgs.eog
        pkgs.adwaita-icon-theme
        pkgs.gnomeExtensions.appindicator
        pkgs.nautilus
        pkgs.gnome-terminal
        pkgs.arc-icon-theme
        pkgs.arandr
      ] else [
        pkgs.gnome3.eog
        pkgs.gnome3.adwaita-icon-theme
        pkgs.gnomeExtensions.appindicator
        pkgs.gnome3.nautilus
        pkgs.gnome3.gnome-terminal
        pkgs.arc-icon-theme
        pkgs.arandr
      ];

    home-manager.users.rszamszur = { ... }: {

      home.file = {

        ".config/awesome/volume-control".source = pkgs.fetchFromGitHub {
          owner = "rszamszur";
          repo = "volume-control";
          rev = "a18e862";
          sha256 = "0fc1l1bqwfwxchg3yqxd7ivx2nf0qcxkg16xzhl9707ycvbqajpi";
        };

        ".config/awesome/awesome-wm-widgets".source = pkgs.fetchFromGitHub {
          owner = "rszamszur";
          repo = "awesome-wm-widgets";
          rev = "b8e3a86";
          sha256 = "1y3bbxczzrqk1d2636rc0z76x8648vf3f78dwsjwsy289zmby3dq";
        };

        ".config/awesome/rc.lua".source = cfg.rclua;

        ".config/awesome/json.lua".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/rszamszur/json.lua/v0.1.2/json.lua";
          sha256 = "11xbx7imgn3n92mgzk0mwwa51vkpxa094qd1qyzb6zf76adzagdi";
        };

        ".config/awesome/wallpapers".source = ./wallpapers;

      };

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
