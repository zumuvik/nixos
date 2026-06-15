{ config, lib, pkgs, ... }:

let
  anyCachyEnabled =
    config.my.hardware.kernel-cachy.enable
    || config.my.hardware.kernel-cachy-bore.enable;
in
{
  options.my.hardware = {
    kernel-zen.enable = lib.mkEnableOption "Zen kernel optimizations";
    kernel-cachy.enable = lib.mkEnableOption "CachyOS kernel optimizations";
    kernel-cachy-bore.enable = lib.mkEnableOption "CachyOS BORE kernel optimizations";
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.hardware.kernel-zen.enable {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    })
    (lib.mkIf config.my.hardware.kernel-cachy.enable {
      boot.kernelPackages = pkgs.linuxPackages_cachyos;
    })
    (lib.mkIf config.my.hardware.kernel-cachy-bore.enable {
      boot.kernelPackages = pkgs.linuxPackages_cachyos; # Chaotic-Nyx uses EEVDF by default in their cachyos kernel. There is no separate bore kernel in chaotic-nyx pkgs usually, it's just linuxPackages_cachyos.
    })
  ];
}
