{ lib, ... }:

{
  options.modules = {
    desktop.enable = lib.mkEnableOption "Desktop environment and GUI apps";
    bluetooth.enable = lib.mkEnableOption "Bluetooth support";
    gaming.enable = lib.mkEnableOption "Gaming optimizations and tools";
    server.enable = lib.mkEnableOption "Server-specific configurations";
  };
}
