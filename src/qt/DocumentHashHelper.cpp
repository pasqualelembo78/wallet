#include "DocumentHashHelper.h"
#include <QFile>
#include <QUrl>
#include <QCryptographicHash>
#include <QDebug>
DocumentHashHelper::DocumentHashHelper(QObject *parent) : QObject(parent) {}
QString DocumentHashHelper::sha256File(const QString &filePath) const {
    QString p = filePath;
    if (p.startsWith("file://")) p = QUrl(p).toLocalFile();
    QFile f(p);
    if (!f.open(QIODevice::ReadOnly)) { qWarning() << "Cannot open:" << p; return {}; }
    QCryptographicHash h(QCryptographicHash::Sha256);
    while (!f.atEnd()) h.addData(f.read(1048576));
    f.close();
    return h.result().toHex();
}
QString DocumentHashHelper::sha256Text(const QString &text) const {
    return QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Sha256).toHex();
}
bool DocumentHashHelper::verifyFileHash(const QString &filePath, const QString &expectedHash) const {
    QString c = sha256File(filePath);
    return !c.isEmpty() && c.toLower() == expectedHash.toLower();
}
