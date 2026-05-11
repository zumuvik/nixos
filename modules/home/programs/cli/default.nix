{ ... }: {
  imports = [
    ./fish.nix         # Шелл
    ./starship.nix     # Промпт
    ./zoxide.nix       # Умная навигация
    ./fzf.nix          # Быстрый поиск
    ./eza.nix          # Современный ls
    ./micro.nix        # Текстовый редактор
    ./fastfetch.nix    # Системная информация
  ];
}
