{ ... }: {
  programs.git = {
    enable = true;
    
    settings = {
      user = {
        name = "zumuvik";
        email = "toovalvedota2@gmail.com";
      };
      
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit";
        ps = "push";
        pl = "pull";
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      };
    };

    lfs.enable = true;
    ignores = [ ".DS_Store" "*.swp" "dist/" "node_modules/" ];
  };
}
