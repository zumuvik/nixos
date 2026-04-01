{ ... }: {
  programs.zsh = {
    enable = true;
    initContent = ''
      # Suppress zsh-newuser-install
      unsetopt BEEP
    '';
  };
}
