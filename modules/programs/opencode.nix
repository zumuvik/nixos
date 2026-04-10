_: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "oh-my-opencode"
        "opencode-antigravity-auth"
      ];
    };
  };
}
