{ config, lib, pkgs, ... }:

let
  cfg = config.my.sound;
in
{

  options.my.sound.enable = lib.mkEnableOption "Enables common sound settings.";

  config = lib.mkIf cfg.enable {
    sound.enable = true;
    hardware = {
      pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
      };
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        hsphfpd.enable = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };
    };
    services.blueman.enable = true;
    programs.noisetorch.enable = true;

    environment.systemPackages = [
      pkgs.pavucontrol
    ];
  };

}
