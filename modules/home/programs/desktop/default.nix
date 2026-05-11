{ ... }: {
  imports = [
    ./firefox.nix      # Браузер
    ./zen-browser.nix  # Кастомный браузер
    ./foot.nix         # Терминал
    ./vscodium.nix     # Редактор кода
    ./opencode.nix     # AI-assisted coding
    ./obs.nix          # Запись экрана
    ./ags.nix          # Виджеты (в планах)
    ./nixcord.nix      # Discord
    ./ncmpcpp.nix      # Музыкальный плеер
  ];
}
