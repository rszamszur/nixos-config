{ config, lib, pkgs, ... }:

let
  cfg = config.my.remote-gaming;
in
{
  options.my.remote-gaming = {
    enable = lib.mkEnableOption "Enables remote-gaming module";
    gpuType = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "nvidia"
        "software"
      ];
      default = "software";
      example = "amd";
      description = "Which GPU backend to use.";
    };
  };

  # Everything that should be done when/if the service is enabled
  config = lib.mkIf cfg.enable (
    let
      # The docker-compose.yml file (as a JSON)
      wolfDevices =
        if cfg.gpuType == "amd" then
          [
            "/dev/dri"
          ]
        else if cfg.gpuType == "nvidia" then
          [
            "/dev/dri"
            "/dev/nvidia-uvm"
            "/dev/nvidia-uvm-tools"
            "/dev/nvidia-caps/nvidia-cap1"
            "/dev/nvidia-caps/nvidia-cap2"
            "/dev/nvidiactl"
            "/dev/nvidia0"
            "/dev/nvidia1"
            "/dev/nvidia-modeset"
          ]
        else
          [ ];

      wolfEnvironment =
        if cfg.gpuType == "software" then
          [
            "WOLF_RENDER_NODE=software"
          ]
        else if cfg.gpuType == "nvidia" then
          [
            "NVIDIA_DRIVER_VOLUME_NAME=nvidia-driver-vol"
          ]
        else
          [ ];

      wolfVolumes =
        if cfg.gpuType == "nvidia" then
          [
            "nvidia-driver-vol:/usr/nvidia:rw"
          ]
        else
          [ ];

      nvidiaVolume =
        if cfg.gpuType == "nvidia" then
          {
            volumes = {
              nvidia-driver-vol = {
                external = true;
              };
            };
          }
        else
          { };

      dockerComposeConfig = {
        services.wolf = {
          image = "ghcr.io/games-on-whales/wolf:stable";
          environment = wolfEnvironment ++ [
            "XDG_RUNTIME_DIR=/tmp/sockets"
            "HOST_APPS_STATE_FOLDER=/etc/wolf"
            # WARNING: WOLF behaviour is flaky with multiple GPU's.
            # For more details please see:
            # https://github.com/games-on-whales/wolf/issues/233
            # https://github.com/games-on-whales/wolf/issues/118
            "WOLF_USE_ZERO_COPY=FALSE"
            "WOLF_RENDER_NODE=/dev/dri/renderD129"
            "WOLF_ENCODER_NODE=/dev/dri/renderD129"
            # Not sure if this is needed
            "NVIDIA_DRIVER_CAPABILITIES=all"
            "NVIDIA_VISIBLE_DEVICES=nvidia.com/gpu=all"
            # Debug variables, uncomment as needed
            #"RUST_LOG=DEBUG"
            #"WOLF_LOG_LEVEL=debug"
            #"GST_DEBUG=5"
          ];
          volumes = wolfVolumes ++ [
            "/etc/wolf/:/etc/wolf"
            "/tmp/sockets:/tmp/sockets:rw"
            "/var/run/docker.sock:/var/run/docker.sock:rw"
            "/dev/:/dev/:rw"
            "/run/udev:/run/udev:rw"
          ];
          device_cgroup_rules = [ "c 13:* rmw" ];
          devices = wolfDevices ++ [
            "/dev/uinput"
            "/dev/uhid"
          ];
          network_mode = "host";
          restart = "unless-stopped";
        };
      }
      // nvidiaVolume; # Merge conditionally
    in
    {
      assertions = [
        {
          assertion = config.my.sound.enable;
          message = "Module my.sound is required.";
        }
        {
          assertion = config.my.sound.driver == "pulseaudio";
          message = "Only pulseaudio driver is supported.";
        }
      ];
      services.udev.packages = [
        # prevent wolf's virtual controllers from being picked up by host session
        (pkgs.writeTextFile {
          name = "wolf-virtual-controller-udev-rules";
          text = ''SUBSYSTEMS=="input", ATTRS{name}=="Wolf X-Box One (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9", GROUP="root"'';
          destination = "/etc/udev/rules.d/60-wolf-virtual-controller-hid.rules";
        })
      ];
      #######################################################
      # GOW - Wolf Setup
      #######################################################
      # Required packages
      environment.systemPackages = with pkgs; [
        curl
        docker
        docker-compose
      ];

      # Open selected port in the firewall.
      # We can reference the port that the user configured.
      networking.firewall = {
        allowedTCPPorts = [
          # Wolf - Game streaming
          47984 # Wolf - https
          47989 # Wolf - http
          48010 # Wolf - rtsp
        ];
        allowedUDPPorts = [
          # Wolf - Game streaming
          47999 # Wolf - Control
          48100
          48101
          48102
          48103
          48104
          48105
          48106
          48107
          48108
          48109
          48110
          48200
          48201
          48202
          48203
          48204
          48205
          48206
          48207
          48208
          48209
          48210
          #(lib.range 48100 48110)
          #(lib.range 48200 48210)
          #{ from = 48100; to = 48110; }  # Wolf - Video (up to 10 users, you can open more ports if needed)
          #{ from = 48200; to = 48210; }  # Wolf - Audio (up to 10 users, you can open more ports if needed)
        ];
      };

      # Enable Docker
      my.docker = {
        enable = true;
        enableNvidia = true;
        # Let the ops user run docker commands without sudo
        #extraDockerGroupUsers = [ "ops" ];
      };

      # Extra groups (not entirely sure this is needed)
      # Setup ops group
      users.groups.ops = {
        gid = 2000; # Set the gid
      };

      users.users = lib.mkMerge [
        {
          # Setup ops user for ssh'ing into the box
          ops = {
            isNormalUser = true;
            uid = 2000; # Set the uid
            group = "ops"; # Primary group for the user
            extraGroups = [
              "wheel"
            ];
            home = "/home/ops"; # Ensure the home directory is set
          };
        }
      ];

      users.extraUsers.ops.extraGroups = [
        "audio"
        "ops"
      ];

      # Create the necessary directories
      systemd.tmpfiles.rules = [
        "d /etc/wolf 0755 root root"
        "d /tmp/sockets 0755 root root"
        #"d /ROMs 0755 ops users"
      ];

      virtualisation.docker.daemon.settings = {
        data-root = "/docker/daemon";
      };

      environment.etc."wolf/docker-compose.yml".text =
        builtins.toJSON dockerComposeConfig;

      # Build out the nvidia-driver-vol if gpu is nvidia
      systemd.services = {
        nvidiaDriverVolumeSetup =
          lib.mkIf (cfg.gpuType == "nvidia")
            {
              description = "One-time NVIDIA driver Docker volume builder for GOW";
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "build-nvidia-volume" ''
                  set -euo pipefail

                  MARKER=/etc/wolf/.nvidia-driver-vol-ready

                  # Not sure if this "NVIDIA_CAPS" is needed
                  NVIDIA_CAPS=/dev/nvidia-caps
                  if [ ! -d "$NVIDIA_CAPS" ]; then
                    echo "Building NVIDIA-CAPS"
                    nvidia-container-cli --load-kmods info
                  fi

                  if [ -f "$MARKER" ]; then
                    echo "NVIDIA driver volume already built. Skipping."
                    exit 0
                  fi

                  echo "Building NVIDIA driver volume - Started"
                  ${pkgs.curl}/bin/curl https://raw.githubusercontent.com/games-on-whales/gow/master/images/nvidia-driver/Dockerfile \
                    | ${pkgs.docker}/bin/docker build -t gow/nvidia-driver:latest -f - --build-arg NV_VERSION=$(cat /sys/module/nvidia/version) .
                  ${pkgs.docker}/bin/docker create --rm --mount source=nvidia-driver-vol,destination=/usr/nvidia gow/nvidia-driver:latest sh

                  echo "Building NVIDIA driver volume - Finished"
                  touch "$MARKER"
                '';
              };

              # Ensure it runs after Docker is ready
              after = [ "docker.service" ];
              before = [ "wolf.service" ];
              requires = [ "docker.service" ];
            };

        # Ensure the wolf service is started via docker-compose
        wolf = {
          description = "Wolf Docker Compose Service";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/wolf/docker-compose.yml up";
            ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/wolf/docker-compose.yml down";
            Restart = "on-failure";
            WorkingDirectory = "/etc/wolf";
          };

          # Make sure we don't start it until docker is up (and nvidia volume setup)
          after = [
            "docker.service"
          ]
          ++ lib.optional
            (
              cfg.gpuType == "nvidia"
            ) "nvidiaDriverVolumeSetup.service";
          requires = [
            "docker.service"
          ]
          ++ lib.optional
            (
              cfg.gpuType == "nvidia"
            ) "nvidiaDriverVolumeSetup.service";
        };
      };
    }
  );
}
