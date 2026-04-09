{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Suppress greeting
      set fish_greeting

      # Ensure wrappers (setuid binaries like sudo) are found first
      set -gx PATH /run/wrappers/bin $PATH

      # nix-index database for package search and completions
      if test -f /etc/profile.d/nix-index.sh
        source /etc/profile.d/nix-index.sh
      end

      # SSH aliases
      alias lp='ssh 192.168.1.80'
      alias sr='ssh 192.168.1.145'
    '';
  };

  home.packages = with pkgs; [
    fish
    nix-index
  ];
}
