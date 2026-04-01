{ config, pkgs, ... }:

{
  # Graphics (AMD/Intel)
  hardware.graphics.enable = true;

  # AMD GPU
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "amdgpu.dc=1" ];

  # Virtualization
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Real-Time Audio
  security.rtkit.enable = true;
}
