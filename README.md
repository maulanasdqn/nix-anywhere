# nix-anywhere

My personal unified Nix configuration for both **NixOS** and **macOS** (nix-darwin), with home-manager and nixvim.

## Structure

```
.
├── flake.nix                       # Main entry point
├── flake.lock
├── config.nix                      # User configuration
├── config.example.nix              # Example configuration
├── .envrc                          # Direnv integration
├── hosts/
│   ├── workstation/                # NixOS workstation config
│   └── vps/                        # VPS configurations (nixos-anywhere)
│       ├── hostinger/              # Hostinger VPS (static IP, BIOS)
│       └── digitalocean/           # DigitalOcean Droplet (DHCP, hybrid boot)
├── profiles/
│   ├── base.nix                    # Base profile for all systems
│   └── server.nix                  # Server profile (hardened SSH, nginx, docker)
├── templates/                      # Devenv project templates
│   ├── laravel/
│   ├── nodejs/
│   └── rust/
└── modules/
    ├── nix.nix                     # Nix/Determinate settings
    ├── darwin/                     # macOS-specific modules
    │   ├── default.nix
    │   ├── defaults/               # macOS system defaults
    │   ├── fonts/
    │   ├── homebrew/
    │   ├── packages/
    │   ├── security/
    │   ├── system/
    │   ├── yabai/                  # Tiling WM
    │   ├── skhd/                   # Hotkey daemon
    │   └── sketchybar/             # Custom menu bar
    ├── nixos/                      # NixOS-specific modules
    │   ├── default.nix
    │   ├── boot.nix
    │   ├── hardware.nix
    │   ├── networking.nix
    │   ├── locale.nix
    │   ├── desktop.nix
    │   ├── audio.nix
    │   ├── users.nix
    │   ├── fonts.nix
    │   ├── programs.nix
    │   └── nix.nix
    └── home/
        ├── darwin.nix              # macOS home entry point
        ├── nixos.nix               # NixOS home entry point
        ├── packages/
        │   ├── darwin.nix          # macOS packages
        │   └── nixos.nix           # NixOS packages
        ├── hyprland/               # NixOS-only (Wayland compositor)
        ├── vscode/                 # NixOS-only
        ├── docker/                 # macOS-only (Colima)
        ├── ghostty/                # macOS-only
        ├── laravel/                # macOS-only
        ├── services/               # macOS-only
        ├── sketchybar/             # macOS-only
        ├── sops/                   # macOS-only
        ├── wallpaper/              # macOS-only
        └── ... (shared)
            ├── git/
            ├── neovim/
            ├── starship/
            ├── ssh/
            ├── tmux/
            └── zsh/
```

## What's Included

### Shared (Both Platforms)

| Component | Description |
|-----------|-------------|
| **Neovim** | Full IDE with LSP, Treesitter, Telescope, Rose Pine theme |
| **Zsh** | Oh-My-Zsh, syntax highlighting, autosuggestions |
| **Starship** | Cross-shell prompt |
| **Tmux** | Terminal multiplexer with Rose Pine theme |
| **Git** | Git configuration with delta |

### macOS (nix-darwin)

| Component | Description |
|-----------|-------------|
| **Yabai** | Tiling window manager (optional) |
| **skhd** | Hotkey daemon (optional) |
| **Sketchybar** | Custom menu bar (optional) |
| **Ghostty** | GPU-accelerated terminal |
| **Homebrew** | Casks and formulae |
| **Colima** | Docker runtime |
| **Laravel** | PHP development environment (optional) |
| **Sops-nix** | Secrets management |

### NixOS

| Component | Description |
|-----------|-------------|
| **GNOME** | Desktop environment (default) |
| **Hyprland** | Wayland compositor (optional) |
| **Waybar** | Status bar (optional) |
| **Wofi** | Application launcher (optional) |
| **VSCode** | Visual Studio Code |
| **PipeWire** | Audio |

## Installation

### macOS

```bash
# Prerequisites: Determinate Nix
# https://determinate.systems/posts/determinate-nix-installer

# Clone the repo
git clone git@github.com:maulanasdqn/nix-anywhere.git ~/.config/nix
cd ~/.config/nix

# Create your configuration
cp config.example.nix config.nix
nvim config.nix

# Build and apply
nix develop --command rebuild
```

