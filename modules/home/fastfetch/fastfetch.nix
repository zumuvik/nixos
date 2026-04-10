# ──────────────────────────────────────────────
# Fastfetch configuration
# System information display tool
# ──────────────────────────────────────────────

{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    fastfetch
  ];

  home.file.".config/fastfetch/config.jsonc" = {
    text = ''
      {
        "logo": {
          "source": "~/Pictures/fastfetch-logo.txt",
          "padding": {
            "right": 1
          }
        },
        "display": {
          "separator": " → ",
          "binaryPrefix": "si",
          "percentType": "bar"
        },
        "modules": [
          "title",
          "separator",
          "os",
          "host",
          "kernel",
          "uptime",
          "shell",
          "resolution",
          "wm",
          "wm-theme",
          "terminal",
          "cpu",
          "gpu",
          "memory",
          "swap",
          "disk",
          "colors"
        ]
      }
    '';
  };

  # ASCII art logo for fastfetch
  home.file."Pictures/fastfetch-logo.txt" = {
    text = ''
         ╔══════════════════════════════════════════════╗
         ║                                              ║
         ║            ░▒▓█ FASTFETCH █▓▒░              ║
         ║                                              ║
         ║       ╱────────────────────────────╲        ║
         ║      │  System Information Display  │       ║
         ║      │    Blazingly Fast & Efficient │      ║
         ║       ╲────────────────────────────╱        ║
         ║                                              ║
         ║    ⚡ Lightweight • Colorful • Modern ⚡   ║
         ║                                              ║
         ╚══════════════════════════════════════════════╝
    '';
  };
}

