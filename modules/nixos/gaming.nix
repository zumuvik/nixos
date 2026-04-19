{ config, lib, pkgs, ... }:

{
  options.my.gaming.enable = lib.mkEnableOption "Gaming optimizations and tools";

  config = lib.mkIf config.my.gaming.enable {
    # Gaming specific optimizations can go here
    # Example: gamemode is already enabled at host level but could be here
    
    # Steam is often host-specific but some parts could be shared
    programs.steam.enable = lib.mkDefault true;
    
    # Gamepad support
    services.udev.packages = with pkgs; [ game-devices-udev-rules ];
  };
}
