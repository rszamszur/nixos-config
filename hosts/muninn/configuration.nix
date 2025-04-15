{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.supportedFilesystems = [ "ntfs" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "muninn";

  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  #   environment.systemPackages = [
  #     pkgs.acpi
  #   ];

  #   services.acpid.enable = true;
  #   # A keyboard shortcut daemon
  #   services.actkbd.enable = true;

  boot.loader.raspberryPi.bootloader = "uboot";
  hardware.raspberry-pi.extra-config = ''
    psu_max_current=5000
    dtparam=pciex1
    dtparam=pciex1_gen=3
  '';

  my.bash.enable = true;
  my.vim.enable = true;
  my.podman.enable = true;
  my.docker.enable = true;

  my.cache = {
    enable = false;
    extraSubstituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extraTrustedPublicKeys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
