{
  description = "Radosław Szamszur NixOS configurations";
  nixConfig = {
    bash-prompt = ''\n\[\033[1;32m\][nix-develop:\w]\$\[\033[0m\] '';
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    rcu.url = "github:rszamszur/pkg-rcu";
    b3.url = "github:rszamszur/b3-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, home-manager-unstable, sops-nix, comin, flake-parts, rcu, b3 }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        ./shells/flake-module.nix
        ./pkgs/flake-module.nix
        ./images/flake-module.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, pkgs, system, ... }: {
        packages = {
          rcu = rcu.packages.${system}.rcu;
          b3 = b3.packages.${system}.default;
        };
        overlayAttrs = {
          inherit (config.packages) rcu b3;
          mylib = import ./lib { lib = pkgs.lib; };
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
          uv2nix = {
            path = ./templates/uv2nix;
            description = ''
              Base flake for Python projects using uv2nix.
            '';
          };
        };
        overlays = {
          mylib = import ./overlays/mylib.nix;
          poetry2nix = import ./overlays/poetry2nix.nix;
          lunar-lake-firmware-fix = import ./overlays/lunar-lake-firmware-fix.nix;
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
              inputs.comin.nixosModules.comin
              self.nixosModules.common
              self.nixosModules.awesome
              self.nixosModules.bash
              self.nixosModules.vim
              self.nixosModules.sound
              self.nixosModules.kvm
              self.nixosModules.podman
              self.nixosModules.docker
              self.nixosModules.vscode
              self.nixosModules.chrome
              self.nixosModules.gaming
              self.nixosModules.cache
              self.nixosModules.comin
              self.nixosModules.local-llm
              self.nixosModules.remote-gaming
            ];
            specialArgs = {
              pkgs-unstable = import inputs.nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
          };
          draugr = inputs.nixpkgs-unstable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                nixpkgs.overlays = [
                  self.overlays.default
                  self.overlays.lunar-lake-firmware-fix
                ];
              }
              ./hosts/draugr/hardware-configuration.nix
              ./hosts/draugr/configuration.nix
              inputs.home-manager-unstable.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
              self.nixosModules.common
              self.nixosModules.hyprland
              self.nixosModules.laptop
              self.nixosModules.bash
              self.nixosModules.vim
              self.nixosModules.sound
              self.nixosModules.podman
              self.nixosModules.docker
              self.nixosModules.vscode
              self.nixosModules.remarkable
              self.nixosModules.chrome
              self.nixosModules.rbe
              self.nixosModules.cache
              self.nixosModules.wireguard
              self.nixosModules.nas
              self.nixosModules.dns
              self.nixosModules.gaming
            ];
          };
          nixgard = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              {
                nixpkgs.overlays = [ self.overlays.default ];
              }
              ./hosts/nixgard/hardware-configuration.nix
              ./hosts/nixgard/configuration.nix
              inputs.sops-nix.nixosModules.sops
              inputs.comin.nixosModules.comin
              self.nixosModules.common
              self.nixosModules.acme
              self.nixosModules.binary-cache
              self.nixosModules.comin
              self.nixosModules.upstream-overrides
            ];
            specialArgs = {
              pkgs-unstable = import inputs.nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
          };
          installation-iso = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              self.nixosModules.cache
              self.nixosModules.dns
              ({ pkgs, ... }: {
                environment.systemPackages = [ pkgs.git ];
                services.qemuGuest.enable = true;
                services.openssh.settings.PermitRootLogin = "yes";
                my.cache.enable = true;
                my.dns.enable = true;
              })
            ];
          };
        } // inputs.nixpkgs.lib.listToAttrs (
          inputs.nixpkgs.lib.map
            (
              replica: {
                name = replica.name;
                value = inputs.nixpkgs.lib.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    {
                      nixpkgs.overlays = [ self.overlays.default ];
                    }
                    ./hosts/tyr/configuration.nix
                    {
                      imports = [
                        replica.hardware-configuration-variant
                      ];
                      networking.hostName = replica.name;
                    }
                    inputs.home-manager.nixosModules.home-manager
                    inputs.sops-nix.nixosModules.sops
                    inputs.comin.nixosModules.comin
                    self.nixosModules.common
                    self.nixosModules.cache
                    self.nixosModules.bash
                    self.nixosModules.vim
                    self.nixosModules.podman
                    self.nixosModules.github-runners
                    self.nixosModules.remote-builder
                    self.nixosModules.comin
                  ];
                };
              }
            )
            [
              {
                name = "tyr";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration.nix;
              }
              {
                name = "pve-nixos-tyr1";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration.nix;
              }
              {
                name = "pve-nixos-tyr2";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration.nix;
              }
              {
                name = "pve-nixos-tyr3";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration.nix;
              }
              {
                name = "pve-nixos-tyr4";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration-n4-6.nix;
              }
              {
                name = "pve-nixos-tyr5";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration-n4-6.nix;
              }
              {
                name = "pve-nixos-tyr6";
                hardware-configuration-variant = ./hosts/tyr/hardware-configuration-n4-6.nix;
              }
            ]
        );
        nixosModules = builtins.listToAttrs (map
          (module: {
            name = builtins.replaceStrings [ ".nix" ] [ "" ] (builtins.baseNameOf module);
            value = module;
          })
          (import ./modules { lib = inputs.nixpkgs.lib; }).imports);
        homeConfigurations = {
          coder = home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./home/default.nix
              {
                home = {
                  username = "coder";
                  homeDirectory = "/home/coder";
                  stateVersion = "25.11";
                };
              }
            ];

          };
          rszamszur = home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./home/default.nix
              {
                home = {
                  username = "rszamszur";
                  homeDirectory = "/home/rszamszur";
                  stateVersion = "25.11";
                };
              }
            ];
          };
        };
        # https://github.com/NixOS/nix/issues/7165#issuecomment-3396300462
        checks = inputs.nixpkgs.lib.attrsets.unionOfDisjoint { /* Actual checks */ } self.packages;
      };
    };
}
