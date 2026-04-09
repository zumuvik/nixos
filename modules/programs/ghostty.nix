{ ... }: {
  programs.ghostty = {
    enable = true;
    settings = {
      shell-integration = "fish";

      # Theme & Colors (LiquidCarbon-like)
      background = "000000";
      foreground = "dddddd";
      background-opacity = 0.85;
      background-blur = true;

      # Font
      font-family = "FantasqueSansM Nerd Font Mono";
      font-size = 13;
      font-style = "bold";

      # Cursor
      cursor-style = "bar";
      cursor-color = "ffffff";
      cursor-text = "000000";
      cursor-style-blink = true;

      # Window
      window-padding-x = 12;
      window-padding-y = 12;
      window-decoration = false;
      gtk-titlebar = false;

      # Scrollback
      scrollback-limit = 5000;
      mouse-scroll-multiplier = 3;

      # Misc
      confirm-close-surface = false;
      bell-features = "";
      auto-update = "off";
    };
  };
}
