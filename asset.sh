#!/bin/bash
# setup-android-assets.sh
# Crea android/ con AndroidManifest.xml, strings.xml e icone
# per Qt 5.15 + Android NDK r26d (API 31)
# Esegui dalla root del progetto PRIMA di build.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── Verifica prerequisiti ───────────────────────────────────────────
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERRORE: Esegui dalla root del progetto wallet"
    exit 1
fi

SRC_ICON="images/appicons/256x256.png"
if [ ! -f "$SRC_ICON" ]; then
    echo "ERRORE: Icona sorgente non trovata: $SRC_ICON"
    exit 1
fi

echo "============================================"
echo "  MevaCoin Wallet - Android Assets Setup"
echo "============================================"
echo ""

# ── 1. Struttura directory ──────────────────────────────────────────
echo "[1/4] Creazione struttura android/..."
mkdir -p android/res/values
mkdir -p android/res/mipmap-ldpi
mkdir -p android/res/mipmap-mdpi
mkdir -p android/res/mipmap-hdpi
mkdir -p android/res/mipmap-xhdpi
mkdir -p android/res/mipmap-xxhdpi
mkdir -p android/res/mipmap-xxxhdpi
echo "  ✓ Directory create"
echo ""

# ── 2. strings.xml ─────────────────────────────────────────────────
echo "[2/4] Creazione android/res/values/strings.xml..."
cat > android/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">MevaCoin Wallet</string>
</resources>
EOF
echo "  ✓ strings.xml  →  app_name = 'MevaCoin Wallet'"
echo ""

# ── 3. AndroidManifest.xml ─────────────────────────────────────────
echo "[3/4] Creazione android/AndroidManifest.xml..."
cat > android/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.intelligame.mevacoin_wallet"
    android:versionName="-- %%INSERT_VERSION_NAME%% --"
    android:versionCode="-- %%INSERT_VERSION_CODE%% --"
    android:installLocation="auto">

    <supports-screens
        android:anyDensity="true"
        android:largeScreens="true"
        android:normalScreens="true"
        android:smallScreens="true"/>

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <application
        android:name="org.qtproject.qt5.android.bindings.QtApplication"
        android:label="@string/app_name"
        android:icon="@mipmap/icon"
        android:hardwareAccelerated="true"
        android:requestLegacyExternalStorage="false">

        <activity
            android:name="org.qtproject.qt5.android.bindings.QtActivity"
            android:label="@string/app_name"
            android:screenOrientation="unspecified"
            android:configChanges="orientation|uiMode|screenLayout|screenSize|smallestScreenSize|locale|fontScale|keyboard|keyboardHidden|navigation|mcc|mnc|density"
            android:launchMode="singleTop"
            android:exported="true">

            <!-- OBBLIGATORIO su API 31+: exported=true per activity con intent-filter -->

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Qt 5.15 runtime metadata -->
            <meta-data android:name="android.app.lib_name"
                android:value="mevacoin-wallet-gui"/>
            <meta-data android:name="android.app.qt_sources_resource_id"
                android:resource="@array/qt_sources"/>
            <meta-data android:name="android.app.repository"
                android:value="default"/>
            <meta-data android:name="android.app.qt_libs_resource_id"
                android:resource="@array/qt_libs"/>
            <meta-data android:name="android.app.bundled_libs_resource_id"
                android:resource="@array/bundled_libs"/>
            <meta-data android:name="android.app.extract_android_style"
                android:value="minimal"/>
        </activity>
    </application>
</manifest>
EOF
echo "  ✓ AndroidManifest.xml  →  package=com.intelligame.mevacoin_wallet, API 31 compliant"
echo ""

# ── 4. Icone ───────────────────────────────────────────────────────
# Dimensioni standard Android mipmap:
#   ldpi=36  mdpi=48  hdpi=72  xhdpi=96  xxhdpi=144  xxxhdpi=192
echo "[4/4] Ridimensionamento icone da $SRC_ICON..."

if command -v convert &> /dev/null; then
    echo "  → ImageMagick trovato: resize preciso"
    convert "$SRC_ICON" -resize 36x36!   android/res/mipmap-ldpi/icon.png
    convert "$SRC_ICON" -resize 48x48!   android/res/mipmap-mdpi/icon.png
    convert "$SRC_ICON" -resize 72x72!   android/res/mipmap-hdpi/icon.png
    convert "$SRC_ICON" -resize 96x96!   android/res/mipmap-xhdpi/icon.png
    convert "$SRC_ICON" -resize 144x144! android/res/mipmap-xxhdpi/icon.png
    convert "$SRC_ICON" -resize 192x192! android/res/mipmap-xxxhdpi/icon.png
    echo "  ✓ Icone ridimensionate con precisione"

elif command -v python3 &> /dev/null && python3 -c "from PIL import Image" 2>/dev/null; then
    echo "  → Pillow trovato: resize con Python"
    python3 - << 'PYEOF'
from PIL import Image
src = "images/appicons/256x256.png"
targets = {
    "android/res/mipmap-ldpi/icon.png":    (36,  36),
    "android/res/mipmap-mdpi/icon.png":    (48,  48),
    "android/res/mipmap-hdpi/icon.png":    (72,  72),
    "android/res/mipmap-xhdpi/icon.png":   (96,  96),
    "android/res/mipmap-xxhdpi/icon.png":  (144, 144),
    "android/res/mipmap-xxxhdpi/icon.png": (192, 192),
}
img = Image.open(src).convert("RGBA")
for path, size in targets.items():
    img.resize(size, Image.LANCZOS).save(path)
    print(f"  ✓ {path}  ({size[0]}x{size[1]})")
PYEOF

else
    echo "  → ImageMagick e Pillow non trovati: copia approssimata delle PNG esistenti"
    echo "    (installa imagemagick per le dimensioni esatte)"
    cp images/appicons/48x48.png    android/res/mipmap-ldpi/icon.png
    cp images/appicons/48x48.png    android/res/mipmap-mdpi/icon.png
    cp images/appicons/64x64.png    android/res/mipmap-hdpi/icon.png
    cp images/appicons/96x96.png    android/res/mipmap-xhdpi/icon.png
    cp images/appicons/128x128.png  android/res/mipmap-xxhdpi/icon.png
    cp images/appicons/256x256.png  android/res/mipmap-xxxhdpi/icon.png
    echo "  ✓ Icone copiate (approssimate)"
fi
echo ""

# ── Riepilogo ──────────────────────────────────────────────────────
echo "============================================"
echo "  SETUP COMPLETATO!"
echo ""
echo "  File creati:"
echo "  android/AndroidManifest.xml"
echo "  android/res/values/strings.xml"
echo "  android/res/mipmap-ldpi/icon.png    (36x36)"
echo "  android/res/mipmap-mdpi/icon.png    (48x48)"
echo "  android/res/mipmap-hdpi/icon.png    (72x72)"
echo "  android/res/mipmap-xhdpi/icon.png   (96x96)"
echo "  android/res/mipmap-xxhdpi/icon.png  (144x144)"
echo "  android/res/mipmap-xxxhdpi/icon.png (192x192)"
echo ""
echo "  Nome app APK : MevaCoin Wallet"
echo "  Package ID   : org.mevacoin.wallet"
echo "  Qt lib name  : mevacoin-wallet-gui"
echo ""
echo "  Prossimo step: bash build.sh"
echo "============================================"
