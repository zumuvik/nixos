{ modules, lib, inputs, ... }: {
  imports = [ inputs.ags.homeManagerModules.default ];
  config = lib.mkIf modules.desktop.enable {
    programs.ags.enable = true;
  };
}
