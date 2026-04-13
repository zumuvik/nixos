{ modules, lib, inputs, ... }: 

{
  imports = [ inputs.nixcord.homeModules.nixcord ];
  config = lib.mkIf modules.desktop.enable {
    programs.nixcord = {
      enable = true;
      vesktop.enable = true;

      config = {
        useQuickCss = true;
        themeLinks = [
          "https://raw.githubusercontent.com/refact0r/midnight-discord/master/midnight.css"
        ];
        frameless = true;

        plugins = {
          fakeNitro.enable = true;
          shikiCodeblocks.enable = true;
          noTypingAnimation.enable = true;
        };
      };
    };
  };
}
