{ config, lib, pkgs, ... }:
let
  microSettings = {
    autosuccess = true;
    clipboard = "external";
    colorscheme = "default";
    cursorline = true;
    mkparents = true;
    mouse = true;
    rmtrailingws = true;
    savecursor = true;
    saveundo = true;
    scrollbar = false;
    statusline = true;
    tabsize = 4;
    tabstospaces = true;
    softwrap = true;
    sucmd = "sudo";

    filemanager.openonstart = true;
    filemanager.width = 20;
  };
in
{
  programs.micro = {
    enable = true;
    settings = microSettings;
  };

  home.activation.installMicroPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.micro}/bin/micro -plugin install fzf snippets pony misspell crystal editorconfig go jump autofmt detectindent palettero monokai-dark runit fish bookmark joinLines manipulator aspell wakatime bounce quickfix jlabbrev wc gotham-colors cheat nordcolors quoter
  '';
}
