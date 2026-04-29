{ config, lib, pkgs, ... }:

{
  options.my.hardware.amdgpu.enable = lib.mkEnableOption "AMD GPU support";

  config = lib.mkIf config.my.hardware.amdgpu.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
    boot.initrd.kernelModules = [ "amdgpu" ];
    # Enable overclocking/undervolting support
    boot.kernelParams = [ "amdgpu.dc=1" "amdgpu.ppfeaturemask=0xffffffff" ];

    programs.corectrl = {
      enable = true;
      gpuOverclock.enable = true;
    };
  };
}
