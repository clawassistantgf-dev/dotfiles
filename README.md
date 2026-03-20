# dotfiles

Setup terminal pro — VPS Ubuntu/Debian + Mac.

## Installation sur VPS fresh

```bash
curl -sL https://raw.githubusercontent.com/TON_USER/dotfiles/main/bootstrap.sh | bash
```

## Contenu

| Fichier | Rôle |
|---|---|
| `.vimrc` | Vim minimal, opinionated |
| `.tmux.conf` | Tmux avec resurrect + statusbar |
| `tmux-sessions/monitoring.sh` | Logs services + db + debug |
| `tmux-sessions/dev.sh` | Dev app/bot + git + run |
| `tmux-sessions/brainstorm.sh` | Spec/réflexion + claude + notes |
| `bootstrap.sh` | Install complète en une commande |

## Sessions tmux

### Monitoring
```bash
mon <session_name> <projet_dir>

# Avec variables d'environnement pour customiser :
LOG1="journalctl -fu monservice" \
LOG2="tail -f /var/log/app.log" \
DB_CMD="psql -U user mydb" \
mon myapp /srv/myapp
```

### Dev
```bash
dev <session_name> <projet_dir>

RUN_CMD="node bot.js" dev monbot /srv/monbot
```

### Brainstorm
```bash
bst <session_name> <projet_dir>
```

## Raccourcis tmux clés

| Raccourci | Action |
|---|---|
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h/j/k/l` | Navigation panes (vim) |
| `Prefix + s` | Vue arbre toutes sessions |
| `Prefix + r` | Reload config |

## Raccourcis shell

| Alias | Action |
|---|---|
| `vf` | Ouvre un fichier avec fzf |
| `ta <nom>` | Attach session tmux |
| `tls` | Liste sessions tmux |
| `mon / dev / bst` | Lance les sessions |
