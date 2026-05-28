// Copyright (c) 2020-2024, The Mevacoin Project
// (license header identica all'originale)

#include "downloader.h"
#include <QReadLocker>
#include <QWriteLocker>

#ifdef Q_OS_ANDROID
#include <QFile>
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#endif

#include "updater.h"

namespace {
class DownloaderStateGuard {
public:
    DownloaderStateGuard(bool &active, QReadWriteLock &mutex, std::function<void()> onActiveChanged)
        : m_active(active), m_acquired(false), m_mutex(mutex), m_onActiveChanged(std::move(onActiveChanged)) {
        { QWriteLocker locker(&m_mutex); if (m_active) return; m_active = true; }
        m_onActiveChanged();
        m_acquired = true;
    }
    ~DownloaderStateGuard() {
        if (!m_acquired) return;
        { QWriteLocker locker(&m_mutex); m_active = false; }
        m_onActiveChanged();
    }
    bool acquired() const { return m_acquired; }
private:
    bool &m_active; bool m_acquired;
    QReadWriteLock &m_mutex;
    std::function<void()> m_onActiveChanged;
};
} // namespace

Downloader::Downloader(QObject *parent)
    : QObject(parent), m_active(false), m_httpClient(new HttpClient()), m_network(this), m_scheduler(this) {
    QObject::connect(m_httpClient.get(), SIGNAL(contentLengthChanged()), this, SIGNAL(totalChanged()));
    QObject::connect(m_httpClient.get(), SIGNAL(receivedChanged()), this, SIGNAL(loadedChanged()));
}

Downloader::~Downloader() { cancel(); }

void Downloader::cancel() {
    m_httpClient->cancel();
    QWriteLocker locker(&m_mutex);
    m_contents.clear();
}

bool Downloader::get(const QString &url, const QString &hash, const QJSValue &callback) {
    auto future = m_scheduler.run([this, url, hash]() {
        DownloaderStateGuard stateGuard(m_active, m_mutex, [this]() { emit activeChanged(); });
        if (!stateGuard.acquired()) return QJSValueList({"downloading is already running"});
        { QWriteLocker locker(&m_mutex); m_contents.clear(); }
        std::string response;
        {
            QString error;
            auto task = m_scheduler.run([this, &error, &response, &url] { error = m_network.get(m_httpClient, url, response); });
            if (!task.first) return QJSValueList({"failed to start downloading task"});
            task.second.waitForFinished();
            if (!error.isEmpty()) return QJSValueList({error});
        }
        if (response.empty()) return QJSValueList({"empty response"});
        try {
            const QByteArray calculatedHash = Updater().getHash(&response[0], response.size());
            if (QByteArray::fromHex(hash.toUtf8()) != calculatedHash) return QJSValueList({"hash sum mismatch"});
        } catch (const std::exception &e) { return QJSValueList({e.what()}); }
        { QWriteLocker locker(&m_mutex); m_contents = std::move(response); }
        return QJSValueList({});
    }, callback);
    return future.first;
}

bool Downloader::saveToFile(const QString &path) const {
    QWriteLocker locker(&m_mutex);
    if (m_active || m_contents.empty()) return false;
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) return false;
    if (static_cast<size_t>(file.write(m_contents.data(), m_contents.size())) != m_contents.size()) return false;
    return true;
}