### NixOS

```bash
# Clone the repo
git clone git@github.com:maulanasdqn/nix-anywhere.git ~/.config/nix
cd ~/.config/nix

# Create your configuration
cp config.example.nix config.nix
nvim config.nix

# Generate hardware config (first time only)
sudo nixos-generate-config --show-hardware-config > modules/nixos/hardware.nix

# Build and apply
sudo nixos-rebuild switch --flake .#nixos
```

### VPS Deployment (nixos-anywhere)

Deploy NixOS to a fresh VPS running Ubuntu/Debian:

```bash
# Hostinger VPS (uses static IP, BIOS boot, LTS kernel)
nix run github:nix-community/nixos-anywhere -- \
  --flake .#hostinger --build-on remote root@<VPS_IP>

# DigitalOcean Droplet (uses DHCP, hybrid BIOS/EFI boot)
nix run github:nix-community/nixos-anywhere -- \
  --flake .#digitalocean --build-on remote root@<VPS_IP>
```

**VPS Provider Configurations:**

| Provider | Boot Mode | Disk Device | Network | Kernel |
|----------|-----------|-------------|---------|--------|
| Hostinger | BIOS (GRUB) | `/dev/sda` | Static IP | LTS 6.6 |
| DigitalOcean | Hybrid BIOS/EFI | `/dev/vda` | DHCP | Latest |

**Note:** For Hostinger, edit `hosts/vps/hostinger/default.nix` to set your static IP, gateway, and nameservers before deployment.

## Configuration

Edit `config.nix` to customize your setup:

```nix
{
  # Your username (used for both platforms)
  username = "your-username";

  # Hostnames
  darwinHostname = "your-mac-hostname";
  nixosHostname = "your-nixos-hostname";

  # Optional features
  enableLaravel = true;      # PHP, Composer, MySQL, PostgreSQL, Redis (macOS only)
  enableTilingWM = true;     # Tiling WM (see below)

  # SSH public keys
  sshKeys = [
    "ssh-ed25519 AAAAC3Nza... user@example.com"
  ];
}
```

| Option | Type | Platform | Description |
|--------|------|----------|-------------|
| `username` | string | Both | Your username |
| `darwinHostname` | string | macOS | Machine hostname |
| `nixosHostname` | string | NixOS | Machine hostname |
| `enableLaravel` | bool | macOS | Enable PHP/Laravel stack |
| `enableTilingWM` | bool | Both | macOS: yabai/skhd/sketchybar, NixOS: hyprland/waybar/wofi |
| `sshKeys` | list | Both | SSH public keys |

## Usage

### macOS

```bash
# Rebuild
sudo darwin-rebuild switch --flake .#mrscraper

# Or use the helper
nix develop --command rebuild
```

### NixOS

```bash
# Rebuild
sudo nixos-rebuild switch --flake .#nixos

# Or use the helper in dev shell
nix develop --command rebuild
```

## Keybindings

### macOS (skhd)

| Key | Action |
|-----|--------|
| `Cmd + Enter` | Open Ghostty |
| `Cmd + 1-9` | Switch workspace |
| `Cmd + Shift + 1-9` | Move window to workspace |
| `Cmd + h/j/k/l` | Focus window |
| `Cmd + Shift + h/j/k/l` | Swap windows |
| `Cmd + Shift + f` | Toggle fullscreen |
| `Cmd + t` | Toggle float |

### NixOS (Hyprland)

| Key | Action |
|-----|--------|
| `Super + Enter` | Open terminal |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + h/j/k/l` | Focus window |
| `Super + Shift + h/j/k/l` | Move window |
| `Super + d` | Open Wofi |
| `Super + q` | Close window |

### Neovim

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>e` | Toggle file tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `<leader>ca` | Code action |

### Tmux

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix key |
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `prefix + h/j/k/l` | Navigate panes |

## Shell Aliases

| Alias | Command |
|-------|---------|
| `v` | nvim |
| `t` | tmux startup script |
| `gs` | git status |
| `ga` | git add |
| `gc` | git commit |
| `gp` | git push |
| `ls` | eza --icons |
| `ll` | eza -la --icons |
| `cat` | bat |

## License

MIT
