{ config, lib, pkgs, ... }:

let
  cfg = config.my.sound;
in
{

  options.my.sound = {
    enable = lib.mkEnableOption "Enables common sound settings.";
    driver = lib.mkOption {
      type = lib.types.enum [
        "pulseaudio"
        "pipewire"
      ];
      default = "pulseaudio";
      description = ''
        What sound server to use, defaults to pulseaudio.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
        hsphfpd.enable = if cfg.driver == "pulseaudio" then true else false;
      };
    } // lib.optionalAttrs
      (cfg.driver == "pulseaudio")
      {
        pulseaudio = {
          enable = true;
          package = pkgs.pulseaudioFull;
        };
      };

    services.pipewire = {
      enable = if cfg.driver == "pipewire" then true else false;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = if cfg.driver == "pipewire" then true else false;
    };

    services.blueman.enable = true;
    programs.noisetorch.enable = true;

    environment.systemPackages =
      [
        pkgs.alsa-utils
      ]
      ++ lib.optionals (cfg.driver == "pulseaudio")
        [
          pkgs.pavucontrol
        ]
      ++ lib.optionals (cfg.driver == "pipewire")
        [
          pkgs.pwvucontrol
        ];

    security.rtkit.enable = true;
  };

}
