#!/bin/bash
set -e
echo "Installing wizard mobile layout patches..."

if [ ! -f "CMakeLists.txt" ]; then
    echo "ERRORE: Esegui dalla root del progetto wallet"
    exit 1
fi

echo "[1/3] wizard/WizardController.qml (responsive width)"
curl -sL -o wizard/WizardController.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/f67b8349ba32476c80cf4ecf75baeffa7575598782824f82a430e17ef9b6559c/WizardController.qml"

echo "[2/3] wizard/WizardCreateWallet2.qml (button wrapping + margins)"
curl -sL -o wizard/WizardCreateWallet2.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/4ac4a354f9784c51bea8d624c2529317a2a95a8776c143d8b72415654c34198c/WizardCreateWallet2.qml"

echo "[3/3] wizard/WizardCreateWallet1.qml (margins)"
curl -sL -o wizard/WizardCreateWallet1.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/c2db56ad9e7d4a24afe5effe3f610a448866f9bfad9444679c4b2ceabdea2cf5/WizardCreateWallet1.qml"

echo ""
echo "============================================"
echo "  WIZARD MOBILE LAYOUT PATCHES INSTALLATE!"
echo "  - wizardSubViewWidth responsive"
echo "  - Margini ridotti (100px -> 32px)"
echo "  - Bottoni che vanno a capo (Flow)"
echo "  - Top margin ridotto"
echo "============================================"
