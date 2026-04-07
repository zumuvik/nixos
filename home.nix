{ pkgs, inputs, username, hostName, lib, ... }:

{
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.ags.homeManagerModules.default
    inputs.nixvim.homeModules.nixvim
    ./modules/home
    ./modules/programs
  ];

  # ────────────────────────────────────────────────────────
  # Home Manager Base Settings
  # ────────────────────────────────────────────────────────
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  home.language = {
    base = "ru_RU.UTF-8";
  };

  home.sessionVariables = {
    TERMINAL = "ghostty";
  };

  home.sessionPath = [ "/run/current-system/sw/bin" ];

  dconf.enable = false;

  # ────────────────────────────────────────────────────────
  # Hypridle (Screen lock/sleep/hibernate)
  # ────────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1200;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
  xdg.terminal-exec = {
    enable = true;
    package = pkgs.ghostty;
  };

  # ────────────────────────────────────────────────────────
  # Core Packages
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
    cava
    ytermusic
    yt-dlp
    firefox

    # Utilities
    micro
    ghostty
    thunar
    thunar-archive-plugin
    tumbler
    scrcpy
    android-tools
    remmina
    libnotify
    cliphist
    bibata-cursors
    sassc
    galaxy-buds-client
    virt-manager
    qemu
    libvirt
    virt-viewer
    opencode

  ] ++ lib.optionals (hostName == "nixlensk323") [
    inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
