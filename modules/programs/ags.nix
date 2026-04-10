{ pkgs, ... }:{
    programs.ags = {
      enable = true;
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk_6_0
        accountsservice
      ];
    };
}
