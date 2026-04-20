{ ... }: {
  imports = [
    ./services/wg-easy.nix
    ./services/nginx
    ./services/mailserver
    ./services/roundcube
    ./services/cloudflare-sync
    ./services/nh.nix
    ./services/git-sync
    ./hardware/bluetooth.nix
    ./hardware/zram.nix
    ./hardware/swap.nix
    ./hardware/default.nix
    ./gaming.nix
    ./ui
  ];
}
