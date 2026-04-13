{ modules, lib, pkgs, ... }: {
  config = lib.mkIf modules.desktop.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      package = pkgs.ghostty;
      
      settings = {
        theme = "GruvboxDarkHard";
        font-family = "JetBrainsMono Nerd Font";
        font-size = 13;
        window-decoration = false;
        background-opacity = 0.9;
        confirm-close-surface = false;
      };
    };
  };
}
