{ config, lib, pkgs, my, ... }:

let
  cfg = my.ui.mpd;
in
{
  config = lib.mkIf cfg.enable {

    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };

      settings = {
        # ── Подключение ───────────────────────────────────────────────────────
        mpd_host                              = "127.0.0.1";
        mpd_port                             = 6600;

        # ── Визуализатор ──────────────────────────────────────────────────────
        visualizer_data_source               = "/tmp/mpd.fifo";
        visualizer_output_name               = "visualizer_feed";
        visualizer_in_stereo                 = "yes";
        visualizer_type                      = "spectrum";
        visualizer_look                      = "●▮";
        visualizer_color                     = "cyan,blue,magenta";

        # ── Тексты песен ──────────────────────────────────────────────────────
        lyrics_directory                     = "~/.local/share/ncmpcpp/lyrics";
        follow_now_playing_lyrics            = "yes";
        fetch_lyrics_for_current_song_in_background = "yes";
        store_lyrics_in_song_dir             = "no";

        # ── Интерфейс ─────────────────────────────────────────────────────────
        playlist_display_mode                = "columns";
        browser_display_mode                 = "columns";
        search_engine_display_mode           = "columns";
        centered_cursor                      = "yes";
        cyclic_scrolling                     = "yes";
        mouse_support                        = "no";
        enable_window_title                  = "yes";
        external_editor                      = "micro";
        use_console_editor                   = "yes";

        # ── Внешний вид ───────────────────────────────────────────────────────
        colors_enabled                       = "yes";
        header_visibility                    = "no";
        statusbar_visibility                 = "yes";
        titles_visibility                    = "no";
        progressbar_look                     = "━━━";
        progressbar_elapsed_color            = "cyan";
        progressbar_color                    = "black";

        # ── Формат плейлиста (колонки) ────────────────────────────────────────
        song_columns_list_format             = "(20)[cyan]{a} (30)[white]{t} (30)[magenta]{b} (7f)[blue]{l}";
        song_library_format                  = "{%a - }{%t}|{%f}";
        now_playing_prefix                   = "$b$2";
        now_playing_suffix                   = "$/b";

        # ── Поиск ─────────────────────────────────────────────────────────────
        default_find_mode                    = "wrapped";
        incremental_seeking                  = "yes";
        seek_time                            = 5;
      };

      bindings = [
        # Навигация
        { key = "j"; command = "scroll_down"; }
        { key = "k"; command = "scroll_up"; }
        { key = "J"; command = "move_sort_order_down"; }
        { key = "K"; command = "move_sort_order_up"; }
        { key = "h"; command = "previous_column"; }
        { key = "l"; command = "next_column"; }
        { key = "g"; command = "move_home"; }
        { key = "G"; command = "move_end"; }
        { key = "ctrl-u"; command = "page_up"; }
        { key = "ctrl-d"; command = "page_down"; }

        # Воспроизведение
        { key = "u"; command = "update_database"; }
        { key = "i"; command = "show_song_info"; }
        { key = "y"; command = "save_tag_changes"; }
        { key = "U"; command = "toggle_playing_song_centering"; }
        { key = ";"; command = "seek_forward"; }
        { key = ","; command = "seek_backward"; }

        # Вкладки
        { key = "1"; command = "show_playlist"; }
        { key = "2"; command = "show_browser"; }
        { key = "3"; command = "show_search_engine"; }
        { key = "4"; command = "show_media_library"; }
        { key = "5"; command = "show_tag_editor"; }
        { key = "6"; command = "show_outputs"; }
        { key = "7"; command = "show_visualizer"; }
        { key = "8"; command = "show_lyrics"; }
      ];
    };

    home.activation.createNcmpcppDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.local/share/ncmpcpp/lyrics"
    '';
  };
}
