# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kratos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.wlp5s0.useDHCP = true;
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  programs.dconf.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;

    users = {
      rszamszur = {
        uid = 1001;
        isNormalUser = true;
        description = "Radoslaw Szamszur";
        home = "/home/rszamszur";
        createHome = true;
        group = "users";
        extraGroups = [ "networkmanager" "wheel" ];
        hashedPassword = "$6$5UsMsT9nvv3Xy3Tl$wO/sQaNSqOUxjymXDYEeuWCsH0lZYwJhXh3sbBucUmr./CWNeWXRmJ5yqEj9pMC/jye9Vha7G5/YD1gH9dLpP1";
      };

      root.hashedPassword = "$6$DBH/m/TvG3cIKJUr$v5TjDD4RRQhrCbOZs3ktWj6v1Vz81z0KIMzlBVq6UfG8dlFkTmKLl.s3QFW4CwLIdeZmDHyof7Iufx.8VhGOk0";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    firefox
    git
    vlc
    gnome3.adwaita-icon-theme
    gnomeExtensions.appindicator
    gnome3.nautilus
    gnome3.gnome-terminal
    okular
    xsecurelock
    htop
    tmux
    jq
    dnsutils
    cryptsetup
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  virtualisation.podman.enable = true;

  home-manager.users.rszamszur = { ... }: {
   
   home.file = {

     ".config/awesome/volume-control".source = pkgs.fetchFromGitHub {
       owner = "rszamszur";
       repo = "volume-control";
       rev = "a18e862";
       sha256 = "0fc1l1bqwfwxchg3yqxd7ivx2nf0qcxkg16xzhl9707ycvbqajpi";
     };

     ".config/awesome/awesome-wm-widgets".source = pkgs.fetchFromGitHub {
       owner = "rszamszur";
       repo = "awesome-wm-widgets";
       rev = "b8e3a86";
       sha256 = "1y3bbxczzrqk1d2636rc0z76x8648vf3f78dwsjwsy289zmby3dq";
     };

     ".config/awesome/rc.lua".source = "rc.lua";

   };

   programs.git = {
     enable = true;
     userName = "Radosław Szamszur";
     userEmail = "radoslawszamszur@gmail.com";
   };

   services.screen-locker = {
     enable = true;
     lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
     inactiveInterval = 5;
     xautolock.enable = false;
     xss-lock = {
       package = pkgs.xss-lock;
       extraOptions = [
         "-n"
         "${pkgs.xsecurelock}/libexec/xsecurelock/dimmer"
         "-l"
       ];
     };
   };

   programs.vim = {
     enable = true;
     plugins = with pkgs.vimPlugins; [
       YouCompleteMe
       syntastic
       vim-flake8
       nerdtree
       vim-airline
       gruvbox
     ];
   };

   home.packages = with pkgs; [
     coreutils
     nmap
     zip
     unzip
     gnumake
     gcc
     vagrant
     openvpn
     gimp
     google-chrome
     flameshot
     spotify
     signal-desktop
     libreoffice
     keepassxc
   ];

  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

