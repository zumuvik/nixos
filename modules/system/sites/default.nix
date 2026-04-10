{ ... }: {
  imports = [
    ./nginx.nix
    ./roundcube.nix
    ./mailserver.nix
    ./wg-easy-nginx.nix
    ../cloudflare-dns-sync.nix
  ];
}
