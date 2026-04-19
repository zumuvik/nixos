{ my, lib, pkgs, inputs, ... }: {
  config = lib.mkIf my.profiles.desktop.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
