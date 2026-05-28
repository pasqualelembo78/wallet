#!/bin/bash
set -e

THREADS=${1:-4}
KEYSTORE_PASS=${2:-desy2011}

echo "============================================"
echo "  MevaCoin Wallet GUI - Android Build"
echo "  Threads: ${THREADS}"
echo "============================================"
echo ""

echo ">>> Step 1: Patch sorgenti..."
bash apply-patches.sh
echo ""

KEYSTORE_PATH="android-keystore/mevacoin-release.keystore"
KEYSTORE_ALIAS="mevacoin-release"
if [ ! -f "$KEYSTORE_PATH" ] || ! keytool -list -keystore "$KEYSTORE_PATH" -storepass "${KEYSTORE_PASS}" -alias "$KEYSTORE_ALIAS" >/dev/null 2>&1; then
    echo ">>> Generazione keystore..."
    mkdir -p android-keystore && rm -f "$KEYSTORE_PATH"
    keytool -genkeypair -v \
        -keystore "$KEYSTORE_PATH" -alias "$KEYSTORE_ALIAS" \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass "${KEYSTORE_PASS}" -keypass "${KEYSTORE_PASS}" \
        -dname "CN=MevaCoin, OU=Wallet, O=MevaCoin, L=Unknown, ST=Unknown, C=IT"
    echo "  Keystore creato."
else
    echo ">>> Keystore OK"
fi
echo ""

# ── Patch main.qml: drawer header → banner MevaCoin ─────────────
echo ">>> Step 1.6: Patch main.qml (drawer banner)..."
python3 << PYEOF
import re

f = 'main.qml'
with open(f, encoding='utf-8') as h:
    content = h.read()

OLD = (
    '                    Rectangle {\n'
    '                        width: parent.width; height: 80\n'
    '                        color: MevaCoinComponents.Style.blackTheme ? "#262626" : "#4C4C4C"\n'
    '                        Column {\n'
    '                            anchors.centerIn: parent; spacing: 4\n'
    '                            Text { text: "MevaCoin"; font.family: MevaCoinComponents.Style.fontBold.name; font.pixelSize: 20; font.bold: true; color: "white"; anchors.horizontalCenter: parent.horizontalCenter }\n'
    '                            Text { text: leftPanel.balanceString + " MEVA"; font.family: MevaCoinComponents.Style.fontRegular.name; font.pixelSize: 14; color: "#CCCCCC"; anchors.horizontalCenter: parent.horizontalCenter }\n'
    '                        }\n'
    '                    }'
)

NEW = (
    '                    Rectangle {\n'
    '                        width: parent.width; height: 110\n'
    '                        color: "#1a1a1a"\n'
    '                        Image {\n'
    '                            anchors.horizontalCenter: parent.horizontalCenter\n'
    '                            anchors.top: parent.top; anchors.topMargin: 10\n'
    '                            source: "qrc:///images/mevacoinLogo_white.png"\n'
    '                            height: 70; width: parent.width - 40\n'
    '                            fillMode: Image.PreserveAspectFit\n'
    '                            opacity: 0.95\n'
    '                        }\n'
    '                        Text {\n'
    '                            anchors.bottom: parent.bottom; anchors.bottomMargin: 6\n'
    '                            anchors.horizontalCenter: parent.horizontalCenter\n'
    '                            text: leftPanel.balanceString + " MEVA"\n'
    '                            font.family: MevaCoinComponents.Style.fontRegular.name\n'
    '                            font.pixelSize: 13; color: "#CCCCCC"\n'
    '                        }\n'
    '                    }'
)

if OLD in content:
    content = content.replace(OLD, NEW)
    with open(f, 'w', encoding='utf-8') as h:
        h.write(content)
    print('  OK: drawer header sostituito con banner MevaCoin')
else:
    print('  INFO: Pattern non trovato - gia patchato o diverso indentation')
    if 'height: 80' in content and 'text: "MevaCoin"' in content:
        print('  WARN: Le stringhe ci sono ma indentation diversa - controlla main.qml')
PYEOF
echo ""

echo ">>> Step 2: Build immagine Docker..."
docker build --tag mevacoin:build-env-android \
    --build-arg THREADS=${THREADS} \
    --file Dockerfile.android .
echo ""

echo ">>> Step 3: Build + firma APK..."
docker run --rm -i \
    -v "$(pwd):/mevacoin-gui" \
    -e THREADS=${THREADS} \
    -e KEYSTORE_PASS="${KEYSTORE_PASS}" \
    mevacoin:build-env-android sh -ex << 'DOCKER_EOF'
