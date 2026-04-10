{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];
}