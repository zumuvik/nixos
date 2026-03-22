{ pkgs, lib, ... }:

{
  imports = [
   ./binds.nix
   ./style.nix
   ./monitors.nix
   ./workspaces.nix
   ./startup_apps.nix
];


  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
