{ config, lib, pkgs, ... }:

let
  cfg = config.my.remarkable;

  rcu-src = pkgs.fetchFromGitHub {
    owner = "rszamszur";
    repo = "pkg-rcu";
    rev = "74b2513754d8ee823541571cf32059acf827ccca";
    sha256 = "1ka4s6r1b9k73whs238a3lfrwq38hyg6g9d2ryxc8cwgmjzb0ar2";
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

  rmview = pkgs.callPackage ../pkgs/applications/misc/remarkable/rmview {
    lib = pkgs.lib;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    python3Packages = pkgs.python39Packages;
    wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook;
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
        rmview
        rcu
      ];

    };

  };

}
