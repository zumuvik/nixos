# AGENTS.md — инструкции для агентов

## О проекте

Это flake-based NixOS конфигурация с Home Manager. Язык — Nix.
Управление окнами — Hyprland (Wayland). Редактор — Neovim (через nixvim).
Терминал — Ghostty. Объявлено 3 хоста: `nixlensk321` (ноутбук), `nixlensk322` (сервер/роутер), `nixlensk323` (игровой ПК).

## Структура

```
├── flake.nix / flake.lock          — точка входа, хосты, inputs
├── configuration.nix               — общие системные настройки (все хосты)
├── home.nix                        — общие пользовательские настройки
├── lib/default.nix                 — общие переменные (username = "zumuvik")
├── hosts/<host>/                   — конфигурация конкретного хоста
│   ├── default.nix                 — импорты модулей хоста
│   ├── configuration.nix           — специфичные system-настройки
│   └── hardware-configuration.nix  — автогенерированная аппаратная конфигурация
├── modules/system/                 — NixOS-модули (services, hardware, greetd, и т.д.)
├── modules/home/                   — Home Manager модули (common, hyprland)
└── modules/programs/               — конфигурации программ (nixvim, ghostty, zsh, и т.д.)
```

## Команды

### Сборка и применение

```bash
# Применить системную конфигурацию для конкретного хоста
sudo nixos-rebuild switch --flake .#<hostname>

# Применить Home Manager конфигурацию
home-manager switch --flake .#<hostname>

# Обновить все flake inputs
nix flake update

# Откат к предыдущей генерации
sudo nixos-rebuild switch --rollback
```

### Проверка конфигурации (без применения)

```bash
# Проверить системную конфигурацию
nixos-rebuild build --flake .#<hostname>

# Проверить Home Manager
home-manager build --flake .#<hostname>
```

### Тестирование

Тестов как таковых нет. Валидация — успешная сборка через `nixos-rebuild build`.

## Стиль кода

### Форматирование

- Отступ: **2 пробела**, без табуляций
- Подтверждено настройками nixvim: `tabstop = 2`, `shiftwidth = 2`, `expandtab = true`
- Форматтеры Nix (alejandra/nixfmt) не настроены — следуй существующему стилю

### Именование

- Файлы: `kebab-case` (`git-sync.nix`, `exec-once.nix`, `hardware-configuration.nix`)
- Опции Nix: `camelCase` (`hardware.opengl.enable`, `services.openssh.enable`)
- Переменные Nix: `camelCase` (`nixpkgsHost`, `hardwareConfig`)
- Папки: строчные буквы (`modules/system/`, `modules/home/`, `modules/programs/`)

### Организация файлов

- Каждый модуль имеет `default.nix` для реэкспорта/импортов
- Разделение: `modules/system/` — системные, `modules/home/` — пользовательские, `modules/programs/` — программы
- Хосты живут в `hosts/<hostname>/`
- Конфигурация Hyprland разбита на логические файлы: `hyprland.nix`, `binds.nix`, `style.nix`, `exec-once.nix`, и т.д.

### Комментарии

- Разделители секций: `# ──────────────────────────────────────────────`
- Комментарии на русском допустимы
- Описательные заголовки секций: `# Services`, `# Hardware`, `# Hyprland`

### Imports

- Используй `imports = [ ./file.nix ];` для подключения модулей
- `default.nix` импортирует все sibling-модули через `./module.nix`
- Хосты импортируют общие конфиги: `../../configuration.nix`, `../../modules/system/`

### Конвенции Nix

- `options` / `config` паттерн для модулей (через `{ config, pkgs, lib, ... }:`)
- `with pkgs;` допустим для списков пакетов
- `mkIf`, `mkEnableOption` — для условной активации
- `extraConfig` — для raw-конфигов (Hyprland, ghostty)
- Строки с несколькими строками: `''` (multi-line string)

### Error handling

- Nix — декларативный язык, обработка ошибок через валидацию сборки
- Для shell-скриптов (`modules/home/hyprland/scripts/`): `set -euo pipefail`
- Проверяй синтаксис через `nixos-rebuild build` перед коммитом

### Git

- Ветки: `master`, `main`, `alpha`, `beta`
- Настроен auto-sync по LAN (UDP порт 9876) — коммит на одной машине распространяется на все
- Не коммить изменения без явного запроса пользователя
