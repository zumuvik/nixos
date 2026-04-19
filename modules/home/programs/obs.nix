{ my, lib, pkgs, ... }:{
  config = lib.mkIf my.profiles.desktop.enable {
    programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-vaapi
          obs-pipewire-audio-capture
          wlrobs
          obs-vkcapture
        ];
      };
  };
}
