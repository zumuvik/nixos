{ my, lib, pkgs, ... }: {
  config = lib.mkIf my.profiles.desktop.enable {
    home.packages = [ pkgs.opencode ];
  };
}
