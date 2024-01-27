{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # A lot GUI programs need this, nearly all wayland applications
      "cma=128M"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      raspberryPi = {
        enable = true;
        version = 4;
        firmwareConfig = "dtparam=sd_poll_once=on";
      };
      grub.enable = false;
    };
    supportedFilesystems = [ "ntfs" ];
  };
  hardware.enableRedistributableFirmware = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "huginn";

  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  environment.systemPackages = [
    pkgs.acpi
  ];

  services.acpid.enable = true;
  # A keyboard shortcut daemon
  services.actkbd.enable = true;

  my.bash = {
    enable = true;
    homepkgs = [
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.minikube
    ];
  };
  my.vim.enable = true;
  my.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
