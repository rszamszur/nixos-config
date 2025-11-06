{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming;
in
{

  options.my.gaming = {
    enable = lib.mkEnableOption "Enables gaming related things.";
    gpuType = lib.mkOption {
      type = lib.types.enum [
        "nvidia"
        "intel-lunar-lake"
      ];
      default = "nvidia";
      description = ''
        Which GPU backend to use.
      '';
    };
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Open Steam in the background at boot.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    ##########
    # Common #
    ##########

    programs.steam = {
      enable = true;
      package = pkgs.steam;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    hardware.steam-hardware.enable = true;

    ###########################
    # Connect xbox controller #
    ###########################

    # Enable the xpadneo driver for Xbox One wireless controllers
    hardware.xpadneo.enable = config.hardware.bluetooth.enable;
    hardware.bluetooth = lib.mkIf config.hardware.bluetooth.enable {
      settings = {
        General = {
          # show battery
          experimental = true;

          # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
          # for pairing bluetooth controller
          Privacy = "device";
          JustWorksRepairing = "always";
          Class = "0x000100";
          FastConnectable = true;
        };
      };
    };
    boot.extraModulePackages = lib.mkIf config.hardware.bluetooth.enable [ config.boot.kernelPackages.xpadneo ];
    boot.extraModprobeConfig = lib.mkIf config.hardware.bluetooth.enable ''
      options bluetooth disable_ertm=Y
    '';

    ####################
    # GPU Type: Nvidia #
    ####################

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = lib.mkIf (cfg.gpuType == "nvidia") [ "nvidia" ];
    hardware.nvidia = lib.mkIf (cfg.gpuType == "nvidia") {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    ##############################
    # GPU Type: Intel Lunar Lake #
    ##############################

    hardware.graphics = lib.mkIf (cfg.gpuType == "intel-lunar-lake") {
      enable = true;
      extraPackages = [
        pkgs.vpl-gpu-rt
        pkgs.my-intel-media-driver
        pkgs.intel-vaapi-driver
        pkgs.libvdpau-va-gl
        pkgs.vaapiIntel
      ];
    };
    boot.kernelParams = lib.mkIf (cfg.gpuType == "intel-lunar-lake") [ "i915.force_probe=64a0" ];

    ###################
    # Steam autostart #
    ###################

    systemd.user.services.steam = lib.mkIf cfg.autostart {
      enable = true;
      description = "Open Steam in the background at boot";
      path = [ pkgs.steam ];
      serviceConfig = {
        ExecStart = "${pkgs.steam}/bin/steam -nochatui -nofriendsui -silent %U";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      wantedBy = [ "graphical-session.target" ];
    };
  };

}
