final: prev:
{
  RPiGPIO = final.callPackage ../pkgs/development/python-modules/RPi.GPIO {
    buildPythonPackage = final.python39Packages.buildPythonPackage;
    fetchPypi = final.python39Packages.fetchPypi;
    setuptools = final.python39.pkgs.setuptools;
  };
  apa102 = final.callPackage ../pkgs/development/python-modules/apa102 {
    buildPythonPackage = final.python39Packages.buildPythonPackage;
    fetchPypi = final.python39Packages.fetchPypi;
    setuptools = final.python39.pkgs.setuptools;
    RPiGPIO = final.RPiGPIO;
    spidev = final.python39.pkgs.spidev;
  };
  fanshim = final.callPackage ../pkgs/development/python-modules/fanshim {
    buildPythonPackage = final.python39Packages.buildPythonPackage;
    fetchPypi = final.python39Packages.fetchPypi;
    setuptools = final.python39.pkgs.setuptools;
    psutil = final.python39.pkgs.psutil;
    apa102 = final.apa102;
    RPiGPIO = final.RPiGPIO;
  };
  manix = final.callPackage ../pkgs/tools/nix/manix { };
  cups-remarkable = final.callPackage ../pkgs/misc/cups/drivers/remarkable { };
}
