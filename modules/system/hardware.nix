{ config, pkgs, ... }:

{
  # Graphics (AMD/Intel)
  hardware.graphics = {
    enable = true;
  };

  # AMD GPU - Vega 56
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "amdgpu.dc=1" ];

  # Tablet Driver (OpenTabletDriver)
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  # Input Devices (для аналоговых джойстиков, etc)
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];

  # Virtualization - enabled on all hosts by default
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Real-Time Audio
  security.rtkit.enable = true;
}
