self: super: {

  # p2self & p2super refers to poetry2nix
  poetry2nix = super.poetry2nix.overrideScope' (p2nixself: p2nixsuper: {

    # pyself & pysuper refers to python packages
    defaultPoetryOverrides = p2nixsuper.defaultPoetryOverrides.extend (pyself: pysuper: {

      mypy = pysuper.mypy.overridePythonAttrs (old: {
        patches = [ ];
        # Compile mypy with mypyc, which makes mypy about 4 times faster. The compiled
        # version is also the default in the wheels on Pypi that include binaries.
        # is64bit: unfortunately the build would exhaust all possible memory on i686-linux.
        MYPY_USE_MYPYC = self.stdenv.buildPlatform.is64bit;
        # If one wants to use pure python mypy, use the following:
        #MYPY_USE_MYPYC = false;
      });
      idna = pysuper.idna.overridePythonAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [ pysuper.flit-core ];
      });
      mdit-py-plugins = pysuper.mdit-py-plugins.overridePythonAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [ pysuper.flit-core ];
      });
      suds = pysuper.suds.overridePythonAttrs (old: {
        # Fix naming convention shenanigans.
        # https://github.com/suds-community/suds/blob/a616d96b070ca119a532ff395d4a2a2ba42b257c/setup.py#L648
        SUDS_PACKAGE = "suds";
      });

    });

  });
}

