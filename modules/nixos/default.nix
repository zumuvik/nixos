{ ... }: {
  imports = [
    ./services/wg-easy.nix
    ./services/awg-easy.nix
    ./services/nginx
    ./services/mailserver
    ./services/roundcube
    ./services/cloudflare-sync
    ./services/nh.nix
    ./hardware/bluetooth.nix
    ./hardware/zram.nix
    ./hardware/swap.nix
    ./hardware/default.nix
    ./gaming.nix
    ./ui
  ];
}
