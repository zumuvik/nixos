{ pkgs, username, inputs, ... }:

{
  imports = [
    ./modules/home
    ./modules/home/programs
  ];

   home = {
     inherit username;
     homeDirectory = "/home/${username}";
     stateVersion = "25.11";

    language.base = "ru_RU.UTF-8";

    sessionVariables = {
    };

     # Base packages for all hosts (CLI ONLY)
     packages = with pkgs; [
          micro
          jq
          btop
          inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
  };

  # Programs (core)
  programs.fish.enable = true;

  # Base settings
  nixpkgs.config.allowUnfree = true;
  dconf.enable = false;
}
