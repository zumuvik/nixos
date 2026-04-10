# NixOS Configuration

Personal NixOS configuration for my machines — declarative, flake-based, with Home Manager.

## Machines

| Host | Role | Description |
|------|------|-------------|
| `nixlensk321` | Laptop | Daily driver, portable |
| `nixlensk322` | Server | Router, nginx, web services |
| `nixlensk323` | Desktop | Gaming PC, primary workstation |

## Stack

- **Window Manager**: Hyprland (Wayland)
- **Editor**: Neovim (via nixvim)
- **Terminal**: Ghostty
- **Shell**: Zsh
- **Bar**: AGS (Aylur's GTK Shell)
- **Telegram**: Ayugram (custom build)
- **Boot**: GRUB with Tela theme
- **Locale**: ru_RU.UTF-8

## nixleski323 Special: LLM Inference

- **GPU**: AMD Radeon RX Vega 56 (8GB VRAM)
- **Runtime**: llama.cpp (v8667, ROCm-enabled)
- **Model**: DeepSeek-Coder-V2-Lite (16B params, IQ2_XS quant)
- **API**: REST on localhost:8080
- **Integration**: OpenCode AI development

See [`QUICKSTART.sh`](./QUICKSTART.sh) and [`LLAMA_OPENCODE_INTEGRATION.md`](./LLAMA_OPENCODE_INTEGRATION.md) for setup.

## Quick Start

### Build (dry-run)

```bash
sudo nixos-rebuild build --flake .#<hostname>
home-manager build --flake .#<hostname>
```

### Apply

```bash
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<hostname>
```

### Rollback

```bash
sudo nixos-rebuild switch --rollback
home-manager switch --rollback
```

## Project Structure

```
├── flake.nix                    # Flake entry, inputs, host definitions
├── configuration.nix            # Shared system config (all hosts)
├── home.nix                     # Shared Home Manager config
├── lib/default.nix              # Shared variables (username)
├── hosts/
│   ├── nixlensk321/             # Laptop config
│   ├── nixlensk322/             # Server config
│   ├── nixlensk323/             # Desktop config
│   └── template/                # New host template
├── modules/
│   ├── system/                  # NixOS modules (services, hardware, sites)
│   ├── home/                    # Home Manager modules (hyprland, common)
│   └── programs/                # Program configs (nixvim, ghostty, zsh)
└── AGENTS.md                    # Instructions for coding agents
```

## Flake Inputs

- **nixpkgs**: `nixos-unstable`
- **home-manager**: latest (follows nixpkgs)
- **nixvim**: Neovim via Nix
- **ags**: Aylur's GTK Shell
- **nixcord**: Discord client config
- **ayugram-desktop**: Custom Telegram build
- **grub2-themes**: GRUB theming

## Key Commands

```bash
# Verify config without applying
sudo nixos-rebuild build --flake .#<hostname>

# Apply system + user config
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<hostname>

# Update flake inputs
nix flake update

# Clean old generations
nix-collect-garbage -d

# Debug: evaluate a value
nix eval .#nixosConfigurations.<hostname>.pkgs.hyprland.outPath
```

## Adding a New Host

1. Copy template: `cp -r hosts/template hosts/<hostname>`
2. Generate hardware config: `nixos-generate-config --dir hosts/<hostname>`
3. Register in `flake.nix` via `makeHost`
4. Build: `sudo nixos-rebuild build --flake .#<hostname>`

## Web Services (nixlensk322)

Nginx virtual hosts are defined in `modules/system/sites/`.

| Site | Domain |
|------|--------|
| Roundcube | mail.samolensk.ru |

## Git

- Default branch: `main`
- Other branches: `alpha`, `beta`
- Auto-sync via LAN (UDP 9876)
