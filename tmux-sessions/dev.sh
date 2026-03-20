#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# Session : dev
# Usage   : ./dev.sh <nom_session> <dossier_projet>
#
# Exemples :
#   ./dev.sh monbot /srv/monbot
#   ./dev.sh alertservice ~/projets/alertservice
#
# Layout :
#   Window 1 "claude"  → shell principal (claude code ici)
#   Window 2 "run"     → process qui tourne | logs live
#   Window 3 "git"     → lazygit
#   Window 4 "shell"   → shell libre
# ─────────────────────────────────────────────────────────

SESSION=${1:-"dev"}
DIR=${2:-"$HOME"}

# Commande pour lancer le service/bot en dev
RUN_CMD=${RUN_CMD:-"echo 'Remplace par : node bot.js OU python service.py'"}

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Session '$SESSION' existe déjà — attachement..."
  tmux attach -t "$SESSION"
  exit 0
fi

# ── Window 1 : claude code ─────────────────────────────
tmux new-session -d -s "$SESSION" -n "claude" -c "$DIR"
# pane principal : shell pour lancer claude / vim
tmux split-window -v -t "$SESSION:claude" -c "$DIR" -p 25
# pane bas (25%) : shell secondaire / commandes rapides

tmux select-pane -t "$SESSION:claude.1"

# ── Window 2 : run ─────────────────────────────────────
tmux new-window -t "$SESSION" -n "run" -c "$DIR"
tmux send-keys -t "$SESSION:run" "$RUN_CMD" Enter

tmux split-window -v -t "$SESSION:run" -c "$DIR" -p 35
# pane bas = logs live ou watch

# ── Window 3 : git ─────────────────────────────────────
tmux new-window -t "$SESSION" -n "git" -c "$DIR"
tmux send-keys -t "$SESSION:git" "lazygit" Enter

# ── Window 4 : shell libre ─────────────────────────────
tmux new-window -t "$SESSION" -n "shell" -c "$DIR"

# Démarrer sur claude
tmux select-window -t "$SESSION:claude"
tmux select-pane -t "$SESSION:claude.1"

tmux attach -t "$SESSION"
