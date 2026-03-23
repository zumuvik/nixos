{ pkgs, inputs, ... }:
{
  imports = [
    inputs.ags.homeManagerModules.default
    inputs.nixvim.homeModules.nixvim
    ./modules/home
  ];

  # ────────────────────────────────────────────────────────
  # Home Manager Base Settings
  # ────────────────────────────────────────────────────────
  home.username = "zumuvik";
  home.homeDirectory = "/home/zumuvik";
  home.stateVersion = "25.11";

  # ────────────────────────────────────────────────────────
  # Environment Variables
  # ────────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.language = {
    base = "ru_RU.UTF-8";
  };

  # ────────────────────────────────────────────────────────
  # Theme & Appearance
  # ────────────────────────────────────────────────────────
  dconf.enable = false;

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
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

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
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

    # Communication
    discord

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
}
