{ my, lib, ... }: {
  config = lib.mkIf my.profiles.desktop.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [ "ru" "en-US" ];
    };
  };
}
