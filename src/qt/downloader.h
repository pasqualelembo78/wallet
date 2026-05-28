// Copyright (c) 2020-2024, The Mevacoin Project
// (license header identica all'originale)

#pragma once
#include <QReadWriteLock>
#include "network.h"

class Downloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged);
    Q_PROPERTY(quint64 loaded READ loaded NOTIFY loadedChanged);
    Q_PROPERTY(quint64 total READ total NOTIFY totalChanged);
    Q_PROPERTY(QString proxyAddress READ proxyAddress WRITE setProxyAddress NOTIFY proxyAddressChanged)

public:
    Downloader(QObject *parent = nullptr);
    ~Downloader();

    Q_INVOKABLE void cancel();
    Q_INVOKABLE bool get(const QString &url, const QString &hash, const QJSValue &callback);
    Q_INVOKABLE bool saveToFile(const QString &path) const;

    // Android: salva in Downloads pubblica (MediaStore API 29+ o storage diretto API<29).
    // Nessun dialog, nessun intent esterno. Funziona su Appetize.io e dispositivi reali.
#ifdef Q_OS_ANDROID
    Q_INVOKABLE bool saveToPublicDownloads(const QString &filename, const QString &mimeType) const;
#endif

signals:
    void activeChanged() const;
    void loadedChanged() const;
    void totalChanged() const;
    void proxyAddressChanged() const;

private:
    bool active() const;
    quint64 loaded() const;
    quint64 total() const;
    QString proxyAddress() const;
    void setProxyAddress(QString address);

private:
    bool m_active;
    std::string m_contents;
    std::shared_ptr<HttpClient> m_httpClient;
    mutable QReadWriteLock m_mutex;
    Network m_network;
    QString m_proxyAddress;
    mutable QMutex m_proxyMutex;
    mutable FutureScheduler m_scheduler;
};
