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
      default = "pipewire";
      description = ''
        What sound server to use, defaults to pipewire.
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
      };
    } // lib.optionalAttrs
      (cfg.driver == "pulseaudio")
      {
        pulseaudio = {
          enable = true;
          package = pkgs.pulseaudioFull;
        };
        bluetooth = {
          hsphfpd.enable = true;
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

    environment.systemPackages = [
      pkgs.pavucontrol
    ];

    security.rtkit.enable = true;
  };

}
