with import <nixpkgs> { };

let
  my-home-manager = stdenv.mkDerivation {
    name = "my-home-manager";
    version = "release-22.05";

    src = builtins.fetchTarball {
      url = "https://github.com/nix-community/home-manager/archive/4a3d01fb53f52ac83194081272795aa4612c2381.tar.gz";
      sha256 = "0sdirpwqk61hnq8lvz4r2j60fxpcpwc8ffmicail2n4h6zifcn9n";
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
