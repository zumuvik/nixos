{ config, lib, pkgs, ... }:

{
  options.my.ui.plymouth.enable = lib.mkEnableOption "Plymouth animated boot splash";

  config = lib.mkIf config.my.ui.plymouth.enable {
    boot.plymouth = {
      enable = true;
      theme = "rings";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    boot.kernelParams = lib.mkAfter [
      "splash"
      "vt.global_cursor_default=0"
      "plymouth.use-simpledrm"
    ];

    boot.initrd.verbose = lib.mkForce false;
    boot.consoleLogLevel = lib.mkDefault 0;
  };
}
