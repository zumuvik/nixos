{ ... }: {
  imports = [
    ./nixvim.nix       # Декларативный Nvim
    ./vscodium.nix     # vscode без слежки
    ./firefox.nix      # Браузер
    ./obs.nix          # Запись экрана/стримы
    ./ags.nix          # В планах
    ./nixcord.nix      # Декларативный discord
    ./ghostty.nix      # Терминал
    ./fish.nix         # Шелл
    ./micro.nix        # Текстовый редактор
    ./opencode.nix     # AI-assisted coding
    ./zen-browser.nix  # Кастомный браузер
    ./fastfetch.nix    # Системная информация

  ];
}

