#!/usr/bin/env bash
# ==============================================================
#  replace_ui_terms.sh — Solo stringhe visibili all'utente
# ==============================================================
#
#  FILE TOCCATI (solo UI):
#    *.qml                        (interfaccia Qt)
#    android/res/values/strings.xml  (etichette Android)
#    translations/*.ts            (file di traduzione Qt)
#
#  FILE NON TOCCATI:
#    *.cpp *.h *.cmake CMakeLists.txt *.sh Makefile
#    Dockerfile* *.yml *.gradle *.py  ecc.
#
#  SOSTITUZIONI (con word-boundary \b — non tocca parti di parola):
#    XMR / Xmr / xmr     -->  MVC / Mvc / mvc
#    MEVA / Meva / meva   -->  MVC / Mvc / mvc
#    MONERO / Monero / monero --> MEVACOIN / Mevacoin / mevacoin
#
#  GARANZIE \b:
#    "xmrAmount"   rimane "xmrAmount"   (non e' standalone)
#    "mevacoin"    rimane "mevacoin"    (\bmeva\b non matcha dentro mevacoin)
#    "XMR coins"   diventa "MVC coins"  (XMR e' standalone)
#
#  Uso: bash replace_ui_terms.sh [percorso_repo]
#       Senza argomento usa la directory corrente.
# ==============================================================

set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"

echo ""
echo "======================================================"
echo "  replace_ui_terms.sh  (solo file UI)"
echo "  Repository: $ROOT"
echo "======================================================"
echo ""

changed=0
total=0

do_replacements() {
    local f="$1"
    # \b = word boundary (GNU sed, Linux)
    # Sostituisce solo parole "intere":
    #   XMR standalone  → MVC    (ma non xmrAmount)
    #   meva standalone → mvc    (ma non mevacoin)
    #   monero standalone → mevacoin
    sed -i \
      -e 's/\bMONERO\b/MEVACOIN/g' \
      -e 's/\bMonero\b/Mevacoin/g' \
      -e 's/\bmonero\b/mevacoin/g' \
      -e 's/\bXMR\b/MVC/g' \
      -e 's/\bXmr\b/Mvc/g' \
      -e 's/\bxmr\b/mvc/g' \
      -e 's/\bMEVA\b/MVC/g' \
      -e 's/\bMeva\b/Mvc/g' \
      -e 's/\bmeva\b/mvc/g' \
      "$f"
}

needs_change() {
    grep -qwE '(XMR|Xmr|xmr|MEVA|Meva|meva|MONERO|Monero|monero)' "$f" 2>/dev/null
}

process_file() {
    local f="$1"
    local relpath="${f#"$ROOT"/}"
    (( total++ )) || true
    if needs_change "$f"; then
        do_replacements "$f"
        echo "  ✔  $relpath"
        (( changed++ )) || true
    fi
}

echo "--- File QML ---"
while IFS= read -r -d '' f; do
    process_file "$f"
done < <(find "$ROOT" -name "*.qml" -not -path "*/.git/*" -print0)

echo ""
echo "--- Android strings.xml ---"
while IFS= read -r -d '' f; do
    process_file "$f"
done < <(find "$ROOT" -path "*/res/values/strings.xml" -not -path "*/.git/*" -print0)

echo ""
echo "--- Traduzioni Qt (translations/*.ts) ---"
while IFS= read -r -d '' f; do
    process_file "$f"
done < <(find "$ROOT" -path "*/translations/*.ts" -not -path "*/.git/*" -print0)

echo ""
echo "======================================================"
echo "  Completato!"
echo "======================================================"
echo "  File processati : $total"
echo "  File modificati : $changed"
echo ""
echo "  Sostituzioni applicate (solo parole intere):"
echo "    XMR / Xmr / xmr       -->  MVC / Mvc / mvc"
echo "    MEVA / Meva / meva     -->  MVC / Mvc / mvc"
echo "    MONERO / Monero / monero --> MEVACOIN / Mevacoin / mevacoin"
echo ""
echo "  File di build/codice NON modificati."
echo ""
echo "  Controlla le modifiche:"
echo "    git diff"
echo ""
echo "  Poi committa:"
echo "    git add -A && git commit -m \"ui: xmr/meva/monero -> mvc/mevacoin (solo UI)\" && git push"
echo ""
