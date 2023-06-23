{ pkgs ? import <nixpkgs> { }
, name ? "rpi-fanshim"
, tag ? "latest"
, RPiGPIO
, fanshim
, apa102
}:

let
  service = pkgs.writeTextDir "src/run.py" (builtins.readFile ./run.py);

  pyEnv = pkgs.python39.withPackages (ps: with ps; [
    RPiGPIO
    fanshim
    apa102
  ]);
in

pkgs.dockerTools.buildImage {
  inherit name tag;

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [
      pyEnv
      service
      pkgs.bash
      pkgs.coreutils
      pkgs.cacert
    ];
    pathsToLink = [ "/bin" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    mkdir /tmp
    chmod 777 -R /tmp
    mkdir -p /usr/bin
    ln -s ${pkgs.coreutils}/bin/env /usr/bin/env
    groupadd -r nonroot
    useradd -r -g nonroot nonroot
    mkdir -p /home/nonroot
    chown nonroot:nonroot /home/nonroot
  '';

  config = {
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "PYTHONDONTWRITEBYTECODE=1"
      "PYTHONUNBUFFERED=1"
    ];
    User = "nonroot";
    WorkingDir = "/home/nonroot";
    Entrypoint = [ "${pyEnv}/bin/python3" "/src/run.py" ];
  };
}
