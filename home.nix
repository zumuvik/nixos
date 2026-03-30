{ pkgs, inputs, username, ... }:

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
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
        {
          timeout = 1200;
          on-timeout = "systemctl hibernate";
        }
      ];
    };
  };

  # ────────────────────────────────────────────────────────
  # Neovim (nixvim)
  # ────────────────────────────────────────────────────────


  # ────────────────────────────────────────────────────────
  # VSCode
  # ────────────────────────────────────────────────────────
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
  };

  # ────────────────────────────────────────────────────────
  # AGS (System tray/widgets)
  # ────────────────────────────────────────────────────────
  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_6_0
      accountsservice
    ];
  };

  # ────────────────────────────────────────────────────────
  # OBS Studio
  # ────────────────────────────────────────────────────────
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-pipewire-audio-capture
      wlrobs
      obs-vkcapture
    ];
  };

  # ────────────────────────────────────────────────────────
  # NixCord (Discord)
  # ────────────────────────────────────────────────────────
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;

    config = {
      useQuickCss = true;
      themeLinks = [
        "https://raw.githubusercontent.com/refact0r/midnight-discord/master/midnight.css"
      ];
      frameless = true;

      plugins = {
        fakeNitro.enable = true;
        shikiCodeblocks.enable = true;
        noTypingAnimation.enable = true;
      };
    };
  };

  # ────────────────────────────────────────────────────────
  # Core Packages
  # ────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Desktop Environment
    waybar
    rofi
    waypaper
    nwg-look
    nwg-displays

    # Media
    mpv
    mpvpaper
    cava
    firefox

    # Utilities
    micro
    kitty
    thunar
    thunar-archive-plugin
    tumbler
    scrcpy
    android-tools
    remmina
    pavucontrol
    libnotify
    cliphist
    bibata-cursors
    sassc
    galaxy-buds-client
    virt-manager
    qemu
    libvirt
    virt-viewer

    # Custom packages from inputs (only for nixlensk323)
    # inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
