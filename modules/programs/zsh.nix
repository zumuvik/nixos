{ ... }: {
  programs.zsh = {
    enable = true;
    initContent = ''
      # Suppress zsh-newuser-install
      unsetopt BEEP

      # Ensure wrappers (setuid binaries like sudo) are found first
      export PATH="/run/wrappers/bin:$PATH"
    '';
  };
}
