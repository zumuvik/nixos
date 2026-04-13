{ ... }: {
  imports = [
    ./options.nix
    ../profiles/core.nix
    ../profiles/desktop.nix
    ../profiles/server.nix

    ./services.nix
    ./hardware.nix
    ./zram.nix
    ./greetd.nix
    ./git-sync.nix
    ./fonts.nix
    ./bluetooth.nix
  ];
}
