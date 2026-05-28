#!/bin/bash
# ==============================================================================
# sync-submodule.sh — Aggiorna il submodule mevacoin all'ultimo commit
# ==============================================================================
# Uso: cd /root/wallet && bash sync-submodule.sh
# ==============================================================================
set -e
cd /root/wallet || { echo "❌ /root/wallet non trovato"; exit 1; }

echo "🔄 Aggiornamento submodule mevacoin..."

cd mevacoin
git fetch origin
git checkout mevacoin
git pull origin mevacoin
HASH=$(git rev-parse --short HEAD)
echo "  ✓ Core aggiornato a: $HASH"

cd ..
git add mevacoin
if git diff --cached --quiet; then
    echo "  ℹ️  Nessuna modifica — il wallet punta già all'ultimo commit."
else
    git commit -m "Aggiorna submodule mevacoin ($HASH)"
    git push origin main
    echo "  ✓ Wallet aggiornato e pushato!"
fi

echo "✅ Fatto."
