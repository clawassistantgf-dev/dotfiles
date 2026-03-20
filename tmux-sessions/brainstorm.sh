#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# Session : brainstorm / spec
# Usage   : ./brainstorm.sh <nom_session> <dossier_projet>
#
# Exemples :
#   ./brainstorm.sh newapp ~/projets/specs/newapp
#
# Layout :
#   Window 1 "claude"  → claude code (agent de réflexion)
#   Window 2 "notes"   → vim sur le fichier de spec/notes
#   Window 3 "shell"   → shell libre (recherches, git init...)
# ─────────────────────────────────────────────────────────

SESSION=${1:-"brainstorm"}
DIR=${2:-"$HOME"}
NOTES_FILE=${NOTES_FILE:-"SPEC.md"}

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Session '$SESSION' existe déjà — attachement..."
  tmux attach -t "$SESSION"
  exit 0
fi

# ── Window 1 : claude ──────────────────────────────────
tmux new-session -d -s "$SESSION" -n "claude" -c "$DIR"

# ── Window 2 : notes/spec ──────────────────────────────
tmux new-window -t "$SESSION" -n "notes" -c "$DIR"

# Crée le fichier de spec s'il n'existe pas
if [ ! -f "$DIR/$NOTES_FILE" ]; then
  cat > "$DIR/$NOTES_FILE" << 'EOF'
# Spec

## Objectif

## Fonctionnalités principales

## Stack envisagée

## Questions ouvertes

## Notes
EOF
fi

tmux send-keys -t "$SESSION:notes" "vim $NOTES_FILE" Enter

# ── Window 3 : shell libre ─────────────────────────────
tmux new-window -t "$SESSION" -n "shell" -c "$DIR"

# Démarrer sur claude
tmux select-window -t "$SESSION:claude"

tmux attach -t "$SESSION"
