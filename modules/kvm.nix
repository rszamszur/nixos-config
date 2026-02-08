{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.kvm;
in
{
  options.my.kvm.enable = lib.mkEnableOption "Enable KVM related modules.";

  config = lib.mkIf cfg.enable {

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
    };

    environment.systemPackages = [
      pkgs.libvirt
    ];

    users.extraGroups.libvirtd.members = [ "rszamszur" ];

  };

}