export PATH=$PATH:${ANDROID_SDK_ROOT}/build-tools/30.0.2

cd /tmp
wget -q https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz
tar -xzf zlib-1.3.1.tar.gz && cd zlib-1.3.1
CC=aarch64-linux-android31-clang CFLAGS="-fPIC" ./configure --prefix=/opt/android/prefix --static
make -j${THREADS} && make -j${THREADS} install

cd /mevacoin-gui
mkdir -p build/Android/release && cd build/Android/release
cmake \
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
    -DMANUAL_SUBMODULES=ON \
    -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release -DARCH=armv8-a \
    -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL} \
    -DANDROID_ABI=arm64-v8a -DANDROID_TOOLCHAIN=clang -DANDROID_STL=c++_shared \
    -DBoost_USE_STATIC_LIBS=ON -DBoost_USE_STATIC_RUNTIME=ON \
    -DBOOST_ROOT=${PREFIX} -DBOOST_INCLUDEDIR=${PREFIX}/include \
    -DBOOST_LIBRARYDIR=${PREFIX}/lib -DBoost_NO_SYSTEM_PATHS=ON \
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW -DBoost_COMPILER=-clang \
    -DLRELEASE_PATH=${PREFIX}/bin \
    -DQT_ANDROID_APPLICATION_BINARY=mevacoin-wallet-gui \
    -DANDROID_SDK=${ANDROID_SDK_ROOT} \
    -DWITH_SCANNER=ON -DWITH_DESKTOP_ENTRY=OFF \
    -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_CXX_EXTENSIONS=OFF ../../..
make generate_translations_header
make -j${THREADS} -C src

echo ">>> Fase A: make apk..."
make -j${THREADS} apk

ABUILD=/mevacoin-gui/build/Android/release/android-build
ASRC=/mevacoin-gui/android
MANIFEST=${ABUILD}/AndroidManifest.xml
echo ">>> Fase B: patch risorse e manifest..."
cp -r ${ASRC}/res/. ${ABUILD}/res/

python3 << MANIFEOF
import re
MANIFEST = '/mevacoin-gui/build/Android/release/android-build/AndroidManifest.xml'
with open(MANIFEST) as f: content = f.read()
content = re.sub(r'package="[^"]*"', 'package="com.intelligame.mevacoin_wallet"', content)
content = content.replace('android:label="mevacoin-wallet-gui"', 'android:label="MevaCoin Wallet"')
content = re.sub(r'android:icon="@drawable/[^"]*"', 'android:icon="@mipmap/ic_launcher"', content)
if 'android:icon=' not in content:
    content = content.replace('android:label="MevaCoin Wallet"', 'android:label="MevaCoin Wallet"\n        android:icon="@mipmap/ic_launcher"')
content = re.sub(r'android:roundIcon="@drawable/[^"]*"', 'android:roundIcon="@mipmap/ic_launcher_round"', content)
if 'android:roundIcon=' not in content:
    content = content.replace('android:icon="@mipmap/ic_launcher"', 'android:icon="@mipmap/ic_launcher"\n        android:roundIcon="@mipmap/ic_launcher_round"')
with open(MANIFEST, 'w') as f: f.write(content)
print('  Manifest patchato')
MANIFEOF

echo ">>> Fase C: rebuild Gradle..."
export ANDROID_HOME=${ANDROID_SDK_ROOT}
cd ${ABUILD}
chmod +x gradlew
./gradlew assembleDebug --no-daemon

APK=${ABUILD}/build/outputs/apk/debug/android-build-debug.apk
ls -lh "${APK}"

echo ">>> Firma APK..."
apksigner sign \
    --ks /mevacoin-gui/android-keystore/mevacoin-release.keystore \
    --ks-pass "pass:${KEYSTORE_PASS}" \
    --ks-key-alias mevacoin-release \
    --key-pass "pass:${KEYSTORE_PASS}" \
    --out /mevacoin-gui/mevacoin-release.apk \
    "${APK}"

apksigner verify /mevacoin-gui/mevacoin-release.apk
ls -lh /mevacoin-gui/mevacoin-release.apk
DOCKER_EOF

echo ""
echo "============================================"
echo "  BUILD COMPLETATO!"
ls -lh "$(pwd)/mevacoin-release.apk"
echo "  APK pronta in: $(pwd)/mevacoin-release.apk"
echo "============================================"
