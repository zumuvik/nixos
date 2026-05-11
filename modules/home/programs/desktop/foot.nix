{ config, lib, my, pkgs, ... }: {
  config = lib.mkIf my.profiles.desktop.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          font = "JetBrainsMono Nerd Font:size=15";
        };
        "colors-dark" = {
          alpha = 0.7;
        };
      };
    };
  };
}
