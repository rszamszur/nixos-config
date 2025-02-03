{ config, pkgs, ... }:

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

  # Sops secrets
  sops.age.keyFile = "/root/.config/age/sops/key.txt";
  sops.age.sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
  sops.age.generateKey = true;
  sops.secrets.nixremote = {
    sopsFile = ./secrets/rbe.yaml;
    owner = "root";
    group = "root";
    mode = "0600";
  };
  sops.secrets.nasCredentials = {
    sopsFile = ./secrets/nas.yaml;
    owner = "${builtins.toString config.users.users.rszamszur.name}";
    group = "root";
    mode = "0600";
  };

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
  my.remarkable.enable = true;
  my.chrome.enable = true;
  my.gaming.enable = true;
  my.rbe = {
    enable = true;
    rbePrivateKey = config.sops.secrets.nixremote.path;
  };
  my.cache = {
    enable = true;
    extraSubstituters = [
      "ssh-ng://nix-rbe"
    ];
    extraTrustedPublicKeys = [
      "tyr:bbjBCfYPxGt0i2LGCDy802CbgqkRRoRGL2h3u7QVeVg="
    ];
  };
  my.nas = {
    enable = true;
    credentialsPath = config.sops.secrets.nasCredentials.path;
  };
  my.comin = {
    enable = true;
    openFirewall = true;
  };
  my.local-llm = {
    enable = true;
    loadModels = [
      "llama3.3:70b"
      "qwen2.5-coder:32b"
      "deepseek-r1:70b"
      "deepseek-r1:32b"
    ];
    ollamaHome = "/data/ollama";
    ingressFQDN = "fyi.goto.fail";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
