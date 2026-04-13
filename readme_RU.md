# NixOS Конфигурация

Flake-based конфигурация NixOS для нескольких хостов с рабочим столом Hyprland.

## Машины

| Хост | Роль | Особенности |
|------|------|------------|
| `nixlensk321` | Ноутбук | Hyprland, управление батареей |
| `nixlensk322` | Сервер/Роутер | Docker, NAT, dnsmasq, firewall, nginx |
| `nixlensk323` | Игровой ПК | Steam, Hyprland |

## Структура проекта

```
.
├── flake.nix                  # Точка входа Flake
├── configuration.nix          # Общие системные настройки
├── home.nix                   # Конфигурация Home Manager
├── lib/default.nix            # Общие переменные (username)
├── secrets/                   # Зашифрованные секреты (sops-nix)
├── hosts/
│   ├── nixlensk323/           # Игровой ПК
│   ├── nixlensk322/           # Сервер/Роутер
│   ├── nixlensk321/           # Ноутбук
│   └── template/              # Шаблон для новых хостов
└── modules/
    ├── profiles/              # Общие профили (desktop, server, core)
    ├── system/
    │   ├── services.nix       # PipeWire, SSH, VPN, XDG
    │   ├── hardware.nix       # GPU, Виртуализация
    │   ├── zram.nix           # Конфигурация ZRAM
    │   ├── swap.nix           # Конфигурация Swap (только nixlensk323)
    │   ├── greetd.nix         # Логин-менеджер
    │   ├── laptop.nix         # Ноутбук-специфичные (только nixlensk321)
    │   ├── bluetooth.nix      # Bluetooth (опционально)
    │   ├── git-sync.nix       # Авто-синхронизация git по LAN
    │   └── sites/             # Nginx виртуальные хосты
    ├── home/
    │   ├── common/            # Общие настройки home
    │   └── hyprland/          # Конфигурация Hyprland WM
    └── programs/
        ├── nixvim.nix         # Декларативный Neovim
        ├── ghostty.nix        # Терминал
        ├── vscodium.nix       # VSCode без телеметрии
        ├── obs.nix            # OBS Studio
        ├── ags.nix            # Aylur's Gtk Shell
        ├── nixcord.nix        # Декларативный Vesktop
        ├── zsh.nix            # Конфигурация Zsh
        ├── zen-browser.nix    # Браузер Zen
        └── micro.nix          # Конфиг Micro редактора
├── AGENTS.md                  # Инструкции для AI кодинга
└── SETUP_MANUAL.md            # Пошаговое руководство установки
```

## Требования

- NixOS minimal ISO
- Подключение к интернету
- Установленный Git: `nix-shell -p git`

Смотри [`SETUP_MANUAL.md`](./SETUP_MANUAL.md) для подробного пошагового руководства установки.

## Сборка и развёртывание

### Проверка конфигурации (запускайте ДО применения)

```bash
sudo nixos-rebuild build --flake .#<hostname>   # сухой запуск
home-manager build --flake .#<hostname>         # только Home Manager
nix flake check                                 # проверка flake outputs
```

### Применение

Одной команды достаточно для сборки всей системы и пользовательского окружения (Home Manager встроен как модуль NixOS):

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Откат

```bash
sudo nixos-rebuild switch --rollback
```

### Обслуживание

```bash
nix flake update && nix-collect-garbage -d
```

## Линтинг / Статический анализ

```bash
deadnix -W .    # обнаружение неиспользуемых переменных
statix check .  # статический анализ Nix паттернов
```

## Обновление

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .#myhost
```

## Стиль кода

### Форматирование
- **Отступ**: 2 пробела, без табуляций
- **Без автоматического форматера** (no alejandra/nixfmt) — следуйте существующему стилю
- По одному атрибуту в строке в attrsets
- Списки: по одному элементу в строке, если > 2 элементов или элемент сложный

### Соглашения об именовании

| Элемент | Соглашение | Пример |
|---------|-----------|--------|
| Файлы | kebab-case | `git-sync.nix` |
| Опции | camelCase | `hardware.opengl.enable` |
| Переменные | camelCase | `nixpkgsHost` |
| Папки | lowercase | `modules/system/` |

## Кастомизация

### Hyprland

Файлы конфигурации в `modules/home/hyprland/`:

- `binds.nix` — горячие клавиши
- `style.nix` — отступы, границы, анимации (эффект «жидкого стекла»)
- `exec-once.nix` — автозапуск приложений
- `swaync/` — конфигурация уведомлений (SwayNC)
- `scripts/` — shell скрипты

### Скрипты Hyprland

Основные скрипты в `modules/home/hyprland/scripts/`:

- `Brightness.sh` — управление яркостью
- `Battery.sh` — статус батареи
- `Volume.sh` — управление громкостью
- `ThemeChanger.sh` — смена темы
- `DarkLight.sh` — темная/светлая тема
- `KeyboardLayout.sh` — раскладка клавиатуры
- `ChangeLayout.sh` — переключение раскладки
- `TouchPad.sh` — управление тачпадом
- `ClipManager.sh` — менеджер буфера обмена
- `Dropterminal.sh` — выпадающий терминал
- `GameMode.sh` — игровой режим

(Всего 40+ скриптов в директории)

### Neovim (nixvim)

Отредактируйте `home.nix` в секции `programs.nixvim`.

### Пакеты

Добавляйте пакеты в двух местах:

1. **Системные**: `hosts/myhost/configuration.nix` → `environment.systemPackages`
2. **Пользовательские**: `home.nix` → `home.packages`

## Синхронизация Git по LAN

После каждого коммита, post-commit hook отправляет UDP сигнал всем остальным хостам в LAN. Каждый хост запускает listener, который автоматически выполняет `git pull --rebase --autostash`.

Нет необходимости в ручной синхронизации — закоммитьте на одной машине, остальные обновятся автоматически.

## Управление удалёнными хостами

Управляйте другими хостами через SSH. Пример:

```bash
ssh -o ConnectTimeout=3 zumuvik@192.168.10.242 "cd /etc/nixos && git status"
```

Известные хосты:

| Хост | IP | Описание |
|------|-----|---------|
| nixlensk321 | 192.168.10.242 | Ноутбук |
| nixlensk322 | 192.168.10.120 | Сервер |
| nixlensk323 | 192.168.10.210 | Игровой ПК |

## Веб-сервисы (nixlensk322)

Nginx виртуальные хосты в `modules/system/sites/`.

| Сайт | Домен |
|------|--------|
| Roundcube | mail.samolensk.ru |

## Устранение проблем

### Сборка падает с конфликтом опций

Используйте `lib.mkForce` или `lib.mkDefault` для разрешения конфликтов приоритетов:

```nix
some.option = lib.mkForce "value";     # Переопределить всё
some.option = lib.mkDefault "value";   # Низкий приоритет (по умолчанию)
```

### Конфликты файлов Home Manager

При конфликте файлов при первом запуске:

```bash
home-manager switch --flake .#myhost
```

Конфиг использует `home-manager.backupFileExtension = "backup"` для обработки конфликтов.

### Откат к предыдущей генерации

```bash
sudo nixos-rebuild switch --rollback
# или выберите генерацию при загрузке в GRUB
```

## Для AI кодирующих агентов

Смотри [`AGENTS.md`](./AGENTS.md) для подробных руководств:
- Подробная структура директорий
- Паттерны модулей и импортов
- Nix идиомы (условия, списки пакетов, упорядочение атрибутов)
- Стиль комментариев
- Обработка ошибок
- Соглашения shell-скриптов
- Workflow Git
- Добавление новых хостов
