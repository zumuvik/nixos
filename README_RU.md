# Конфигурация NixOS

Конфигурация NixOS на базе Flake для нескольких хостов с рабочим окружением Hyprland.

## Машины

| Хост | Роль | Особенности |
|------|------|-------------|
| `nixlensk321` | Ноутбук | Hyprland, управление питанием, ядро Zen |
| `nixlensk322` | Сервер | Podman, Nginx, WireGuard, Firewall |
| `nixlensk323` | Игровой ПК | Hyprland, Steam, ядро Zen, AMD GPU |

## Модульная структура

Конфигурация использует модульный подход с кастомным пространством имен `my.*` для всех системных настроек.

```
.
├── flake.nix                  # Точка входа Flake
├── configuration.nix          # Базовая конфигурация системы (core)
├── home.nix                   # Общая конфигурация Home Manager
├── lib/default.nix            # Общие переменные (username)
├── secrets/                   # Зашифрованные секреты (sops-nix)
├── hosts/
│   ├── <host>/                # Специфичные для хоста файлы
│   │   ├── default.nix        # Импорты хоста
│   │   └── configuration.nix  # Переключатели функций хоста (my.*)
├── modules/
│   ├── nixos/                 # Модули NixOS (Namespace: my.*)
│   │   ├── services/          # Сервисы (nginx, wg-easy)
│   │   ├── hardware/          # Оборудование (bluetooth, amdgpu, laptop, kernel)
│   │   ├── ui/                # Интерфейс (fonts, greetd, common)
│   │   └── gaming.nix         # Твики для игр
│   ├── home/                  # Модули Home Manager
│   │   ├── profiles/          # Общие профили home (desktop)
│   │   └── hyprland/          # Конфигурация Hyprland
│   ├── profiles/              # Системные профили (server, desktop)
│   └── programs/              # Конфиги программ Home Manager (nixvim, fish и др.)
├── AGENTS.md                  # Инструкции для ИИ-агентов
└── SETUP_MANUAL.md            # Руководство по установке
```

## Как использовать модульные опции

Вместо ручного импорта файлов, включайте нужные функции в `hosts/<host>/configuration.nix`:

```nix
{ ... }: {
  my.profiles.desktop.enable = true;
  my.hardware.amdgpu.enable = true;
  my.hardware.bluetooth.enable = true;
  my.gaming.enable = true;
}
```

## Сборка и деплой

### Проверка (перед применением)

```bash
sudo nixos-rebuild build --flake .#<hostname>   # сборка без применения
nix flake check                                 # проверка flake outputs
```

### Применение

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Управление

### Известные хосты

| Хост | IP | Описание |
|------|-----|----------|
| nixlensk321 | 192.168.10.242 | Ноутбук |
| nixlensk322 | 192.168.10.120 | Сервер |
| nixlensk323 | 192.168.10.210 | Игровой ПК |

## Стиль кода

- **Namespace**: Используйте `my.<category>.<feature>.enable` для всех переключателей.
- **Отступы**: 2 пробела.
- **Именование**: kebab-case для файлов, camelCase для опций.

## Для ИИ-агентов

См. [`AGENTS.md`](./AGENTS.md) для получения подробных инструкций по новой модульной структуре и стандартам кодинга.
