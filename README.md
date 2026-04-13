# NixOS Configuration

Flake-based NixOS configuration for multiple hosts with Hyprland desktop.

## Machines

| Host | Role | Features |
|------|------|----------|
| `nixlensk321` | Laptop | Hyprland, battery management |
| `nixlensk322` | Server/Router | Docker, NAT, dnsmasq, firewall, nginx |
| `nixlensk323` | Gaming PC | Steam, Hyprland |

## Structure

```
.
├── flake.nix                  # Flake entry point
├── configuration.nix          # Shared system config
├── home.nix                   # Home Manager config
├── lib/default.nix            # Shared variables (username)
├── secrets/                   # Encrypted secrets (sops-nix)
├── hosts/
│   ├── nixlensk323/           # Gaming PC
│   ├── nixlensk322/           # Server/Router
│   ├── nixlensk321/           # Laptop
│   └── template/              # Template for new hosts
├── modules/
│   ├── profiles/              # Shared profiles (desktop, server, core)
│   ├── system/
│   │   ├── services.nix       # PipeWire, SSH, VPN, XDG
│   │   ├── hardware.nix       # GPU, Virtualization
│   │   ├── zram.nix           # ZRAM config
│   │   ├── swap.nix           # Swap config (nixlensk323 only)
│   │   ├── greetd.nix         # Login manager
│   │   ├── laptop.nix         # Laptop-specific (nixlensk321 only)
│   │   ├── bluetooth.nix      # Bluetooth (optional)
│   │   ├── git-sync.nix       # Auto git-sync across LAN
│   │   └── sites/             # Nginx virtual hosts
│   ├── home/
│   │   ├── common/            # Shared home settings
│   │   └── hyprland/          # Hyprland WM config
│   └── programs/
│       ├── nixvim.nix         # Declarative Neovim
│       ├── ghostty.nix        # Terminal
│       ├── vscodium.nix       # VSCode without telemetry
│       ├── obs.nix            # OBS Studio
│       ├── ags.nix            # Aylur's Gtk Shell
│       ├── nixcord.nix        # Declarative Vesktop
│       ├── fish.nix           # Fish config
│       ├── zen-browser.nix    # Zen Browser
│       └── micro.nix          # Micro editor config
├── AGENTS.md                  # Instructions for AI coding agents
└── SETUP_MANUAL.md            # Step-by-step installation guide
```

## Requirements

- NixOS minimal ISO
- Internet connection
- Git installed: `nix-shell -p git`

See [`SETUP_MANUAL.md`](./SETUP_MANUAL.md) for detailed step-by-step installation instructions.

## Build and Deploy

### Verification (run BEFORE applying)

```bash
sudo nixos-rebuild build --flake .#<hostname>   # dry-run
home-manager build --flake .#<hostname>         # Home Manager only
nix flake check                                 # check flake outputs
```

### Apply

A single command applies both system and user configurations (Home Manager is a NixOS module):

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Rollback

```bash
sudo nixos-rebuild switch --rollback
```

### Maintenance

```bash
nix flake update && nix-collect-garbage -d
```

## Linting / Static Analysis

```bash
deadnix -W .    # detect unused variables
statix check .  # static analysis for Nix patterns
```

## Updating

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .#myhost
```

## Code Style

### Formatting
- **Indentation**: 2 spaces, no tabs
- **No automated formatter** (no alejandra/nixfmt) — follow existing style
- One attribute per line in attrsets
- Lists: one item per line when > 2 items or any item is complex

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | kebab-case | `git-sync.nix` |
| Options | camelCase | `hardware.opengl.enable` |
| Variables | camelCase | `nixpkgsHost` |
| Folders | lowercase | `modules/system/` |

## Customization

### Hyprland

Config files are in `modules/home/hyprland/`:

- `binds.nix` — keyboard shortcuts
- `style.nix` — gaps, borders, animations (liquid glass effect)
- `exec-once.nix` — autostart applications
- `swaync/` — SwayNC notifications configuration
- `scripts/` — shell scripts

### Neovim (nixvim)

Edit `home.nix` under `programs.nixvim` to customize.

### Packages

Add packages in two places:

1. **System-wide**: `hosts/myhost/configuration.nix` → `environment.systemPackages`
2. **User-level**: `home.nix` → `home.packages`

## Git Sync (LAN)

After each commit, a post-commit hook sends a UDP signal to all other hosts on the LAN. Each host runs a listener that automatically runs `git pull --rebase --autostash`.

No manual sync needed — commit on one machine, others update automatically.

## Remote Host Management

Manage other hosts via SSH. Example:

```bash
ssh -o ConnectTimeout=3 zumuvik@192.168.10.242 "cd /etc/nixos && git status"
```

Known hosts:

| Host | IP | Description |
|------|-----|-------------|
| nixlensk321 | 192.168.10.242 | Laptop |
| nixlensk322 | 192.168.10.120 | Server |
| nixlensk323 | 192.168.10.210 | Gaming PC |

## Web Services (nixlensk322)

Nginx virtual hosts in `modules/system/sites/`.

| Site | Domain |
|------|--------|
| Roundcube | mail.samolensk.ru |

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

## For AI Coding Agents

See [`AGENTS.md`](./AGENTS.md) for detailed guidelines:
- Directory structure details
- Module patterns and imports
- Nix idioms (conditionals, package lists, attribute ordering)
- Comments style
- Error handling
- Shell script conventions
- Git workflow
- Adding new hosts
