{ config, lib, pkgs, ... }:

let
  cfg = config.my.hyprland;
in
{
  options = {
    my.hyprland = {
      enable = lib.mkEnableOption "Enable common hyprland window manager options.";
      configOverrides = lib.mkOption {
        type = lib.types.attrs;
        description = lib.mdDoc ''
          Override attribute set of files to link into the user home.
        '';
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {


    programs.hyprland.enable = true;
    programs.waybar.enable = true;
    environment.systemPackages = [
      # Hyprland ecosytem packages
      pkgs.kitty # required by default config
      pkgs.hyprlock
      pkgs.hypridle
      pkgs.hyprshot
      pkgs.hyprcursor
      pkgs.swaybg # or hyprpaper?
      pkgs.wlogout # not sure if used?

      # Launcher/menu programs
      pkgs.wofi
      pkgs.rofi-wayland

      # Utils used by hyprland
      pkgs.nwg-displays
      pkgs.brightnessctl
      pkgs.playerctl
      pkgs.ranger
      pkgs.ueberzugpp # image preview for ranger
      pkgs.swayimg
      pkgs.nautilus
      pkgs.alacritty
    ];
    fonts.packages = [
      pkgs.nerdfonts
      pkgs.font-awesome
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services.xserver = {
      xkb.layout = "pl";
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    home-manager.users.rszamszur = { ... }: {

      home = {
        file = {
          ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
          ".config/hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
          ".config/hypr/hypridle.conf".source = ./hypr/hypridle.conf;
          ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
          ".config/waybar/style.css".source = ./waybar/style.css;
          ".config/waybar/scripts/power-menu.sh".source = ./waybar/scripts/power-menu.sh;
          ".config/rofi/theme.rasi".source = ./rofi/theme.rasi;
          ".config/rofi/power-menu.rasi".source = ./rofi/power-menu.rasi;
          ".config/ranger/rc.conf".source = ./ranger/rc.conf;
          ".config/alacritty/alacritty.toml".source = ./alacritty/alacritty.toml;

          ".config/wallpapers".source = ../awesome/wallpapers;
        } // cfg.configOverrides;
      };

    };

  };

}
