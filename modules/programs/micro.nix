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

  xdg.configFile."micro/init.lua".text = ''
    local micro = import("micro")
    local config = import("config")

    -- Close empty buffer on startup if filemanager is enabled
    micro.Init(function()
      if config.GetGlobalOption("filemanager.openonstart") then
        -- Wait a moment for plugins to load
        local function closeEmpty()
           for _, pane in ipairs(micro.Panes) do
             local buf = pane.Buf
             if buf.Path == "" and buf:Modified() == false then
               pane:Close()
             end
           end
        end
        micro.AddTimer(100):Start(closeEmpty)
      end
    end)
  '';
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
