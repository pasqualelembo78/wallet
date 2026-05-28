#!/bin/bash
set -e
echo "=========================================="
echo "  FIX DEFINITIVO SUBMODULE WORKTREE PATHS"
echo "=========================================="

cd ~/wallet

# 1. DIAGNOSI: mostra tutti i worktree sbagliati
echo ""
echo "[1/4] Cercando worktree paths con 'mevacoin'..."
BROKEN=$(grep -r "worktree.*mevacoin" .git/modules/ --include=config -l 2>/dev/null || true)

if [ -z "$BROKEN" ]; then
    echo "  Nessun worktree path errato trovato!"
else
    echo "  File con path errato:"
    for f in $BROKEN; do
        echo "    ❌ $f"
        grep "worktree" "$f" | sed 's/^/       /'
    done
fi

# 2. FIX: correggi TUTTI i worktree paths in un colpo solo
echo ""
echo "[2/4] Correggendo tutti i worktree paths (mevacoin -> mevacoin)..."
find .git/modules/mevacoin -name config -exec grep -l "mevacoin" {} \; 2>/dev/null | while read f; do
    sed -i 's|/mevacoin/|/mevacoin/|g' "$f"
    sed -i 's|/mevacoin$|/mevacoin|' "$f"
    echo "  ✅ Fixato: $f"
done

# 3. FIX: correggi anche la config principale se serve
if grep -q "mevacoin" .git/modules/mevacoin/config 2>/dev/null; then
    sed -i 's|worktree = ../../../mevacoin|worktree = ../../../mevacoin|' .git/modules/mevacoin/config
    echo "  ✅ Fixato: .git/modules/mevacoin/config (top-level)"
fi

# 4. VERIFICA: controlla che non ci siano più path errati
echo ""
echo "[3/4] Verifica finale..."
STILL_BROKEN=$(grep -r "worktree.*mevacoin" .git/modules/ --include=config 2>/dev/null || true)

if [ -z "$STILL_BROKEN" ]; then
    echo "  ✅ Tutti i worktree paths sono corretti!"
else
    echo "  ⚠️ Ancora path errati:"
    echo "$STILL_BROKEN"
fi

# 5. TEST: prova git add -A
echo ""
echo "[4/4] Test: git add -A..."
if git add -A 2>&1; then
    echo "  ✅ git add -A funziona PERFETTAMENTE!"
    echo ""
    echo "=========================================="
    echo "  FIX COMPLETATO CON SUCCESSO!"
    echo "  Ora puoi usare git add -A normalmente"
    echo "=========================================="
else
    echo "  ❌ git add -A ha ancora problemi"
    echo "  Controlla l'errore sopra"
fi
