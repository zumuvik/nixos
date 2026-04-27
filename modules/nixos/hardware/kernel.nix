{ config, lib, pkgs, ... }:

{
  options.my.hardware = {
    kernel-zen.enable = lib.mkEnableOption "Zen kernel optimizations";
    kernel-cachy.enable = lib.mkEnableOption "CachyOS kernel optimizations";
    kernel-cachy-bore.enable = lib.mkEnableOption "CachyOS Bore kernel optimizations";
  };

  config = lib.mkMerge [
    {
      nix.settings = {
        substituters = [ "https://xddxdd.cachix.org" ];
        trusted-public-keys = [ "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=" ];
      };
    }
    (lib.mkIf config.my.hardware.kernel-zen.enable {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    })
    (lib.mkIf config.my.hardware.kernel-cachy.enable {
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    })
    (lib.mkIf config.my.hardware.kernel-cachy-bore.enable {
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
    })
  ];
}
