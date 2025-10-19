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

  networking.hostName = "draugr";

  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Lunar lake fixes
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    pkgs-unstable.sof-firmware
    pkgs-unstable.alsa-firmware
  ];
  environment.systemPackages = [
    pkgs-unstable.alsa-topology-conf
    pkgs.my-alsa-ucm-conf
    pkgs-unstable.alsa-utils
    pkgs.my-intel-media-driver
  ];

  environment.variables = {
    ALSA_CONFIG_UCM = "${pkgs.my-alsa-ucm-conf}/share/alsa/ucm";
    ALSA_CONFIG_UCM2 = "${pkgs.my-alsa-ucm-conf}/share/alsa/ucm2";
  };
  environment.sessionVariables = {
    ALSA_CONFIG_UCM = "${pkgs.my-alsa-ucm-conf}/share/alsa/ucm";
    ALSA_CONFIG_UCM2 = "${pkgs.my-alsa-ucm-conf}/share/alsa/ucm2";
  };
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM = config.environment.variables.ALSA_CONFIG_UCM;
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM = config.environment.variables.ALSA_CONFIG_UCM;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;

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

  my.hyprland.enable = true;
  my.laptop.enable = true;
  my.sound = {
    enable = true;
    driver = "pipewire";
  };
  my.bash = {
    enable = true;
    homepkgs = [
      pkgs.spotify
      pkgs.kdePackages.okular
      pkgs.vlc
      pkgs.firefox
      pkgs.signal-desktop
      pkgs.libreoffice
      pkgs.keepassxc
      pkgs.jetbrains.pycharm-community
      pkgs.solaar
      pkgs.openvpn
      pkgs.gimp
      pkgs.b3
      pkgs.discord
      pkgs.k9s
      pkgs.coder
    ];
  };
  my.vim.enable = true;
  my.podman.enable = true;
  my.docker.enable = true;
  my.vscode.enable = true;
  my.remarkable.enable = true;
  my.chrome.enable = true;
  my.nas = {
    enable = true;
    credentialsPath = config.sops.secrets.nasCredentials.path;
  };
  my.rbe = {
    enable = true;
    rbePrivateKey = config.sops.secrets.nixremote.path;
  };
  my.cache.enable = true;
  my.dns = {
    enable = true;
    puqu.enable = true;
  };
  my.zerotier =
    let
      networkId = builtins.getEnv "ZEROTIER_NET_ID";
    in
    {
      enable = if networkId == "" then false else true;
      inherit networkId;
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
