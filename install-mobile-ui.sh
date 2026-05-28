#!/bin/bash
set -e
echo "Installing MevaCoin mobile UI patches..."

if [ ! -f "CMakeLists.txt" ]; then
    echo "ERRORE: Esegui dalla root del progetto wallet"
    exit 1
fi

echo "[1/3] Downloading patched main.qml..."
curl -sL -o main.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/9c286ed76edc466092643b853d78e90fcbec0bef6ca246cbb3f534e97247ada3/main.qml"

echo "[2/3] Downloading patched TitleBar.qml..."
curl -sL -o components/TitleBar.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/e2678e39b3d8468fa06567f8d0bbd32e6181c05ee1884063bae6f2f5dd16865b/TitleBar.qml"

echo "[3/3] Downloading patched StandardButton.qml..."
curl -sL -o components/StandardButton.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/edfe64816e4f42b5bed8b7b6ac6306777bd608300941474091134b5a816a8cb1/StandardButton.qml"

echo ""
echo "============================================"
echo "  MOBILE UI PATCHES INSTALLATE!"
echo "  - Bottom nav bar (5 tab)"
echo "  - Mobile header con bilancio"
echo "  - Drawer menu hamburger"
echo "  - Touch target 48dp"
echo "  - TitleBar nascosta su Android"
echo "  - LeftPanel nascosto, full width"
echo "============================================"
