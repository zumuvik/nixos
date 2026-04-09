# AGENTS.md — NixOS Configuration

Flake-based NixOS + Home Manager. Language: Nix.
- **WM**: Hyprland | **Editor**: nixvim | **Terminal**: Ghostty
- **Hosts**: `nixlensk321` (laptop), `nixlensk322` (server), `nixlensk323` (gaming PC)

## Directory Structure

```
flake.nix / flake.lock          # Entry point, hosts, inputs
configuration.nix               # Shared system config
home.nix                        # Shared Home Manager config
lib/default.nix                 # Shared variables (username = "zumuvik")
hosts/<host>/                  # Host-specific configs
  ├── default.nix               # Imports
  ├── configuration.nix         # Host settings
  └── hardware-configuration.nix # Auto-generated
modules/
  ├── system/                   # NixOS modules (services, hardware, sites)
  │   └── sites/               # Web sites (nginx)
  ├── home/                     # Home Manager (hyprland, common)
  │   └── hyprland/scripts/     # Shell scripts
  └── programs/                 # Program configs (nixvim, ghostty, zsh)
```

## Build / Test / Deploy

```bash
# Verification (run BEFORE applying)
sudo nixos-rebuild build --flake .#<hostname>   # dry-run
home-manager build --flake .#<hostname>         # Home Manager only
nix flake check                                 # check flake outputs

# Evaluate value (debugging)
nix eval .#nixosConfigurations.nixlensk321.pkgs.hyprland.outPath

# Apply
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<hostname>

# Rollback
sudo nixos-rebuild switch --rollback
home-manager switch --rollback

# Maintenance
nix flake update && nix-collect-garbage -d
```

## Linting / Static Analysis

```bash
deadnix -W .    # detect unused variables
statix check .  # static analysis for Nix patterns
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

### Module Patterns

```nix
# default.nix — re-exports siblings
{ ... }: { imports = [ ./module1.nix ./module2.nix ]; }

# module.nix — actual config
{ config, pkgs, lib, ... }: {
  imports = [ ./binds.nix ./style.nix ];
  # use mkIf, mkMerge, mkDefault as needed
}
```

### Imports
- `imports = [ ./file.nix ];` — always include `.nix` extension
- `default.nix` imports siblings via `./module.nix`
- Flake inputs: `inputs.nixvim.homeModules.nixvim`

### Nix Idioms

```nix
# Conditionals
mkIf condition { option = value; }
lib.optionals (hostName == "nixlensk323") [ pkgs.something ]
lib.mkMerge [ baseConfig hostOverrides ]

# Package lists
home.packages = with pkgs; [ pkg1 pkg2 ];
```

### Attribute Ordering
1. `imports` 2. `environment` 3. `boot` 4. `nix` 5. `services`
6. `programs` 7. `users` 8. `system stateVersion`

### Comments
- Section separators: `# ──────────────────────────────────────────────`
- Russian comments are acceptable
- Disable options: `# gestures (disabled - causes errors)`

### Error Handling
- Nix errors surface at build time — run `nixos-rebuild build` first
- Shell scripts: `set -euo pipefail`
- Verify options exist in your nixpkgs version

### Shell Scripts (`modules/home/hyprland/scripts/`)

```bash
#!/usr/bin/env bash
set -euo pipefail

case "$1" in
    "--get")  echo "value" ;;
    "--inc")  echo "increased" ;;
    *)        echo "Usage: $0 --get|--inc" ;;
esac
```

## Git Workflow
- Branches: `main`, `alpha`, `beta`
- Auto-sync via LAN (UDP port 9876)
- **Do not commit without explicit user request**

## Remote Host Management

You can manage other hosts via SSH. Example:

```bash
ssh -o ConnectTimeout=3 zumuvik@192.168.10.242 "cd /etc/nixos && git status"
```

This runs git status on nixlensk321 (laptop). Known hosts:

| Host | IP | Description |
|------|-----|-------------|
| nixlensk321 | 192.168.10.242 | Laptop |
| nixlensk322 | 192.168.10.120 | Server |
| nixlensk323 | 192.168.10.210 | Gaming PC (this host)

## Adding a New Host
1. Create `hosts/<hostname>/` with `default.nix`, `configuration.nix`, `hardware-configuration.nix`
2. Register in `flake.nix` via `makeHost { hostName = "myhost"; }`
3. Build: `sudo nixos-rebuild build --flake .#<hostname>`

## Sites & Nginx (Server nixlensk322)

Sites in `modules/system/sites/`.

| Site | Domain | Module |
|------|--------|--------|
| Roundcube | mail.samolensk.ru | `roundcube.nix` |

```bash
sudo nginx -t && sudo systemctl reload nginx
sudo journalctl -u nginx -f
```

Add HTTPS: `enableACME = true; forceSSL = true;`
Files go to `/var/www/sites/<domain>/`
Не забывай делать комиты при изменении
