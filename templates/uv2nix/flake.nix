{
  description = "Description for the MY-PROJECT";
  nixConfig = {
    bash-prompt = ''\n\[\033[1;32m\][nix-develop:\w]\$\[\033[0m\] '';
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-utils = {
      url = "github:rszamszur/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      pyproject-nix,
      uv2nix,
      pyproject-build-systems,
      nix-utils,
    }@inputs:
    let
      mkApp =
        {
          drv,
          name ? drv.pname or drv.name,
          exePath ? drv.passthru.exePath or "/bin/${name}",
        }:
        {
          type = "app";
          program = "${drv}${exePath}";
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          # Optional: Add nix-utils lib overlay to have it globally under pkgs.nix-utils
          # _module.args.pkgs = import nixpkgs {
          #   inherit system;
          #   overlays = [ nix-utils.overlays.default ];
          # };

          packages =
            let
              mkProject =
                {
                  python ? pkgs.python3,
                }:
                let
                  build = pkgs.callPackage ./build.nix {
                    inherit
                      python
                      pkgs
                      src
                      uv2nix
                      pyproject-nix
                      pyproject-build-systems
                      ;
                    lib = pkgs.lib;
                    nix-utils = nix-utils.lib;
                  };
                in
                {
                  "MY-PROJECT-${python.sourceVersion.major}${python.sourceVersion.minor}-wheel" = build.wheel;
                  "MY-PROJECT-${python.sourceVersion.major}${python.sourceVersion.minor}-sdist" = build.sdist;
                  "MY-PROJECT-${python.sourceVersion.major}${python.sourceVersion.minor}-venv" = build.virtualenv;
                  "MY-PROJECT-${python.sourceVersion.major}${python.sourceVersion.minor}-app" = build.application;
                };

              src = nix-utils.lib.sources.filterPythonSources {
                path = ./.;
              };
            in
            {
              default = self'.packages.MY-PROJECT-311-venv;
            }
            // (mkProject { python = pkgs.python311; })
            // (mkProject { python = pkgs.python312; })
            // (mkProject { python = pkgs.python313; })
            // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
              image = pkgs.callPackage ./image.nix {
                inherit pkgs;
                MY-PROJECT = self'.packages.MY-PROJECT-311-app;
              };
            };

          overlayAttrs = {
            inherit (config.packages) default;
            nix-utils = nix-utils.lib;
          };

          apps = {
            MY-PROJECT = mkApp { drv = self'.packages.default; };
            checks = {
              type = "app";
              program = toString (
                pkgs.writeScript "checks" ''
                  #!${pkgs.bash}/bin/bash
                  export PATH="${
                    pkgs.lib.makeBinPath [
                      self'.packages.default
                    ]
                  }"
                  echo "[checks] Run some checks under Nix env."
                ''
              );
            };
          };

          devShells = {
            default = self'.devShells.virtualenv;
            virtualenv = pkgs.mkShell {
              name = "MY-PROJECT-venv";
              packages = [
                self'.packages.default
                pkgs.uv
              ];

              env = {
                UV_NO_SYNC = "1";
                UV_PYTHON = "${self'.packages.default}/bin/python";
                UV_PYTHON_DOWNLOADS = "never";
              };

              shellHook = ''
                # Undo dependency propagation by nixpkgs.
                unset PYTHONPATH
                # Get repository root using git. This is expanded at runtime by the editable `.pth` machinery.
                export REPO_ROOT=$(git rev-parse --show-toplevel)
              '';
            };
            dev-shell = pkgs.mkShell {
              name = "MY-PROJECT-dev-shell";
              packages = [
                pkgs.python3
                pkgs.uv
              ];

              env = {
                UV_PYTHON = pkgs.python3.interpreter;
                UV_PYTHON_DOWNLOADS = "never";
              };

              shellHook = ''
                unset PYTHONPATH
              '';
            };
          };
        };
      flake = { };
    };
}
