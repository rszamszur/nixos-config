{ pkgs
, lib
, src
, python
, uv2nix
, pyproject-nix
, pyproject-build-systems
,
}:

let
  inherit (pkgs.mylib.sources)
    filterSources
    languageIgnoreFilesets
    languageFileFilters
    ;
  inherit (pkgs.lib.fileset) unions;

  workspace = uv2nix.lib.workspace.loadWorkspace {
    # Workaround for https://github.com/pyproject-nix/uv2nix/issues/179
    workspaceRoot = /. + (builtins.unsafeDiscardStringContext src);
  };
  workspaceOverlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
  pyprojectOverrides = final: prev: {
    # Overrides goes here. Examples:
    #
    # pyyaml-include = prev.pyyaml-include.overrideAttrs (old: {
    #   patch = ''
    #     substituteInPlace setup.py --replace 'setup()' 'setup(version="${old.version}")'
    #   '';
    # });
    #
    # sphinx = prev.sphinx.overrideAttrs (old: {
    #   buildInputs = old.buildInputs or [ ] ++ [ final.flit-core ];
    # });
    #
    # sphinx-click = prev.sphinx-click.override {
    #   sourcePreference = "wheel";
    # };
  };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          workspaceOverlay
          pyprojectOverrides
        ]
      );
  editableOverlay = workspace.mkEditablePyprojectOverlay {
    # Use environment variable
    root = "$REPO_ROOT";
    # Optional: Only editable for these packages
    members = [ "MY-PROJECT" ];
  };

  # Override previous set with our overridable overlay.
  editablePythonSet = pythonSet.overrideScope (
    lib.composeManyExtensions [
      editableOverlay

      # Apply fixups for building an editable package of your workspace packages
      (final: prev: {
        # It's a good idea to filter the sources goting into an editable build
        # so the editable package doesn't have to be rebuild on every change.
        MY-PROJECT = prev.MY-PROJECT.overrideAttrs (old: {
          src =
            let
              ignoreFilesets = languageIgnoreFilesets old.src;
              ignoreFileFilters = languageFileFilters old.src;
            in
            filterSources {
              path = old.src;
              positiveFileset = unions ([
                (old.src + "/README.md")
                (old.src + "/uv.lock")
                (old.src + "/pyproject.toml")
                (old.src + "/MY_PROJECT_MODULE_NAME/")
              ]);
              negativeFileset = unions ([
                ignoreFilesets.common
                ignoreFilesets.python.venv
                ignoreFilesets.python.build
                ignoreFilesets.python.pyTest
                ignoreFilesets.python.config
                ignoreFileFilters.common
                ignoreFileFilters.python.pyCache
                ignoreFileFilters.python.pyTestCache
                ignoreFileFilters.python.eggInfo
              ]);
            };

          # Hatchling (our build system) has a dependency on the `editables` package when building editables.
          #
          # In normal Python flows this dependency is dynamically handled, and doesn't need to be explicitly declared.
          # This behaviour is documented in PEP-660
          #
          # With Nix the dependency needs to be explicitly declared.
          nativeBuildInputs =
            old.nativeBuildInputs
            ++ final.resolveBuildSystem { editables = [ ]; };
        });
      })
    ]
  );

  # Build virtual environment, with local packages being editable.
  #
  # Enable all optional dependencies for development.
  virtualenv = editablePythonSet.mkVirtualEnv "MY-PROJECT-dev-env" workspace.deps.all;

  sdist = (pythonSet.MY-PROJECT.override {
    pyprojectHook = pythonSet.pyprojectDistHook;
  }).overrideAttrs (_: {
    env.uvBuildType = "sdist";
  });
  wheel = pythonSet.MY-PROJECT.override {
    pyprojectHook = pythonSet.pyprojectDistHook;
  };

  util = pyproject-nix.build.util { runCommand = pkgs.runCommand; python3 = pythonSet.python; };
  application = util.mkApplication {
    venv = pythonSet.mkVirtualEnv "application-env" workspace.deps.default;
    package = pythonSet.MY-PROJECT;
  };
in
{
  inherit sdist wheel virtualenv application;
}
