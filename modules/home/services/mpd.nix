{ config, lib, pkgs, my, ... }:

{
  config = lib.mkIf my.ui.mpd.enable {
    services.mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";
      dataDir = "${config.home.homeDirectory}/.local/share/mpd";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }

        audio_output {
          type "fifo"
          name "Visualizer feed"
          path "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };

    services.mpd-mpris.enable = true;

    # Auto-start mpd-discord-rpc if we wanted it, but let's stick to the core for now.
    # We also need to ensure the music directory exists.
  };
}
