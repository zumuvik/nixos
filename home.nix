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
    bibata-cursors
    inputs.ayugram-desktop.packages.${pkgs.system}.default # Юзаем наш инпут
  ];



  # Чтобы Home Manager работал, нужно указать версию
  home.stateVersion = "26.05";
}
