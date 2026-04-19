{ config, lib, ... }:

{
  options.my.hardware.zram.enable = lib.mkEnableOption "zram swap support";

  config = lib.mkIf config.my.hardware.zram.enable {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 10;
    };
  };
}
