{ config, lib, ... }:

{
  config = lib.mkIf config.modules.server.enable {
    # ────────────────────────────────────────────────────────
    # Server Profile Settings
    # ────────────────────────────────────────────────────────
    
    # Disable Cloudflare WARP by default on servers
    services.cloudflare-warp.enable = lib.mkDefault false;

    # Performance / Server specific tweaks
    boot.kernelParams = [ "idle=nomwait" ];
    
    # Force English locale for server logs/messages
    i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
  };
}
