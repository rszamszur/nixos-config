{ config, lib, pkgs, ... }:

let
  cfg = config.my.cache;
in
{
  options.my.cache = {
    enable = lib.mkEnableOption "Enable cache module.";
    extraSubstituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of extra substituters.";
    };
    extraTrustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of extra trusted public keys.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://rszamszur-nixos.cachix.org"
      ] ++ cfg.extraSubstituters;
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "rszamszur-nixos.cachix.org-1:OOpiY87os0SYfYVQmLzxTvvn2sEoeOkKzaeguQCZVyQ="
      ] ++ cfg.extraTrustedPublicKeys;
    };
    environment.systemPackages = [ pkgs.cachix ];
  };

}
