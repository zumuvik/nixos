# /etc/nixos/home.nix
{ pkgs, inputs, ... }:

{
  home.username = "zumuvik";
  home.homeDirectory = "/home/zumuvik";

  # Сюда переносим пакеты из configuration.nix
  home.packages = with pkgs; [
    discord
    vesktop
    spotube
    cava
    steam
    firefox waybar
    bibata-cursors
    inputs.ayugram-desktop.packages.${pkgs.system}.default # Юзаем наш инпут
  ];
  # Установка языка интерфейса, системы и формата региона
  # В home.nix
  home.language = {
    base = "ru_RU.UTF-8";
    address = "ru_RU.UTF-8";
    messages = "ru_RU.UTF-8";
  };
  # В home.nix
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark"; # Стандартная темная тема
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk"; # Заставляет Qt программы выглядеть как GTK
    style.name = "adwaita-dark";
  };


  # Чтобы Home Manager работал, нужно указать версию
  home.stateVersion = "26.05";
}
