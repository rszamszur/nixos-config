{ config, lib, pkgs, ... }:

let
  cfg = config.my.raspberry;
  service = pkgs.writeText "run.py" (pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/pimoroni/fanshim-python/33abcde2d51944e6dcb3bc2ecbddb251f65eb79a/examples/automatic.py";
    sha256 = "1ms85bx0mz4pxa6ijlff8aiqcqdclkr3r705p07jx3kx9vh6v2c8";
  });

  pyEnv = pkgs.python39.withPackages (ps: with ps; [
    pkgs.RPiGPIO
    pkgs.fanshim
    pkgs.apa102
  ]);
in
{

  options.my.raspberry = {
    enable = lib.mkEnableOption "Enables raspberrypi related modules.";
    fanshim = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables fanshim systemd service";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.fanshim = lib.mkIf cfg.fanshim {
      description = "Fanshim service";
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;
      serviceConfig = {
        User = "root";
        Group = "root";
        Restart = "always";
        Type = "forking";
        ExecStart = "${pyEnv}/bin/python ${service}";
      };
    };

    environment.systemPackages = [
      pkgs.raspberrypi-eeprom
    ];

  };

}
