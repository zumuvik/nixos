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
│   ├── home/                      # Home Manager modules (common, hyprland)
│   └── programs/                  # Program configs (nixvim, ghostty, zsh, etc.)
```

## Build & Deployment Commands

```bash
# Build system config (dry run - no changes)
sudo nixos-rebuild build --flake .#<hostname>

# Apply system config
sudo nixos-rebuild switch --flake .#<hostname>

# Apply Home Manager config
home-manager switch --flake .#<hostname>

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Update flake inputs
nix flake update

# Build a specific host (examples)
sudo nixos-rebuild build --flake .#nixlensk321
sudo nixos-rebuild build --flake .#nixlensk322
sudo nixos-rebuild build --flake .#nixlensk323

# Shell with Nix tools for debugging
nix develop .#nixosConfigurations.nixlensk321.config.system.build.toplevel
```

## Code Style Guidelines

### Formatting

- **Indentation**: 2 spaces (no tabs)
- Verified in nixvim: `tabstop = 2`, `shiftwidth = 2`, `expandtab = true`
- No automated formatters (alejandra/nixfmt) — follow existing style

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | kebab-case | `git-sync.nix`, `hardware-configuration.nix` |
| Nix options | camelCase | `hardware.opengl.enable`, `services.openssh.enable` |
| Nix variables | camelCase | `nixpkgsHost`, `hardwareConfig` |
| Folders | lowercase | `modules/system/`, `modules/home/` |

### Module Patterns

**Standard module structure:**
```nix
# default.nix — re-exports sibling modules
{ ... }: {
  imports = [
    ./module1.nix
    ./module2.nix
  ];
}

# module.nix — actual configuration
{ config, pkgs, lib, ... }:

{
  # Configuration options
}
```

**Host-specific modules:**
```nix
{ ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/some-module.nix
  ];
}
```

### Imports

- Use `imports = [ ./file.nix ];` for module imports
- `default.nix` imports sibling modules via `./module.nix`
- Hosts import shared configs: `../../configuration.nix`, `../../modules/system/`
- Use flake inputs directly in home.nix: `inputs.nixvim.homeModules.nixvim`

### Nix Idioms

```nix
# Conditional activation
mkIf condition [ ]

# Conditional packages (string comparison)
lib.optionals (hostName == "nixlensk323") [ ]

# Merging configurations
lib.mkMerge [ config1 config2 ]

# Multi-line strings
''
  first line
  second line
''

# with pkgs for package lists (home.packages, etc.)
home.packages = with pkgs; [
  package1
  package2
];
```

### Comments

- Section separators: `# ──────────────────────────────────────────────`
- Comments in Russian are acceptable
- Descriptive section headers: `# Services`, `# Hardware`, `# Hyprland`

### Error Handling

- Nix is declarative — errors surface during build validation
- For shell scripts (`modules/home/hyprland/scripts/`): `set -euo pipefail`
- Always verify syntax with `nixos-rebuild build` before committing

## Git Workflow

- Branches: `master`, `main`, `alpha`, `beta`
- Auto-sync via LAN (UDP port 9876) — commits propagate to all hosts
- **Do not commit without explicit user request**

## Adding a New Host

1. Create directory: `hosts/<hostname>/`
2. Generate hardware config: `sudo nixos-generate-config --dir hosts/<hostname>`
3. Create `hosts/<hostname>/default.nix` with imports
4. Register in `flake.nix` under `nixosConfigurations`
5. Build and test: `sudo nixos-rebuild build --flake .#<hostname>`

## Optional Modules

Enable in `flake.nix` via `makeHost`:
```nix
makeHost {
  hostName = "myhost";
  enableBluetooth = true;  # or false
  enableRouter = true;     # or false
}
```
