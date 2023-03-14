final: prev:
let
  src = final.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "1.39.1";
    sha256 = "0kb738zsp9d2hywv7js9clz2nwmjfqya2ln8xxq2yil7bpns0xnf";
  };
  p2n = import "${src.out}/default.nix" { pkgs = final; poetry = final.poetry; };
in
{
  # p2n-final & p2n-prev refers to poetry2nix
  poetry2nix = p2n.overrideScope' (p2n-final: p2n-prev: {

    # py-final & py-prev refers to python packages
    defaultPoetryOverrides = p2n-prev.defaultPoetryOverrides.extend (py-final: py-prev: {

      mypy = py-prev.mypy.overridePythonAttrs (old: {
        patches = [ ];
        # Compile mypy with mypyc, which makes mypy about 4 times faster. The compiled
        # version is also the default in the wheels on Pypi that include binaries.
        # is64bit: unfortunately the build would exhaust all possible memory on i686-linux.
        MYPY_USE_MYPYC = final.stdenv.buildPlatform.is64bit;
        # If one wants to use pure python mypy, use the following:
        #MYPY_USE_MYPYC = false;
      });
      pyyaml-include = py-prev.pyyaml-include.overridePythonAttrs (old: {
        postPatch = ''
          substituteInPlace setup.py --replace 'setup()' 'setup(version="${old.version}")'
        '';
      });
      pydantic = py-prev.pydantic.overrideAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [ final.libxcrypt ];
      });

    });

  });
}
