{ config, lib, pkgs, ... }:

let
  cfg = config.my.remarkable;

  rcu-src = pkgs.fetchFromGitHub {
    owner = "rszamszur";
    repo = "pkg-rcu";
    rev = "2ac8d966aa91ea21ce9edb4eb593c512f169c9aa";
    sha256 = "1w89c7pqp2556gf1jikcb64k07zil4zbd8lk3hh1gj33073vzvci";
  };

  rcu = pkgs.python38.pkgs.callPackage "${rcu-src}/pkg.nix" {
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
