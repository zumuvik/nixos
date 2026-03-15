{ pkgs, inputs, ... }:

{
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  home.username = "zumuvik";
  home.homeDirectory = "/home/zumuvik";

  home.packages = with pkgs; [
    # Интерфейс и система
    fastfetch micro kitty zip unzip git
    mako swww waypaper waybar rofi
    grim slurp wl-clipboard libnotify
    pavucontrol nix-search

      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.tumbler # для превью картинок

    # Мультимедиа и работа
    mpv mpvpaper spotube cava playerctl
    discord vesktop firefox
    scrcpy android-tools brightnessctl sassc

    # Bluetooth & Софт для наушников
    galaxy-buds-client

    # Темы и кастом
    bibata-cursors
    nwg-look

    # Пакеты из внешних инпутов
    inputs.ayugram-desktop.packages.${pkgs.system}.default
  ];

  # Настройка AGS
  programs.ags = {
    enable = true;
    # configDir = ./ags; # Раскомментируй, если папка ags лежит рядом с home.nix
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_6_0
      accountsservice
    ];
  };

  # Настройка OBS (перенесено из системного конфига)
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-pipewire-audio-capture
      wlrobs
      obs-vkcapture
    ];
  };

  # Локализация
  home.language = {
    base = "ru_RU.UTF-8";
  };

  # Темы (под твой монохромный стиль)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  home.stateVersion = "25.11";
}
