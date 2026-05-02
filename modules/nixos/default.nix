{ ... }: {
  imports = [
    ./services/nginx
    ./services/mailserver
    ./services/roundcube
    ./services/cloudflare-sync
    ./services/nh.nix
    ./services/3x-ui.nix
    ./services/legacy.nix
    ./hardware/bluetooth.nix
    ./hardware/zram.nix
    ./hardware/swap.nix
    ./hardware/default.nix
    ./gaming.nix
    ./ui
  ];
}
