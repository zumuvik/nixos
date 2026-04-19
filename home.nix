{ pkgs, username, inputs, ... }:

{
  imports = [
    ./modules/home
    ./modules/programs
  ];

   home = {
     inherit username;
     homeDirectory = "/home/${username}";
     stateVersion = "25.11";

    language.base = "ru_RU.UTF-8";

    sessionVariables = {
      TERMINAL = "ghostty";
    };

     # Base packages for all hosts
     packages = with pkgs; [
         micro
         ghostty
         jq
         btop
         inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
       ];
  };

  # Terminal settings
  xdg.terminal-exec = {
    enable = true;
    package = pkgs.ghostty;
  };
  
  # Programs (core)
  programs.fish.enable = true;

  # Base settings
  nixpkgs.config.allowUnfree = true;
  dconf.enable = false;
}
