{ modules, lib, pkgs, ... }: {
  config = lib.mkIf modules.desktop.enable {
    home.packages = [ pkgs.opencode ];
  };
}
