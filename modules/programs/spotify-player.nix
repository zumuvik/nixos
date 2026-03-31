{ config, pkgs, ... }:

{
  programs.spotify-player = {
    enable = true;
    settings = {
      theme = "default";
      playback_window_position = "Top";
      enable_media_control = true;
      device = {
        volume = 80;
        bitrate = 320;
      };
    };
  };
}