{ config, lib, ... }:

{
  options.my.ui.mpd.enable = lib.mkEnableOption "MPD and ncmpcpp music setup";

  config = lib.mkIf config.my.ui.mpd.enable {
    # This module acts as a toggle for Home Manager components
    # Actual implementation is in modules/home/services/mpd.nix 
    # and modules/home/programs/ncmpcpp.nix
  };
}
