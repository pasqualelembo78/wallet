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
    Q_PROPERTY(QString daemonUsername READ daemonUsername WRITE setDaemonUsername NOTIFY daemonUsernameChanged)
    Q_PROPERTY(QString daemonPassword READ daemonPassword WRITE setDaemonPassword NOTIFY daemonPasswordChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit MevatrustManager(QObject *parent = nullptr);

    QString daemonAddress() const;
    QString daemonUsername() const;
    QString daemonPassword() const;
    bool busy() const;

    Q_INVOKABLE void setDaemonAddress(const QString &address);
    Q_INVOKABLE void setDaemonUsername(const QString &username);
    Q_INVOKABLE void setDaemonPassword(const QString &password);
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
    // Write RPC methods
    Q_INVOKABLE void registerNode(const QString &publicKey, const QString &signature, const QString &address,
                                   const QString &viewKeyHex = "", const QString &proofTxid = "",
                                   quint32 proofOutputIndex = 0, const QString &nodePublicKey = "");
    Q_INVOKABLE void unregisterNode(const QString &nodeId, const QString &address, const QString &signature);
    Q_INVOKABLE void circleCreate(const QString &name, const QString &adminPubkey);
    Q_INVOKABLE void circleInfo(const QString &circleId);
    Q_INVOKABLE void circleList(const QString &walletPubkey = "");
    Q_INVOKABLE void circleJoin(const QString &circleId, const QString &memberPubkey, const QString &callerPubkey);
    Q_INVOKABLE void circleLeave(const QString &circleId, const QString &memberPubkey, const QString &callerPubkey);
    Q_INVOKABLE void circleChangeAdmin(const QString &circleId, const QString &newAdminPubkey, const QString &callerPubkey);
    Q_INVOKABLE void circleDisband(const QString &circleId, const QString &callerPubkey);
    Q_INVOKABLE void getPenaltyHistory(const QString &nodeId);
    Q_INVOKABLE void getEligibleNodes();
    Q_INVOKABLE void banNode(const QString &nodeId, const QString &reason, const QString &callerPubkey);
    Q_INVOKABLE void unbanNode(const QString &nodeId, const QString &callerPubkey);

    // ── Store RPC methods ────────────────────────────────────────────────
    Q_INVOKABLE void storeList(bool activeOnly = true, quint32 limit = 0, bool top = true);
    Q_INVOKABLE void storeShow(const QString &storeId);
    Q_INVOKABLE void storeSearch(const QString &keyword, bool searchItems = true);
    Q_INVOKABLE void storeMyPurchases(const QString &buyerPubkey);
    Q_INVOKABLE void storePurchasesByStore(const QString &storeId);

signals:
    void daemonAddressChanged();
    void daemonUsernameChanged();
    void daemonPasswordChanged();
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
    // Write RPC response signals
    void registerNodeReceived(const QJsonObject &result);
    void unregisterNodeReceived(const QJsonObject &result);
    void circleCreateReceived(const QJsonObject &result);
    void circleInfoReceived(const QJsonObject &result);
    void circleListReceived(const QJsonObject &result);
    void circleJoinReceived(const QJsonObject &result);
    void circleLeaveReceived(const QJsonObject &result);
    void circleChangeAdminReceived(const QJsonObject &result);
    void circleDisbandReceived(const QJsonObject &result);
    void penaltyHistoryReceived(const QJsonObject &result);
    void eligibleNodesReceived(const QJsonObject &result);
    void banNodeReceived(const QJsonObject &result);
    void unbanNodeReceived(const QJsonObject &result);
    // Store response signals
    void storeListReceived(const QJsonObject &result);
    void storeShowReceived(const QJsonObject &result);
    void storeSearchReceived(const QJsonObject &result);
    void storeMyPurchasesReceived(const QJsonObject &result);
    void storePurchasesByStoreReceived(const QJsonObject &result);

private:
    void rpcCall(const QString &method, const QJsonObject &params,
                 std::function<void(const QJsonObject&)> callback);
    void rpcCallInternal(const QString &method, const QJsonObject &params,
                         std::function<void(const QJsonObject&)> callback);

    QString m_daemonAddress;
    QString m_daemonUsername;
    QString m_daemonPassword;
    bool m_busy{false};
    QNetworkAccessManager *m_network{nullptr};
};

#endif
