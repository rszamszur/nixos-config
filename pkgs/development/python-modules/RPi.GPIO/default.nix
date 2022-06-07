{ lib
, buildPythonPackage
, fetchPypi
, setuptools
}:

buildPythonPackage rec {
  pname = "RPi.GPIO";
  version = "0.7.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0w1v6zxi6ixaj1z5wag03333773lcacfmkss9ax2pdip7jqc8qfd";
  };

  buildInputs = [
    setuptools
  ];

  # Disable check since RPi.GPIO package can be executed only on Raspberry Pi board.
  # Otherwise following error will be raised:
  # RuntimeError: This module can only be run on a Raspberry Pi!
  doCheck = false;
  #   pythonImportsCheck = [ "RPi.GPIO" ];

  meta = with lib; {
    homepage = "https://sourceforge.net/projects/raspberry-gpio-python/";
    description = "A module to control Raspberry Pi GPIO channels.";
    license = licenses.mit;
  };
}
