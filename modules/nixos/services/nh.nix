{ config, lib, pkgs, ... }: {
  options.my.services.nh.enable = lib.mkEnableOption "NH (Nix Helper) - A better way to manage NixOS";

  config = lib.mkIf config.my.services.nh.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/etc/nixos";
    };

    environment.systemPackages = with pkgs; [
      nix-output-monitor
      nvd
    ];
  };
}
