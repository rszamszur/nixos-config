{ config, lib, pkgs, ... }:

let
  cfg = config.my.cache;
in
{
  options.my.cache.enable = lib.mkEnableOption "Enable cache module.";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://fastapi-mvc.cachix.org"
        "https://rszamszur-nixos.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fastapi-mvc.cachix.org-1:knQ8Qo41bnhBmOB6Sp0UH10EV76AXW5o69SbAS668Fg="
        "rszamszur-nixos.cachix.org-1:OOpiY87os0SYfYVQmLzxTvvn2sEoeOkKzaeguQCZVyQ="
      ];
    };
    environment.systemPackages = [ pkgs.cachix ];
  };

}
