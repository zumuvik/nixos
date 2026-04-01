{ ... }: {
  programs.ghostty = {
    enable = true;
    settings = {
      shell-integration = "zsh";
    };
  };
}
