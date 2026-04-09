{ config, pkgs, lib, ... }:

let
  username = config.home.username;
  homeDir = config.home.homeDirectory;

  # ──────────────────────────────────────────────
  # Скрипты waybar
  # ──────────────────────────────────────────────

  cavaScript = pkgs.writeShellScriptBin "waybar-cava" ''
    #!/usr/bin/env bash
    ${pkgs.cava}/bin/cava -p <(cat << 'EOF'
    [general]
    bars = 12
    framerate = 30

    [input]
    method = pulse

    [output]
    method = raw
    raw_target = /dev/stdout
    data_format = ascii
    ascii_max_range = 8
    EOF
    ) | while read -r line; do
        out=""
        for c in $(echo "$line" | sed 's/./& /g'); do
            level=$(printf "%d" "'$c")
            bars=$((level - 48))
            out+="$(printf '%*s' "$bars" | tr ' ' '█') "
        done
        echo "$out"
    done
  '';

  # ──────────────────────────────────────────────
  # Основные модули waybar
  # ──────────────────────────────────────────────

  modules = {
    temperature = {
      interval = 10;
      tooltip = true;
      hwmon-path = [
        "/sys/class/hwmon/hwmon1/temp1_input"
        "/sys/class/thermal/thermal_zone0/temp"
      ];
      critical-threshold = 82;
      format-critical = "{temperatureC}°C {icon}";
      format = "{temperatureC}°C {icon}";
      format-icons = ["󰈸"];
      on-click-right = "$HOME/.config/hypr/scripts/WaybarScripts.sh --nvtop";
    };

    backlight = {
      interval = 2;
      align = 0;
      rotate = 0;
      format-icons = [" " " " " " "󰃝 " "󰃞 " "󰃟 " "󰃠 "];
      format = "{icon}";
      tooltip-format = "backlight {percent}%";
      icon-size = 10;
      on-scroll-up = "$HOME/.config/hypr/scripts/Brightness.sh --inc";
      on-scroll-down = "$HOME/.config/hypr/scripts/Brightness.sh --dec";
      smooth-scrolling-threshold = 1;
    };

    battery = {
      format = "{capacity}% ";
      format-charging = "{capacity}% ";
    };

    clock = {
      interval = 1;
      format = "{:%H:%M}";
      format-alt = "{:%d.%m.%Y}";
      tooltip-format = "{:%A, %d %B %Y\n%H:%M:%S}";
    };

    pulseaudio = {
      format = "  {volume}%";
      format-muted = " muted";
      scroll-step = 5;
      on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
    };

    "pulseaudio#microphone" = {
      format = "{format_source}";
      format-source = " {volume}%";
      format-source-muted = "";
      on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +5%";
      on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -5%";
      scroll-step = 5;
    };

    wireplumber = {
      format = "  {volume}%";
      format-muted = " muted";
      scroll-step = 5;
      on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
    };

    "custom/headset" = {
      format = "{}";
      return-type = "json";
      interval = 30;
      exec = "~/.local/bin/headset-battery.sh";
      tooltip = false;
    };

    "custom/mic" = {
      format = "{}";
      exec = "pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes && echo '' || echo ''";
      interval = 1;
      on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    };

    memory = {
      interval = 10;
      format = " {used:0.1f}G";
      tooltip-format = "{used}/{total}";
    };

    cpu = {
      interval = 10;
      format = "󰻠 {usage}%";
      tooltip-format = "{usage}%";
    };

    disk = {
      interval = 30;
      format = "󰋊 {percentage_used}%";
      tooltip-format = "{used}/{total}";
    };

    tray = {
      icon-size = 20;
      spacing = 8;
    };

    "wlr/taskbar" = {
      format = "{icon}";
      icon-size = 20;
      spacing = 8;
      tooltip-format = "{title}";
      on-click = "activate";
      on-click-right = "close";
    };

    "hyprland/workspaces" = {
      active-only = false;
      all-outputs = true;
      format = "{icon}";
      show-special = false;
      on-click = "activate";
      on-scroll-up = "hyprctl dispatch workspace e+1";
      on-scroll-down = "hyprctl dispatch workspace e-1";
      persistent-workspaces = {
        "*" = 5;
      };
      format-icons = {
        active = "";
        default = "";
      };
    };

    network = {
      format = "󰤥 ";
      format-wifi = "󰤨 {essid}";
      format-ethernet = "󰌐 ";
      format-disconnected = "󰌷 ";
      tooltip-format = "{ipv4}";
      on-click = "$HOME/.config/hypr/scripts/WaybarScripts.sh --network";
    };

    bluetooth = {
      format = "󰂯 ";
      format-connected = "󰂯 {num_connections}";
      tooltip-format = "{device_alias}";
      on-click = "$HOME/.config/hypr/scripts/WaybarScripts.sh --bluetooth";
    };

    "power-profiles-daemon" = {
      format = "{icon}";
      tooltip-format = "Power Profile:\n{profile}";
      tooltip = true;
      format-icons = {
        default = "󰓅";
        performance = "󰓅";
        balanced = "⚡";
        "power-saver" = "🔋";
      };
    };

    "keyboard-state" = {
      numlock = true;
      capslock = true;
      format = "{name} {icon}";
      format-icons = {
        locked = "󰒌 ";
        unlocked = " ";
      };
    };

    # ──────────────────────────────────────────────
    # Custom модули
    # ──────────────────────────────────────────────

    "custom/power" = {
      format = "⏻";
      on-click = "niri msg action quit";
      tooltip-format = "Power Menu";
    };

    "custom/lock" = {
      format = "🔒";
      on-click = "hyprlock";
      tooltip-format = "Lock Screen";
    };

    "custom/logout" = {
      format = "🚪";
      on-click = "hyprctl dispatch exit";
      tooltip-format = "Logout";
    };

    "custom/reboot" = {
      format = "🔄";
      on-click = "systemctl reboot";
      tooltip-format = "Reboot";
    };

    "custom/quit" = {
      format = "❌";
      on-click = "hyprctl dispatch exit";
      tooltip-format = "Quit";
    };

    "custom/menu" = {
      format = "";
      tooltip-format = "Menu";
    };

    "custom/light_dark" = {
      format = "󰔎 ";
      on-click = "$HOME/.config/hypr/scripts/WaybarScripts.sh --theme";
      tooltip-format = "Toggle Theme";
    };

    "custom/file_manager" = {
      format = " ";
      on-click = "$HOME/.config/hypr/scripts/WaybarScripts.sh --files";
      tooltip-format = "File Manager";
    };

    "custom/tty" = {
      format = " ";
      on-click = "$HOME/.config/hypr/scripts/WaybarScripts.sh --term";
      tooltip-format = "Launch Terminal";
    };

    "custom/browser" = {
      format = " ";
      on-click = "xdg-open https://";
      tooltip-format = "Launch Browser";
    };

    "custom/settings" = {
      format = " ";
      on-click = "$HOME/.config/hypr/scripts/Kool_Quick_Settings.sh";
      tooltip-format = "Settings";
    };

    "custom/cycle_wall" = {
      format = " ";
      on-click = "$HOME/.config/hypr/UserScripts/WallpaperSelect.sh";
      on-click-right = "$HOME/.config/hypr/UserScripts/WallpaperRandom.sh";
      tooltip-format = "Wallpaper";
    };

    "custom/hint" = {
      format = "󰺁 HINT!";
      on-click = "$HOME/.config/hypr/scripts/KeyHints.sh";
      tooltip-format = "Key Hints";
    };

    "custom/dot_update" = {
      format = " 󰁈 ";
      on-click = "$HOME/.config/hypr/scripts/KooLsDotsUpdate.sh";
      tooltip-format = "Check Updates";
    };

    "custom/hypridle" = {
      format = "󱫗 ";
      return-type = "json";
      escape = true;
      exec-on-event = true;
      interval = 60;
      exec = "$HOME/.config/hypr/scripts/Hypridle.sh status";
      on-click = "$HOME/.config/hypr/scripts/Hypridle.sh toggle";
    };

    "custom/keyboard" = {
      exec = "$HOME/.config/hypr/scripts/KeyboardLayout.sh status";
      interval = 1;
      format = " {}";
      on-click = "$HOME/.config/hypr/scripts/KeyboardLayout.sh switch";
    };

    "custom/swaync" = {
      format = "";
      exec = "$HOME/.config/hypr/scripts/SwayNC.sh";
      on-click = "swaync-client -t -sw";
      tooltip-format = "Notifications";
    };

    "custom/cava_mviz" = {
      format = "{}";
      exec = "~/.config/waybar/scripts/cava.sh";
      return-type = "plain";
      interval = 0.03;
    };
  };

  # ──────────────────────────────────────────────
  # CSS стили (Black & White Monochrome)
  # ──────────────────────────────────────────────

  style = ''
    /* ---- 💫 Black & White Glass Edition 💫 ---- */
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-weight: 800;
      min-height: 0;
      font-size: 14px;
      font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
      padding: 0;
      margin: 0;
      border: none;
      color: #000000;
    }

    window#waybar {
      background: rgba(255, 255, 255, 0.1);
      border-radius: 14px;
    }

    /* Тултипы */
    tooltip {
      background: rgba(255, 255, 255, 0.9);
      border: 1px solid rgba(0, 0, 0, 0.2);
      border-radius: 10px;
      padding: 5px 10px;
    }

    tooltip label {
      color: #000000;
    }

    /* Группы модулей */
    .modules-left,
    .modules-center,
    .modules-right {
      background: rgba(255, 255, 255, 0.15);
      border-radius: 12px;
      border: 1px solid rgba(255, 255, 255, 0.25);
      padding: 2px 6px;
      margin: 4px;
    }

    /* Workspaces / Taskbar */
    #workspaces button,
    #taskbar button {
      color: #000000;
      background: transparent;
      border-radius: 8px;
      padding: 0 8px;
      margin: 0 2px;
      opacity: 0.6;
      transition: all 0.2s ease;
    }

    #workspaces button:hover,
    #taskbar button:hover {
      background: rgba(255, 255, 255, 0.2);
      opacity: 1;
    }

    #workspaces button.active,
    #taskbar button.active {
      color: #000000;
      background: rgba(255, 255, 255, 0.35);
      opacity: 1;
    }

    #workspaces button.urgent {
      background: #ff0000;
      color: #ffffff;
      opacity: 1;
    }

    /* Общий стиль для всех модулей */
    #clock,
    #wireplumber,
    #pulseaudio,
    #custom-headset,
    #custom-cava_mviz,
    #memory,
    #cpu,
    #tray,
    #custom-power {
      color: #000000;
      background: rgba(255, 255, 255, 0.15);
      border-radius: 10px;
      padding: 0 12px;
      margin: 0 4px;
      transition: all 0.2s ease;
    }

    /* Специальные состояния */
    #pulseaudio.muted,
    #wireplumber.muted {
      color: #ff0000;
    }

    #tray {
      background: transparent;
    }

    #tray menu {
      background: rgba(255, 255, 255, 0.95);
      color: #000000;
      border: 1px solid rgba(0, 0, 0, 0.15);
      border-radius: 8px;
    }

    /* Слайдер */
    #pulseaudio-slider highlight {
      background: #000000;
    }

    #pulseaudio-slider trough {
      background: rgba(0, 0, 0, 0.1);
    }
  '';

