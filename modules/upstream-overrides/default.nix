{ config
, pkgs
, lib
, ...
}: {
  imports = [
    ./ncps.nix
  ];
  disabledModules = [
    "services/networking/ncps.nix"
  ];
}
