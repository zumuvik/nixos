{ modules, lib, pkgs, ... }:{
  config = lib.mkIf modules.desktop.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium.fhs;
    };
  };
}