in

{
  home.packages = with pkgs; [
    waybar
    cava
  ];

  # Копируем скрипт cava.sh для использования в конфиге
  home.file.".config/waybar/scripts/cava.sh" = {
    source = "${cavaScript}/bin/waybar-cava";
    executable = true;
    force = true;
  };

  # Копируем скрипты в .local/bin
  home.file.".local/bin/headset-battery.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Placeholder для скрипта батареи наушников
      echo '{"text": "🎧", "tooltip": "Headset Battery"}'
    '';
    executable = true;
    force = true;
  };

  # ──────────────────────────────────────────────
  # Конфигурация waybar через Home Manager
  # ──────────────────────────────────────────────

  programs.waybar = {
    enable = true;
    settings = [
      # Верхняя панель (TOP)
      {
        name = "topbar";
        layer = "top";
        position = "top";
        exclusive = true;
        spacing = 4;
        gtk-layer-shell = true;
        reload_style_on_change = true;

        modules-left = ["custom/power"];
        modules-center = ["clock"];
        modules-right = [
          "wireplumber"
          "pulseaudio#microphone"
          "custom/headset"
        ];

        inherit (modules) clock wireplumber pulseaudio;
        "pulseaudio#microphone" = modules."pulseaudio#microphone";
        inherit (modules) "custom/headset";
      }

      # Нижняя панель (BOTTOM)
      {
        name = "bottombar";
        layer = "top";
        position = "bottom";
        height = 42;
        exclusive = true;
        spacing = 4;
        gtk-layer-shell = true;
        reload_style_on_change = true;

        modules-left = ["custom/cava_mviz" "hyprland/workspaces" "memory"];
        modules-center = ["wlr/taskbar"];
        modules-right = ["tray"];

        inherit (modules) "custom/cava_mviz" "hyprland/workspaces" memory tray "wlr/taskbar";
      }
    ];

    style = style;
  };
}
