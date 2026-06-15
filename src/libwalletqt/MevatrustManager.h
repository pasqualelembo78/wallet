#ifndef MEVATRUST_MANAGER_H
#define MEVATRUST_MANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>

class MevatrustManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString daemonAddress READ daemonAddress WRITE setDaemonAddress NOTIFY daemonAddressChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit MevatrustManager(QObject *parent = nullptr);

    QString daemonAddress() const;
    bool busy() const;

    Q_INVOKABLE void setDaemonAddress(const QString &address);
    Q_INVOKABLE void lookupNode(const QString &nodeId);
    Q_INVOKABLE void lookupNodeByWallet(const QString &walletAddress);
    Q_INVOKABLE void getNetworkStats();
    Q_INVOKABLE void getNodeScore(const QString &nodeId);
    Q_INVOKABLE void getNodeBadges(const QString &nodeId);
    Q_INVOKABLE void getNodeUptime(const QString &nodeId);
    Q_INVOKABLE void getNodeRewards(const QString &nodeId);
    Q_INVOKABLE void getRewardHistory(const QString &nodeId, quint64 limit = 50);
    Q_INVOKABLE void getTopNodes(quint32 count = 20);
    Q_INVOKABLE void getBadgeRequirements();
    Q_INVOKABLE void getNodeIncentiveHistory(const QString &nodeId, quint64 limit = 50, quint64 offset = 0);

signals:
    void daemonAddressChanged();
    void busyChanged();
    void nodeInfoReceived(const QJsonObject &info);
    void nodeBadgesReceived(const QJsonObject &badges);
    void nodeStatusReceived(const QJsonObject &status);
    void nodeScoreReceived(const QJsonObject &score);
    void nodeUptimeReceived(const QJsonObject &uptime);
    void nodeRewardsReceived(const QJsonObject &rewards);
    void rewardHistoryReceived(const QJsonObject &history);
    void networkStatsReceived(const QJsonObject &stats);
    void topNodesReceived(const QJsonObject &nodes);
    void badgeRequirementsReceived(const QJsonObject &requirements);
    void lookupNodeByWalletReceived(const QJsonObject &result);
    void errorOccurred(const QString &error);

private:
    void rpcCall(const QString &method, const QJsonObject &params,
                 std::function<void(const QJsonObject&)> callback);
    void rpcCallInternal(const QString &method, const QJsonObject &params,
                         std::function<void(const QJsonObject&)> callback);

    QString m_daemonAddress;
    bool m_busy{false};
    QNetworkAccessManager *m_network{nullptr};
};

#endif
