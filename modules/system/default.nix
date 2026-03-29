{ ... }: {
  imports = [
    ./services.nix
    ./hardware.nix
    ./swap.nix
    ./zram.nix
  ];
}
