# nix-darwin

My personal macOS configuration using nix-darwin, home-manager, and nixvim.

## Structure

```
.
├── flake.nix                       # Main entry point
├── flake.lock
├── config.nix                      # User configuration (git-ignored)
├── config.example.nix              # Example configuration
├── .envrc                          # Direnv integration
├── templates/                      # Devenv project templates
│   ├── laravel/
│   ├── nodejs/
│   └── rust/
└── modules/
    ├── nix.nix                     # Nix/Determinate settings
    ├── darwin/
    │   ├── default.nix             # Darwin module entry
    │   ├── defaults/
    │   │   ├── default.nix         # Defaults entry
    │   │   ├── dock.nix            # Dock settings
    │   │   ├── finder.nix          # Finder settings
    │   │   ├── global.nix          # Global macOS settings
    │   │   └── trackpad.nix        # Trackpad gestures
    │   ├── fonts/
    │   │   └── default.nix         # Nerd Fonts
    │   ├── homebrew/
    │   │   └── default.nix         # Homebrew casks & brews
    │   ├── packages/
    │   │   └── default.nix         # System packages
    │   ├── security/
    │   │   └── default.nix         # Touch ID, sudo
    │   ├── system/
    │   │   └── default.nix         # System settings
    │   ├── yabai/
    │   │   └── default.nix         # Tiling window manager
    │   ├── skhd/
    │   │   └── default.nix         # Keyboard shortcuts
    │   └── sketchybar/
    │       └── default.nix         # Custom menu bar
    └── home/
        ├── default.nix             # Home-manager entry
        ├── docker/
        │   └── default.nix         # Colima & Docker
        ├── ghostty/
        │   └── default.nix         # Ghostty terminal
        ├── git/
        │   └── default.nix         # Git configuration
        ├── laravel/
        │   └── default.nix         # PHP, Composer, databases
        ├── neovim/
        │   ├── default.nix         # Neovim entry
        │   ├── keymaps.nix         # Key mappings
        │   ├── options.nix         # Editor options
        │   └── plugins/
        │       ├── default.nix     # Plugins entry
        │       ├── colorscheme.nix # Rose-pine theme
        │       ├── cmp.nix         # Autocompletion
        │       ├── formatting.nix  # Formatters & autopairs
        │       ├── lsp.nix         # Language servers
        │       ├── telescope.nix   # Fuzzy finder
        │       ├── treesitter.nix  # Syntax highlighting
        │       └── ui.nix          # UI components
        ├── packages/
        │   └── default.nix         # CLI tools
        ├── services/
        │   └── default.nix         # Auto-start services
        ├── sketchybar/
        │   └── default.nix         # Sketchybar plugins
        ├── sops/
        │   └── default.nix         # Secrets management
        ├── starship/
        │   └── default.nix         # Starship prompt
        ├── tmux/
        │   ├── default.nix         # Tmux entry
        │   ├── keybindings.nix     # Tmux keybindings
        │   └── theme.nix           # Rose-pine theme
        ├── wallpaper/
        │   └── default.nix         # NixOS wallpaper
        └── zsh/
            ├── default.nix         # Zsh entry
            └── aliases.nix         # Shell aliases
```

## What's Included

### Window Management (yabai + skhd + sketchybar)

A complete tiling window manager setup similar to Hyprland on Linux:

- **Yabai** - Binary space partitioning tiling WM
- **skhd** - Simple hotkey daemon for keybindings
- **Sketchybar** - Custom menu bar with Rose Pine theme

#### Sketchybar Features
- Nix logo (click to open System Settings)
- Workspace icons (terminal, browser, slack, discord, code, folder, music, mail, settings)
- Current app name
- CPU & Memory usage
- Battery with charging indicator
- WiFi network name (click to open WiFi settings)
- Volume level (click to open Sound settings)
- Date & Time

