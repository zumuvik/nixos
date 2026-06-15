{ config, lib, pkgs, ... }:

{
  options.my.hardware.virtualization.enable = lib.mkEnableOption "Virtualization support (libvirtd)";

  config = lib.mkIf config.my.hardware.virtualization.enable {
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "suspend";
      qemu.package = pkgs.qemu_kvm;
      qemu.runAsRoot = false;
      qemu.swtpm.enable = true;
    };
    virtualisation.spiceUSBRedirection.enable = true;
    users.groups.libvirtd.members = [ "root" ];
  };
}
