{ config, lib, pkgs, ... }:

let
  cfg = config.my.laptop;
in
{
  options.my.laptop.enable = lib.mkEnableOption "Enable laptop related modules.";

  config = lib.mkIf cfg.enable {

    my.awesome.enable = true;
    my.sound.enable = true;
    my.bash.enable = true;
    my.vbox.enable = true;

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
    # Enable cups daemon, and add rmfilter for remarkable printing
    services.printing = {
      enable = true;
      bindirCmds = ''
      cat << 'EOF' > $out/lib/cups/filter/rmfilter
      #!${pkgs.bash}/bin/bash
      # send job name
      echo -n "@PJL JOB NAME = "
      echo "\"$3\""
      # accept PDF as argument or from stdin
      ${pkgs.coreutils}/bin/cat "$6" -
      EOF
      chmod a+x $out/lib/cups/filter/rmfilter
      '';
    };

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

        ".config/awesome/json.lua".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/rszamszur/json.lua/v0.1.2/json.lua";
          sha256 = "11xbx7imgn3n92mgzk0mwwa51vkpxa094qd1qyzb6zf76adzagdi";
        };

        ".config/awesome/wallpapers".source = awesome/wallpapers;

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
          screensaverCycle = 5;
        };
      };

      programs.git = {
        enable = true;
        userName = "Radosław Szamszur";
        userEmail = "radoslawszamszur@gmail.com";
        extraConfig = {
          init = {
            defaultBranch = "master";
          };
          core = {
            editor = "vim";
          };
        };
      };

      home.packages = [
        pkgs.coreutils
        pkgs.nmap
        pkgs.zip
        pkgs.unzip
        pkgs.gnumake
        pkgs.gcc
        pkgs.vagrant
        pkgs.openvpn
        pkgs.gimp
        pkgs.flameshot
        pkgs.spotify
        pkgs.okular
        pkgs.htop
        pkgs.vlc
        pkgs.firefox
        pkgs.signal-desktop
        pkgs.openconnect
        pkgs.libreoffice
        pkgs.keepassxc
        pkgs.teams
        pkgs.jetbrains.pycharm-professional
        pkgs.kubectl
        pkgs.kubernetes-helm
      ];

    };

  };

}
