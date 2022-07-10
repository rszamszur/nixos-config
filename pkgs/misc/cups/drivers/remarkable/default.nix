{ lib, stdenv, fetchFromGitHub, coreutils }:

stdenv.mkDerivation rec {
  pname = "cups-remarkable";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "rszamszur";
    repo = "remarkable_printer";
    rev = "37c00b6";
    sha256 = "09288nmhi705a3nbi6wydl7ickcrzhhasvfrby4nav5nbmgvq3cp";
  };

  phases = [ "installPhase" "postInstall" "fixupPhase" ];

  propagatedBuildInputs = [ coreutils ];

  installPhase = ''
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model
    cp $src/rmfilter $out/lib/cups/filter/rmfilter
    cp $src/remarkable.ppd $out/share/cups/model/remarkable.ppd
    chmod a+x $out/lib/cups/filter/rmfilter
  '';

  postInstall = ''
    substituteInPlace $out/lib/cups/filter/rmfilter --replace "cat" "${coreutils}/bin/cat"
  '';

  meta = with lib; {
    description = "CUPS Linux drivers for remarkable printing";
    homepage = "https://github.com/rszamszur/remarkable_printer";
  };
}
