{
  description = "Radosław Szamszur NixOS configurations";
  nixConfig = {
    bash-prompt = ''\n\[\033[1;32m\][nix-develop:\w]\$\[\033[0m\] '';
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rszamszur-nixos.cachix.org-1:OOpiY87os0SYfYVQmLzxTvvn2sEoeOkKzaeguQCZVyQ="
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://rszamszur-nixos.cachix.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    fastapi-mvc.url = "github:fastapi-mvc/fastapi-mvc";
    rcu.url = "github:rszamszur/pkg-rcu";
    b3.url = "github:rszamszur/b3-flake";
  };

  outputs = { self, nixpkgs, home-manager, flake-parts, fastapi-mvc, rcu, b3 }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        ./shells/flake-module.nix
        ./pkgs/flake-module.nix
        ./images/flake-module.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          fastapi-mvc = fastapi-mvc.packages.${system}.default;
          rcu = rcu.packages.${system}.rcu;
          b3 = b3.packages.${system}.default;
        };
        overlayAttrs = {
          inherit (config.packages) fastapi-mvc rcu b3;
        };
      };
      flake = {
        templates = {
          default = {
            path = ./templates/default;
            description = ''
              A minimal flake using flake-parts.
            '';
          };
          poetry2nix = {
            path = ./templates/poetry2nix;
            description = ''
              Base flake for Python projects using poetry2nix.
            '';
          };
        };
        overlays = {
          poetry2nix = import ./overlays/poetry2nix.nix;
        };
        nixosConfigurations = {
          fenrir = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                nixpkgs.overlays = [ self.overlays.default ];
              }
              ./hosts/fenrir/hardware-configuration.nix
              ./hosts/fenrir/configuration.nix
              inputs.home-manager.nixosModules.home-manager
            ];
          };
          draugr = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                nixpkgs.overlays = [ self.overlays.default ];
              }
              ./hosts/draugr/hardware-configuration.nix
              ./hosts/draugr/configuration.nix
              inputs.home-manager.nixosModules.home-manager
            ];
          };
          tyr = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              {
                nixpkgs.overlays = [ self.overlays.default ];
              }
              ./hosts/tyr/hardware-configuration.nix
              ./hosts/tyr/configuration.nix
              inputs.home-manager.nixosModules.home-manager
            ];
          };
        };
        nixosModules = builtins.listToAttrs (map
          (module: {
            name = builtins.replaceStrings [ ".nix" ] [ "" ] (builtins.baseNameOf module);
            value = module;
          })
          (import ./modules { lib = inputs.nixpkgs.lib; }).imports);
      };
    };
}
