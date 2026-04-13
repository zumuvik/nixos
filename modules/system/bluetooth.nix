{ config, lib, ... }:

{
  config = lib.mkIf config.modules.bluetooth.enable {
    # Bluetooth Hardware
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    # Blueman GUI
    services.blueman.enable = true;
  };
}
