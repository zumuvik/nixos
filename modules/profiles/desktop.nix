{ config, lib, pkgs, ... }:

{
  options.my.profiles.desktop.enable = lib.mkEnableOption "Desktop Profile";

  config = lib.mkIf config.my.profiles.desktop.enable {
    # ────────────────────────────────────────────────────────
    # Desktop Profile Settings
    # ────────────────────────────────────────────────────────

    # UI Components
    my.ui.greetd.enable = lib.mkDefault true;
    my.ui.fonts.enable = lib.mkDefault true;
    my.ui.common.enable = lib.mkDefault true;

    # Misc
    programs.nix-ld.enable = true;

    # Throne (VLESS client)
    programs.throne = {
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };

    # Environment
    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "gtk";
      GTK_THEME = "Adwaita-dark";
    };
  };
}
