{ config, lib, inputs, modules, pkgs, hostName, ... }:

{
  config = lib.mkIf modules.desktop.enable {
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

      # Screenshots
      grim
      slurp
      wl-clipboard
      swappy
    ] ++ lib.optionals (hostName == "nixlensk323") [
      inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Hypridle (Screen lock/sleep/hibernate)
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          { timeout = 300; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
          { timeout = 600; on-timeout = "hyprctl dispatch switchxkblayout all en && loginctl lock-session"; }
          { timeout = 900; on-timeout = "systemctl suspend"; }
        ];
      };
    };
  };
}
