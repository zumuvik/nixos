{ config, lib, pkgs, ... }:

{
  options.my.hardware = {
    kernel-zen.enable = lib.mkEnableOption "Zen kernel optimizations";
  };

  config = lib.mkIf config.my.hardware.kernel-zen.enable {
    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
}
