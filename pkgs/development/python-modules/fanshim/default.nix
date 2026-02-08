{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  psutil,
  apa102,
  RPiGPIO,
}:

buildPythonPackage rec {
  pname = "fanshim";
  version = "0.0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1nl4y1x6bcl6h8wlg7az5r0injjs62j5077smx5nz9q88q0bi8b5";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    psutil
    apa102
    RPiGPIO
  ];

  # Disable check since RPi.GPIO package can be executed only on Raspberry Pi board.
  # Otherwise following error will be raised:
  # RuntimeError: This module can only be run on a Raspberry Pi!
  doCheck = false;
  #pythonImportsCheck = [ "fanshim" ];

  meta = with lib; {
    homepage = "https://github.com/pimoroni/fanshim-python";
    description = "Python library for the Fan SHIM for Raspberry Pi";
    license = licenses.mit;
  };
}
