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
    │   ├── nix.nix
    │   └── git-sync.nix            # VPS config sync from git
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

### Workstation (NixOS)

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
sudo nixos-rebuild switch --flake .#workstation
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

**Note:** Configure your VPS settings in `config.nix` before deployment.

### VPS Git Sync

After initial deployment, VPS servers automatically sync configuration from git:

```bash
# Config is cloned to /etc/nixos-config on first rebuild
# Auto-sync runs hourly via systemd timer

# Manual sync
ssh root@<VPS_IP> "systemctl start nixos-config-sync.service"

# Check sync status
ssh root@<VPS_IP> "systemctl status nixos-config-sync.timer"
```

**Workflow:**
1. Edit config locally and push to GitHub
2. VPS auto-pulls and rebuilds hourly (or trigger manually)

## Configuration

Edit `config.nix` to customize your setup:

```nix
{
  # Darwin (macOS)
  darwinUsername = "your-username";
  darwinHostname = "your-mac-hostname";
  darwinEnableTilingWM = true;  # yabai, skhd, sketchybar

  # Workstation (NixOS desktop)
  workstationUsername = "your-username";
  workstationHostname = "your-workstation-hostname";
  workstationEnableTilingWM = true;  # hyprland, waybar, wofi

  # VPS - Hostinger
  vpsHostingerUsername = "your-username";
  vpsHostingerHostname = "your-vps-hostname";
  vpsHostingerIP = "your-vps-ip";
  vpsHostingerGateway = "your-gateway-ip";

  # ACME (Let's Encrypt)
  acmeEmail = "your-email@example.com";

  # VPS - DigitalOcean
  vpsDigitalOceanUsername = "your-username";
  vpsDigitalOceanHostname = "your-droplet-hostname";

  # Development tools
  enableLaravel = true;  # PHP, Composer, MySQL, PostgreSQL, Redis
  enableRust = true;     # Rust toolchain (rustup)
  enableVolta = true;    # Node.js version manager

  # SSH public keys
  sshKeys = [
    "ssh-ed25519 AAAAC3Nza... user@example.com"
  ];
}
```

### Configuration Options

| Option | Platform | Description |
|--------|----------|-------------|
| `darwinUsername` | macOS | Your macOS username |
| `darwinHostname` | macOS | Machine hostname |
| `darwinEnableTilingWM` | macOS | Enable yabai/skhd/sketchybar |
| `workstationUsername` | Workstation | Your workstation username |
| `workstationHostname` | Workstation | Machine hostname |
| `workstationEnableTilingWM` | Workstation | Enable hyprland/waybar/wofi |
| `vpsHostingerUsername` | VPS | Hostinger VPS username |
| `vpsHostingerHostname` | VPS | Hostinger VPS hostname |
| `vpsHostingerIP` | VPS | Hostinger static IP address |
| `vpsHostingerGateway` | VPS | Hostinger gateway IP |
| `vpsDigitalOceanUsername` | VPS | DigitalOcean username |
| `vpsDigitalOceanHostname` | VPS | DigitalOcean hostname |
| `acmeEmail` | VPS | Email for Let's Encrypt SSL certificates |
| `enableLaravel` | macOS | Enable PHP/Laravel stack |
| `enableRust` | macOS | Enable Rust toolchain |
| `enableVolta` | macOS | Enable Volta (Node.js manager) |
| `sshKeys` | All | SSH public keys for authorized access |

## Usage

### macOS

```bash
# Rebuild
sudo darwin-rebuild switch --flake .#mrscraper

# Or use the helper
nix develop --command rebuild
```

### Workstation

```bash
# Rebuild
sudo nixos-rebuild switch --flake .#workstation

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

### Workstation (Hyprland)

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
