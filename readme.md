# NixOS Configuration

Flake-based NixOS configuration for multiple hosts with Hyprland desktop.

## Structure

```
.
├── flake.nix                  # Flake entry point
├── configuration.nix          # Shared system config
├── home.nix                   # Home Manager config
├── lib/default.nix            # Shared variables (username)
├── hosts/
│   ├── nixlensk323/           # Gaming PC
│   ├── nixlensk322/           # Server/Router
│   ├── nixlensk321/           # Laptop
│   └── template/              # Template for new hosts
└── modules/
    ├── system/
    │   ├── services.nix       # PipeWire, SSH, VPN, XDG
    │   ├── hardware.nix       # GPU, Virtualization
    │   ├── zram.nix           # ZRAM config
    │   ├── swap.nix           # Swap config (nixlensk323 only)
    │   ├── greetd.nix         # Login manager
    │   ├── laptop.nix         # Laptop-specific (nixlensk321 only)
    │   ├── bluetooth.nix      # Bluetooth (optional)
    │   ├── router.nix         # Router/DHCP/NAT (optional)
    │   └── git-sync.nix       # Auto git-sync across LAN
    ├── home/
    │   ├── common/            # Shared home settings
    │   └── hyprland/          # Hyprland WM config
    └── programs/
        ├── nixvim.nix         # Declarative Neovim
        ├── ghostty.nix        # Terminal
        ├── vscodium.nix       # VSCode without telemetry
        ├── obs.nix            # OBS Studio
        ├── ags.nix            # Aylur's Gtk Shell
        ├── nixcord.nix        # Declarative Vesktop
        └── zsh.nix            # Zsh config
```

## Requirements

- NixOS minimal ISO
- Internet connection
- Git installed: `nix-shell -p git`

## Setup

### 1. Clone and rename

```bash
git clone <repo-url> /tmp/nixos-config
cd /tmp/nixos-config
```

### 2. Change username

Edit `lib/default.nix`:

```nix
{
  username = "your_username";  # CHANGE THIS
}
```

### 3. Generate hardware config for your machine

```bash
sudo nixos-generate-config --dir /tmp/nixos-config/hosts/myhost
```

This creates `hardware-configuration.nix` in the host directory.

### 4. Create host directory

```bash
cp -r hosts/template hosts/myhost
```

Edit `hosts/myhost/configuration.nix`:

```nix
{ config, lib, pkgs, username, ... }:

{
  networking.hostName = "myhost";
  time.timeZone = "Europe/Moscow";  # Change to your timezone

  # Copy UUIDs from generated hardware-configuration.nix
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/YOUR_UUID_HERE";
  #   fsType = "ext4";
  # };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;  # or pkgs.fish, pkgs.zsh
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    # Add your packages here
  ];
}
```

### 5. Register host in flake.nix

Edit `flake.nix` — add your host:

```nix
nixosConfigurations = {
  myhost = makeHost {
    hostName = "myhost";
    # enableSteam = true;
    # enableBluetooth = true;
    # enableRouter = true;
  };
  # ... existing hosts ...
};
```

### 6. Locale and timezone

Edit `configuration.nix` to change locale:

```nix
i18n.defaultLocale = "en_US.UTF-8";  # Change from ru_RU.UTF-8
```

If your host needs a different locale than the default, use `lib.mkForce` in your host config:

```nix
i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
```

### 7. Build and switch

```bash
cd /etc/nixos  # or wherever you placed the config
sudo nixos-rebuild switch --flake .#myhost
```

## Available Hosts

| Host | Type | Features |
|------|------|----------|
| `nixlensk323` | Gaming PC | Steam, Bluetooth, Hyprland |
| `nixlensk322` | Server/Router | Docker, NAT, dnsmasq, firewall |
| `nixlensk321` | Laptop | Hyprland, battery management |

## Optional Modules

Enable optional modules in `flake.nix`:

```nix
myhost = makeHost {
  hostName = "myhost";
  enableBluetooth = true;  # Enable Bluetooth support
  enableRouter = true;     # Enable Router/NAT/DHCP
  # enableSteam is not used as a module toggle yet
};
```

## Customization

### Hyprland

Config files are in `modules/home/hyprland/`:

- `binds.nix` — keyboard shortcuts
- `style.nix` — gaps, borders, animations
- `exec-once.nix` — autostart applications
- `scripts/` — shell scripts

### Neovim (nixvim)

Edit `home.nix` under `programs.nixvim` to customize.

### Packages

Add packages in two places:

1. **System-wide**: `hosts/myhost/configuration.nix` → `environment.systemPackages`
2. **User-level**: `home.nix` → `home.packages`

## Updating

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .#myhost
```

## Git Sync (LAN)

After each commit, a post-commit hook sends a UDP signal to all other hosts on the LAN. Each host runs a listener that automatically runs `git pull --rebase --autostash`.

No manual sync needed — commit on one machine, others update automatically.

## Troubleshooting

### Build fails with conflicting options

Use `lib.mkForce` or `lib.mkDefault` to resolve priority conflicts:

```nix
some.option = lib.mkForce "value";     # Override everything
some.option = lib.mkDefault "value";   # Low priority default
```

### Home Manager file conflicts

If files conflict on first run:

```bash
home-manager switch --flake .#myhost
```

The config uses `home-manager.backupFileExtension = "backup"` to handle conflicts.

### Rollback to previous generation

```bash
sudo nixos-rebuild switch --rollback
# or select at boot in GRUB
```
