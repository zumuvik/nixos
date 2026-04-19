{ config, lib, pkgs, ... }:

{
  options.my.hardware.virtualization.enable = lib.mkEnableOption "Virtualization support (libvirtd)";

  config = lib.mkIf config.my.hardware.virtualization.enable {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
