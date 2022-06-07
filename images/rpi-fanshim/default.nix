{ pkgs ? import <nixpkgs> { system = "x86_64-linux"; } }:

let
  nonRootShadowSetup = { user, uid, gid ? uid }: with pkgs; [
    (
      writeTextDir "etc/shadow" ''
        root:!x:::::::
        ${user}:!:::::::
      ''
    )
    (
      writeTextDir "etc/passwd" ''
        root:x:0:0::/root:${runtimeShell}
        ${user}:x:${toString uid}:${toString gid}::/home/${user}:
      ''
    )
    (
      writeTextDir "etc/group" ''
        root:x:0:
        ${user}:x:${toString gid}:
      ''
    )
    (
      writeTextDir "etc/gshadow" ''
        root:x::
        ${user}:x::
      ''
    )
  ];

  service = pkgs.writeTextDir "src/run.py" (builtins.readFile ./run.py);

  RPiGPIO = pkgs.callPackage ../../pkgs/development/python-modules/RPi.GPIO {
    buildPythonPackage = pkgs.python39Packages.buildPythonPackage;
    fetchPypi = pkgs.python39Packages.fetchPypi;
    setuptools = pkgs.python39.pkgs.setuptools;
  };

  apa102 = pkgs.callPackage ../../pkgs/development/python-modules/apa102 {
    buildPythonPackage = pkgs.python39Packages.buildPythonPackage;
    fetchPypi = pkgs.python39Packages.fetchPypi;
    setuptools = pkgs.python39.pkgs.setuptools;
    inherit RPiGPIO;
    spidev = pkgs.python39.pkgs.spidev;
  };

  fanshim = pkgs.callPackage ../../pkgs/development/python-modules/fanshim {
    buildPythonPackage = pkgs.python39Packages.buildPythonPackage;
    fetchPypi = pkgs.python39Packages.fetchPypi;
    setuptools = pkgs.python39.pkgs.setuptools;
    psutil = pkgs.python39.pkgs.psutil;
    inherit apa102;
    inherit RPiGPIO;
  };

  pyEnv = pkgs.python39.withPackages (ps: with ps; [
    RPiGPIO
    fanshim
    apa102
  ]);
in

pkgs.dockerTools.buildImage {
  name = "rpi-fanshim";
  tag = "latest";

  contents = [
    pyEnv
    service
  ] ++ nonRootShadowSetup { uid = 999; user = "nonroot"; };

  config = {
    User = "nonroot";
    Entrypoint = [ "${pyEnv}/bin/python3" "/src/run.py" ];
  };
}
