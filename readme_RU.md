# NixOS Конфигурация

Flake-based конфигурация NixOS для нескольких хостов с рабочим столом Hyprland.

## Структура проекта

```
.
├── flake.nix                  # Точка входа Flake
├── configuration.nix          # Общие системные настройки
├── home.nix                   # Конфигурация Home Manager
├── lib/default.nix            # Общие переменные (username)
├── hosts/
│   ├── nixlensk323/           # Игровой ПК
│   ├── nixlensk322/           # Сервер/Роутер
│   ├── nixlensk321/           # Ноутбук
│   └── template/              # Шаблон для новых хостов
└── modules/
    ├── system/
    │   ├── services.nix       # PipeWire, SSH, VPN, XDG
    │   ├── hardware.nix       # GPU, Планшет, Виртуализация
    │   ├── swap.nix           # Конфигурация Swap
    │   ├── zram.nix           # Конфигурация ZRAM
    │   ├── bluetooth.nix      # Bluetooth (опционально)
    │   ├── router.nix         # Роутер/DHCP/NAT (опционально)
    │   └── greetd.nix         # Логин-менеджер greetd
    └── home/
        ├── common/            # Общие настройки home
        └── hyprland/          # Конфигурация Hyprland WM
            ├── hyprland.nix   # Основная конфигурация
            ├── binds.nix      # Горячие клавиши
            ├── style.nix      # Отступы, границы, анимации
            ├── exec-once.nix  # Автозапуск приложений
            ├── monitors.nix   # Настройка мониторов
            ├── workspaces.nix # Рабочие пространства
            ├── startup_apps.nix# Приложения при старте
            ├── hyprlock.nix   # Конфигурация блокировки экрана
            ├── scripts.nix    # Общие скрипты
            └── scripts/       # Shell скрипты
```

## Требования

- NixOS minimal ISO
- Подключение к интернету
- Установленный Git: `nix-shell -p git`

## Установка

### 1. Клонировать и переименовать

```bash
git clone <repo-url> /tmp/nixos-config
cd /tmp/nixos-config
```

### 2. Изменить имя пользователя

Отредактируйте `lib/default.nix`:

```nix
{
  username = "ваш_юзернейм";  # ИЗМЕНИТЕ ЭТО
}
```

### 3. Сгенерировать конфигурацию оборудования

```bash
sudo nixos-generate-config --dir /tmp/nixos-config/hosts/myhost
```

Создаст файл `hardware-configuration.nix` в директории хоста.

### 4. Создать директорию хоста

```bash
cp -r hosts/template hosts/myhost
```

Отредактируйте `hosts/myhost/configuration.nix`:

```nix
{ config, lib, pkgs, username, ... }:

{
  networking.hostName = "myhost";
  time.timeZone = "Europe/Moscow";  # Измените на свой часовой пояс

  # Скопируйте UUID из сгенерированного hardware-configuration.nix
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/ВАШ_UUID_ЗДЕСЬ";
  #   fsType = "ext4";
  # };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;  # или pkgs.fish, pkgs.zsh
  };

  # Системные пакеты
  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    # Добавьте свои пакеты здесь
  ];
}
```

### 5. Зарегистрировать хост во flake.nix

Отредактируйте `flake.nix` — добавьте свой хост:

```nix
nixosConfigurations = {
  myhost = makeHost {
    hostName = "myhost";
    # enableSteam = true;
    # enableBluetooth = true;
    # enableRouter = true;
  };
  # ... существующие хосты ...
};
```

### 6. Локаль и часовой пояс

Отредактируйте `configuration.nix` для смены локали:

```nix
i18n.defaultLocale = "ru_RU.UTF-8";  # Оставьте ru_RU или смените
```

Если хосту нужна другая локаль, используйте `lib.mkForce`:

```nix
i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
```

### 7. Собрать и переключиться

```bash
cd /etc/nixos  # или где лежит конфиг
sudo nixos-rebuild switch --flake .#myhost
```

## Доступные хосты

| Хост | Тип | Особенности |
|------|-----|------------|
| `nixlensk323` | Игровой ПК | Steam, Bluetooth, Hyprland |
| `nixlensk322` | Сервер/Роутер | Docker, NAT, dnsmasq, firewall |
| `nixlensk321` | Ноутбук | Hyprland, управление батареей |

## Опциональные модули

Включите опциональные модули в `flake.nix`:

```nix
myhost = makeHost {
  hostName = "myhost";
  enableBluetooth = true;  # Включить Bluetooth
  enableRouter = true;     # Включить Router/NAT/DHCP
  # enableSteam пока не используется как переключатель модуля
};
```

## Кастомизация

### Hyprland

Файлы конфигурации в `modules/home/hyprland/`:

- `hyprland.nix` — основная конфигурация
- `binds.nix` — горячие клавиши
- `style.nix` — отступы, границы, анимации
- `monitors.nix` — настройка мониторов
- `workspaces.nix` — рабочие пространства
- `exec-once.nix` — автозапуск приложений
- `startup_apps.nix` — приложения при старте
- `hyprlock.nix` — блокировка экрана
- `scripts.nix` — общие скрипты
- `scripts/` — shell скрипты (40+ скриптов)

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

### Neovim (nixvim)

Отредактируйте `home.nix` в секции `programs.nixvim`.

### Пакеты

Добавляйте пакеты в двух местах:

1. **Системные**: `hosts/myhost/configuration.nix` → `environment.systemPackages`
2. **Пользовательские**: `home.nix` → `home.packages`

## Обновление

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .#myhost
```

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
