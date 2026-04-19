{ config, lib, pkgs, inputs, ... }:

{
  options.my.hardware = {
    kernel-zen.enable = lib.mkEnableOption "Zen kernel optimizations";
    kernel-cachy.enable = lib.mkEnableOption "CachyOS kernel optimizations";
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.hardware.kernel-zen.enable {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    })
    (lib.mkIf config.my.hardware.kernel-cachy.enable {
      boot.kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.${pkgs.system}.linuxPackages-cachyos-latest;
    })
  ];
}
