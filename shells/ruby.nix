{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.ruby
    pkgs.bundler
    pkgs.sqlite
    pkgs.postgresql
    pkgs.libxml2
    pkgs.libxslt
    pkgs.pkg-config
    pkgs.shared-mime-info
    pkgs.gnumake
    pkgs.cacert
  ];
  shellHook = ''
    export GEM_HOME=$PWD/.gems
    export GEM_PATH=$GEM_HOME
    export PATH=$GEM_PATH/bin:$PATH
    export FREEDESKTOP_MIME_TYPES_PATH="${pkgs.shared-mime-info}/share/mime"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  '';
}
