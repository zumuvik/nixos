{ ... }: {
  imports = [
    ./services.nix
    ./hardware.nix
    ./zram.nix
    ./greetd.nix
  ];
}
