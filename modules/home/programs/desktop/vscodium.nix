{ my, lib, pkgs, ... }:{
  config = lib.mkIf my.profiles.desktop.enable {
    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium.fhs;
    };
  };
}
