{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      share = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      findNoDups = true;
      ignoreSpace = true;
    };
    initContent = ''
      set -o vi
      set -o ignoreeof
      set -o correct

      PS1="%F{green}%n%f@%F{blue}%m%f %F{yellow}%~%f %% "

      alias ls='ls --color=auto'
      alias ll='ls -la'
      alias la='ls -a'
      alias grep='grep --color=auto'
    '';

    autosuggestion.enable = true;

    syntaxHighlighting.enable = true;
  };

  home.packages = with pkgs; [
    zsh
    autojump
  ];
}
