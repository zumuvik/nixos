{ pkgs, inputs, ... }:

{
  # 1. Добавляем импорт модуля AGS из инпутов флейка
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  home.username = "zumuvik";
  home.homeDirectory = "/home/zumuvik";

  home.packages = with pkgs; [
    discord
    vesktop
    spotube
    cava
    steam
    firefox
    waybar # Можно оставить пока не допишете конфиг AGS
    galaxy-buds-client
    bibata-cursors
    inputs.ayugram-desktop.packages.${pkgs.system}.default

    # Рекомендуемые пакеты для работы виджетов AGS
    sassc              # Для компиляции стилей scss -> css
    brightnessctl      # Для управления яркостью через виджеты
    playerctl          # Для управления музыкой
  ];

  # 2. Настройка AGS
  programs.ags = {
    enable = true;

    # Путь к папке с конфигом (создайте её в /etc/nixos/ags или ~/.config/ags)
    # configDir = ./ags;

    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_6_0
      accountsservice
    ];
  };

  home.language = {
    base = "ru_RU.UTF-8";
    address = "ru_RU.UTF-8";
    messages = "ru_RU.UTF-8";
  };

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

  home.stateVersion = "25.05"; # Обратите внимание: версия должна соответствовать вашему каналу nixpkgs
}
