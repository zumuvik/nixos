{ lib, my, ... }: {
  imports = [
    ./git.nix           # Конфигурация Git
    ./lazygit.nix       # TUI для Git
    ./nixvim.nix       # Декларативный Nvim
    ./fish.nix         # Шелл
    ./starship.nix     # Красивый промпт
    ./zoxide.nix       # Умная навигация
    ./fzf.nix          # Быстрый поиск
    ./bat.nix          # cat с подсветкой
    ./eza.nix          # Современный ls
    ./micro.nix        # Текстовый редактор
    ./fastfetch.nix    # Системная информация
  ] ++ lib.optionals my.profiles.desktop.enable [
    ./vscodium.nix     # vscode без слежки
    ./firefox.nix      # Браузер
    ./obs.nix          # Запись экрана/стримы
    ./ags.nix          # В планах
    ./nixcord.nix      # Декларативный discord
    ./foot.nix         # Терминал
    ./opencode.nix     # AI-assisted coding
    ./zen-browser.nix  # Кастомный браузер
    ./ncmpcpp.nix      # Музыкальный плеер
  ];
}

