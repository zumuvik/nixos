{ config, lib, ... }:

{
  options.my.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = lib.mkIf config.my.hardware.bluetooth.enable {
    # Bluetooth Hardware
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    # Blueman GUI
    services.blueman.enable = true;
  };
}
