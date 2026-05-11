{ config, lib, ... }:

{
  options.my.ui.mpd.enable = lib.mkEnableOption "MPD and ncmpcpp music setup";

  config = lib.mkIf config.my.ui.mpd.enable { 
  };
}
