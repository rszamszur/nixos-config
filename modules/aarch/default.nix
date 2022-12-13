{ config, lib, pkgs, ... }:

let
  cfg = config.my.aarch;

  pycharm = pkgs.callPackage ./pycharm-aarch.nix {
    inherit lib;
    fetchurl = pkgs.fetchurl;
    makeDesktopItem = pkgs.makeDesktopItem;
    patchelf = pkgs.patchelf;
    makeWrapper = pkgs.makeWrapper;
    python3 = pkgs.python3;
    jdk = pkgs.jdk;
    coreutils = pkgs.coreutils;
    gnugrep = pkgs.gnugrep;
    which = pkgs.which;
    git = pkgs.git;
    unzip = pkgs.unzip;
    libsecret = pkgs.libsecret;
    libnotify = pkgs.libnotify;
    e2fsprogs = pkgs.e2fsprogs;
  };

  idea = pkgs.callPackage ./idea-aarch.nix {
    inherit lib;
    fetchurl = pkgs.fetchurl;
    makeDesktopItem = pkgs.makeDesktopItem;
    patchelf = pkgs.patchelf;
    makeWrapper = pkgs.makeWrapper;
    maven = pkgs.maven;
    zlib = pkgs.zlib;
    jdk = pkgs.jdk;
    coreutils = pkgs.coreutils;
    gnugrep = pkgs.gnugrep;
    which = pkgs.which;
    git = pkgs.git;
    unzip = pkgs.unzip;
    libsecret = pkgs.libsecret;
    libnotify = pkgs.libnotify;
    e2fsprogs = pkgs.e2fsprogs;
  };
in
{

  options = {
    my.aarch = {
      enable = lib.mkEnableOption "Enables aarch64 platform related modules and workarounds.";
      idea = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to add Jetbrains IDEA to user packages.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {

      home.packages = [
        pycharm
      ] ++ lib.optionals cfg.idea [ idea ];

    };

  };

}
