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
    boot.kernelParams = [ "amdgpu.dc=1" ];
  };
}
