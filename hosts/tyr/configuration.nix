{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

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

  # Sops secrets
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ "/etc/ssh/sopsnix_ed25519" ];
  sops.age.generateKey = true;
  sops.secrets.gh-runners-token = {
    sopsFile = ./secrets/gh-runners.yaml;
    restartUnits = [
      "github-runner-pve-nixos-tyr-runner1.service"
      "github-runner-pve-nixos-tyr-runner2.service"
    ];
  };
  sops.secrets.binary-cache-key = {
    sopsFile = ./secrets/remote-builder.yaml;
    owner = "nixremote";
    group = "nixremote";
    mode = "0600";
  };

  # My NixOS modules
  my.cache.enable = true;
  my.bash.enable = true;
  my.vim.enable = true;
  my.podman.enable = true;
  my.github-runners = {
    enable = true;
    namePrefix = "nixos-tyr";
    tokenFile = config.sops.secrets.gh-runners-token.path;
  };
  my.remote-builder = {
    enable = true;
    authorizedKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrV5PuqdHzkTDzoWB3JA6377lNzPooNx+Rt4Bx9CkZP1uCiGQzvdrfGcBCkWeJGQcyP2J0AqJ+wJjdQKyrOfHXXPXkwvaudReU/wIc0FSVbOGr3bsa2FF4mHhezW+0N4FHWpFpqlhp4cGY5Lw9nT8J6s0mEe3Z+VzaGhAETvJON+rDtl9Z8IhRJ2QvcTDGkh2rHvF5+87hmzIgCzyWTUNX8VTunYiznBGCFo7N4TRoF+N1RPZM3AGsUuVwI00iOkgFdK5cXy2N3bomHNuFH8jvinp0g2jZUw2pRFlIuN95obPvdkAPnAsSM+iqKG37kFBhqkPM5bup9+dM1pRynnAIjiuOAQGRPJJfGJUt+dF1KuJqQ0VNLOPW0Gkq7eK1Q5AhrI7dTd4e9edUTGh3If4HIqDyU7+LaxjkB6lsXW6JcYE5dQed9cgihWi4iWHosiDdQmx5TTfZTjk/VtbAUV3dGHjq8ScObz+FU/V6tEPI6awfTCpFOMxUW+CuPbG/PPFZjaR0iNcuiFyP1+Wx9EyBYHEY5eW4Z1PrkhQ/yKKGhcJmUwCM+4GbjO0WgSqMQBacyA/L2Nz102SZbzmEw/UMA9ly8MBrgo+dXDpZUJs6QPAWsxPg9uXURyyB7LGfnSilKTJoNNZvqH/YY1pWcE9uLGfl3q3cGJIYbt668BChLw== rszamszur@fenrir"
    ];
    binaryCacheKey = config.sops.secrets.binary-cache-key.path;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
