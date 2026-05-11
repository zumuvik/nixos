{ my, lib, inputs, ... }: {
  imports = [ inputs.ags.homeManagerModules.default ];
  config = lib.mkIf my.profiles.desktop.enable {
    programs.ags.enable = true;
  };
}
