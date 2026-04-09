{ ... }:
let
  microSettings = {
    autosuccess = true;
    clipboard = "terminal";
    colorscheme = "catppuccin-macchiato";
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
    linter = true;
    autoclose = true;
    lsp.autocomplete = true;
    lsp.formatOnSave = true;
  };
in
{
  programs.micro = {
    enable = true;
    settings = microSettings;
  };
}
