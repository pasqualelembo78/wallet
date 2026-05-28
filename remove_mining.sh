#!/usr/bin/env bash
# =============================================================================
# remove_mining.sh
# MevaCoin Wallet — rimozione completa di Mining, XMRig, P2Pool
# Uso: chmod +x remove_mining.sh && ./remove_mining.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ─────────────────────────────────────────────────────────────────────────────
# Repo root
# ─────────────────────────────────────────────────────────────────────────────
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || realpath "$(dirname "$0")")"
cd "$REPO_ROOT"

# ─────────────────────────────────────────────────────────────────────────────
# UI
# ─────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
removed() { echo -e "${RED}[DEL]${NC}   $*"; }

echo
echo -e "${CYAN}==========================================================${NC}"
echo -e "${CYAN} MevaCoin Wallet — Mining Removal Script (robusto)${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo -e "  Repo: ${REPO_ROOT}"
echo

# ─────────────────────────────────────────────────────────────────────────────
# Backup directory
# ─────────────────────────────────────────────────────────────────────────────
BACKUP_DIR=".backup/remove_mining_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_path() {
    local path="$1"
    [ -e "$path" ] || return 0

    mkdir -p "$BACKUP_DIR/$(dirname "$path")"
    cp -a "$path" "$BACKUP_DIR/$path"
}

remove_path() {
    local path="$1"
    if [ -e "$path" ]; then
        backup_path "$path"
        rm -rf -- "$path"
        removed "$path"
    else
        warn "$path già assente"
    fi
}

