{ config, lib, pkgs, my, ... }:

{
  config = lib.mkIf my.ui.mpd.enable {
    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
      settings = {
        # Visualizer
        visualizer_data_source = "/tmp/mpd.fifo";
        visualizer_output_name = "visualizer_feed";
        visualizer_in_stereo = "yes";
        visualizer_type = "spectrum";
        visualizer_look = "●▮";
        visualizer_color = "cyan,blue,magenta";

        # Lyrics
        lyrics_directory = "~/.local/share/ncmpcpp/lyrics";
        follow_now_playing_lyrics = "yes";
        fetch_lyrics_for_current_song_in_background = "yes";
        store_lyrics_in_song_dir = "no";

        # General
        playlist_display_mode = "columns";
        centered_cursor = "yes";
        enable_window_title = "yes";
        external_editor = "micro";
        
        # Appearance
        colors_enabled = "yes";
        header_visibility = "no";
        statusbar_visibility = "yes";
        titles_visibility = "no";
        progressbar_look = "━━━";
        progressbar_elapsed_color = "cyan";
        progressbar_color = "black";
        
        # Columns format
        song_columns_list_format = "(20) [cyan]{a} (30) [white]{t} (30) [magenta]{b} (7f) [blue]{l}";
      };
    };

    home.activation.createNcmpcppLyricsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.local/share/ncmpcpp/lyrics
    '';
  };
}
