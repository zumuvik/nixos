{ pkgs, inputs, ... }:
{
  imports = [
    inputs.ags.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim  
  ];


  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    
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

    
    colorschemes.gruvbox = {
      enable = true;
      settings.contrast = "hard";
    };

    # 
    globals.mapleader = " ";

    
    keymaps = [
      { mode = "n"; key = "<leader>w"; action = "<cmd>w<CR>"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>q<CR>"; }
    ];

  
    plugins = {
      lualine.enable = true;
      treesitter.enable = true;
      neo-tree.enable = true;
      telescope.enable = true;
      which-key.enable = true;

      # LSP
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
  };

  home.username = "zumuvik";
  home.homeDirectory = "/home/zumuvik";

  home.packages = with pkgs; [
    
    osu-lazer-bin
    fastfetch kitty zip unzip git
    mako swww waypaper waybar rofi
    grim slurp wl-clipboard libnotify
    pavucontrol nix-search
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.tumbler
    mpv mpvpaper spotube cava playerctl
    discord vesktop firefox
    scrcpy android-tools brightnessctl sassc
    galaxy-buds-client micro
    bibata-cursors
    nwg-look 
    inputs.ayugram-desktop.packages.${pkgs.system}.default
  ];

  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_6_0
      accountsservice
    ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-pipewire-audio-capture
      wlrobs
      obs-vkcapture
    ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";   
    VISUAL = "nvim";
  };



  home.language = {
    base = "ru_RU.UTF-8";
  };

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

  home.stateVersion = "25.11";
}
