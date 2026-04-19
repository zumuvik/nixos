{ config, lib, ... }:

{
  # Legacy options for Home Manager compatibility
  options.modules = {
    desktop.enable = lib.mkEnableOption "Desktop features (Legacy)";
    server.enable = lib.mkEnableOption "Server features (Legacy)";
    bluetooth.enable = lib.mkEnableOption "Bluetooth features (Legacy)";
    gaming.enable = lib.mkEnableOption "Gaming features (Legacy)";
  };

  config.modules = {
    desktop.enable = config.my.profiles.desktop.enable;
    server.enable = config.my.profiles.server.enable;
    bluetooth.enable = config.my.hardware.bluetooth.enable;
    gaming.enable = config.my.gaming.enable;
  };
}
