{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tyr";

  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # QEMU guest tools
  environment.systemPackages = [ pkgs.spice ];

  my.awesome = {
    enable = true;
    rclua = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/rszamszur/054dd09d279890e502322ac3e560ab0f/raw/23e8515e4884803c0f7fb50f7ad3e00e90480966/rc.lua";
      sha256 = "1x56pp2pr8y5x45sy08yvwzk4j82v4hi5zvzdpxhwakk3p5lz3h5";
    };
  };
  my.laptop.enable = true;
  my.bash = {
    enable = true;
    gitEmail = builtins.getEnv "TYR_GIT_EMAIL";
    homepkgs = [
      pkgs.google-cloud-sdk
      pkgs.firefox
      pkgs.keepassxc
      pkgs.kubectl
      pkgs.kubernetes-helm
    ];
  };
  my.vim.enable = true;
  my.podman.enable = true;
  my.vscode.enable = true;
  my.chrome.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
