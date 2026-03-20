#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# bootstrap.sh — Setup complet sur VPS Ubuntu/Debian fresh
#
# Usage :
#   curl -sL https://raw.githubusercontent.com/TON_USER/dotfiles/main/bootstrap.sh | bash
#
# Ce que ça fait :
#   1. Installe les packages apt (tmux, vim, fzf, git, curl)
#   2. Installe lazygit
#   3. Installe zoxide
#   4. Installe starship (prompt)
#   5. Clone le repo dotfiles
#   6. Crée les symlinks (~/.vimrc, ~/.tmux.conf, ~/tmux-sessions/)
#   7. Installe TPM (plugin manager tmux)
#   8. Installe les plugins tmux en headless
# ─────────────────────────────────────────────────────────

set -e  # stop si erreur

DOTFILES_REPO="https://github.com/clawassistantgf-dev/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}▶${NC} $1"; }
ok()  { echo -e "${GREEN}✓${NC} $1"; }

# ── 1. Packages apt ────────────────────────────────────
log "Installation des packages apt..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  tmux \
  vim \
  fzf \
  git \
  curl \
  wget \
  unzip \
  build-essential
ok "Packages apt installés"

# ── 2. lazygit ─────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
  log "Installation de lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
  curl -sLo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo mv /tmp/lazygit /usr/local/bin/
  ok "lazygit installé (v${LAZYGIT_VERSION})"
else
  ok "lazygit déjà installé"
fi

# ── 3. zoxide ──────────────────────────────────────────
if ! command -v zoxide &>/dev/null; then
  log "Installation de zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  ok "zoxide installé"
else
  ok "zoxide déjà installé"
fi

# ── 4. starship ────────────────────────────────────────
if ! command -v starship &>/dev/null; then
  log "Installation de starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  ok "starship installé"
else
  ok "starship déjà installé"
fi

# ── 5. Clone dotfiles ──────────────────────────────────
if [ ! -d "$DOTFILES_DIR" ]; then
  log "Clone du repo dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  ok "Dotfiles clonés dans $DOTFILES_DIR"
else
  log "Dotfiles déjà présents — pull..."
  git -C "$DOTFILES_DIR" pull --rebase
  ok "Dotfiles mis à jour"
fi

# ── 6. Symlinks ────────────────────────────────────────
log "Création des symlinks..."

# Backup si un fichier existe déjà (pas un symlink)
backup_if_exists() {
  local target="$1"
  if [ -f "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "  Backup de $target"
  fi
}

backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.tmux.conf"

ln -sf "$DOTFILES_DIR/.vimrc"     "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Sessions tmux
mkdir -p "$HOME/tmux-sessions"
ln -sf "$DOTFILES_DIR/tmux-sessions/monitoring.sh" "$HOME/tmux-sessions/monitoring.sh"
ln -sf "$DOTFILES_DIR/tmux-sessions/dev.sh"         "$HOME/tmux-sessions/dev.sh"
ln -sf "$DOTFILES_DIR/tmux-sessions/brainstorm.sh"  "$HOME/tmux-sessions/brainstorm.sh"
chmod +x "$HOME/tmux-sessions/"*.sh

ok "Symlinks créés"

# ── 7. Ajouter starship + zoxide au shell ──────────────
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "starship init" "$SHELL_RC" 2>/dev/null; then
  log "Ajout de starship au shell..."
  echo '' >> "$SHELL_RC"
  echo '# Starship prompt' >> "$SHELL_RC"
  echo 'eval "$(starship init bash)"' >> "$SHELL_RC"
fi

if ! grep -q "zoxide init" "$SHELL_RC" 2>/dev/null; then
  log "Ajout de zoxide au shell..."
  echo '' >> "$SHELL_RC"
  echo '# zoxide (cd intelligent)' >> "$SHELL_RC"
  echo 'eval "$(zoxide init bash)"' >> "$SHELL_RC"
fi

# Alias utiles
if ! grep -q "alias vf=" "$SHELL_RC" 2>/dev/null; then
  log "Ajout des alias..."
  cat >> "$SHELL_RC" << 'EOF'

# Dotfiles aliases
alias vf='vim $(fzf)'                        # ouvre un fichier avec fuzzy search
alias tls='tmux ls'                          # liste les sessions tmux
alias ta='tmux attach -t'                    # attach à une session : ta nom
alias ts='tmux-sessions'                     # raccourci vers les templates
alias mon='~/tmux-sessions/monitoring.sh'    # lance monitoring
alias dev='~/tmux-sessions/dev.sh'           # lance dev
alias bst='~/tmux-sessions/brainstorm.sh'    # lance brainstorm
EOF
fi

ok "Shell configuré"

# ── 8. TPM + plugins tmux ──────────────────────────────
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installation de TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  ok "TPM installé"
else
  ok "TPM déjà installé"
fi

# Installation headless des plugins (sans tmux ouvert)
log "Installation des plugins tmux..."
"$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
ok "Plugins tmux installés"

# ── Done ───────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup terminé ✓${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  source $SHELL_RC   (ou reconnecte-toi)"
echo ""
echo "  Lancer une session :"
echo "    mon <nom> <dossier>    # monitoring"
echo "    dev <nom> <dossier>    # dev/bot"
echo "    bst <nom> <dossier>    # brainstorm"
echo ""
