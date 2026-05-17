# NixOS Configuration

Flake-based NixOS configuration for multiple hosts with modular `my.*` option system, Home Manager, and Hyprland desktop.

## Hosts

| Host | Role | Profile | Key Features |
|------|------|---------|--------------|
| `nixlensk321` | Laptop | Desktop | Hyprland, AMD GPU, Bluetooth, CachyOS kernel, laptop power management |
| `nixlensk322` | Server | Server | Nginx, Roundcube, Mailserver, Cloudflare DNS sync |
| `nixlensk323` | Gaming PC | Desktop | Hyprland, Steam, AMD GPU, CachyOS kernel, gaming optimizations |
| `nixlensk324` | VPS | Server | 3X-UI (VPN), Crafty (Minecraft), NixOS container, Cloudflare DNS sync |

## Structure

```
.
├── flake.nix                       # Entry point — inputs, host definitions
├── flake.lock                      # Pinned dependency versions
├── home.nix                        # Shared Home Manager config
├── lib/
│   └── default.nix                 # Shared variables (username, SSH keys)
├── secrets/
│   └── secrets.yaml                # Encrypted secrets (sops-nix)
├── hosts/
│   ├── nixlensk3{21,22,23,24}/     # Host-specific configs
│   │   ├── default.nix             # Host imports
│   │   ├── configuration.nix       # Feature toggles (my.*)
│   │   └── hardware-configuration.nix
│   └── template/                   # Template for new hosts
├── modules/
│   ├── core/
│   │   └── default.nix             # Base system config (all hosts)
│   ├── profiles/                   # System profiles
│   │   ├── desktop.nix             # Desktop profile (UI, greetd, VLESS)
│   │   └── server.nix              # Server profile (fail2ban, nginx)
│   ├── nixos/                      # NixOS modules (my.* namespace)
│   │   ├── hardware/               # bluetooth, amdgpu, laptop, kernel, zram, swap, virt
│   │   ├── services/               # nginx, mailserver, roundcube, 3x-ui, crafty, nh, ...
│   │   ├── ui/                     # fonts, greetd, plymouth, mpd, common
│   │   └── gaming.nix              # Gaming optimizations (Steam, Gamemode)
│   └── home/                       # Home Manager modules
│       ├── programs/               # App configs (nixvim, fish, starship, firefox, ...)
│       ├── services/               # User services (mpd)
│       ├── ui/                     # Theme (GTK/QT dark mode, cursors)
│       ├── profiles/
│       │   └── desktop.nix         # Desktop home profile (packages, Hyprland, Waybar)
│       ├── hyprland/               # WM config (binds, style, scripts, swaync)
│       └── waybar/                 # Waybar panel config
├── AGENTS.md                       # AI agent guidelines
└── SETUP_MANUAL.md                 # Installation guide
```

## Modular Options (my.* namespace)

All features are defined as NixOS modules with `my.*` options. Enable them in `hosts/<host>/configuration.nix`:

```nix
{ ... }: {
  # Profiles
  my.profiles.desktop.enable = true;

  # Hardware
  my.hardware.amdgpu.enable = true;
  my.hardware.bluetooth.enable = true;
  my.hardware.laptop.enable = true;
  my.hardware.kernel-cachy.enable = true;
  my.hardware.zram.enable = true;
}
```

## Build & Deploy

```bash
# Verify first
sudo nixos-rebuild build --flake .#<hostname>
nix flake check

# Apply
sudo nixos-rebuild switch --flake .#<hostname>

# Rollback
sudo nixos-rebuild switch --rollback
```

## Hyprland

Config files in `modules/home/hyprland/`:
- `binds.nix` — keyboard shortcuts
- `style.nix` — gaps, borders, animations
- `exec-once.nix` — autostart applications
- `scripts/` — shell scripts for WM operations

## Services

### Server nixlensk322

| Service | Domain | Module |
|---------|--------|--------|
| Roundcube | mail.samolensk.ru | `services/roundcube/` |
| Mailserver | samolensk.ru | `services/mailserver/` |
| Cloudflare Sync | — | `services/cloudflare-sync/` |

### VPS nixlensk324

| Service | Domain | Module |
|---------|--------|--------|
| 3X-UI (VPN) | vpn.samolensk.ru | `services/3x-ui.nix` |
| Crafty (Minecraft) | crafty.samolensk.ru | `services/crafty.nix` |
| Cloudflare Sync | — | `services/cloudflare-sync/` |

## Known Hosts

| Host | IP | Description |
|------|-----|-------------|
| nixlensk321 | 192.168.10.242 | Laptop |
| nixlensk322 | 192.168.10.120 | Home Server |
| nixlensk323 | 192.168.10.210 | Gaming PC |
| nixlensk324 | 45.13.237.210 | VPS (+ `valera-box` container) |

## Code Style

- **Namespace**: `my.<category>.<feature>.enable` for all module toggles
- **Indentation**: 2 spaces, no tabs
- **File naming**: kebab-case (`amdgpu.nix`)
- **Option naming**: camelCase (`my.hardware.amdgpu.enable`)
- **Imports**: always include `.nix` extension

## For AI Coding Agents

See [`AGENTS.md`](./AGENTS.md) for detailed guidelines on the modular structure and coding standards.
