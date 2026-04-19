{ config, lib, inputs, my, pkgs, hostName, ... }:

{
  config = lib.mkIf my.profiles.desktop.enable {
    # ────────────────────────────────────────────────────────
    # Desktop Home Manager Settings
    # ────────────────────────────────────────────────────────
    
    home.packages = with pkgs; [
      # Desktop Environment
      waybar
      rofi
      swaynotificationcenter
      waypaper
      nwg-look
      nwg-displays

      # Media
      mpv
      mpvpaper
      imv
      cava
      ytermusic
      yt-dlp

      # GUI Utilities
      thunar
      thunar-archive-plugin
      tumbler
      scrcpy
      android-tools
      remmina
      libnotify
      cliphist
      bibata-cursors
      galaxy-buds-client
      virt-manager
      virt-viewer
      pavucontrol

      # Screenshots
      grim
      slurp
      wl-clipboard
      swappy
   ];

    };
}
