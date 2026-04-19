{ ... }: {
  imports = [
    ./server.nix
    ./desktop.nix
    ../core
    ../nixos
  ];
}