patch_python_file() {
    local file="$1"
    local pycode="$2"

    if [ -f "$file" ]; then
        backup_path "$file"
        python3 - "$file" <<PY
from pathlib import Path
path = Path("$file")
text = path.read_text(encoding="utf-8")
$pycode
path.write_text(text, encoding="utf-8")
PY
        ok "$file patchato"
    else
        warn "$file non trovato"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Rimuovi src/p2pool/
# ─────────────────────────────────────────────────────────────────────────────
info "Step 1/7 — Rimuovi src/p2pool/"
remove_path "src/p2pool"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Rimuovi src/xmrig/
# ─────────────────────────────────────────────────────────────────────────────
info "Step 2/7 — Rimuovi src/xmrig/"
remove_path "src/xmrig"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Rimuovi immagini mining
# ─────────────────────────────────────────────────────────────────────────────
info "Step 3/7 — Rimuovi immagini mining"
for img in \
    "images/miningxmr.png" \
    "images/miningxmr@2x.png"
do
    remove_path "$img"
done

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — Rimuovi file GitHub legati a P2Pool
# ─────────────────────────────────────────────────────────────────────────────
info "Step 4/7 — Rimuovi file .github P2Pool"
for f in \
    ".github/verify_p2pool.py" \
    ".github/workflows/verify_p2pool.yml"
do
    remove_path "$f"
done

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Patch src/CMakeLists.txt
# ─────────────────────────────────────────────────────────────────────────────
info "Step 5/7 — Patch src/CMakeLists.txt"
patch_python_file "src/CMakeLists.txt" '
from pathlib import Path
import re

original = text

# Rimuovi riferimenti a p2pool e xmrig
text = re.sub(r"^[ \t]*.*p2pool/.*\n?", "", text, flags=re.MULTILINE)
text = re.sub(r"^[ \t]*.*xmrig/.*\n?", "", text, flags=re.MULTILINE)

# Rimuovi eventuali include directory specifiche
text = re.sub(r"^[ \t]*\$\{CMAKE_CURRENT_SOURCE_DIR\}/p2pool[ \t]*\n?", "", text, flags=re.MULTILINE)
text = re.sub(r"^[ \t]*\$\{CMAKE_CURRENT_SOURCE_DIR\}/xmrig[ \t]*\n?", "", text, flags=re.MULTILINE)

# Pulisci righe vuote multiple
text = re.sub(r"\n{3,}", "\n\n", text)

if text == original:
    print("  WARN: src/CMakeLists.txt già pulito o pattern non trovato")
'

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — Patch src/main/main.cpp
# ─────────────────────────────────────────────────────────────────────────────
patch_python_file "src/main/main.cpp" '
lines = text.splitlines(keepends=True)
out = []

for line in lines:

    # include P2Pool / Xmrig
    if "P2PoolManager" in line:
        continue
    if "XmrigManager" in line:
        continue

    # istanze
    if "P2PoolManager p2poolManager" in line:
        continue
    if "XmrigManager xmrigManager" in line:
        continue

    # QML registration
    if "qmlRegisterUncreatableType<P2PoolManager>" in line:
        continue
    if "qmlRegisterUncreatableType<XmrigManager>" in line:
        continue

    # 🔥 QUESTO è il pezzo che ti mancava
    if "setContextProperty" in line and "p2poolManager" in line:
        continue

    # qualsiasi accesso diretto residuo
    if "p2poolManager" in line:
        continue
    if "xmrigManager" in line:
        continue

    out.append(line)

text = "".join(out)
'

# ─────────────────────────────────────────────────────────────────────────────
# STEP 7 — Patch main.qml e qml.qrc
# ─────────────────────────────────────────────────────────────────────────────
info "Step 7/7 — Patch main.qml e qml.qrc"

patch_python_file "main.qml" '
from pathlib import Path
import re

lines = text.splitlines(keepends=True)
out = []
i = 0

while i < len(lines):
    line = lines[i]

    # Rimuovi import P2PoolManager / XmrigManager
    if re.match(r"\s*import\s+mevacoinComponents\.P2PoolManager\s+\d+\.\d+", line):
        i += 1
        continue
    if re.match(r"\s*import\s+mevacoinComponents\.XmrigManager\s+\d+\.\d+", line):
        i += 1
        continue

    # Rimuovi blocchi completi P2PoolManager { ... } / XmrigManager { ... }
    if re.match(r"\s*P2PoolManager\s*\{", line) or re.match(r"\s*XmrigManager\s*\{", line):
        depth = 0
        while i < len(lines):
            for ch in lines[i]:
                if ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
            i += 1
            if depth == 0:
                break
        continue

    # Rimuovi righe con riferimenti mining
    tokens = [
        "p2poolManager",
        "xmrigManager",
        "allow_background_mining",
        "allow_p2pool_mining",
        "allowRemoteNodeMining",
        "miningIgnoreBattery",
        "miningModeSelected",
        "p2poolFlags",
        "P2PoolManager",
        "XmrigManager",
    ]
    if any(tok in line for tok in tokens):
        i += 1
        continue

    out.append(line)
    i += 1

text = "".join(out)
text = re.sub(r"\n{3,}", "\n\n", text)
'

patch_python_file "qml.qrc" '
from pathlib import Path
import re

original = text
text = re.sub(r"^[ \t]*<file>images/miningxmr\.png</file>[ \t]*\n?", "", text, flags=re.MULTILINE)
text = re.sub(r"^[ \t]*<file>images/miningxmr@2x\.png</file>[ \t]*\n?", "", text, flags=re.MULTILINE)
text = re.sub(r"\n{3,}", "\n\n", text)

if text == original:
    print("  WARN: qml.qrc già pulito o pattern non trovato")
'

# ─────────────────────────────────────────────────────────────────────────────
# Verifica finale
# ─────────────────────────────────────────────────────────────────────────────
info "Verifica finale — nessun riferimento residuo"

LEFTOVER="$(grep -RInE \
    'P2PoolManager|XmrigManager|p2poolManager|xmrigManager|p2pool/|xmrig/' \
    src main.qml qml.qrc .github 2>/dev/null || true)"

if [ -n "$LEFTOVER" ]; then
    echo
    echo -e "${RED}Riferimenti residui trovati:${NC}"
    echo "$LEFTOVER"
    echo
    echo -e "${RED}Il repository non è ancora pulito. Correggi i riferimenti sopra prima della build.${NC}"
    exit 1
fi

echo
echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}  MINING REMOVAL COMPLETATO CON SUCCESSO${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo
echo "Backup creato in: $BACKUP_DIR"
echo
echo "File principali toccati:"
echo "  src/CMakeLists.txt"
echo "  src/main/main.cpp"
echo "  main.qml"
echo "  qml.qrc"
echo
echo "File eliminati:"
echo "  src/p2pool/"
echo "  src/xmrig/"
echo "  images/miningxmr.png"
echo "  images/miningxmr@2x.png"
echo "  .github/verify_p2pool.py"
echo "  .github/workflows/verify_p2pool.yml"
echo
echo "Controllo consigliato:"
echo "  git diff --stat"
echo