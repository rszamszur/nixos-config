{ config, lib, pkgs, ... }:

let
  cfg = config.my.sound;
in
{

  options.my.sound.enable = lib.mkEnableOption "Enables common sound settings.";

  config = lib.mkIf cfg.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
    # hardware.bluetooth.hsphfpd.enable = true;
  };

}
