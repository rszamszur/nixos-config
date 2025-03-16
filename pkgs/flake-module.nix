{ self, lib, withSystem, ... }:

{
  perSystem = { config, self', inputs', pkgs, ... }: {
    packages = {
      cups-remarkable = pkgs.callPackage ./misc/cups/drivers/remarkable { };
      rmview = pkgs.callPackage ../pkgs/applications/misc/remarkable/rmview {
        python3Packages = pkgs.python311Packages;
        wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook;
      };
    };
    overlayAttrs = {
      inherit (config.packages) cups-remarkable rmview;
    };
  };
  flake = {
    packages.aarch64-linux = withSystem "aarch64-linux" (ctx@{ pkgs, ... }: {
      RPiGPIO = pkgs.callPackage ./development/python-modules/RPi.GPIO {
        buildPythonPackage = pkgs.python39Packages.buildPythonPackage;
        fetchPypi = pkgs.python39Packages.fetchPypi;
        setuptools = pkgs.python39.pkgs.setuptools;
      };
      apa102 = pkgs.callPackage ./development/python-modules/apa102 {
        buildPythonPackage = pkgs.python39Packages.buildPythonPackage;
        fetchPypi = pkgs.python39Packages.fetchPypi;
        setuptools = pkgs.python39.pkgs.setuptools;
        RPiGPIO = self.packages.aarch64-linux.RPiGPIO;
        spidev = pkgs.python39.pkgs.spidev;
      };
      fanshim = pkgs.callPackage ./development/python-modules/fanshim {
        buildPythonPackage = pkgs.python39Packages.buildPythonPackage;
        fetchPypi = pkgs.python39Packages.fetchPypi;
        setuptools = pkgs.python39.pkgs.setuptools;
        psutil = pkgs.python39.pkgs.psutil;
        apa102 = self.packages.aarch64-linux.apa102;
        RPiGPIO = self.packages.aarch64-linux.RPiGPIO;
      };
    });
  };
}
  