{ config, ... }:

{
  # Import hyprlock.conf via home.file to avoid Nix parsing error
  home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
}
