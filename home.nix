{ pkgs, inputs, username, ... }:

{
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.ags.homeManagerModules.default
    inputs.nixvim.homeModules.nixvim
    ./modules/home
  ];

  # ────────────────────────────────────────────────────────
  # Home Manager Base Settings
  # ────────────────────────────────────────────────────────
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  home.language = {
    base = "ru_RU.UTF-8";
  };

  dconf.enable = false;

  # ────────────────────────────────────────────────────────
  # Hypridle (Screen lock/sleep/hibernate)
  # ────────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
        {
          timeout = 1200;
          on-timeout = "systemctl hibernate";
        }
      ];
    };
  };

  # ────────────────────────────────────────────────────────
  # Neovim (nixvim)
  # ────────────────────────────────────────────────────────
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      ignorecase = true;
      smartcase = true;
      cursorline = true;
      termguicolors = true;
      signcolumn = "yes";
      mouse = "a";
      clipboard = "unnamedplus";
      undofile = true;
      swapfile = false;
    };

    globals.mapleader = " ";

    keymaps = [
      { mode = "n"; key = "<leader>w"; action = "<cmd>w<CR>"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>q<CR>"; }
    ];

    colorschemes.gruvbox = {
      enable = true;
      settings.contrast = "hard";
    };

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      treesitter.enable = true;
      neo-tree.enable = true;
      telescope.enable = true;
      which-key.enable = true;

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          bashls.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
      };
    };

    viAlias = true;
    vimAlias = true;
  };

  # ────────────────────────────────────────────────────────
  # VSCode
  # ────────────────────────────────────────────────────────
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
  };

  # ────────────────────────────────────────────────────────
  # AGS (System tray/widgets)
  # ────────────────────────────────────────────────────────
  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_6_0
      accountsservice
    ];
  };

  # ────────────────────────────────────────────────────────
  # OBS Studio
  # ────────────────────────────────────────────────────────
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-pipewire-audio-capture
      wlrobs
      obs-vkcapture
    ];
  };

  # ────────────────────────────────────────────────────────
  # NixCord (Discord)
  # ────────────────────────────────────────────────────────
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;

    config = {
      useQuickCss = true;
      themeLinks = [
        "https://raw.githubusercontent.com/refact0r/midnight-discord/master/midnight.css"
      ];
      frameless = true;

      plugins = {
        fakeNitro.enable = true;
        shikiCodeblocks.enable = true;
        noTypingAnimation.enable = true;
      };
    };
  };

  # ────────────────────────────────────────────────────────
  # Core Packages
  # ────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Desktop Environment
    waybar
    rofi
    waypaper
    nwg-look
    nwg-displays

    # Media
    mpv
    mpvpaper
    cava
    firefox

    # Utilities
    micro
    kitty
    thunar
    thunar-archive-plugin
    tumbler
    scrcpy
    android-tools
    remmina
    pavucontrol
    libnotify
    cliphist
    bibata-cursors
    sassc
    galaxy-buds-client
    virt-manager
    qemu
    libvirt
    virt-viewer

    # Custom packages from inputs
    inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home.file.".config/hypr/hyprlock.conf".source = ./modules/home/hyprland/hyprlock.conf;
}
