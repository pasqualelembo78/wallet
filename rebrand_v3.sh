#!/bin/bash
# ==============================================================================
# MEVA REBRANDING SCRIPT V3 — Esclude submodule mevacoin/ e external/
# ==============================================================================
# PRIMA: cd /root/wallet && git checkout . && cd mevacoin && git checkout . && cd ..
# Uso:   cd /root/wallet && bash rebrand_v3.sh
# ==============================================================================
set -e
cd /root/wallet || { echo "❌ /root/wallet non trovato"; exit 1; }
[ -f "main.qml" ] || { echo "❌ main.qml non trovato"; exit 1; }

echo "============================================"
echo "  MEVA Rebranding V3 (esclude submodule)"
echo "============================================"

# Esclude: mevacoin/ (core submodule), external/mevacoin-seed/, .git/
EXCLUDE="--exclude-dir=mevacoin --exclude-dir=.git --exclude-dir=build"

echo ""
echo "[1/4] Sostituzioni nel contenuto (solo GUI)..."

# URL
grep -rl $EXCLUDE "getmevacoin\.org" . 2>/dev/null | xargs -r sed -i 's|getmevacoin\.org|mevacoin.com|g'
echo "  ✓ mevacoin.com → mevacoin.com"

# File references (translation filenames)
grep -rl $EXCLUDE "mevacoin-core" . 2>/dev/null | xargs -r sed -i 's|mevacoin-core|mevacoin-core|g'
echo "  ✓ mevacoin-core → mevacoin-core"

# Class names
grep -rl $EXCLUDE "MevaSettings" . 2>/dev/null | xargs -r sed -i 's|MevaSettings|MevaSettings|g'
echo "  ✓ MevaSettings → MevaSettings"

# Desktop identifiers
grep -rl $EXCLUDE "org.mevacoin.MevaCoin" . 2>/dev/null | xargs -r sed -i 's|org\.getmevacoin\.MevaCoin|org.mevacoin.MevaCoin|g'
echo "  ✓ org.mevacoin.MevaCoin → org.mevacoin.MevaCoin"

# Binary/daemon names
grep -rl $EXCLUDE "mevacoin-wallet-gui\|mevacoin-wallet-cli\|mevacoind\|mevacoin-daemon" . 2>/dev/null | xargs -r sed -i     -e 's|mevacoin-wallet-gui|mevacoin-wallet-gui|g'     -e 's|mevacoin-wallet-cli|mevacoin-wallet-cli|g'     -e 's|mevacoin-daemon|mevacoin-daemon|g'     -e 's|mevacoind|mevacoind|g'
echo "  ✓ Binary names"

# URI schema
grep -rl $EXCLUDE '"mevacoin:' . 2>/dev/null | xargs -r sed -i 's|"mevacoin:|"mevacoin:|g'
grep -rl $EXCLUDE "'mevacoin:" . 2>/dev/null | xargs -r sed -i "s|'mevacoin:|'mevacoin:|g"
echo "  ✓ URI: mevacoin: → mevacoin:"

# Variable names
grep -rl $EXCLUDE "mevaAccountsDir\|mevaAccountsRootDir" . 2>/dev/null | xargs -r sed -i     -e 's|mevaAccountsDir|mevaAccountsDir|g'     -e 's|mevaAccountsRootDir|mevaAccountsRootDir|g'
echo "  ✓ Variables"

# Project name
grep -rl $EXCLUDE "The MevaCoin Project" . 2>/dev/null | xargs -r sed -i 's|The MevaCoin Project|The MevaCoin Project|g'
echo "  ✓ The MevaCoin Project → The MevaCoin Project"

# UPPERCASE (defines, macros) - GUI only
grep -rl $EXCLUDE "MEVACOIN" . 2>/dev/null | xargs -r sed -i 's|MEVACOIN|MEVACOIN|g'
echo "  ✓ MEVACOIN → MEVACOIN"

# Generic MevaCoin → MevaCoin
grep -rl $EXCLUDE "MevaCoin" . 2>/dev/null | xargs -r sed -i 's|MevaCoin|MevaCoin|g'
echo "  ✓ MevaCoin → MevaCoin"

# Generic lowercase
grep -rl $EXCLUDE "mevacoin" . 2>/dev/null | xargs -r sed -i 's|mevacoin|mevacoin|g'
echo "  ✓ mevacoin → mevacoin"

echo ""
echo "[2/4] Fix doppie sostituzioni..."
grep -rl $EXCLUDE "MevaCoin\|mevacoin\|MEVACOIN\|mevacoin-core" . 2>/dev/null | xargs -r sed -i     -e 's|MevaCoin|MevaCoin|g'     -e 's|mevacoin|mevacoin|g'     -e 's|MEVACOIN|MEVACOIN|g'     -e 's|mevacoin-core|mevacoin-core|g'     -e 's|mevacoind|mevacoind|g'     -e 's|mevacoin-wallet-gui|mevacoin-wallet-gui|g'
echo "  ✓ Doppie sostituzioni corrette"

echo ""
echo "[3/4] Rinomina file..."
for f in translations/mevacoin-core*.ts; do
    [ -f "$f" ] || continue
    newname=$(echo "$f" | sed 's/mevacoin-core/mevacoin-core/g')
    git mv "$f" "$newname" 2>/dev/null || mv "$f" "$newname"
    echo "  ✓ $(basename $f)"
done

[ -f "installers/windows/MevaCoin.iss" ] && { git mv "installers/windows/MevaCoin.iss" "installers/windows/MevaCoin.iss" 2>/dev/null || true; echo "  ✓ MevaCoin.iss"; }
[ -f "installers/windows/mevacoin-daemon.bat" ] && { git mv "installers/windows/mevacoin-daemon.bat" "installers/windows/mevacoin-daemon.bat" 2>/dev/null || true; echo "  ✓ mevacoin-daemon.bat"; }
[ -f "share/org.mevacoin.MevaCoin.desktop" ] && { git mv "share/org.mevacoin.MevaCoin.desktop" "share/org.mevacoin.MevaCoin.desktop" 2>/dev/null || true; echo "  ✓ desktop"; }
[ -f "share/org.mevacoin.MevaCoin.metainfo.xml" ] && { git mv "share/org.mevacoin.MevaCoin.metainfo.xml" "share/org.mevacoin.MevaCoin.metainfo.xml" 2>/dev/null || true; echo "  ✓ metainfo"; }
[ -f "src/qt/MevaSettings.cpp" ] && { git mv "src/qt/MevaSettings.cpp" "src/qt/MevaSettings.cpp" 2>/dev/null || true; echo "  ✓ MevaSettings.cpp"; }
[ -f "src/qt/MevaSettings.h" ] && { git mv "src/qt/MevaSettings.h" "src/qt/MevaSettings.h" 2>/dev/null || true; echo "  ✓ MevaSettings.h"; }

echo ""
echo "[4/4] Verifica (solo GUI, esclude submodule)..."
REMAINING=$(grep -ril $EXCLUDE "mevacoin" . 2>/dev/null | wc -l)
echo "  File GUI residui con 'mevacoin': $REMAINING"

echo ""
echo "============================================"
echo "  ✅ Rebranding V3 completato!"
echo "  Il submodule mevacoin/ NON è stato toccato."
echo ""
echo "  Prossimi passi:"
echo "  1. git diff --stat | tail -5"
echo "  2. Rilancia la build"
echo "  3. git add -A && git commit -m 'Rebranding GUI MevaCoin→MevaCoin'"
echo "============================================"
