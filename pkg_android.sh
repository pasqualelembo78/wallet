#!/bin/bash
set -ex
export PATH=$PATH:${ANDROID_SDK_ROOT}/build-tools/30.0.2
export ANDROID_HOME=${ANDROID_SDK_ROOT}
export JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true -Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2"
ABUILD=/mevacoin-gui/build/Android/release/android-build
ASRC=/mevacoin-gui/android

echo ">>> res e manifest patch..."
cp -r ${ASRC}/res/. ${ABUILD}/res/

python3 << 'MANIFEOF'
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

cd ${ABUILD}
chmod +x gradlew
for i in 1 2 3 4 5 6; do
    if ./gradlew assembleDebug --no-daemon; then
        echo "gradle OK ($i)"
        break
    else
        echo "gradle FAIL ($i) - riprovo"
        sleep 5
    fi
done

APK=${ABUILD}/build/outputs/apk/debug/android-build-debug.apk
test -s "${APK}"
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