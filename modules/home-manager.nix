with import <nixpkgs> { };

let
  my-home-manager = stdenv.mkDerivation {
    name = "my-home-manager";
    version = "release-21.11";

    src = builtins.fetchTarball {
      url = "https://github.com/nix-community/home-manager/archive/d93d56ab8c1c6aa575854a79b9d2f69d491db7d0.tar.gz";
      sha256 = "1fi27zabvqlyc2ggg7wr01j813gs46rswg1i897h9hqkbgqsjkny";
    };

    patch = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/nix-community/home-manager/a985e711e88e3aab82c54df39bc4666f98f54937/modules/services/screen-locker.nix";
      sha256 = "14h0dqwhw9jwzaqyrw1b9nfp7dzj3z5914xayhzghkf8vv2jkr2d";
    };

    phases = "unpackPhase installPhase";

    installPhase = ''
      cp -R ./ $out
      cat $patch > $out/modules/services/screen-locker.nix
    '';
  };
in
{
  imports = [
    (import "${my-home-manager}/nixos")
  ];
}
