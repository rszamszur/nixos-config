with import <nixpkgs> { };

let
  my-home-manager = stdenv.mkDerivation {
    name = "my-home-manager";
    version = "release-22.05";

    src = builtins.fetchTarball {
      url = "https://github.com/nix-community/home-manager/archive/6639e3a837fc5deb6f99554072789724997bc8e5.tar.gz";
      sha256 = "0vg6x7cw2bpiga9k6nlj2n1vrm4qw84721gmlhp3j1i58v100ybc";
    };

    phases = "unpackPhase installPhase";

    installPhase = ''
      cp -R ./ $out
    '';
  };
in
{
  imports = [
    (import "${my-home-manager}/nixos")
  ];
}
