{ config, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$terminal" = "ghostty";
    "$fileManager" = "Thunar";
    # $sD is defined in exec-once.nix

    bind = [
      # General
      "$mainMod, Return, exec, $terminal"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, Q, killactive,"
      "$mainMod, M, exit,"
      "$mainMod, V, togglefloating"
      "$mainMod SHIFT, R, exec, hyprctl reload"
      "$mainMod SHIFT, F, fullscreen, 0"
      "$mainMod CTRL, F, fullscreen, 1"
      "$mainMod, D, exec, pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"

      "$mainMod, space, togglefloating"
      # Config Picker
      "$mainMod, T, exec, bash ~/.config/hypr/scripts/config_picker.sh"


      "SUPER, Tab, workspace, e+1"


      "ALT, Tab, cyclenext,"
      "ALT, Tab, bringactivetotop,"

      # Window Navigation
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Workspaces
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move to workspace
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      # Screenshot
      "SUPER_SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
      "SHIFT, Print, exec, grim - | wl-copy"

      # Custom
      "$mainMod, P, exec, ~/.local/bin/nix-pkg-manage.sh"
      "SUPER, Caps_Lock, exec, ~/.local/bin/ayu-toggle.sh"
    ];


    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      ",XF86AudioNext, exec, playerctl next"
      ",XF86AudioPause, exec, playerctl play-pause"
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioPrev, exec, playerctl previous"
    ];


    bindd = [
    "$mainMod ALT, V, clipboard manager, exec, $sD/ClipManager.sh"
    ];
    binde = [
      # "$mainMod, mouse_down, workspace, e+1"
      # "$mainMod, mouse_up, workspace, e-1"
    ];
  };
}
