{ config, pkgs, ... }:

{
  home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;

  home.packages = with pkgs; [
    playerctl
  ];
}
