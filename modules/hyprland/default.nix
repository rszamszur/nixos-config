{ config, lib, pkgs, ... }:

let
  cfg = config.my.hyprland;
  pluginsToHyprconf = plugins: (builtins.concatStringsSep "\n" (builtins.map
    (entry:
      if lib.types.package.check entry then
        "plugin = ${entry}/lib/lib${entry.pname}.so"
      else
        "plugin = ${entry}")
    plugins));
in
{
  options = {
    my.hyprland = {
      enable = lib.mkEnableOption "Enable common hyprland window manager options.";
      package = lib.mkPackageOption pkgs "hyprland" { };
      hyprlandConf = lib.mkOption {
        type = lib.types.path;
        description = lib.mdDoc ''
          The path to a hyprland configuration file.
        '';
        default = ./hypr/hyprland.conf;
      };
      configOverrides = lib.mkOption {
        type = lib.types.attrs;
        description = lib.mdDoc ''
          Override attribute set of files to link into the user home.
        '';
        default = { };
      };
      plugins = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.package lib.types.path);
        default = [ pkgs.hyprlandPlugins.hyprsplit ];
        description = ''
          List of Hyprland plugins to use. Can either be packages or
          absolute plugin paths.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {


    programs.hyprland = {
      enable = true;
      package = cfg.package;
    };
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
      pkgs.eog
      pkgs.swayimg
      pkgs.nautilus
      pkgs.alacritty
      pkgs.bibata-cursors
      pkgs.xdg-desktop-portal-hyprland
    ];
    fonts.packages = [
      pkgs.font-awesome
      # Not sure which are needed for hyprland
      pkgs.nerd-fonts._0xproto
      pkgs.nerd-fonts.droid-sans-mono
      pkgs.nerd-fonts.noto
      pkgs.nerd-fonts.symbols-only
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.roboto-mono
      pkgs.nerd-fonts.dejavu-sans-mono
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services = {
      xserver = {
        xkb.layout = "pl";
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
      };
      # Needed for nautilus USB devices discovery and mount
      gvfs.enable = true;
    };

    home-manager.users.rszamszur = { ... }: {

      home = {
        file = {
          ".config/hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
          ".config/hypr/hypridle.conf".source = ./hypr/hypridle.conf;
          ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
          ".config/waybar/style.css".source = ./waybar/style.css;
          ".config/waybar/scripts/power-menu.sh".source = ./waybar/scripts/power-menu.sh;
          ".config/rofi/theme.rasi".source = ./rofi/theme.rasi;
          ".config/rofi/power-menu.rasi".source = ./rofi/power-menu.rasi;
          ".config/ranger/rc.conf".source = ./ranger/rc.conf;
          ".config/alacritty/alacritty.toml".source = ./alacritty/alacritty.toml;
          ".local/share/icons/Bibata-Modern-Classic".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic";

          ".config/wallpapers".source = ../awesome/wallpapers;
        } // cfg.configOverrides // {
          ".config/hypr/hyprland.conf".text = pluginsToHyprconf cfg.plugins + "\n" + (builtins.readFile cfg.hyprlandConf);
        };
      };

    };

  };

}
