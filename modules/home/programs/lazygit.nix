{ ... }: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui.showIcons = true;
      git = {
        pagers = [
          {
            # Исправлено: теперь это элемент списка
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };
    };
  };
}
