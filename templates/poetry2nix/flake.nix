{
  description = "Description for the project";
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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    poetry2nix = {
      url = "github:nix-community/poetry2nix?ref=1.40.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts, poetry2nix }@inputs:
    let
      mkApp =
        { drv
        , name ? drv.pname or drv.name
        , exePath ? drv.passthru.exePath or "/bin/${name}"
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
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Add poetry2nix overrides to nixpkgs
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.poetry2nix ];
        };

        packages =
          let
            mkProject =
              { python ? pkgs.python3
              }:
              pkgs.callPackage ./default.nix {
                inherit python;
                poetry2nix = pkgs.poetry2nix;
              };
          in
          {
            default = mkProject { };
            my-project-py38 = mkProject { python = pkgs.python38; };
            my-project-py39 = mkProject { python = pkgs.python39; };
            my-project-py310 = mkProject { python = pkgs.python310; };
            my-project-py311 = mkProject { python = pkgs.python311; };
            my-project-dev = pkgs.callPackage ./editable.nix {
              poetry2nix = pkgs.poetry2nix;
              python = pkgs.python3;
            };
          } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            image = pkgs.callPackage ./image.nix {
              inherit pkgs;
              app = config.packages.default;
            };
          };

        overlayAttrs = {
          inherit (config.packages) default;
        };

        apps = {
          my-project = mkApp { drv = config.packages.default; };
        };

        devShells = {
          default = config.packages.my-project-dev.env.overrideAttrs (oldAttrs: {
            buildInputs = [
              pkgs.poetry
              pkgs.coreutils
            ];
          });
          poetry = import ./shell.nix { inherit pkgs; };
        };
      };
      flake = {
        overlays.poetry2nix = nixpkgs.lib.composeManyExtensions [
          poetry2nix.overlay
          (import ./overlay.nix)
        ];
      };
    };
}
