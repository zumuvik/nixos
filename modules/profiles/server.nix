{ config, lib, ... }:

{
  options.my.profiles.server.enable = lib.mkEnableOption "Server Profile";

  config = lib.mkIf config.my.profiles.server.enable {
    # ────────────────────────────────────────────────────────
    # Server Profile Settings
    # ────────────────────────────────────────────────────────
    
    # Disable Cloudflare WARP by default on servers
    services.cloudflare-warp.enable = lib.mkDefault false;

    # Performance / Server specific tweaks
    boot.kernelParams = [ "idle=nomwait" ];
    
    # Force English locale for server logs/messages
    i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

    # Default services for servers
    my.services.nginx.enable = lib.mkDefault true;
    my.services.git-sync.enable = lib.mkDefault true;
  };
}
