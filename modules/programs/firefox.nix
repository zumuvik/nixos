{ modules, lib, ... }: {
  config = lib.mkIf modules.desktop.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [ "ru" "en-US" ];
    };
  };
}
