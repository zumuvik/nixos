{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        modules-left = ["hyprland/workspaces"];
        modules-center = ["clock"];
        modules-right = ["pulseaudio" "network" "cpu" "memory" "tray"];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%A, %d %B %Y}";
          on-click = "foot -e tty-clock -s -c -C 4 -b";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-icons = ["󰕿" "󰖀" "󰕾"];
          on-click = "pavucontrol";
        };

        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰌘";
          format-disconnected = "󰌙";
          on-click = "nm-connection-editor";
        };

        cpu = {
          format = "󰻠 {usage}%";
        };

        memory = {
          format = "󰍛 {percentage}%";
        };

        tray = {
          spacing = 10;
        };
      }
    ];

    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0.7);
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: #ffffff;
      }

      #workspaces button.active {
        background: rgba(255, 255, 255, 0.2);
      }

      #clock, #pulseaudio, #network, #cpu, #memory, #tray {
        padding: 0 10px;
      }
    '';
  };
}
