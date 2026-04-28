{ config, lib, ... }:

{
  options.my.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = lib.mkIf config.my.hardware.bluetooth.enable {
    # Bluetooth Hardware
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          ControllerMode = "bredr";
        };
      };
      input = {
        General = {
          UserspaceHID = false;
        };
      };
    };
    # Blueman GUI
    services.blueman.enable = true;
  };
}
