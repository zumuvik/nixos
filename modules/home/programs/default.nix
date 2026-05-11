{ lib, my, ... }: {
  imports = [
    ./cli               # CLI-утилиты (все хосты)
    ./dev               # Инструменты разработки (все хосты)
  ] ++ lib.optionals my.profiles.desktop.enable [
    ./desktop           # GUI-приложения (только desktop)
  ];
}
