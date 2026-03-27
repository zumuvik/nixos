{ config, pkgs, inputs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -la";
      edit = "micro";
      conf = "micro /etc/nixos/configuration.nix";
      rebuild = "sudo nixos-rebuild switch";
    };
  };
}
