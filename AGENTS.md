# AGENTS.md — NixOS Configuration

#
Flake-based NixOS + Home Manager. Language: Nix.
- **WM**: Hyprland | **Editor**: nixvim | **Terminal**: Ghostty
- **Namespace**: `my.*` (custom options)

## Directory Structure

```
flake.nix / flake.lock          # Entry point, hosts, inputs
configuration.nix               # Base system config (Core)
home.nix                        # Shared Home Manager config
lib/default.nix                 # Shared variables (username = "zumuvik")
hosts/<host>/                  # Host-specific configs
  ├── default.nix               # Imports
  └── configuration.nix         # Host-specific feature toggles (my.*)
modules/
  ├── nixos/                    # NixOS custom modules (Namespace: my.*)
  │   ├── services/             # Services (nginx, git-sync, etc.)
  │   ├── hardware/             # Hardware settings (gpu, kernel, etc.)
  │   ├── ui/                   # UI settings (fonts, greetd, etc.)
  │   ├── default.nix           # Index of modules
  │   └── legacy-shims.nix      # Shims for Home Manager compatibility
  ├── home/                     # Home Manager modules
  │   ├── profiles/             # Home profiles (desktop)
  │   └── hyprland/             # WM specific config
  ├── profiles/                 # System profiles (server, desktop)
  └── programs/                 # Application configs (nixvim, fish, etc.)
```

## Build / Test / Deploy

```bash
# Verification (run BEFORE applying)
sudo nixos-rebuild build --flake .#<hostname>   # dry-run
home-manager build --flake .#<hostname>         # Home Manager only
nix flake check                                 # check flake outputs

# Apply
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<hostname>

# Rollback
sudo nixos-rebuild switch --rollback
home-manager switch --rollback
```

## Modular Pattern (IMPORTANT)

All custom functionality must be defined as a module in `modules/nixos/` and tied to the `my.*` namespace.

Example module:
```nix
{ config, lib, pkgs, ... }: {
  options.my.subfolder.feature.enable = lib.mkEnableOption "Feature description";
  config = lib.mkIf config.my.subfolder.feature.enable {
    # implementation
  };
}
```

## Code Style

### Formatting
- **Indentation**: 2 spaces, no tabs
- One attribute per line in attrsets
- Lists: one item per line when > 2 items

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | kebab-case | `git-sync.nix` |
| Options | camelCase | `my.hardware.amdgpu.enable` |
| Folders | lowercase | `modules/nixos/` |

### Imports
- `imports = [ ./file.nix ];` — ALWAYS include `.nix` extension.
- Use conditional imports where appropriate: `lib.optionals condition [ ./module.nix ]`.

## Git Workflow
- Branches: `main`, `alpha`, `beta`
- **Do not commit without explicit user request** (unless completing a task agreed upon).

## Sites & Nginx (Server nixlensk322)

Sites in `modules/nixos/services/`.
| Site | Domain | Module |
|------|--------|--------|
| Roundcube | mail.samolensk.ru | `roundcube.nix` |
| WG-Easy | vpn.samolensk.ru | `wg-easy.nix` |

Add HTTPS: `enableACME = true; forceSSL = true;`
Не забывай делать коммиты при изменениях.
