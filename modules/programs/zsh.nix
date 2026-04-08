{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      # Suppress zsh-newuser-install
      unsetopt BEEP

      # Ensure wrappers (setuid binaries like sudo) are found first
      export PATH="/run/wrappers/bin:$PATH"

      # nix-index database for package search and completions
      if [ -f /etc/profile.d/nix-index.sh ]; then
        source /etc/profile.d/nix-index.sh
      fi

      # SSH aliases
      alias lp='ssh 192.168.1.80'
      alias sr='ssh 192.168.1.145'

      # Improved completion system (fish-like)
      autoload -Uz compinit && compinit
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors ""
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt COMPLETE_ALIASES
    '';
  };

  home.packages = with pkgs; [
    nix-zsh-completions
    nix-index
  ];
}
