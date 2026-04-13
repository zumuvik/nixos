{ modules, lib, pkgs, inputs, ... }: {
  config = lib.mkIf modules.desktop.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
