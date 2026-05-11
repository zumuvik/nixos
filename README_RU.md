# Конфигурация NixOS

Конфигурация NixOS на базе Flake для нескольких хостов с модульной системой опций `my.*`, Home Manager и рабочим окружением Hyprland.

## Хосты

| Хост | Роль | Профиль | Особенности |
|------|------|---------|-------------|
| `nixlensk321` | Ноутбук | Desktop | Hyprland, AMD GPU, Bluetooth, ядро CachyOS, управление питанием |
| `nixlensk322` | Сервер | Server | Nginx, Roundcube, Mailserver, синхронизация DNS через Cloudflare |
| `nixlensk323` | Игровой ПК | Desktop | Hyprland, Steam, AMD GPU, ядро CachyOS, игровые оптимизации |
| `nixlensk324` | VPS | Server | 3X-UI (VPN), Crafty (Minecraft), NixOS-контейнер, Cloudflare DNS |

## Структура

```
.
├── flake.nix                       # Точка входа — инпуты, определения хостов
├── flake.lock                      # Закреплённые версии зависимостей
├── home.nix                        # Общая конфигурация Home Manager
├── lib/
│   └── default.nix                 # Общие переменные (username, SSH-ключи)
├── secrets/
│   └── secrets.yaml                # Зашифрованные секреты (sops-nix)
├── hosts/
│   ├── nixlensk3{21,22,23,24}/     # Конфиги для конкретных хостов
│   │   ├── default.nix             # Импорты хоста
│   │   ├── configuration.nix       # Переключатели функций (my.*)
│   │   └── hardware-configuration.nix
│   └── template/                   # Шаблон для новых хостов
├── modules/
│   ├── core/
│   │   └── default.nix             # Базовая конфигурация (общая для всех хостов)
│   ├── profiles/                   # Системные профили
│   │   ├── desktop.nix             # Профиль рабочего стола (UI, greetd, VLESS)
│   │   └── server.nix              # Серверный профиль (fail2ban, nginx)
│   ├── nixos/                      # Модули NixOS (пространство имён my.*)
│   │   ├── hardware/               # bluetooth, amdgpu, laptop, kernel, zram, swap, virt
│   │   ├── services/               # nginx, mailserver, roundcube, 3x-ui, crafty, nh, ...
│   │   ├── ui/                     # fonts, greetd, plymouth, mpd, common
│   │   └── gaming.nix              # Игровые оптимизации (Steam, Gamemode)
│   └── home/                       # Модули Home Manager
│       ├── programs/               # Конфиги приложений (nixvim, fish, starship, firefox, ...)
│       ├── services/               # Пользовательские сервисы (mpd)
│       ├── ui/                     # Тема (GTK/QT тёмный режим, курсоры)
│       ├── profiles/
│       │   └── desktop.nix         # Домашний профиль (пакеты, Hyprland, Waybar)
│       ├── hyprland/               # Конфигурация WM (биндинги, стиль, скрипты, swaync)
│       └── waybar/                 # Конфигурация панели Waybar
├── AGENTS.md                       # Инструкции для ИИ-агентов
└── SETUP_MANUAL.md                 # Руководство по установке
```

## Модульные опции (my.*)

Все функции определены как модули NixOS с опциями `my.*`. Включайте их в `hosts/<host>/configuration.nix`:

```nix
{ ... }: {
  # Профили
  my.profiles.desktop.enable = true;   # или my.profiles.server.enable

  # Оборудование
  my.hardware.amdgpu.enable = true;
  my.hardware.bluetooth.enable = true;
  my.hardware.laptop.enable = true;
  my.hardware.kernel-cachy.enable = true;
  my.hardware.zram.enable = true;

  # Сервисы
  my.services.roundcube.enable = true;
  my.services.mailserver.enable = true;
  my.services.x3-ui.enable = true;
  my.services.crafty.enable = true;

  # Прочее
  my.gaming.enable = true;
  my.ui.mpd.enable = true;
}
```

## Сборка и деплой

```bash
# Проверка
sudo nixos-rebuild build --flake .#<hostname>
nix flake check

# Применение
sudo nixos-rebuild switch --flake .#<hostname>

# Откат
sudo nixos-rebuild switch --rollback
```

## Hyprland

Конфиги в `modules/home/hyprland/`:
- `binds.nix` — горячие клавиши
- `style.nix` — отступы, рамки, анимации
- `exec-once.nix` — автозапуск приложений
- `scripts/` — shell-скрипты для WM

## Сервисы

### Сервер nixlensk322

| Сервис | Домен | Модуль |
|--------|-------|--------|
| Roundcube | mail.samolensk.ru | `services/roundcube/` |
| Mailserver | samolensk.ru | `services/mailserver/` |
| Cloudflare Sync | — | `services/cloudflare-sync/` |

### VPS nixlensk324

| Сервис | Домен | Модуль |
|--------|-------|--------|
| 3X-UI (VPN) | vpn.samolensk.ru | `services/3x-ui.nix` |
| Crafty (Minecraft) | crafty.samolensk.ru | `services/crafty.nix` |
| Cloudflare Sync | — | `services/cloudflare-sync/` |

## Известные хосты

| Хост | IP | Описание |
|------|-----|----------|
| nixlensk321 | 192.168.10.242 | Ноутбук |
| nixlensk322 | 192.168.10.120 | Домашний сервер |
| nixlensk323 | 192.168.10.210 | Игровой ПК |
| nixlensk324 | 45.13.237.210 | VPS (+ контейнер `valera-box`) |

## Стиль кода

- **Namespace**: `my.<category>.<feature>.enable` для всех переключателей
- **Отступы**: 2 пробела, без табов
- **Имена файлов**: kebab-case (`amdgpu.nix`)
- **Имена опций**: camelCase (`my.hardware.amdgpu.enable`)
- **Импорты**: всегда указывать расширение `.nix`

## Для ИИ-агентов

См. [`AGENTS.md`](./AGENTS.md) для подробных инструкций по модульной структуре и стандартам кодинга.