### System (darwin)
- Touch ID for sudo
- Passwordless sudo
- Nerd Fonts (JetBrains Mono, Fira Code, Hack)
- macOS defaults (dock disabled, finder, keyboard)
- Three-finger swipe for workspace switching
- Reduced motion/animations
- Homebrew integration
- Caps Lock <-> Escape swap

### Development

#### Languages & Runtimes
- **PHP 8.3** with Laravel extensions (composer, phpactor, php-cs-fixer)
- **TypeScript/JavaScript** via Volta, Bun, Deno
- **Rust** via rustup with rustaceanvim
- **Lua** with stylua formatter
- **Nix** with nil LSP and nixfmt

#### Databases
- MySQL (via Homebrew, auto-start)
- PostgreSQL 16 (via Homebrew, auto-start)
- Redis (via Homebrew, auto-start)

#### Docker
- Colima (Docker runtime for macOS)
- Docker client & docker-compose

#### Devenv Templates
Quick project setup with direnv:
```bash
init-laravel   # Laravel/PHP project
init-nodejs    # Node.js project
init-rust      # Rust project
```

### Shell (zsh)
- Oh-My-Zsh with git, z, docker plugins
- Starship prompt
- Zoxide, fzf integration
- Syntax highlighting & autosuggestions
- Useful aliases for git, docker, php artisan

### Editor (neovim via nixvim)
- Rose-pine theme with transparent background
- Full LSP support:
  - PHP (phpactor)
  - TypeScript/JavaScript (ts_ls, eslint)
  - Rust (rustaceanvim)
  - Tailwind CSS, HTML, CSS, JSON
  - Lua, Nix
- Treesitter with context
- Telescope fuzzy finder
- Neo-tree file explorer
- Git signs, lualine, which-key
- Autocompletion with nvim-cmp
- Format on save
- Claude Code integration (claudecode.nvim)
- Noice.nvim for better UI

### Terminal (Ghostty)
- Rose Pine color scheme
- Background blur & transparency
- Hidden titlebar

### Terminal Multiplexer (tmux)
- Rose-pine theme
- Vim-like navigation
- Mouse support
- Custom keybindings with `Ctrl+a` prefix
- Auto-start with predefined sessions

### Apps (via Homebrew)
- Microsoft Edge
- Ghostty
- Postman
- Discord
- Raycast (Spotlight replacement)
- Shottr (Screenshot tool)

## Installation

