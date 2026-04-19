{ config, lib, ... }:

{
  options.my.hardware.swap.enable = lib.mkEnableOption "swap file support";

  config = lib.mkIf config.my.hardware.swap.enable {
    swapDevices = [
      {
        device = "/swap/swapfile";
        size = 32768;
      }
    ];
  };
}
