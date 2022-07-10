{ config, lib, pkgs, ... }:

let
  cfg = config.my.remarkable;

  rcu = pkgs.callPackage
    (pkgs.fetchFromGitHub {
      owner = "rszamszur";
      repo = "pkg-rcu";
      rev = "af30bef";
      sha256 = "18ayiy4s81sk5nlk3zk46n0c8l6j5qrcp25mxw95ywlisgljd94n";
    })
    {
      productKey = builtins.getEnv "RCU_PRODUCT_KEY";
    };

  remarkable-driver = pkgs.callPackage ../pkgs/misc/cups/drivers/remarkable {
    lib = pkgs.lib;
    stdenv = pkgs.stdenv;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    coreutils = pkgs.coreutils;
  };
in
{

  options.my.remarkable.enable = lib.mkEnableOption "Enables remarkable related modules.";

  config = lib.mkIf cfg.enable {

    # Enable cups daemon, and add rmfilter for remarkable printing
    services.printing = {
      enable = true;
      drivers = [ remarkable-driver ];
    };

    hardware.printers.ensurePrinters = [
      {
        name = "reMarkable";
        location = "reMarkable";
        deviceUri = "socket://192.168.0.189:9100";
        model = "remarkable.ppd";
      }
    ];

    home-manager.users.rszamszur = { ... }: {

      home.file = {

        ".config/rmview.json" = {
          text = ''
            {
                "ssh": {
                    "address": [
                        "192.168.0.189"
                    ],
                    "auth_method": "key",
                    "key": "/home/rszamszur/.ssh/remarkable"
                },
                "orientation": "portrait",
                "pen_size": 15,
                "pen_color": "red",
                "pen_trail": 200
            }
          '';
        };

      };

      home.packages = [
        pkgs.rmview
        rcu
      ];

    };

  };

}
