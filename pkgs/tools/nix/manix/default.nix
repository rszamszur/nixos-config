{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "manix";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "rszamszur";
    repo = pname;
    rev = "7375a73";
    sha256 = "0lgynk257yclrpwwmrz95wy0i1a8m7fjxl6pqc4vgrvds00aq3bb";
  };

  cargoHash = "sha256-NEJQAopHDb7TP+z+xoPU6aVPF3GkW/8qOnj7XyRYE1A=";

  meta = with lib; {
    description = "A fast CLI documentation searcher for Nix.";
    homepage = "https://github.com/rszamszur/manix";
    license = [ licenses.mpl20 ];
  };
}
