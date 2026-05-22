{ config, lib, inputs, my, pkgs, hostName, ... }:

{
  imports = lib.optionals my.profiles.desktop.enable [
    ../hyprland
    ../waybar
    ../services/mpd.nix
    ../ui/theme
  ];

  config = lib.mkIf my.profiles.desktop.enable {
    # ────────────────────────────────────────────────────────
    # Desktop Home Manager Settings
    # ────────────────────────────────────────────────────────
    
    # Core Desktop Settings
    home.sessionVariables = {
      TERMINAL = "foot";
    };

    xdg.terminal-exec = {
      enable = true;
      package = pkgs.foot;
    };

    # Set foot as the default terminal for Thunar (XFCE)
    xdg.configFile."xfce4/helpers.rc".text = ''
      TerminalEmulator=foot
    '';

    xdg.dataFile."xfce4/helpers/foot.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Icon=foot
      Type=X-XFCE-Helper
      Name=Foot
      StartupNotify=false
      X-XFCE-Binaries=foot;
      X-XFCE-Category=TerminalEmulator
      X-XFCE-Commands=%B;
      X-XFCE-CommandsWithParameter=%B -e %s;
    '';

    home.packages = with pkgs; [
      # Desktop Environment
      waybar
      rofi
      swaynotificationcenter
      waypaper
      awww
      nwg-look
      nwg-displays

      # Media
      mpv
      mpvpaper
      imv
      cava
      ytermusic
      yt-dlp
      mmtc

      # GUI Utilities
      thunar
      thunar-archive-plugin
      xfce4-exo
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
      networkmanagerapplet
      # Screenshots
      grim
      slurp
      wl-clipboard
      swappy
      tty-clock
    ];

    xdg.configFile."mmtc/config.toml".text = ''
      address = "127.0.0.1:6600"
    '';
  };
}
