{ pkgs, ... }:

let
  passHash = "$6$5UsMsT9nvv3Xy3Tl$wO/sQaNSqOUxjymXDYEeuWCsH0lZYwJhXh3sbBucUmr./CWNeWXRmJ5yqEj9pMC/jye9Vha7G5/YD1gH9dLpP1";
  rootPassHash = "$6$DBH/m/TvG3cIKJUr$v5TjDD4RRQhrCbOZs3ktWj6v1Vz81z0KIMzlBVq6UfG8dlFkTmKLl.s3QFW4CwLIdeZmDHyof7Iufx.8VhGOk0";
in
{
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.vim
    pkgs.wget
    pkgs.curl
    pkgs.git
    pkgs.tmux
    pkgs.jq
    pkgs.dnsutils
    pkgs.cryptsetup
  ];

  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  users = {
    mutableUsers = false;

    users = {
      rszamszur = {
        uid = 1001;
        isNormalUser = true;
        description = "Radoslaw Szamszur";
        home = "/home/rszamszur";
        createHome = true;
        group = "users";
        extraGroups = [ "networkmanager" "wheel" ];
        hashedPassword = passHash;
      };

      root.hashedPassword = rootPassHash;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  nix.trustedUsers = [ "rszamszur" ];

}
