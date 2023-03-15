{
  description = "Radosław Szamszur NixOS configurations";
  nixConfig.bash-prompt = ''\n\[\033[1;32m\][nix-develop:\w]\$\[\033[0m\] '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

  };

  outputs = { self, nixpkgs, home-manager, flake-utils-plus }@inputs:
    {
      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          self.overlays.pkgs
          self.overlays.poetry2nix
        ];
        pkgs = import ./overlays/pkgs.nix;
        poetry2nix = import ./overlays/poetry2nix.nix;
      };

    } // flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      channelsConfig = {
        allowUnfree = true;
      };

      sharedOverlays = [ self.overlays.default ];

      hostDefaults = {
        system = "x86_64-linux";
        channelName = "nixpkgs";
        modules = [
          home-manager.nixosModules.home-manager
        ];
      };

      hosts.fenrir = {
        modules = [
          ./hosts/fenrir/hardware-configuration.nix
          ./hosts/fenrir/configuration.nix
        ];
      };

      hosts.draugr = {
        modules = [
          ./hosts/draugr/hardware-configuration.nix
          ./hosts/draugr/configuration.nix
        ];
      };

      hosts.tyr = {
        system = "aarch64-linux";
        modules = [
          ./hosts/tyr/hardware-configuration.nix
          ./hosts/tyr/configuration.nix
        ];
      };

      outputsBuilder = channels: {
        packages = {
          manix = channels.nixpkgs.manix;
          cups-remarkable = channels.nixpkgs.cups-remarkable;
        };

        devShells = {
          poetry = import ./shells/py3-poetry.nix { pkgs = channels.nixpkgs; };
          pip = import ./shells/py3-pip.nix { pkgs = channels.nixpkgs; };
          nodejs = import ./shells/js.nix { pkgs = channels.nixpkgs; };
          ruby = import ./shells/ruby.nix { pkgs = channels.nixpkgs; };
        };
      };

      packages.aarch64-linux = {
        rpi-fanshim = import ./images/rpi-fanshim {
          pkgs = self.pkgs.aarch64-linux.nixpkgs;
        };
        RPiGPIO = self.pkgs.aarch64-linux.nixpkgs.RPiGPIO;
        apa102 = self.pkgs.aarch64-linux.nixpkgs.apa102;
        fanshim = self.pkgs.aarch64-linux.nixpkgs.fanshim;
      };

    };
}
