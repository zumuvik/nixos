# Руководство по установке NixOS (Flake + SOPS)

Это подробная инструкция по установке данной конфигурации NixOS на "голое" железо (или новую виртуальную машину).

## 1. Подготовка
1. Скачайте [NixOS Minimal ISO](https://nixos.org/download.html) и запишите на флешку.
2. Загрузитесь с флешки.
3. Подключитесь к интернету. Если вы используете Wi-Fi, введите встроенную утилиту `nmtui` для удобного подключения:
   ```bash
   nmtui
   ```

## 2. Разметка диска

Разметить диск можно двумя способами: с помощью декларативной утилиты `disko` (если у вас есть готовый конфиг) или вручную.

### Вариант А: Использование Disko (Рекомендуется)

Если у вас есть файл конфигурации disko (например, `disko-config.nix`), вы можете автоматически разметить и примонтировать диски одной командой без установки дополнительных пакетов:

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /путь/к/вашему/disko-config.nix
```
*Примечание: Если вы используете этот способ, шаг 3 (Монтирование) можно пропустить, так как disko автоматически примонтирует разделы в `/mnt`.*

### Вариант Б: Ручная разметка (Пример UEFI)

Если вы предпочитаете ручной метод и у вас обычный UEFI и один пустой диск (например, `/dev/nvme0n1`):

```bash
# Создаем новую таблицу разделов
parted /dev/nvme0n1 -- mklabel gpt

# Раздел EFI (Boot) - 512MB
parted /dev/nvme0n1 -- mkpart root fat32 512MB -8GB
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 2 esp on

# Раздел Swap - 8GB (в конце диска)
parted /dev/nvme0n1 -- mkpart swap linux-swap -8GB 100%

# Форматирование
mkfs.fat -F 32 -n boot /dev/nvme0n1p2
mkfs.ext4 -L nixos /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p3
```

## 3. Монтирование

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/nvme0n1p3
```

## 4. Загрузка конфигурации (Flake)

Конфигурация будет лежать в `/etc/nixos` уже на новой системе.

```bash
# Получаем git
nix-shell -p git

# Клонируем конфигурацию
git clone https://github.com/zumuvik/nixos.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

## 5. Настройка оборудования (Hardware Config)

Если вы устанавливаете систему на **новый хост** (например, которого еще нет в папке `hosts/`):

1. Скопируйте шаблон: `cp -r hosts/template hosts/my-new-host`
2. Сгенерируйте `hardware-configuration.nix`:
   ```bash
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/my-new-host/
   ```
3. Откройте `flake.nix` и добавьте свой хост в `nixosConfigurations`.

*(Если вы переустанавливаете существующий хост, например `nixlensk321` на то же самое железо, этот шаг можно пропустить!)*

## 6. Настройка секретов (SOPS-Nix)

Репозиторий использует `sops-nix` для управления секретами, привязанными к системным SSH-ключам (ED25519).

**Если вы восстанавливаете старую систему:**
Убедитесь, что вы скопировали ваш старый `/etc/ssh/ssh_host_ed25519_key` в `/mnt/etc/ssh/`. Иначе сборка или расшифровка упадет!

**Если это полностью новая машина:**
1. Сгенерируйте SSH-ключи для новой системы:
   ```bash
   mkdir -p /mnt/etc/ssh
   ssh-keygen -t ed25519 -N "" -f /mnt/etc/ssh/ssh_host_ed25519_key
   ```
2. Узнайте публичный ключ новой машины:
   ```bash
   cat /mnt/etc/ssh/ssh_host_ed25519_key.pub
   ```
3. Добавьте этот публичный ключ в файл `.sops.yaml` в корне репозитория под новым именем.
4. (На другой машине, где уже есть доступ к секретам) Обновите секреты:
   ```bash
   sops updatekeys secrets/secrets.yaml
   ```
5. Сделайте `git push` и вытяните изменения на устанавливаемую машину через `git pull`.

## 7. Установка системы

Теперь мы можем запустить установку NixOS, используя наш Flake:

```bash
sudo nixos-install --flake /mnt/etc/nixos#<имя_хоста> --no-root-passwd
```
> *Флаг `--no-root-passwd` опускает запрос пароля root, так как пароль или SSH-ключи пользователя обычно заданы декларативно в конфигурации.*

## 8. Завершение

```bash
reboot
```

Поздравляю! Теперь у вас рабочая NixOS с Hyprland. После перезагрузки все изменения можно накатывать командой:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#<имя_хоста>
```
