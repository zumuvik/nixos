{ ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/swap.nix
    ../../modules/system/cachyos-kernel.nix
  ];
}
