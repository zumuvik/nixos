{ config, pkgs, ... }:

{
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32768;
    }
  ];
}
