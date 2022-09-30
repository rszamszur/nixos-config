final: prev:
let
  src = final.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "1.31.0";
    sha256 = "06psv5mc7xg31bvjpg030mwnk0sv90cj5bvgsdmcwicifpl3k3yj";
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
      idna = py-prev.idna.overridePythonAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [ py-final.flit-core ];
      });
      mdit-py-plugins = py-prev.mdit-py-plugins.overridePythonAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [ py-final.flit-core ];
      });
      suds = py-prev.suds.overridePythonAttrs (old: {
        # Fix naming convention shenanigans.
        # https://github.com/suds-community/suds/blob/a616d96b070ca119a532ff395d4a2a2ba42b257c/setup.py#L648
        SUDS_PACKAGE = "suds";
      });
      watchfiles = py-prev.watchfiles.overridePythonAttrs (old: rec {
        src = final.fetchFromGitHub {
          owner = "samuelcolvin";
          repo = "watchfiles";
          # FIXME: Find out why watchfiles does not include Cargo.lock in pypi released tarball. 
          # Then either remove this, or add repo shas map.
          rev = "v0.17.0";
          sha256 = "sha256-HW94cs/WH1EmMutzE2jlQ60cpTQ+ltIZGBgnWIxwl+s=";
        };
        cargoDeps = final.rustPlatform.importCargoLock {
          lockFile = "${src.out}/Cargo.lock";
        };
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
          final.rustPlatform.cargoSetupHook
          final.rustPlatform.maturinBuildHook
        ];
      });
      uvicorn = py-prev.uvicorn.overridePythonAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [ py-final.hatchling ];
        postPatch = ''
          substituteInPlace pyproject.toml --replace 'watchfiles>=0.13' 'watchfiles'
        '';
      });

    });

  });
}
