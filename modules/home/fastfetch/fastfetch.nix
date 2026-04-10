# ──────────────────────────────────────────────
# Fastfetch configuration
# System information display tool
# ──────────────────────────────────────────────

{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    fastfetch
  ];

  home.file.".config/fastfetch/config.jsonc" = {
    force = true;
    text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "type": "builtin",
          "name": "NixOwOS"
        },
        "display": {
          "separator": " → "
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