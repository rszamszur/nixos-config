{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "tyr";

  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # QEMU guest tools
  environment.systemPackages = [ pkgs.spice ];
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;
  services.qemuGuest.enable = true;
  # Run unpatched dynamic binaries on NixOS
  programs.nix-ld.enable = true;

  my.awesome = {
    enable = true;
    rclua = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/rszamszur/054dd09d279890e502322ac3e560ab0f/raw/403d63ae125e316305f2358ea3df469b982cb498/rc.lua";
      sha256 = "1d1fsm9pd615izwiwv8mz4kxabdyq0ad5pj5k5mx5gq28fg9y73k";
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
      pkgs.kubectx
      pkgs.burpsuite
      pkgs.mitmproxy
      pkgs.httpie
      (builtins.getFlake "github:rszamszur/b3-flake").packages.${builtins.currentSystem}.default
    ];
  };
  my.vim.enable = true;
  my.podman.enable = true;
  my.vscode.enable = true;
  my.chrome.enable = true;
  my.aarch = {
    enable = true;
  };
  my.remarkable.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
