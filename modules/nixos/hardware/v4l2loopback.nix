{ config, lib, pkgs, ... }:

{
  options.my.hardware.v4l2loopback = {
    enable = lib.mkEnableOption "v4l2loopback for OBS Virtual Camera";
  };

  config = lib.mkIf config.my.hardware.v4l2loopback.enable {
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
    '';
  };
}