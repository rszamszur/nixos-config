{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "fenrir";

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

  my.awesome = {
    enable = true;
    rclua = ./rc.lua;
  };
  my.bash = {
    enable = true;
    homepkgs = [
      pkgs.spotify
      pkgs.okular
      pkgs.vlc
      pkgs.firefox
      pkgs.signal-desktop
      pkgs.libreoffice
      pkgs.keepassxc
      pkgs.jetbrains.pycharm-community
      pkgs.solaar
      pkgs.openvpn
      pkgs.gimp
    ];
  };
  my.vim.enable = true;
  my.sound.enable = true;
  my.kvm.enable = true;
  my.podman.enable = true;
  my.docker.enable = true;
  my.vscode.enable = true;
  my.chrome.enable = true;
  my.gaming.enable = true;
  my.cache.enable = true;
  my.comin = {
    enable = true;
    openFirewall = true;
  };
  my.local-llm = {
    enable = true;
    ollama = {
      package = pkgs-unstable.ollama;
      loadModels = [
        "llama3.3:70b"
        "qwen2.5-coder:32b"
        "deepseek-r1:70b"
        "deepseek-r1:32b"
      ];
      user = "ollama";
      home = "/data/ollama";
    };
    open-webui = {
      package = pkgs-unstable.open-webui;
    };
    ingressFQDN = "goto.fail";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
