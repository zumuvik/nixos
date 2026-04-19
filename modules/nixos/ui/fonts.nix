{ config, lib, pkgs, ... }:

{
  options.my.ui.fonts.enable = lib.mkEnableOption "system fonts and nerd-fonts";

  config = lib.mkIf config.my.ui.fonts.enable {
    # ────────────────────────────────────────────────────────
    # Fonts configuration
    # ────────────────────────────────────────────────────────
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        # Nerd Fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.iosevka
        nerd-fonts.fantasque-sans-mono
        nerd-fonts.symbols-only
        nerd-fonts.fira-code
        
        # General Fonts
        inter
        jetbrains-mono
        noto-fonts-cjk-serif
        noto-fonts
        noto-fonts-color-emoji
        dejavu_fonts
        liberation_ttf

        # SF Pro Display (system font for lock screen)
        (pkgs.stdenv.mkDerivation {
          pname = "sf-pro-display";
          version = "1.0";
          dontUnpack = true;
          srcs = [
            (pkgs.fetchurl {
              name = "sf-pro-bold.otf";
              url = "https://raw.githubusercontent.com/MrVivekRajan/Hyprlock-Styles/main/Style-9/Fonts/SF%20Pro%20Display/SF%20Pro%20Display%20Bold.otf";
              sha256 = "0pqv47piw79jglk641dripxmdpcgzr673kgiws9y7mmy9l9cxd8w";
            })
            (pkgs.fetchurl {
              name = "sf-pro-regular.otf";
              url = "https://raw.githubusercontent.com/MrVivekRajan/Hyprlock-Styles/main/Style-9/Fonts/SF%20Pro%20Display/SF%20Pro%20Display%20Regular.otf";
              sha256 = "1kxj8hc9ckzgskwz78b9ijikbpy755808xzfllg9wbya01wd3d6z";
            })
          ];
          installPhase = ''
            mkdir -p $out/share/fonts/opentype
            for src in $srcs; do
              cp $src $out/share/fonts/opentype/
            done
          '';
        })
      ];
    };
  };
}