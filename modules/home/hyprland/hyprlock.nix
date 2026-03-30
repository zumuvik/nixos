{ config, pkgs, username, ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = false;
      };

      background = [
        {
          monitor = "";
          path = "/home/${username}/.config/hypr/hyprlock.png";
          blur_passes = 2;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(100, 114, 125, 0.4)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          font_family = "JetBrains Mono Bold";
          placeholder_text = ''<i><span foreground="##ffffff99">Enter Pass</span></i>'';
          hide_input = false;
          position = "0, -225";
          halign = "center";
          valign = "center";
        }
      ];

      image = [
        {
          monitor = "";
          path = "/home/${username}/.config/hypr/zumuvik.png";
          border_color = "0xffdddddd";
          border_size = 0;
          size = 120;
          rounding = -1;
          rotate = 0;
          reload_time = -1;
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 130;
          font_family = "JetBrains Mono Bold";
          position = "0, 240";
          halign = "center";
          valign = "center";
        }
        # Day-Month-Date
        {
          monitor = "";
          text = ''cmd[update:1000] echo -e "$(date +"%A, %d %B")"'';
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 30;
          font_family = "JetBrains Mono Bold";
          position = "0, 105";
          halign = "center";
          valign = "center";
        }
        # User
        {
          monitor = "";
          text = "Hi, $USER";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          font_family = "JetBrains Mono Bold";
          position = "0, -130";
          halign = "center";
          valign = "center";
        }
        # Current Song
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(/home/${username}/.config/hypr/scripts/songdetail.sh)"'';
          color = "rgba(255, 255, 255, 0.7)";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font, JetBrains Mono Bold";
          position = "0, 60";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };

  home.packages = with pkgs; [
    playerctl
  ];
}
