{ pkgs ? import <nixpkgs> { }
, MY-PROJECT
, name ? "MY-PROJECT"
, tag ? "latest"
}:

pkgs.dockerTools.buildImage {
  inherit name tag;

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [
      MY-PROJECT
      pkgs.bash
      pkgs.coreutils
      pkgs.cacert
    ];
    pathsToLink = [ "/bin" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    mkdir -p /tmp
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
    Entrypoint = [ "${MY-PROJECT}/bin/MY-PROJECT" ];
  };
}
