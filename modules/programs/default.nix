{ ... }: {
  imports = [
  ./nixvim.nix #Декларативный Nvim
  ./vscodium.nix #vscode без слежки
  ./obs.nix #Запись экрана/стримы
  ./ags.nix #В планах
  ./nixcord.nix #Декларативный vesktope
  ./ghostty.nix #Терминал
  ./zsh.nix #Шелл
  ];
}
