{ lib, pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Fonts (общее для всех)
  # ────────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.fantasque-sans-mono
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

      # Nothing Dot (Ndot57 - from nothingfont repo)
      # Временно отключено - нет доступа к сети
      # (pkgs.stdenv.mkDerivation {
      #   pname = "nothing-dot";
      #   version = "1.0";
      #   dontUnpack = true;
      #   srcs = [
      #     (pkgs.fetchurl {
      #       name = "ndot57.otf";
      #       url = "https://raw.githubusercontent.com/xeji01/nothingfont/main/fonts/Ndot57-Regular.otf";
      #       sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
      #     })
      #   ];
      #   installPhase = ''
      #     mkdir -p $out/share/fonts/opentype
      #     cp ndot57.otf $out/share/fonts/opentype/
      #   '';
      # })
    ];
  };
}