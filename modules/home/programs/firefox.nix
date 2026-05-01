{ my, lib, ... }: {
  config = lib.mkIf my.profiles.desktop.enable {
    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
      languagePacks = [ "ru" "en-US" ];
    };
  };
}
