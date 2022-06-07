{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, RPiGPIO
, spidev
}:

buildPythonPackage rec {
  pname = "apa102";
  version = "0.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1y9wa5llgq07ppssrg0h1lb0zalgr82016dba9qba9zh4vmbswxf";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    RPiGPIO
    spidev
  ];

  # Disable check since RPi.GPIO package can be executed only on Raspberry Pi board.
  # Otherwise following error will be raised:
  # RuntimeError: This module can only be run on a Raspberry Pi!
  doCheck = false;
  #pythonImportsCheck = [ "apa102" ];

  meta = with lib; {
    homepage = "https://github.com/pimoroni/apa102-python";
    description = "A simple library to drive APA102 pixels from the Raspberry Pi, or similar SBCs.";
    license = licenses.mit;
  };
}
