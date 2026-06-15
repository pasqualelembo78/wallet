#include "MevatrustManager.h"
#include <QJsonDocument>
#include <QJsonValue>
#include <QUrl>
#include <QNetworkRequest>

MevatrustManager::MevatrustManager(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
{
}

QString MevatrustManager::daemonAddress() const
{
    return m_daemonAddress;
}

bool MevatrustManager::busy() const
{
    return m_busy;
}

void MevatrustManager::setDaemonAddress(const QString &address)
{
    if (m_daemonAddress != address) {
        m_daemonAddress = address;
        emit daemonAddressChanged();
    }
}

void MevatrustManager::rpcCall(const QString &method, const QJsonObject &params,
                                std::function<void(const QJsonObject&)> callback)
{
    if (m_daemonAddress.isEmpty()) {
        emit errorOccurred("Daemon address not set");
        return;
    }
    rpcCallInternal(method, params, callback);
}

void MevatrustManager::rpcCallInternal(const QString &method, const QJsonObject &params,
                                        std::function<void(const QJsonObject&)> callback)
{
    if (m_busy) return;
    m_busy = true;
    emit busyChanged();

    QJsonObject rpc;
    rpc["jsonrpc"] = "2.0";
    rpc["id"] = "0";
    rpc["method"] = method;
    rpc["params"] = params;

    QUrl url(m_daemonAddress + "/json_rpc");
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_network->post(req, QJsonDocument(rpc).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [this, reply, callback]() {
        reply->deleteLater();
        m_busy = false;
        emit busyChanged();

        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred("RPC error: " + reply->errorString());
            return;
        }

        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject obj = doc.object();
        if (obj.contains("error")) {
            emit errorOccurred("RPC error: " + obj["error"].toObject()["message"].toString());
            return;
        }
        QJsonObject result = obj["result"].toObject();
        if (result["status"].toString() == "error") {
            emit errorOccurred(result["message"].toString());
            return;
        }
        callback(result);
    });
}

void MevatrustManager::lookupNode(const QString &nodeId)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    rpcCall("get_node_status", params, [this](const QJsonObject &result) {
        emit nodeStatusReceived(result);
    });
}

void MevatrustManager::lookupNodeByWallet(const QString &walletAddress)
{
    QJsonObject params;
    params["wallet_address"] = walletAddress;
    rpcCall("lookup_node_by_wallet", params, [this](const QJsonObject &result) {
        emit lookupNodeByWalletReceived(result);
    });
}

void MevatrustManager::getNetworkStats()
{
    rpcCall("get_incentive_pool_status", QJsonObject(), [this](const QJsonObject &result) {
        emit networkStatsReceived(result);
    });
}

void MevatrustManager::getNodeScore(const QString &nodeId)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    rpcCall("get_mevatrust_score", params, [this](const QJsonObject &result) {
        emit nodeScoreReceived(result);
    });
}

void MevatrustManager::getNodeBadges(const QString &nodeId)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    rpcCall("get_badges", params, [this](const QJsonObject &result) {
        emit nodeBadgesReceived(result);
    });
}

void MevatrustManager::getNodeUptime(const QString &nodeId)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    rpcCall("get_node_uptime", params, [this](const QJsonObject &result) {
        emit nodeUptimeReceived(result);
    });
}

void MevatrustManager::getNodeRewards(const QString &nodeId)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    rpcCall("get_reward_history", params, [this](const QJsonObject &result) {
        emit nodeRewardsReceived(result);
    });
}

void MevatrustManager::getRewardHistory(const QString &nodeId, quint64 limit)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    params["limit"] = (qint64)limit;
    rpcCall("get_reward_history_by_node", params, [this](const QJsonObject &result) {
        emit rewardHistoryReceived(result);
    });
}

void MevatrustManager::getTopNodes(quint32 count)
{
    QJsonObject params;
    params["limit"] = (qint32)count;
    rpcCall("get_all_node_incentives", params, [this](const QJsonObject &result) {
        emit topNodesReceived(result);
    });
}

void MevatrustManager::getBadgeRequirements()
{
    QJsonObject params;
    params["node_id"] = "";
    rpcCall("get_badge_requirements", params, [this](const QJsonObject &result) {
        emit badgeRequirementsReceived(result);
    });
}

void MevatrustManager::getNodeIncentiveHistory(const QString &nodeId, quint64 limit, quint64 offset)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    params["limit"] = (qint64)limit;
    params["offset"] = (qint64)offset;
    rpcCall("get_incentive_history", params, [this](const QJsonObject &result) {
        emit rewardHistoryReceived(result);
    });
}
