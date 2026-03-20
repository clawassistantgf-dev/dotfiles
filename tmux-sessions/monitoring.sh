#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# Session : monitoring
# Usage   : ./monitoring.sh <nom_session> <dossier_projet>
#
# Exemples :
#   ./monitoring.sh myapp /srv/myapp
#   ./monitoring.sh myapp                  (reste dans ~)
#
# Layout :
#   Window 1 "logs"    → logs service 1 | service 2 | service 3
#   Window 2 "db"      → connexion db    | shell debug
#   Window 3 "code"    → vim + shell libre pour debug/claude
# ─────────────────────────────────────────────────────────

SESSION=${1:-"monitoring"}
DIR=${2:-"$HOME"}

# Variables à adapter selon le projet
# (ou passer en argument, ou overrider avant d'appeler le script)
LOG1=${LOG1:-"journalctl -fu service1"}
LOG2=${LOG2:-"journalctl -fu service2"}
LOG3=${LOG3:-"journalctl -fu service3"}
DB_CMD=${DB_CMD:-"echo 'Remplace par : mysql -u user -p db OU psql -U user db'"}

# Ne pas recréer si la session existe déjà
tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Session '$SESSION' existe déjà — attachement..."
  tmux attach -t "$SESSION"
  exit 0
fi

# ── Window 1 : logs ────────────────────────────────────
tmux new-session -d -s "$SESSION" -n "logs" -c "$DIR"
tmux send-keys -t "$SESSION:logs" "$LOG1" Enter

# Split vertical → log 2
tmux split-window -h -t "$SESSION:logs" -c "$DIR"
tmux send-keys -t "$SESSION:logs" "$LOG2" Enter

# Split log 2 horizontal → log 3
tmux split-window -v -t "$SESSION:logs.2" -c "$DIR"
tmux send-keys -t "$SESSION:logs" "$LOG3" Enter

tmux select-layout -t "$SESSION:logs" even-horizontal

# ── Window 2 : db ──────────────────────────────────────
tmux new-window -t "$SESSION" -n "db" -c "$DIR"
tmux send-keys -t "$SESSION:db" "$DB_CMD" Enter

tmux split-window -h -t "$SESSION:db" -c "$DIR"
# pane droit = shell libre pour debug

# ── Window 3 : code / claude ───────────────────────────
tmux new-window -t "$SESSION" -n "code" -c "$DIR"
# pane principal = shell pour claude code ou vim
tmux split-window -v -t "$SESSION:code" -c "$DIR" -p 30
# pane bas (30%) = shell secondaire / output

# Retour sur logs au démarrage
tmux select-window -t "$SESSION:logs"
tmux select-pane -t "$SESSION:logs.1"

tmux attach -t "$SESSION"
