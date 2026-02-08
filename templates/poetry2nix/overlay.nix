final: prev: {
  # p2n-final & p2n-prev refers to poetry2nix
  poetry2nix = prev.poetry2nix.overrideScope' (
    p2n-final: p2n-prev: {

      # py-final & py-prev refers to python packages
      defaultPoetryOverrides = p2n-prev.defaultPoetryOverrides.extend (
        py-final: py-prev: {

          # Here add any custom poetry2nix overrides required to build the project.
          # Example:
          # pyyaml-include = py-prev.pyyaml-include.overridePythonAttrs (old: {
          #   postPatch = ''
          #     substituteInPlace setup.py --replace 'setup()' 'setup(version="${old.version}")'
          #   '';
          # });

        }
      );

    }
  );
}
