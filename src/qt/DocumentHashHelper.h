#ifndef DOCUMENTHASHHELPER_H
#define DOCUMENTHASHHELPER_H
#include <QObject>
#include <QString>
class DocumentHashHelper : public QObject {
    Q_OBJECT
public:
    explicit DocumentHashHelper(QObject *parent = nullptr);
    Q_INVOKABLE QString sha256File(const QString &filePath) const;
    Q_INVOKABLE QString sha256Text(const QString &text) const;
    Q_INVOKABLE bool verifyFileHash(const QString &filePath, const QString &expectedHash) const;
};
#endif
