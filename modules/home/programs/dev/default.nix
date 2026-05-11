{ ... }: {
  imports = [
    ./git.nix          # Конфигурация Git
    ./lazygit.nix      # TUI для Git
    ./nixvim.nix       # Декларативный Nvim
  ];
}
