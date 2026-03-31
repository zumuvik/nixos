{ ... }: {
  imports = [
    ./services.nix
#    ./hardware.nix
    ./swap.nix
    ./zram.nix
    ./greetd.nix
    ./laptop.nix
  ];
}
