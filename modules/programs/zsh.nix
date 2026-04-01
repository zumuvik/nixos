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
    '';
  };

  home.packages = with pkgs; [
    nix-zsh-completions
  ];
}
