#include "MevatrustManager.h"
#include <QJsonDocument>
#include <QJsonValue>
#include <QUrl>
#include <QNetworkRequest>
#include <QByteArray>
#include <QAuthenticator>
#include <QDateTime>

MevatrustManager::MevatrustManager(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
{
    // Handle HTTP Digest auth (RFC 2617) -- used by mevacoind
    connect(m_network, &QNetworkAccessManager::authenticationRequired,
            this, [this](QNetworkReply *reply, QAuthenticator *authenticator) {
        Q_UNUSED(reply)
        if (!m_daemonUsername.isEmpty()) {
            authenticator->setUser(m_daemonUsername);
            authenticator->setPassword(m_daemonPassword);
        }
    });
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

QString MevatrustManager::daemonUsername() const
{
    return m_daemonUsername;
}

QString MevatrustManager::daemonPassword() const
{
    return m_daemonPassword;
}

void MevatrustManager::setDaemonUsername(const QString &username)
{
    if (m_daemonUsername != username) {
        m_daemonUsername = username;
        emit daemonUsernameChanged();
    }
}

void MevatrustManager::setDaemonPassword(const QString &password)
{
    if (m_daemonPassword != password) {
        m_daemonPassword = password;
        emit daemonPasswordChanged();
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

    auto startTime = QDateTime::currentMSecsSinceEpoch();
    emit rpcRequestSent(method, QString::fromUtf8(QJsonDocument(params).toJson(QJsonDocument::Compact)), m_daemonAddress + "/json_rpc");

    auto *reply = m_network->post(req, QJsonDocument(rpc).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [this, reply, callback, method, startTime]() {
        reply->deleteLater();

        auto elapsed = QDateTime::currentMSecsSinceEpoch() - startTime;

        if (reply->error() != QNetworkReply::NoError) {
            emit rpcResponseReceived(method, "", reply->errorString(), elapsed);
            emit errorOccurred("RPC error: " + reply->errorString());
            return;
        }

        QByteArray rawData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(rawData);
        QJsonObject obj = doc.object();
        if (obj.contains("error")) {
            QString errMsg = obj["error"].toObject()["message"].toString();
            emit rpcResponseReceived(method, QString::fromUtf8(rawData), errMsg, elapsed);
            emit errorOccurred("RPC error: " + errMsg);
            return;
        }
        QJsonObject result = obj["result"].toObject();
        QString status = result["status"].toString();
        if (status != "OK" && !status.isEmpty()) {
            emit rpcResponseReceived(method, QString::fromUtf8(rawData), status, elapsed);
            emit errorOccurred(status);
            return;
        }
        emit rpcResponseReceived(method, QString::fromUtf8(rawData), "", elapsed);
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

// ── Write RPC methods ─────────────────────────────────────────────────────

void MevatrustManager::registerNode(const QString &publicKey, const QString &signature, const QString &address,
                                     const QString &viewKeyHex, const QString &proofTxid,
                                     quint32 proofOutputIndex, const QString &nodePublicKey)
{
    QJsonObject params;
    params["public_key"] = publicKey;
    params["signature"] = signature;
    params["address"] = address;
    if (!viewKeyHex.isEmpty()) params["view_key_hex"] = viewKeyHex;
    if (!proofTxid.isEmpty()) params["proof_txid"] = proofTxid;
    params["proof_output_index"] = (qint32)proofOutputIndex;
    if (!nodePublicKey.isEmpty()) params["node_public_key"] = nodePublicKey;
    rpcCall("register_node", params, [this](const QJsonObject &result) {
        emit registerNodeReceived(result);
    });
}

void MevatrustManager::unregisterNode(const QString &nodeId, const QString &address, const QString &signature)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    params["address"] = address;
    params["signature"] = signature;
    rpcCall("unregister_node", params, [this](const QJsonObject &result) {
        emit unregisterNodeReceived(result);
    });
}

void MevatrustManager::circleCreate(const QString &name, const QString &adminPubkey)
{
    QJsonObject params;
    params["name"] = name;
    params["admin_pubkey"] = adminPubkey;
    rpcCall("circle_create", params, [this](const QJsonObject &result) {
        emit circleCreateReceived(result);
    });
}

void MevatrustManager::circleInfo(const QString &circleId)
{
    QJsonObject params;
    params["circle_id"] = circleId;
    rpcCall("circle_info", params, [this](const QJsonObject &result) {
        emit circleInfoReceived(result);
    });
}

void MevatrustManager::circleList(const QString &walletPubkey)
{
    QJsonObject params;
    params["wallet_pubkey"] = walletPubkey;
    rpcCall("circle_list", params, [this](const QJsonObject &result) {
        emit circleListReceived(result);
    });
}

void MevatrustManager::circleJoin(const QString &circleId, const QString &memberPubkey, const QString &callerPubkey)
{
    QJsonObject params;
    params["circle_id"] = circleId;
    params["member_pubkey"] = memberPubkey;
    params["caller_pubkey"] = callerPubkey;
    rpcCall("circle_join", params, [this](const QJsonObject &result) {
        emit circleJoinReceived(result);
    });
}

void MevatrustManager::circleLeave(const QString &circleId, const QString &memberPubkey, const QString &callerPubkey)
{
    QJsonObject params;
    params["circle_id"] = circleId;
    params["member_pubkey"] = memberPubkey;
    params["caller_pubkey"] = callerPubkey;
    rpcCall("circle_leave", params, [this](const QJsonObject &result) {
        emit circleLeaveReceived(result);
    });
}

void MevatrustManager::circleChangeAdmin(const QString &circleId, const QString &newAdminPubkey, const QString &callerPubkey)
{
    QJsonObject params;
    params["circle_id"] = circleId;
    params["new_admin_pubkey"] = newAdminPubkey;
    params["caller_pubkey"] = callerPubkey;
    rpcCall("circle_change_admin", params, [this](const QJsonObject &result) {
        emit circleChangeAdminReceived(result);
    });
}

void MevatrustManager::circleDisband(const QString &circleId, const QString &callerPubkey)
{
    QJsonObject params;
    params["circle_id"] = circleId;
    params["caller_pubkey"] = callerPubkey;
    rpcCall("circle_disband", params, [this](const QJsonObject &result) {
        emit circleDisbandReceived(result);
    });
}

void MevatrustManager::getPenaltyHistory(const QString &nodeId)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    rpcCall("get_penalty_history", params, [this](const QJsonObject &result) {
        emit penaltyHistoryReceived(result);
    });
}

void MevatrustManager::getEligibleNodes()
{
    rpcCall("get_eligible_nodes", QJsonObject(), [this](const QJsonObject &result) {
        emit eligibleNodesReceived(result);
    });
}

void MevatrustManager::banNode(const QString &nodeId, const QString &reason, const QString &callerPubkey)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    params["reason"] = reason;
    params["caller_pubkey"] = callerPubkey;
    rpcCall("ban_node", params, [this](const QJsonObject &result) {
        emit banNodeReceived(result);
    });
}

void MevatrustManager::unbanNode(const QString &nodeId, const QString &callerPubkey)
{
    QJsonObject params;
    params["node_id"] = nodeId;
    params["caller_pubkey"] = callerPubkey;
    rpcCall("unban_node", params, [this](const QJsonObject &result) {
        emit unbanNodeReceived(result);
    });
}

// ── Store RPC methods ─────────────────────────────────────────────────────

void MevatrustManager::storeList(bool activeOnly, quint32 limit, bool top)
{
    QJsonObject params;
    params["active_only"] = activeOnly;
    if (limit > 0) params["limit"] = (qint32)limit;
    params["top"] = top;
    rpcCall("store_list", params, [this](const QJsonObject &result) {
        emit storeListReceived(result);
    });
}

void MevatrustManager::storeShow(const QString &storeId)
{
    QJsonObject params;
    params["store_id"] = storeId;
    rpcCall("store_show", params, [this](const QJsonObject &result) {
        emit storeShowReceived(result);
    });
}

void MevatrustManager::storeSearch(const QString &keyword, bool searchItems)
{
    QJsonObject params;
    params["keyword"] = keyword;
    params["search_items"] = searchItems;
    rpcCall("store_search", params, [this](const QJsonObject &result) {
        emit storeSearchReceived(result);
    });
}

void MevatrustManager::storeMyPurchases(const QString &buyerPubkey)
{
    QJsonObject params;
    params["buyer_pubkey"] = buyerPubkey;
    rpcCall("store_my_purchases", params, [this](const QJsonObject &result) {
        emit storeMyPurchasesReceived(result);
    });
}

void MevatrustManager::storePurchasesByStore(const QString &storeId)
{
    QJsonObject params;
    params["store_id"] = storeId;
    rpcCall("store_purchases_by_store", params, [this](const QJsonObject &result) {
        emit storePurchasesByStoreReceived(result);
    });
}

// ── Governance Dashboard RPC methods ─────────────────────────────────────

void MevatrustManager::getPoolDistributionHistory(quint32 limit)
{
    QJsonObject params;
    params["limit"] = (qint32)limit;
    rpcCall("get_pool_distribution_history", params, [this](const QJsonObject &result) {
        emit poolDistributionHistoryReceived(result);
    });
}

void MevatrustManager::getRecentBlocks(quint32 count)
{
    QJsonObject params;
    params["count"] = (qint32)count;
    rpcCall("get_recent_blocks", params, [this](const QJsonObject &result) {
        emit recentBlocksReceived(result);
    });
}

void MevatrustManager::getTreasuryStatus()
{
    rpcCall("get_treasury_status", QJsonObject(), [this](const QJsonObject &result) {
        emit treasuryStatusReceived(result);
    });
}

void MevatrustManager::getNetworkFundStatus()
{
    rpcCall("get_network_fund_status", QJsonObject(), [this](const QJsonObject &result) {
        emit networkFundStatusReceived(result);
    });
}

void MevatrustManager::getGovernanceActivity(quint64 fromHeight, quint32 count)
{
    QJsonObject params;
    params["from_height"] = (qint64)fromHeight;
    params["count"] = (qint32)count;
    rpcCall("get_governance_activity", params, [this](const QJsonObject &result) {
        emit governanceActivityReceived(result);
    });
}

void MevatrustManager::getProposerStatus()
{
    rpcCall("get_proposer_status", QJsonObject(), [this](const QJsonObject &result) {
        emit proposerStatusReceived(result);
    });
}

void MevatrustManager::getNodePubkey()
{
    rpcCall("get_node_pubkey", QJsonObject(), [this](const QJsonObject &result) {
        emit nodePubkeyReceived(result);
    });
}

void MevatrustManager::circleProposalList(const QString &circleId)
{
    QJsonObject params;
    params["circle_id"] = circleId;
    rpcCall("circle_proposal_list", params, [this](const QJsonObject &result) {
        emit circleProposalListReceived(result);
    });
}

void MevatrustManager::circleProposalVotes(const QString &proposalId)
{
    QJsonObject params;
    params["proposal_id"] = proposalId;
    rpcCall("circle_proposal_votes", params, [this](const QJsonObject &result) {
        emit circleProposalVotesReceived(result);
    });
}