// ─── Android: salva in Downloads pubblica (MediaStore o storage diretto) ────
#ifdef Q_OS_ANDROID
bool Downloader::saveToPublicDownloads(const QString &filename, const QString &mimeType) const
{
    QWriteLocker locker(&m_mutex);
    if (m_active || m_contents.empty()) {
        qWarning() << "saveToPublicDownloads: nessun contenuto";
        return false;
    }

    QAndroidJniEnvironment env;
    const jint sdkInt = QAndroidJniObject::getStaticField<jint>("android/os/Build$VERSION", "SDK_INT");
    qDebug() << "saveToPublicDownloads: Android API" << sdkInt << "file:" << filename;

    if (sdkInt >= 29) {
        // ── Android 10+ : MediaStore.Downloads ─────────────────────────────
        QAndroidJniObject context = QtAndroid::androidContext();
        if (!context.isValid()) return false;

        QAndroidJniObject cr = context.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");
        if (!cr.isValid()) return false;

        QAndroidJniObject cv("android/content/ContentValues","()V");
        cv.callMethod<void>("put","(Ljava/lang/String;Ljava/lang/String;)V",
            QAndroidJniObject::fromString("_display_name").object<jstring>(),
            QAndroidJniObject::fromString(filename).object<jstring>());
        cv.callMethod<void>("put","(Ljava/lang/String;Ljava/lang/String;)V",
            QAndroidJniObject::fromString("mime_type").object<jstring>(),
            QAndroidJniObject::fromString(mimeType).object<jstring>());
        cv.callMethod<void>("put","(Ljava/lang/String;Ljava/lang/Integer;)V",
            QAndroidJniObject::fromString("is_pending").object<jstring>(),
            QAndroidJniObject::callStaticObjectMethod("java/lang/Integer","valueOf","(I)Ljava/lang/Integer;",(jint)1).object());

        QAndroidJniObject dlUri = QAndroidJniObject::getStaticObjectField(
            "android/provider/MediaStore$Downloads","EXTERNAL_CONTENT_URI","Landroid/net/Uri;");
        if (!dlUri.isValid() || env->ExceptionCheck()) { env->ExceptionClear(); return false; }

        QAndroidJniObject fileUri = cr.callObjectMethod("insert",
            "(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;",
            dlUri.object(), cv.object());
        if (!fileUri.isValid() || env->ExceptionCheck()) { env->ExceptionClear(); return false; }

        QAndroidJniObject os = cr.callObjectMethod("openOutputStream",
            "(Landroid/net/Uri;)Ljava/io/OutputStream;", fileUri.object());
        if (!os.isValid() || env->ExceptionCheck()) { env->ExceptionClear(); return false; }

        const jsize sz = static_cast<jsize>(m_contents.size());
        jbyteArray ja = env->NewByteArray(sz);
        env->SetByteArrayRegion(ja, 0, sz, reinterpret_cast<const jbyte*>(m_contents.data()));
        os.callMethod<void>("write","([B)V",ja);
        env->DeleteLocalRef(ja);
        if (env->ExceptionCheck()) { env->ExceptionDescribe(); env->ExceptionClear(); os.callMethod<void>("close"); return false; }
        os.callMethod<void>("flush");
        os.callMethod<void>("close");
        if (env->ExceptionCheck()) env->ExceptionClear();

        // Rendi il file visibile: is_pending = 0
        QAndroidJniObject fv("android/content/ContentValues","()V");
        fv.callMethod<void>("put","(Ljava/lang/String;Ljava/lang/Integer;)V",
            QAndroidJniObject::fromString("is_pending").object<jstring>(),
            QAndroidJniObject::callStaticObjectMethod("java/lang/Integer","valueOf","(I)Ljava/lang/Integer;",(jint)0).object());
        cr.callMethod<jint>("update",
            "(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I",
            fileUri.object(), fv.object(), nullptr, nullptr);
        if (env->ExceptionCheck()) env->ExceptionClear();

        qDebug() << "saveToPublicDownloads: salvato in Downloads (MediaStore)";
        return true;

    } else {
        // ── Android 9- : scrittura diretta su storage esterno ───────────────
        QAndroidJniObject dirType = QAndroidJniObject::getStaticObjectField<jstring>(
            "android/os/Environment","DIRECTORY_DOWNLOADS");
        QAndroidJniObject dir = QAndroidJniObject::callStaticObjectMethod(
            "android/os/Environment","getExternalStoragePublicDirectory",
            "(Ljava/lang/String;)Ljava/io/File;", dirType.object<jstring>());
        if (!dir.isValid() || env->ExceptionCheck()) { env->ExceptionClear(); return false; }

        const QString path = dir.callObjectMethod<jstring>("getAbsolutePath").toString() + "/" + filename;
        QFile file(path);
        if (!file.open(QIODevice::WriteOnly)) return false;
        const qint64 written = file.write(m_contents.data(), static_cast<qint64>(m_contents.size()));
        file.close();
        qDebug() << "saveToPublicDownloads: salvato in" << path;
        return static_cast<size_t>(written) == m_contents.size();
    }
}
#endif
// ─────────────────────────────────────────────────────────────────────────────

bool Downloader::active() const { QReadLocker locker(&m_mutex); return m_active; }
quint64 Downloader::loaded() const { return m_httpClient->received(); }
quint64 Downloader::total() const { return m_httpClient->contentLength(); }
QString Downloader::proxyAddress() const { QMutexLocker locker(&m_proxyMutex); return m_proxyAddress; }
void Downloader::setProxyAddress(QString address) {
    m_scheduler.run([this, address] {
        if (!m_httpClient->set_proxy(address.toStdString())) qCritical() << "Failed to set proxy address" << address;
        QMutexLocker locker(&m_proxyMutex);
        m_proxyAddress = address;
        emit proxyAddressChanged();
    });
}
