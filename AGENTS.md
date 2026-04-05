# AGENTS.md — NixOS Configuration

## Project Overview

Flake-based NixOS configuration with Home Manager. Language: Nix.
- **WM**: Hyprland (Wayland)
- **Editor**: Neovim (via nixvim)
- **Terminal**: Ghostty
- **Hosts**: `nixlensk321` (laptop), `nixlensk322` (server/router), `nixlensk323` (gaming PC)

## Directory Structure

```
├── flake.nix / flake.lock          # Entry point, hosts, inputs
├── configuration.nix              # Shared system config
├── home.nix                       # Shared Home Manager config
├── lib/default.nix                # Shared variables (username = "zumuvik")
├── hosts/<host>/                  # Host-specific configs
│   ├── default.nix                # Imports for the host
│   ├── configuration.nix          # Host system settings
│   └── hardware-configuration.nix  # Auto-generated hardware config
├── modules/
│   ├── system/                    # NixOS modules (services, hardware, etc.)
│   │   ├── sites/                 # Web sites (nginx, applications)
│   ├── home/                      # Home Manager modules (common, hyprland)
│   └── programs/                  # Program configs (nixvim, ghostty, zsh, etc.)
```

## Build / Test / Deploy

```bash
# ── Verification (run BEFORE applying) ──────────────────────

# Dry-run build — catches errors without changing anything
sudo nixos-rebuild build --flake .#<hostname>

# Build only Home Manager config (faster iteration)
home-manager build --flake .#<hostname>

# Evaluate a specific value (debugging)
nix eval .#nixosConfigurations.nixlensk321.pkgs.hyprland.outPath

# Check flake outputs
nix flake check

# ── Apply changes ───────────────────────────────────────────

# Apply system config
sudo nixos-rebuild switch --flake .#<hostname>

# Apply Home Manager config
home-manager switch --flake .#<hostname>

# ── Rollback ────────────────────────────────────────────────

sudo nixos-rebuild switch --rollback
home-manager switch --rollback

# ── Maintenance ─────────────────────────────────────────────

# Update flake inputs
nix flake update

# Garbage collect old generations
nix-collect-garbage -d
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
| Files | kebab-case | `git-sync.nix`, `hardware-configuration.nix` |
| Options | camelCase | `hardware.opengl.enable` |
| Variables | camelCase | `nixpkgsHost`, `hardwareConfig` |
| Folders | lowercase | `modules/system/`, `modules/home/` |

### Module Patterns

```nix
# default.nix — re-exports siblings
{ ... }: { imports = [ ./module1.nix ./module2.nix ]; }

# module.nix — actual config
{ config, pkgs, lib, ... }: {
  # use mkIf, mkMerge, mkDefault as needed
}
```

### Imports
- Use `imports = [ ./file.nix ];` — always include `.nix` extension
- `default.nix` imports siblings via `./module.nix`
- Flake inputs: `inputs.nixvim.homeModules.nixvim`

### Nix Idioms

```nix
# Conditionals
mkIf condition { }
lib.optionals (hostName == "nixlensk323") [ pkgs.something ]

# Merging
lib.mkMerge [ baseOverrides hostOverrides ]

# Multi-line strings
''
  line one
  line two
''

# Package lists
home.packages = with pkgs; [ pkg1 pkg2 ];
```

### Comments
- Section separators: `# ──────────────────────────────────────────────`
- Russian comments are acceptable
- Descriptive headers: `# Services`, `# Hardware`, `# Hyprland`

### Error Handling
- Nix errors surface at build time — always run `nixos-rebuild build` first
- Shell scripts (`modules/home/hyprland/scripts/`): `set -euo pipefail`
- **Binary naming**: Hyprland package provides `Hyprland` (for DM) and `start-hyprland` (for shell). Do NOT use `Hyprland-start` — it doesn't exist.
- **Option existence**: Always verify options exist in your nixpkgs version. E.g., `services.nsncd` does NOT exist — use `services.nscd` instead.

## Git Workflow

- Branches: `main` (default), `alpha`, `beta`
- Auto-sync via LAN (UDP port 9876) — commits propagate to all hosts
- **Do not commit without explicit user request**

## Adding a New Host

1. Create `hosts/<hostname>/` with `default.nix`, `configuration.nix`, `hardware-configuration.nix`
2. Register in `flake.nix` under `nixosConfigurations` via `makeHost`
3. Build: `sudo nixos-rebuild build --flake .#<hostname>`

```nix
makeHost { hostName = "myhost"; enableBluetooth = true; }
```

## Sites & Nginx (Server nixlensk322)

Web-сайты управляются через модули в `modules/system/sites/`.

### Adding a New Site

1. Create `modules/system/sites/<sitename>.nix` with nginx virtualHost config
2. Import in `modules/system/sites/default.nix`
3. Add `enableACME = true` and `forceSSL = true` for HTTPS
4. Files go to `/var/www/sites/<domain>/`

### Current Sites

| Site | Domain | Module |
|------|--------|--------|
| Roundcube | mail.samolensk.ru | `roundcube.nix` |

### Nginx Commands

```bash
sudo nginx -t          # Test config
sudo systemctl reload nginx
sudo journalctl -u nginx -f
```
