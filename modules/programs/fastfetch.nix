{ ... }: {
  programs.fastfetch = {
    enable = true;

    settings = {
      # ──────────────────────────────────────────────
      # Logo
      # ──────────────────────────────────────────────
      logo = {
        source = "NixOS";
        padding = {
          top = 1;
          right = 2;
        };
        color = {
          "1" = "blue";
          "2" = "cyan";
        };
      };

      # ──────────────────────────────────────────────
      # Display settings
      # ──────────────────────────────────────────────
      display = {
        separator = "  ";
        color = {
          keys = "34";
          title = "36";
        };
        key = {
          width = 16;
        };
      };

      # ──────────────────────────────────────────────
      # Modules
      # ──────────────────────────────────────────────
      modules = [
        {
          type = "title";
          format = "{user-name-colored}@{host-name-colored}";
        }
        {
          type = "separator";
          string = "─";
        }

        # ── Система ──
        {
          type = "os";
          key = "  OS";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "  Kernel";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "  Packages";
          keyColor = "yellow";
        }
        {
          type = "uptime";
          key = "  Uptime";
          keyColor = "yellow";
        }

        {
          type = "separator";
          string = "─";
        }

        # ── Окружение ──
        {
          type = "wm";
          key = "  WM";
          keyColor = "green";
        }
        {
          type = "terminal";
          key = "  Terminal";
          keyColor = "green";
        }
        {
          type = "shell";
          key = "  Shell";
          keyColor = "green";
        }
        {
          type = "terminalfont";
          key = "  Font";
          keyColor = "green";
        }

        {
          type = "separator";
          string = "─";
        }

        # ── Железо ──
        {
          type = "cpu";
          key = "  CPU";
          keyColor = "red";
        }
        {
          type = "gpu";
          key = "  GPU";
          keyColor = "red";
        }
        {
          type = "memory";
          key = "  RAM";
          keyColor = "red";
        }
        {
          type = "disk";
          key = "  Disk";
          keyColor = "red";
          folders = "/";
        }

        {
          type = "separator";
          string = "─";
        }

        # ── Сеть ──
        {
          type = "localip";
          key = "  IP";
          keyColor = "magenta";
          showIpv4 = true;
          compact = true;
        }
        {
          type = "display";
          key = "  Display";
          keyColor = "magenta";
        }

        "break"
        {
          type = "colors";
          paddingLeft = 4;
          symbol = "circle";
        }
      ];
    };
  };
}
