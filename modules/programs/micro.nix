{ config, lib, pkgs, ... }:
let
  cfg = config.programs.micro;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.micro = {
    enable = lib.mkEnableOption "micro, a terminal-based text editor";
    package = lib.mkPackageOption pkgs "micro" { nullable = true; };
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        Configuration written to `$XDG_CONFIG_HOME/micro/settings.json`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."micro/settings.json".source = jsonFormat.generate "micro-settings" cfg.settings;
  };
}