### Prerequisites
- macOS on Apple Silicon
- [Determinate Nix](https://determinate.systems/posts/determinate-nix-installer)

### Setup

```bash
# Clone the repo
git clone git@github.com:maulanasdqn/nix-darwin.git ~/.config/nix
cd ~/.config/nix

# Create your configuration
cp config.example.nix config.nix

# Edit config.nix with your settings
nvim config.nix

# Build and apply
nix develop --command rebuild
```

### Enable Yabai Scripting Addition (for workspace switching)

```bash
# 1. Shut down Mac
# 2. Hold power button -> Options -> Recovery
# 3. Open Terminal and run:
csrutil enable --without fs --without debug --without nvram

# 4. Reboot, then run:
sudo nvram boot-args=-arm64e_preview_abi
sudo yabai --load-sa
```

## Configuration

Edit `config.nix` to customize your setup:

```nix
{
  # Your macOS username
  username = "your-username";

  # Enable/disable Laravel development environment
  enableLaravel = true;

  # SSH public keys for authorized_keys
  sshKeys = [
    "ssh-ed25519 AAAAC3Nza... user@example.com"
  ];
}
```

| Option | Type | Description |
|--------|------|-------------|
| `username` | string | Your macOS username |
| `enableLaravel` | bool | Enable PHP, Composer, MySQL, PostgreSQL, Redis |
| `sshKeys` | list | SSH public keys for `~/.ssh/authorized_keys` |

## Secrets Management

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using age encryption.

### Setup

```bash
# Your age key is at ~/.config/sops/age/keys.txt
# Public key is in .sops.yaml

# Edit secrets (will decrypt, open editor, re-encrypt)
sops secrets/secrets.yaml
```

### Available Secrets

| Secret | Location |
|--------|----------|
| `github_token` | `~/.config/sops-nix/secrets/github_token` |
| `openai_api_key` | `~/.config/sops-nix/secrets/openai_api_key` |
| `anthropic_api_key` | `~/.config/sops-nix/secrets/anthropic_api_key` |
| `database_password` | `~/.config/sops-nix/secrets/database_password` |
| `ssh_private_key` | `~/.ssh/id_ed25519` (symlinked) |

## Usage

```bash
# Rebuild after making changes
build-system

# Or manually
sudo darwin-rebuild switch --flake ~/.config/nix

# Start tmux with all sessions
t
```

## Keybindings

### Window Management (skhd)

| Key | Action |
|-----|--------|
| `Cmd + Enter` | Open Ghostty terminal |
| `Cmd + 1-9` | Switch to workspace 1-9 |
| `Cmd + Shift + 1-9` | Move window to workspace 1-9 |
| `Cmd + h/j/k/l` | Focus window (left/down/up/right) |
| `Cmd + Shift + h/j/k/l` | Swap windows |
| `Cmd + Ctrl + h/j/k/l` | Warp (move) window |
| `Cmd + Alt + h/j/k/l` | Resize window |
| `Cmd + Shift + f` | Toggle fullscreen |
| `Cmd + t` | Toggle float |
| `Cmd + b` | Balance windows |
| `Cmd + r` | Rotate layout 90° |
| `Cmd + e` | Toggle split orientation |
| `Cmd + Shift + q` | Close window |
| `Three-finger swipe` | Switch workspace |

### Neovim

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>e` | Toggle file tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Hover docs |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>f` | Format |
| `[d` / `]d` | Prev/next diagnostic |

### Tmux

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix key |
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + s` | List sessions |
| `prefix + (` / `)` | Prev/next session |
| `prefix + r` | Reload config |

### Tmux Auto-Start Sessions

Running `t` starts tmux with these sessions:
1. **Nix Darwin** - `~/.config/nix`
2. **MRScraperV3** - `~/Development/mrscraper/mrscraper-v3`
3. **MRScraperWEB** - `~/Development/mrscraper/mrscraper-web`
4. **YDM FE** - `~/Development/bsm/yes-date-me-frontend`
5. **YDM BE** - `~/Development/bsm/yes-date-me-backend`
6. **ECHO** - `~/Development/bsm/social-media-automation`
7. **BSM Landing** - `~/Development/bsm/bsmart-landing`

## Shell Aliases

### General
| Alias | Command |
|-------|---------|
| `t` | Start tmux with all sessions |
| `v` | nvim |
| `c` | clear |
| `cl` | claude |
| `build-system` | Rebuild nix-darwin |

### Docker
| Alias | Command |
|-------|---------|
| `dc` | docker-compose |
| `dps` | docker ps |
| `dex` | docker exec -it |

### Laravel/PHP
| Alias | Command |
|-------|---------|
| `pa` | php artisan |
| `pas` | php artisan serve |
| `pam` | php artisan migrate |
| `pamfs` | php artisan migrate:fresh --seed |
| `ci` | composer install |
| `cu` | composer update |

### Git
| Alias | Command |
|-------|---------|
| `gs` | git status |
| `ga` | git add |
| `gc` | git commit |
| `gp` | git push |
| `gl` | git pull |
| `gco` | git checkout |
| `gcb` | git checkout -b |

### File Listing (eza)
| Alias | Command |
|-------|---------|
| `ls` | eza --icons |
| `ll` | eza -la --icons |
| `la` | eza -a --icons |
| `lt` | eza --tree --icons |
| `cat` | bat |

## License

MIT
