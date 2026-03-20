#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# tmux-btc-status.sh
# Tourne en arrière-plan, écrit dans /tmp/tmux-btc-status
# Lancer au démarrage : ajouté dans .tmux.conf via run-shell
#
# APIs utilisées :
#   - mempool.space : prix BTC, feerate, block height
#   - (pas besoin de clé API)
# ─────────────────────────────────────────────────────────

CACHE_FILE="/tmp/tmux-btc-status"
INTERVAL=30  # secondes entre chaque fetch

fetch_data() {
  # Prix BTC (USD) via mempool.space
  BTC_PRICE=$(curl -sf --max-time 5 \
    "https://mempool.space/api/v1/prices" \
    | grep -o '"USD":[0-9]*' | grep -o '[0-9]*$')

  # Feerate recommandé (fastest) + block height
  FEES=$(curl -sf --max-time 5 \
    "https://mempool.space/api/v1/fees/recommended")

  FEERATE=$(echo "$FEES" | grep -o '"fastestFee":[0-9]*' | grep -o '[0-9]*$')

  BLOCK=$(curl -sf --max-time 5 \
    "https://mempool.space/api/blocks/tip/height")

  # Formatage
  if [ -n "$BTC_PRICE" ] && [ -n "$FEERATE" ] && [ -n "$BLOCK" ]; then
    # Format prix avec séparateur milliers
    BTC_FORMATTED=$(printf "%'d" "$BTC_PRICE" 2>/dev/null || echo "$BTC_PRICE")
    echo "₿ \$${BTC_FORMATTED} | ${FEERATE} sat/vB | #${BLOCK}"
  else
    # Garde l'ancienne valeur si fetch échoue (pas de flash vide)
    [ -f "$CACHE_FILE" ] || echo "₿ ..." > "$CACHE_FILE"
  fi
}

# Boucle infinie
while true; do
  RESULT=$(fetch_data)
  [ -n "$RESULT" ] && echo "$RESULT" > "$CACHE_FILE"
  sleep "$INTERVAL"
done
