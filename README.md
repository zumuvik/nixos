# NixOS Configuration

Flake-based NixOS configuration for multiple hosts with Hyprland desktop.

## Machines

| Host | Role | Features |
|------|------|----------|
| `nixlensk321` | Laptop | Hyprland, battery management, Zen kernel |
| `nixlensk322` | Server/Router | Podman, Nginx, Firewall |
| `nixlensk323` | Gaming PC | Hyprland, Steam, Zen kernel, AMD GPU |

## Modular Structure

The configuration uses a modular approach with a custom `my.*` namespace for all system options.

```
.
├── flake.nix                  # Flake entry point
├── configuration.nix          # Shared system config (core)
├── home.nix                   # Shared Home Manager config
├── lib/default.nix            # Shared variables (username)
├── secrets/                   # Encrypted secrets (sops-nix)
├── hosts/
│   ├── <host>/                # Host-specific entry points
│   │   ├── default.nix        # Host imports
│   │   └── configuration.nix  # Host feature toggles (my.*)
├── modules/
│   ├── nixos/                 # NixOS Modules (Namespace: my.*)
│   │   ├── services/          # Services (nginx, mailserver)
│   │   ├── hardware/          # Hardware (bluetooth, amdgpu, laptop, kernel)
│   │   ├── ui/                # UI (fonts, greetd, common)
│   │   └── gaming.nix         # Gaming optimizations
│   ├── home/                  # Home Manager Modules
│   │   ├── profiles/          # Shared home profiles (desktop)
│   │   └── hyprland/          # Hyprland WM config
│   ├── profiles/              # NixOS System Profiles (server, desktop)
│   └── programs/              # Home Manager program configs (nixvim, fish, etc)
├── AGENTS.md                  # Instructions for AI coding agents
└── SETUP_MANUAL.md            # Installation guide
```

## How to use modular options

Instead of manually importing files, enable features in `hosts/<host>/configuration.nix`:

```nix
{ ... }: {
  my.profiles.desktop.enable = true;
  my.hardware.amdgpu.enable = true;
  my.hardware.bluetooth.enable = true;
  my.gaming.enable = true;
}
```

## Build and Deploy

### Verification (run BEFORE applying)

```bash
sudo nixos-rebuild build --flake .#<hostname>   # dry-run
home-manager build --flake .#<hostname>         # Home Manager only
nix flake check                                 # check flake outputs
```

### Apply

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Customization

### Hyprland

Config files are in `modules/home/hyprland/`:
- `binds.nix` — keyboard shortcuts
- `style.nix` — gaps, borders, animations
- `exec-once.nix` — autostart

### Neovim (nixvim)

Edit `modules/programs/nixvim.nix` to customize the declarative Neovim experience.

## Management

### Known hosts

| Host | IP | Description |
|------|-----|-------------|
| nixlensk321 | 192.168.10.242 | Laptop |
| nixlensk322 | 192.168.10.120 | Server |
| nixlensk323 | 192.168.10.210 | Gaming PC |

### Services (Server nixlensk322)

| Site | Domain | Module |
|------|--------|--------|
| Roundcube | mail.samolensk.ru | `roundcube.nix` |

## Code Style

- **Namespace**: Use `my.<category>.<feature>.enable` for all module toggles.
- **Indentation**: 2 spaces.
- **Naming**: kebab-case for files, camelCase for options.

## For AI Coding Agents

See [`AGENTS.md`](./AGENTS.md) for detailed guidelines on the new modular structure and coding standards.
