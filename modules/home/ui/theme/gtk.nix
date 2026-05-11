{ pkgs, config, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "adw-gtk3-dark";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = config.gtk.theme;
  };

  xdg.configFile."gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-theme-name=adw-gtk3-dark
      gtk-application-prefer-dark-theme=1
    '';
  };

  home.packages = with pkgs; [
    gnome-themes-extra
    adwaita-icon-theme
    dconf
  ];

  # Force dark mode for some apps via environment variables
  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
    COLORTERM = "truecolor";
  };

  # Set dconf settings for dark mode
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
