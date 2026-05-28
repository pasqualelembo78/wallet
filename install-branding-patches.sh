#!/bin/bash
set -e
echo "Installing MevaCoin branding patches..."

if [ ! -f "CMakeLists.txt" ]; then
    echo "ERRORE: Esegui dalla root del progetto wallet"
    exit 1
fi

echo "[1/5] main.qml (title + stringhe)"
curl -sL -o main.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/e17e3807104645618cb7eda56bac2dd5b6abf7cac5ea473d9f47cfc63102efd9/main.qml"

echo "[2/5] src/main/main.cpp (wallet path + account name)"
curl -sL -o src/main/main.cpp "https://codewords-uploads.s3.amazonaws.com/runtime_v2/39ddeef49b854dcebd5a56fcce830adbc2ede9fa159b48eb807dec538b329e0b/main.cpp"

echo "[3/5] wizard/WizardHome.qml (Welcome to MevaCoin)"
curl -sL -o wizard/WizardHome.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/3730f8451c9a4c08a4db66a1eb673c81f24b5e9df1014542acae91f6ec46ac93/WizardHome.qml"

echo "[4/5] wizard/WizardCreateWallet1.qml (on this device)"
curl -sL -o wizard/WizardCreateWallet1.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/ccbb706d5bdc4435bfb21be4bd847191fbcfd247e9674fa4b5e1d91816e4c634/WizardCreateWallet1.qml"

echo "[5/5] wizard/WizardCreateWallet2.qml (recovery text)"
curl -sL -o wizard/WizardCreateWallet2.qml "https://codewords-uploads.s3.amazonaws.com/runtime_v2/ab38ea767553423fb6f4dfd25a66571dc76f74a804ab4a61b5ea0106c451d7b9/WizardCreateWallet2.qml"

echo ""
echo "============================================"
echo "  BRANDING PATCHES INSTALLATE!"
echo "  - Title: MevaCoin"
echo "  - Welcome to MevaCoin"
echo "  - My MevaCoin Account"
echo "  - MevaCoin/wallets path"
echo "  - on this device (mobile)"
echo "  - Recovery text rebranded"
echo "============================================"
