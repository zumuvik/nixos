{ ... }: {
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}
