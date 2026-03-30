{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    initExtra = ''
      # Shell options
      set -o vi
      set -o ignoreeof
      set -o correct

      # History
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history
      SHARE_HISTORY=true
      HIST_EXPIRE_DUPS_FIRST=true
      HIST_IGNORE_DUPS=true
      HIST_FIND_NO_DUPS=true
      HIST_IGNORE_SPACE=true
      APPEND_HISTORY=true
      INC_APPEND_HISTORY=true

      # Prompt
      PS1="%F{green}%n%f@%F{blue}%m%f %F{yellow}%~%f %% "

      # Aliases
      alias ls='ls --color=auto'
      alias ll='ls -la'
      alias la='ls -a'
      alias grep='grep --color=auto'
    '';
  };

  home.packages = with pkgs; [
    zsh
    autojump
  ];
}
