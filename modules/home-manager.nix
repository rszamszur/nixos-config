with import <nixpkgs> { };

let
  my-home-manager = stdenv.mkDerivation {
    name = "my-home-manager";
    version = "release-22.11";

    src = builtins.fetchTarball {
      url = "https://github.com/nix-community/home-manager/archive/65c47ced082e3353113614f77b1bc18822dc731f.tar.gz";
      sha256 = "1fw01zfankc80rna9ch65p7bpg6fwcnvc0pmwvkpfazb7xq92108";
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
