{ config, lib, pkgs, ... }:

let
  cfg = config.my.laptop;
in
{
  options.my.laptop.enable = lib.mkEnableOption "Enable laptop related modules.";

  config = lib.mkIf cfg.enable {

    my.awesome.enable = true;
    my.sound.enable = true;

    environment.systemPackages = [
      pkgs.acpi
    ];

    services.acpid.enable = true;
    services.tlp.enable = true;
    # A userspace daemon to enable security levels for Thunderbolt 3
    services.hardware.bolt.enable = true;
    # Enable touchpad
    services.xserver.libinput.enable = true;
    # A keyboard shortcut daemon
    services.actkbd.enable = true;

    home-manager.users.rszamszur = { ... }: {

      home.file = {

        ".config/awesome/volume-control".source = pkgs.fetchFromGitHub {
          owner = "rszamszur";
          repo = "volume-control";
          rev = "a18e862";
          sha256 = "0fc1l1bqwfwxchg3yqxd7ivx2nf0qcxkg16xzhl9707ycvbqajpi";
        };

        ".config/awesome/awesome-wm-widgets".source = pkgs.fetchFromGitHub {
          owner = "rszamszur";
          repo = "awesome-wm-widgets";
          rev = "b8e3a86";
          sha256 = "1y3bbxczzrqk1d2636rc0z76x8648vf3f78dwsjwsy289zmby3dq";
        };

        ".config/awesome/rc.lua".source = awesome/rc.lua;

      };

      services.screen-locker = {
        enable = true;
        lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
        inactiveInterval = 5;
        xautolock.enable = false;
        xss-lock = {
          package = pkgs.xss-lock;
          extraOptions = [
            "-n"
            "${pkgs.xsecurelock}/libexec/xsecurelock/dimmer"
            "-l"
          ];
        };
      };

      programs.git = {
        enable = true;
        userName = "Radosław Szamszur";
        userEmail = "radoslawszamszur@gmail.com";
      };

      home.packages = [
        pkgs.coreutils
        pkgs.nmap
        pkgs.zip
        pkgs.unzip
        pkgs.gnumake
        pkgs.gcc
        pkgs.nix-linter
        pkgs.nixpkgs-fmt
        pkgs.vagrant
        pkgs.openvpn
        pkgs.gimp
        pkgs.flameshot
        pkgs.spotify
        pkgs.signal-desktop
        pkgs.openconnect
        pkgs.libreoffice
        pkgs.keepassxc
        pkgs.teams
        pkgs.jetbrains.pycharm-professional
      ];

    };

  };

}
